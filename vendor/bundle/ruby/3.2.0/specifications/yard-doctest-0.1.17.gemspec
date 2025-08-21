# -*- encoding: utf-8 -*-
# stub: yard-doctest 0.1.17 ruby lib

Gem::Specification.new do |s|
  s.name = "yard-doctest".freeze
  s.version = "0.1.17"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rodionov".freeze]
  s.date = "2019-09-12"
  s.description = "Execute YARD examples as tests".freeze
  s.email = "p0deje@gmail.com".freeze
  s.homepage = "https://github.com/p0deje/yard-doctest".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Doctests from YARD examples".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<yard>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<minitest>.freeze, [">= 0"])
  s.add_development_dependency(%q<aruba>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<relish>.freeze, [">= 0"])
end
