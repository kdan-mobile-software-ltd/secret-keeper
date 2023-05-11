# Secret Keeper

Keep all your secret files within openssl

## Install

from console

```bash
gem install secret-keeper
```

with bundler, write follwing line in your Gemfile

```bash
gem 'secret-keeper', require: false
```

## Upgrade from v1 to v2

The *remove_production* parameter of *decrypt_files* has been removed after version 2.0.0.
If you wants to remove *production* settings after decrypt files, you can set *remove_production* option to *true* in *secret-keeper.yml*:

```yaml
options:
  remove_production: false
```

## Usage
setup files need to be encrypted in config/secret-keeper.yml

```yaml
# config/secret-keeper.yml example
development:
  ev_name: SECRET_KEEPER
  cipher: AES-256-CBC
  options:
    slience: false
    remove_production: false
    remove_source: false
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
```

using environment variable SECRET_KEEPER to be your key of cipher

```bash
$> SECRET_KEEPER=[YOUR-CIPHER-KEY-HERE] irb
```

require on demand

```bash
irb> require 'secret-keeper'
```

encrypt files based on your tasks defined in config/secret-keeper.yml

```bash
irb> SecretKeeper.encrypt_files
# Encrypting...
#   * example/database.yml --> example/database.yml.enc, ok
#   * example/secrets.yml --> example/secrets.yml.enc, ok
# Done!
```

decrypt files based on your tasks defined in config/secret-keeper.yml

```bash
irb> SecretKeeper.decrypt_files
# Decrypting...
#   * example/database.yml.enc --> example/database.yml, ok
#   * example/secrets.yml.enc --> example/secrets.yml, ok
# Done!
```

## Available Ciphers

```bash
irb> require 'openssl'
irb> OpenSSL::Cipher.ciphers
```

## Options

* slience
When this option set to *true*, the tasks will run in slience mode. Messages will not show no screen. Default is *false*.

* remove_production
When this option set to *true*, the *production* settings in the decrypted files will be removed after the decryption task. Default is *false*.

* remove_source
When this option set to *true*, the source file will be removed after either encrypt or decrypt tasks. Default is *false*.
