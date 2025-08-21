# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "rcd_test"
  spec.version       = "1.0.0"
  spec.authors       = ["Lars Kanis"]
  spec.email         = ["lars@greiz-reinsdorf.de"]

  spec.summary       = "C extension for testing rake-compiler-dock"
  spec.description   = "This gem has no real use other than testing builds of binary gems."
  spec.homepage      = "https://github.com/rake-compiler/rake-compiler-dock"
  spec.required_ruby_version = ">= 2.0.0"
  spec.license = "MIT"

  spec.files = [
    "ext/java/RcdTestExtService.java",
    "ext/java/RubyRcdTest.java",
    "ext/mri/extconf.rb",
    "ext/mri/rcd_test_ext.c",
    "ext/mri/rcd_test_ext.h",
    "lib/rcd_test.rb",
  ]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/mri/extconf.rb"]
end
