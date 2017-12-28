# Secret Keeper

Keep all your secret files within openssl

## Install

    gem install secret-keeper

## Usage

    require 'secret-keeper'

SecretKeeper.encrypt_files

    Encrypt start...
    * example/database.yml --> example/database.yml.enc, ok
    * example/secrets.yml --> example/secrets.yml.enc, ok
    Encrypt end!

SecretKeeper.decrypt_files

    Decrypt start...
    * example/database.yml.enc --> example/database.yml, ok
    * example/secrets.yml.enc --> example/secrets.yml, ok
    Decrypt end!

## Available Ciphers

    OpenSSL::Cipher.ciphers

## Config Example

```development: &development
  cipher: AES-256-CBC
  tasks:
    -
      - example/database.yml
      - example/database.yml.enc
    -
      - example/secrets.yml
      - example/secrets.yml.enc

test:
  <<: *development

production:
  <<: *development```
