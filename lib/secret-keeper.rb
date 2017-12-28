require 'openssl'

class SecretKeeper
  def self.hi
    puts '...(said nothing)'
  end

  def self.encrypt_files
    puts 'Encrypt start...'
    sk = SecretKeeper.new
    sk.tasks.each do |decrypted_file, encrypted_file|
      result = sk.encrypt_file(decrypted_file, encrypted_file)
      puts "#{decrypted_file} --> #{encrypted_file}, #{result}"
    end
    puts 'Encrypt end!'
    true
  end

  def self.decrypt_files
    puts 'Decrypt start...'
    sk = SecretKeeper.new
    sk.tasks.each do |decrypted_file, encrypted_file|
      result = sk.decrypt_file(encrypted_file, decrypted_file)
      puts "#{encrypted_file} --> #{decrypted_file}, #{result}"
    end
    puts 'Decrypt end!'
    true
  end

  def initialize
    @password = 'password'
    @tasks = [
      ['example/database.yml', 'config/database.yml.enc'],
      ['example/secrets.yml', 'config/secrets.yml.enc'],
    ]
    @using_cipher = OpenSSL::Cipher::AES.new(256, 'CBC')
  end

  def tasks
    @tasks
  end

  def encrypt_file(decrypted_file, encrypted_file)
    encrypted = File.open(decrypted_file, 'rb') { |f| encrypt(f.read) }
    File.open(encrypted_file, 'w:ASCII-8BIT') { |f| f.write(encrypted) }
    :ok
  rescue => e
    return e.message
  end

  def decrypt_file(encrypted_file, decrypted_file)
    decrypted = File.open(encrypted_file, 'rb') { |f| decrypt(f.read) }
    File.open(decrypted_file, 'w') { |f| f.write(decrypted) }
    :ok
  rescue => e
    return e.message
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
