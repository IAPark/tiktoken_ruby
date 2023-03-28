# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"
require "rake/extensiontask"
require "rb_sys/extensiontask"

GEMSPEC = Gem::Specification.load("tiktoken_ruby.gemspec")

RbSys::ExtensionTask.new("tiktoken_ruby", GEMSPEC) do |ext|
  ext.lib_dir = "lib/tiktoken_ruby"
end

RSpec::Core::RakeTask.new(:spec)

task :native, [:platform] do |_t, platform:|
  sh "bundle", "exec", "rb-sys-dock", "--platform", platform, "--build"
end

task build: :compile

task default: %i[compile spec standard]
