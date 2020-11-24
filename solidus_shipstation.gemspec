# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_shipstation'
  s.version     = '1.0.3.paragon'
  s.summary     = 'Solidus/ShipStation Integration'
  s.description = 'Integrates ShipStation API with Solidus. Supports exporting shipments and importing tracking numbers'
  s.required_ruby_version = '>= 2.6.0'

  s.author    = 'Whitespectre'
  s.homepage  = 'https://github.com/whitespectre/solidus_shipstation'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'

  s.add_dependency 'solidus_core', ' >= 1.1', '< 3'
  s.add_dependency 'solidus_support'
end
