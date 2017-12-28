class SecretKeeper
  def self.hi
    puts '...(said nothing)'
  end

  def self.encrypt_files
    puts 'Encrypt start...'
    sk = SecretKeeper.new
    sk.tasks.each do |decrypted_file, encrypted_file|
      result = sk.encrypt(decrypted_file, encrypted_file)
      puts "#{decrypted_file} --> #{encrypted_file}, #{result}"
    end
    puts 'Encrypt end!'
  end

  def self.decrypt_files
    puts 'Decrypt start...'
    sk = SecretKeeper.new
    sk.tasks.each do |encrypted_file, decrypted_file|
      result = sk.decrypt(encrypted_file, decrypted_file)
      puts "#{encrypted_file} --> #{decrypted_file}, #{result}"
    end
    puts 'Decrypt end!'
  end

  def initialize
    @password = 'password'
    @tasks = [
      ['config/database.yml', 'config/database.yml.enc'],
      ['config/secret.yml', 'config/secret.yml.enc'],
    ]
  end

  def tasks
    @tasks
  end

  def encrypt(from, to)
    return :ok
  end

  def decrypt(from, to)
    return :ok
  end
end
