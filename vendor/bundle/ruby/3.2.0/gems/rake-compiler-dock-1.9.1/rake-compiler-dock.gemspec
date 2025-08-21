# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_compiler_dock/version'

Gem::Specification.new do |spec|
  spec.name          = "rake-compiler-dock"
  spec.version       = RakeCompilerDock::VERSION
  spec.authors       = ["Lars Kanis"]
  spec.email         = ["lars@greiz-reinsdorf.de"]
  spec.summary       = %q{Easy to use and reliable cross compiler environment for building Windows and Linux binary gems.}
  spec.description   = %q{Easy to use and reliable cross compiler environment for building Windows and Linux binary gems.
Use rake-compiler-dock to enter an interactive shell session or add a task to your Rakefile to automate your cross build.}
  spec.homepage      = "https://github.com/rake-compiler/rake-compiler-dock"
  spec.license       = "MIT"
#  We do not set a ruby version in the gemspec, to allow addition to the Gemfile of gems that still support ruby-1.8.
#  However we do the version check at runtime.
#  spec.required_ruby_version = '>= 1.9.2'

  spec.files = begin
    `git ls-files -z`.split("\x0")
  rescue StandardError => e
    warn "WARNING: Could not discover files for gemspec: #{e}"
    []
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.7", "< 3.0"
  spec.add_development_dependency "rake", ">= 12"
  spec.add_development_dependency "test-unit", "~> 3.0"
end
