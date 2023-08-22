# frozen_string_literal: true

require_relative "lib/tiktoken_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "tiktoken_ruby"
  spec.version = Tiktoken::VERSION
  spec.authors = ["IAPark"]
  spec.email = ["isaac.a.park@gmail.com"]

  spec.summary = "Ruby wrapper for Tiktoken"
  spec.description = "An unofficial Ruby wrapper for Tiktoken, " \
    "a BPE tokenizer written by and used by OpenAI. It can be used to " \
    "count the number of tokens in text before sending it to OpenAI APIs."

  spec.homepage = "https://github.com/IAPark/tiktoken_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"
  spec.required_rubygems_version = ">= 3.1.0"
  spec.platform = Gem::Platform::RUBY

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/IAPark/tiktoken_ruby"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/github/IAPark/tiktoken_ruby/main"

  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/tiktoken_ruby/extconf.rb"]

  spec.add_dependency "rb_sys", "~> 0.9.81"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
