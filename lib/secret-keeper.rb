require 'openssl'
require 'yaml'

class SecretKeeper
  def self.hi
    puts '...(said nothing)'
  end

  def self.encrypt_files
    puts 'Encrypting...'
    sk = SecretKeeper.new
    sk.tasks.each do |task|
      from = task['encrypt_from']
      to = task['encrypt_to']

      result = sk.encrypt_file(from, to)
      puts "  * #{from} --> #{to}, #{result}"
    end
    puts 'Done!'
  end

  def self.decrypt_files
    puts 'Decrypting...'
    sk = SecretKeeper.new
    sk.tasks.each do |task|
      from = task['decrypt_from'] || task['encrypt_to']
      to = task['decrypt_to'] || task['encrypt_from']

      result = sk.decrypt_file(from, to)
      puts "  * #{from} --> #{to}, #{result}"
    end
    puts 'Done!'
  end

  def initialize
    env = ENV['RAILS_ENV'] || 'development'
    string = File.open('config/secret-keeper.yml', 'rb') { |f| f.read }
    config = YAML.load(string)[env]
    @password = ENV['OPENSSL_PASS'] || 'DEFAULT-PASSWORD'
    @tasks = config['tasks']
    @using_cipher = OpenSSL::Cipher.new(config['cipher'])
  end

  def tasks
    @tasks
  end

  def encrypt_file(from_file, to_file)
    encrypted = File.open(from_file, 'rb') { |f| encrypt(f.read) }
    File.open(to_file, 'w:ASCII-8BIT') { |f| f.write(encrypted) }
    :ok
  rescue => e
    "fail: #{e}"
  end

  def decrypt_file(from_file, to_file)
    decrypted = File.open(from_file, 'rb') { |f| decrypt(f.read) }
    File.open(to_file, 'w') { |f| f.write(decrypted) }
    :ok
  rescue => e
    "fail: #{e}"
  end

  private

  def encrypt(data)
    cipher = @using_cipher.encrypt
    cipher.key = Digest::SHA1.hexdigest(@password)
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = @using_cipher.decrypt
    cipher.key = Digest::SHA1.hexdigest(@password)
    cipher.update(data) + cipher.final
  end
end
