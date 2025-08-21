# -*- encoding: utf-8 -*-
# stub: standard 1.50.0 ruby lib

Gem::Specification.new do |s|
  s.name = "standard".freeze
  s.version = "1.50.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/standardrb/standard/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/standardrb/standard", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/standardrb/standard" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Justin Searls".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-05-13"
  s.email = ["searls@gmail.com".freeze]
  s.executables = ["standardrb".freeze]
  s.files = ["exe/standardrb".freeze]
  s.homepage = "https://github.com/standardrb/standard".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Ruby Style Guide, with linter & automatic code fixer".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.75.5"])
  s.add_runtime_dependency(%q<lint_roller>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<standard-custom>.freeze, ["~> 1.0.0"])
  s.add_runtime_dependency(%q<standard-performance>.freeze, ["~> 1.8"])
  s.add_runtime_dependency(%q<language_server-protocol>.freeze, ["~> 3.17.0.2"])
end
