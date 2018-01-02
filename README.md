# Secret Keeper

Keep all your secret files within openssl

## Install

from console

    gem install secret-keeper

with bundler, write follwing line in your Gemfile

    gem 'secret-keeper'


## Usage
using environment variable OPENSSL_PASS to be your key of cipher

    $> OPENSSL_PASS=[YOUR-CIPHER-KEY-HERE] irb

require on demand

    irb> require 'secret-keeper'

encrypt files based on your tasks defined in config/secret-keeper.yml

    irb> SecretKeeper.encrypt_files
    # Encrypting...
    #   * example/database.yml --> example/database.yml.enc, ok
    #   * example/secrets.yml --> example/secrets.yml.enc, ok
    # Over!

decrypt files based on your tasks defined in config/secret-keeper.yml

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
