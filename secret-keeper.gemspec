Gem::Specification.new do |s|
  s.name        = 'secret-keeper'
  s.version     = '0.2.3'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Keep all your secret files within openssl'
  s.description = 'A Secret keeper'
  s.authors     = ['Ray Lee']
  s.email       = 'ray-lee@kdanmobile.com'
  s.homepage    = 'https://gitlab.com/ray-lee/secret-keeper'
  s.license     = 'MIT'

  s.files            = ['lib/secret-keeper.rb']
  s.test_files       = ['spec/secret-keeper_spec.rb']
  s.extra_rdoc_files = [ 'README.md' ]
  s.rdoc_options     = ['--charset=UTF-8']

  s.required_ruby_version = '>= 2.3.1'
  s.add_development_dependency 'rspec', ['~> 3.0']
end
