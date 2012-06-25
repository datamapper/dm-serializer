# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors     = [ 'Guy van den Berg', 'Dan Kubb' ]
  gem.email       = [ "dan.kubb@gmail.com" ]
  gem.summary     = "DataMapper plugin for serializing Resources and Collections"
  gem.description = gem.summary
  gem.homepage    = "http://datamapper.org"

  gem.files            = `git ls-files`.split("\n")
  gem.test_files       = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.rdoc]

  gem.name          = "dm-serializer"
  gem.require_paths = [ "lib" ]
  gem.version       = '1.2.1'

  gem.add_runtime_dependency('dm-core',    '~> 1.2.0')
  gem.add_runtime_dependency('fastercsv',  '~> 1.5.4')
  gem.add_runtime_dependency('multi_json', '~> 1.0.3')
  gem.add_runtime_dependency('json',       '~> 1.6.1')
  gem.add_runtime_dependency('json_pure',  '~> 1.6.1')

  gem.add_development_dependency('rake',  '~> 0.9.2')
  gem.add_development_dependency('rspec', '~> 1.3.2')
end
