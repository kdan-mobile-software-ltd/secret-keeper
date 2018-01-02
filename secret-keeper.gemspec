Gem::Specification.new do |s|
  s.name        = 'secret-keeper'
  s.version     = '0.1.0'
  s.date        = '2017-12-28'
  s.summary     = 'Keep all your secret files within openssl'
  s.description = 'A Secret keeper'
  s.authors     = ['Ray Lee']
  s.email       = 'ray-lee@kdanmobile.com'
  s.files       = ['lib/secret-keeper.rb']
  s.homepage    = 'https://github.com/redtear1115/secret-keeper'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec'
end
