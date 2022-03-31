describe SecretKeeper do
  before(:each) do
    ENV['SECRET_KEEPER'] = 'PASSWORD_HERE'
  end

  describe '.encrypt_files' do
    it 'should return true' do
      result = SecretKeeper.encrypt_files
      expect(result).to eq(true)
    end
  end

  describe '.decrypt_files' do
    it 'should return true' do
      result = SecretKeeper.decrypt_files
      expect(result).to eq(true)
      hash = YAML.load_file('example/secrets.yml')
      expect(hash['development']['secret_key_base']).to eq('e8310af93d52f174f475940c41fbfb90417b300ebc19e1b24bd5639f4fe35c5ffaa5775a347ace9732958f656a47f6bb8e1fd0760b12e51b0b4fe1f65ef0a1d6')
      expect(hash['production']['secret_key_base']).to eq('339f639f4fe35c5ffaa47ace973260b12e51b0b4fe1f65effd283a5f054f47594b24bd565779e351a20dfd4ada4f777958f0417b305c06cdedbde392b8e1fd07')
    end

    it 'should return true on remove_production true' do
      result = SecretKeeper.decrypt_files(ENV['RAILS_ENV'] != 'production')
      expect(result).to eq(true)
      hash = YAML.load_file('example/secrets.yml')
      expect(hash['development']['secret_key_base']).to eq('e8310af93d52f174f475940c41fbfb90417b300ebc19e1b24bd5639f4fe35c5ffaa5775a347ace9732958f656a47f6bb8e1fd0760b12e51b0b4fe1f65ef0a1d6')
      expect(hash['production']).to be_nil
    end

    it 'should be false, if SECRET_KEEPER incorrect' do
      ENV['SECRET_KEEPER'] = 'incorrect'
      result = SecretKeeper.decrypt_files
      expect(result).to eq(false)
    end

    it 'should raise error, if SECRET_KEEPER nil' do
      ENV['SECRET_KEEPER'] = nil
      expect{ SecretKeeper.decrypt_files }.to raise_error(RuntimeError)
    end

    it 'should raise error, if config file not found' do
      FileUtils.mv('config/secret-keeper.yml', 'config/secret-keeper-tmp.yml')
      expect{ SecretKeeper.decrypt_files }.to raise_error(Errno::ENOENT)
      FileUtils.mv('config/secret-keeper-tmp.yml', 'config/secret-keeper.yml')
    end

    it 'should raise error, if config file format incorrect' do
      FileUtils.mv('config/secret-keeper.yml', 'config/secret-keeper-tmp.yml')
      FileUtils.cp('config/secret-keeper-incorrect-format.yml', 'config/secret-keeper.yml')
      expect{ SecretKeeper.decrypt_files }.to raise_error(Psych::SyntaxError)
      FileUtils.mv('config/secret-keeper-tmp.yml', 'config/secret-keeper.yml')
    end

    it 'should raise error, if config file lack enviorment' do
      FileUtils.mv('config/secret-keeper.yml', 'config/secret-keeper-tmp.yml')
      FileUtils.cp('config/secret-keeper-lack-env.yml', 'config/secret-keeper.yml')
      expect{ SecretKeeper.decrypt_files }.to raise_error(RuntimeError)
      FileUtils.mv('config/secret-keeper-tmp.yml', 'config/secret-keeper.yml')
    end
  end

  describe '.cleanup_files' do
    it 'should return true' do
      tasks = YAML.load_file('config/secret-keeper.yml')['development']['tasks']
      tmp_files = []
      tasks.each do |task|
        origin_name = task['decrypt_to'] || task['encrypt_from']
        backup_name = "#{origin_name}_backup"
        tmp_files << { 'origin_name' => origin_name, 'backup_name' => backup_name }
        FileUtils.cp(origin_name, backup_name)
      end

      result = SecretKeeper.cleanup_files
      expect(result).to eq(true)
      tasks.each do |task|
        target_file = task['decrypt_to'] || task['encrypt_from']
        expect(File.exists?(target_file)).to eq(false)
      end

      tmp_files.each { |f| FileUtils.mv(f['backup_name'], f['origin_name']) }
    end

    it 'should return false if one or more origin files do not exist' do
      tasks = YAML.load_file('config/secret-keeper.yml')['development']['tasks']
      tmp_files = []
      tasks.each_with_index do |task, index|
        origin_name = task['decrypt_to'] || task['encrypt_from']
        backup_name = "#{origin_name}_backup"
        tmp_files << { 'origin_name' => origin_name, 'backup_name' => backup_name }
        if index.odd?
          FileUtils.mv(origin_name, backup_name)
        else
          FileUtils.cp(origin_name, backup_name)
        end
      end

      result = SecretKeeper.cleanup_files
      expect(result).to eq(false)
      tasks.each do |task|
        target_file = task['decrypt_to'] || task['encrypt_from']
        expect(File.exists?(target_file)).to eq(false)
      end

      tmp_files.each { |f| FileUtils.mv(f['backup_name'], f['origin_name']) }
    end
  end
end
