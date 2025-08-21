# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yard/doctest/version'

Gem::Specification.new do |spec|
  spec.name         = 'yard-doctest'
  spec.version      = YARD::Doctest::VERSION
  spec.author       = 'Alex Rodionov'
  spec.email        = 'p0deje@gmail.com'
  spec.summary      = 'Doctests from YARD examples'
  spec.description  = 'Execute YARD examples as tests'
  spec.homepage     = 'https://github.com/p0deje/yard-doctest'
  spec.license      = 'MIT'

  spec.files        = `git ls-files -z`.split("\x0")
  spec.test_files   = spec.files.grep(/^features\//)
  spec.require_path = 'lib'

  spec.add_runtime_dependency 'yard'
  spec.add_runtime_dependency 'minitest'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'relish'
end
