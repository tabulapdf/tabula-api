# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tabula-api"
  s.version     = "0.0.1"
  s.authors     = ["Manuel Aristarán"]
  s.email       = ["manuel@jazzido.com"]
  s.homepage    = "https://github.com/jazzido/tabula-api"
  s.summary     = %q{a REST endpoint for tabula-extractor}
  s.description = %q{a REST endpoint for tabula-extractor}
  s.license     = 'MIT'

  s.platform = 'java'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'fixture_dependencies'

  s.add_runtime_dependency "grape"
  s.add_runtime_dependency "sequel"
  s.add_runtime_dependency "jdbc-sqlite3"
  s.add_runtime_dependency "tabula-extractor"
end
