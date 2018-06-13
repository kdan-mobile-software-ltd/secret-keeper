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
end
