require 'openssl'
require 'yaml'

class SecretKeeper
  def self.encrypt_files
    sk = SecretKeeper.new
    puts 'Encrypting...' unless sk.slience
    ok_queue = []
    sk.tasks.each do |task|
      from = task['encrypt_from']
      to = task['encrypt_to']

      result = sk.encrypt_file(from, to)
      ok_queue << result if result == :ok
      puts "  * #{from} --> #{to}, #{result}" unless sk.slience
    end
    success = ok_queue.count == sk.tasks.count
    puts success ? 'Done!' : 'Failed!' unless sk.slience
    success
  end

  def self.decrypt_files(remove_production=false)
    sk = SecretKeeper.new
    print 'Decrypting...' unless sk.slience
    puts remove_production ? '(production config removed)' : nil unless sk.slience

    ok_queue = []
    sk.tasks.each do |task|
      from = task['decrypt_from'] || task['encrypt_to']
      to = task['decrypt_to'] || task['encrypt_from']

      result = sk.decrypt_file(from, to)

      if result == :ok && remove_production
        result = sk.remove_production_config(to)
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

    @cipher_digest = ENV[ev_name]
    @tasks = config['tasks']
    @using_cipher = OpenSSL::Cipher.new(config['cipher'])
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
    File.open(to_file, 'w') { |f| f.write(decrypted) }
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

  private

  def encrypt(data)
    cipher = @using_cipher.encrypt
    key_size_range = 0..(cipher.key_len-1)
    cipher.key = Digest::SHA2.hexdigest(@cipher_digest)[key_size_range]
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = @using_cipher.decrypt
    key_size_range = 0..(cipher.key_len-1)
    cipher.key = Digest::SHA2.hexdigest(@cipher_digest)[key_size_range]
    cipher.update(data) + cipher.final
  end
end
