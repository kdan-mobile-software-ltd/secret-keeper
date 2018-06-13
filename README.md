# Secret Keeper

Keep all your secret files within openssl

## Install

from console

    gem install secret-keeper

with bundler, write follwing line in your Gemfile

    gem 'secret-keeper', require: false

## Usage
1. setup files need to be encrypted in config/secret-keeper.yml

    # config/secret-keeper.yml example
    development:
      ev_name: SECRET_KEEPER
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

2. using environment variable SECRET_KEEPER to be your key of cipher

    $> SECRET_KEEPER=[YOUR-CIPHER-KEY-HERE] irb

3. require on demand

    irb> require 'secret-keeper'

4. encrypt files based on your tasks defined in config/secret-keeper.yml

    irb> SecretKeeper.encrypt_files
    # Encrypting...
    #   * example/database.yml --> example/database.yml.enc, ok
    #   * example/secrets.yml --> example/secrets.yml.enc, ok
    # Over!

5. decrypt files based on your tasks defined in config/secret-keeper.yml

    irb> SecretKeeper.decrypt_files
    # Decrypting...
    #   * example/database.yml.enc --> example/database.yml, ok
    #   * example/secrets.yml.enc --> example/secrets.yml, ok
    # Over!

## Available Ciphers

    irb> require 'openssl'
    irb> OpenSSL::Cipher.ciphers
