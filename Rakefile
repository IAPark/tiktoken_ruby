# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

require "rake/extensiontask"

task build: :compile

gem_spec = Gem::Specification.load("tiktoken_ruby.gemspec")

# add your default gem packing task
Gem::PackageTask.new(gem_spec) do |pkg|
end

Rake::ExtensionTask.new("tiktoken_ruby", gem_spec) do |ext|
  ext.lib_dir = "lib/tiktoken_ruby"
  ext.cross_compile = true
  ext.cross_platform =  %w[x86-mingw32 x64-mingw-ucrt x64-mingw32-3.2.0 x86-linux x86_64-linux x86_64-darwin arm64-darwin]
end

task default: %i[compile spec standard]
