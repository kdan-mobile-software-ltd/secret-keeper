require 'openssl'
require 'yaml'

class SecretKeeper
  def self.encrypt_files
    sk = SecretKeeper.new
    puts 'Encrypting...'
    ok_queue = []
    sk.tasks.each do |task|
      from = task['encrypt_from']
      to = task['encrypt_to']

      result = sk.encrypt_file(from, to)
      ok_queue << result if result == :ok
      puts "  * #{from} --> #{to}, #{result}"
    end
    success = ok_queue.count == sk.tasks.count
    puts success ? 'Done!' : 'Failed!'
    success
  end

  def self.decrypt_files
    sk = SecretKeeper.new
    puts 'Decrypting...'
    ok_queue = []
    sk.tasks.each do |task|
      from = task['decrypt_from'] || task['encrypt_to']
      to = task['decrypt_to'] || task['encrypt_from']

      result = sk.decrypt_file(from, to)
      ok_queue << result if result == :ok
      puts "  * #{from} --> #{to}, #{result}"
    end
    success = ok_queue.count == sk.tasks.count
    puts success ? 'Done!' : 'Failed!'
    success
  end

  def initialize
    fail 'environment variable OPENSSL_PASS not exist' if ENV['OPENSSL_PASS'].nil?
    env = ENV['RAILS_ENV'] || 'development'
    string = File.open('config/secret-keeper.yml', 'rb') { |f| f.read }
    config = YAML.load(string)[env]
    fail 'config/secret-keeper.yml incorrect or environment not exist' if config.nil?

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
    e
  end

  def decrypt_file(from_file, to_file)
    decrypted = File.open(from_file, 'rb') { |f| decrypt(f.read) }
    File.open(to_file, 'w') { |f| f.write(decrypted) }
    :ok
  rescue => e
    e
  end

  private

  def encrypt(data)
    cipher = @using_cipher.encrypt
    cipher.key = Digest::SHA2.hexdigest(ENV['OPENSSL_PASS'])[0..(cipher.key_len-1)]
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = @using_cipher.decrypt
    cipher.key = Digest::SHA2.hexdigest(ENV['OPENSSL_PASS'])[0..(cipher.key_len-1)]
    cipher.update(data) + cipher.final
  end
end
