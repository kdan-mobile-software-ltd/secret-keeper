require 'openssl'
require 'yaml'

class SecretKeeper
  def self.encrypt_files(remove_source = false)
    sk = SecretKeeper.new
    print 'Encrypting...' unless sk.slience
    puts remove_source ? '(source files removed)' : nil unless sk.slience

    ok_queue = []
    sk.tasks.each do |task|
      from = File.exists?(task['encrypt_from']) ? task['encrypt_from'] : task['decrypt_to']
      to = task['encrypt_to']

      result = sk.encrypt_file(from, to)
      if result == :ok && remove_source
        result = sk.remove_file(from)
      end

      ok_queue << result if result == :ok
      puts "  * #{from} --> #{to}, #{result}" unless sk.slience
    end
    success = ok_queue.count == sk.tasks.count
    puts success ? 'Done!' : 'Failed!' unless sk.slience
    success
  end

  def self.decrypt_files(remove_production=false, remove_source = false)
    sk = SecretKeeper.new

    unless sk.slience
      msg = 'Decrypting...'
      if remove_production
        msg += '(production config removed)'
      elsif remove_source
        msg += '(source files removed)'
      end
      puts msg
    end

    ok_queue = []
    sk.tasks.each do |task|
      from = task['decrypt_from'] || task['encrypt_to']
      to = task['decrypt_to'] || task['encrypt_from']

      result = sk.decrypt_file(from, to)

      if result == :ok
        if remove_production
          result = sk.remove_production_config(to)
        elsif remove_source
          result = sk.remove_file(from)
        end
      end

      ok_queue << result if result == :ok
      puts "  * #{from} --> #{to}, #{result}" unless sk.slience
    end
    success = ok_queue.count == sk.tasks.count
    puts success ? 'Done!' : 'Failed!' unless sk.slience
    success
  end

  def initialize
    env = ENV['RAILS_ENV'] || 'development'
    string = File.open('config/secret-keeper.yml', 'rb') { |f| f.read }
    fail 'config/secret-keeper.yml not existed nor not readable' if string.nil?
    config = YAML.load(string)[env]
    fail 'config/secret-keeper.yml incorrect or environment not exist' if config.nil?
    ev_name = config['ev_name'] || 'SECRET_KEEPER'
    fail "environment variable #{ev_name} not exist" if ENV[ev_name].nil?

    @tasks = config['tasks']
    @using_cipher = OpenSSL::Cipher.new(config['cipher'] || 'AES-256-CBC')
    @cipher_key = Digest::SHA2.hexdigest(ENV[ev_name])[0...@using_cipher.key_len]

    @slience = config['slience'] || false
  end

  def tasks
    @tasks
  end

  def slience
    @slience
  end

  def encrypt_file(from_file, to_file)
    encrypted = File.open(from_file, 'rb') { |f| encrypt(f.read) }
    File.open(to_file, 'w:ASCII-8BIT') { |f| f.write(encrypted) }
    :ok
  rescue => e
    e
  end

  def decrypt_file(from_file, to_file)
    decrypted = File.open(from_file, 'rb') { |f| decrypt(f.read) }
    File.open(to_file, 'w') { |f| f.write(decrypted.force_encoding('UTF-8')) }
    :ok
  rescue => e
    e
  end

  def remove_production_config(file_path)
    return :ok unless file_path =~ /\.yml/
    hash = YAML.load_file(file_path)
    hash.delete('production')
    File.write(file_path, YAML.dump(hash))
    :ok
  rescue => e
    e
  end

  def remove_file(file_path)
    File.delete(file_path)
    :ok
  rescue => e
    e
  end

  private

  def encrypt(data)
    cipher = @using_cipher.encrypt
    cipher.key = @cipher_key
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = @using_cipher.decrypt
    cipher.key = @cipher_key
    cipher.update(data) + cipher.final
  end
end
