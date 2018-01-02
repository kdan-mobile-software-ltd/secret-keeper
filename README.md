# Secret Keeper

Keep all your secret files within openssl

## Install

install from console

    gem install secret-keeper

or write follwing line in your Gemfile

    gem 'secret-keeper'


## Usage

    $> OPENSSL_PASS=DEFAULT-PASSWORD irb
    irb> require 'secret-keeper'
    irb> SecretKeeper.encrypt_files
    # Encrypting...
    #   * example/database.yml --> example/database.yml.enc, ok
    #   * example/secrets.yml --> example/secrets.yml.enc, ok
    # Over!
    irb> SecretKeeper.decrypt_files
    # Decrypting...
    #   * example/database.yml.enc --> example/database.yml, ok
    #   * example/secrets.yml.enc --> example/secrets.yml, ok
    # Over!

## Available Ciphers

    OpenSSL::Cipher.ciphers

## Config Example

    development: &development
      cipher: AES-256-CBC
      tasks:
        -
          encrypt_from: example/database.yml
          encrypt_to: example/database.yml.enc
          # decrypt_from: example/database.yml.enc
          # decrypt_to: example/database.yml
        -
          encrypt_from: example/secrets_from_other_source.yml
          encrypt_to: example/secrets.yml.enc
          # decrypt_from: example/secrets.yml.enc
          decrypt_to: example/secrets.yml
    test:
      <<: *development
    production:
      <<: *development
