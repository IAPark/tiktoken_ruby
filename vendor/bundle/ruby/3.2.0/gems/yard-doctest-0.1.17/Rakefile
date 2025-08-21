require 'bundler/gem_tasks'

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |task|
  task.cucumber_opts = '-f progress features'
end

task default: :cucumber
