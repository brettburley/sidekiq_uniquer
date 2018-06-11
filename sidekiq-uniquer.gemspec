$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sidekiq_uniquer/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sidekiq_uniquer'
  s.version     = SidekiqUniquer::VERSION
  s.authors     = ['Brett Burley']
  s.email       = ['brett@adakist.com']
  s.homepage    = 'http://github.com/brettburley/sidekiq_uniquer'
  s.summary     = 'A gem that extends sidekiq to enable unique jobs that are locked in redis.'
  s.description = 'Description of SidekiqUniquer.'
  s.license     = 'MIT'

  s.files = Dir['lib/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency('sidekiq', '>= 4.0', '<= 6.0')

  s.add_development_dependency('bundler')
  s.add_development_dependency('mock_redis')
  s.add_development_dependency('pry')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('yard')
end
