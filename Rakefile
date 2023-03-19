# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

require "rake/extensiontask"

task build: :compile

Rake::ExtensionTask.new("tiktoken_ruby") do |ext|
  ext.lib_dir = "lib/tiktoken_ruby"
end

task default: %i[compile spec standard]
