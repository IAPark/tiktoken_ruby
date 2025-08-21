require 'erb'
require "rake/clean"
require "rake_compiler_dock"
require_relative "build/gem_helper"
require_relative "build/parallel_docker_build"

CLEAN.include("tmp")

RakeCompilerDock::GemHelper.install_tasks

platforms = [
  # tuple is [platform, target]
  ["aarch64-linux-gnu", "aarch64-linux-gnu"],
  ["aarch64-linux-musl", "aarch64-linux-musl"],
  ["arm-linux-gnu", "arm-linux-gnueabihf"],
  ["arm-linux-musl", "arm-linux-musleabihf"],
  ["arm64-darwin", "aarch64-apple-darwin"],
  ["x64-mingw-ucrt", "x86_64-w64-mingw32"],
  ["x64-mingw32", "x86_64-w64-mingw32"],
  ["x86-linux-gnu", "i686-linux-gnu"],
  ["x86-linux-musl", "i686-unknown-linux-musl"],
  ["x86-mingw32", "i686-w64-mingw32"],
  ["x86_64-darwin", "x86_64-apple-darwin"],
  ["x86_64-linux-gnu", "x86_64-linux-gnu"],
  ["x86_64-linux-musl", "x86_64-unknown-linux-musl"],
]

namespace :build do

  platforms.each do |platform, target|
    sdf = "Dockerfile.mri.#{platform}"

    desc "Build image for platform #{platform}"
    task platform => sdf
    task sdf do
      image_name = RakeCompilerDock::Starter.container_image_name(platform: platform)
      sh(*RakeCompilerDock.docker_build_cmd(platform), "-t", image_name, "-f", "Dockerfile.mri.#{platform}", ".")
      if image_name.include?("linux-gnu")
        sh("docker", "tag", image_name, image_name.sub("linux-gnu", "linux"))
      end
    end

    df = ERB.new(File.read("Dockerfile.mri.erb"), trim_mode: ">").result(binding)
    File.write(sdf, df)
    CLEAN.include(sdf)
  end

  desc "Build image for JRuby"
  task :jruby => "Dockerfile.jruby"
  task "Dockerfile.jruby" do
    image_name = RakeCompilerDock::Starter.container_image_name(rubyvm: "jruby")
    sh(*RakeCompilerDock.docker_build_cmd("jruby"), "-t", image_name, "-f", "Dockerfile.jruby", ".")
  end

  RakeCompilerDock::ParallelDockerBuild.new(platforms.map{|pl, _| "Dockerfile.mri.#{pl}" } + ["Dockerfile.jruby"], workdir: "tmp/docker")

  desc "Build images for all MRI platforms in parallel"
  if ENV['RCD_USE_BUILDX_CACHE']
    task :mri => platforms.map(&:first)
  else
    multitask :mri => platforms.map(&:first)
  end

  desc "Build images for all platforms in parallel"
  if ENV['RCD_USE_BUILDX_CACHE']
    task :all => platforms.map(&:first) + ["jruby"]
  else
    multitask :all => platforms.map(&:first) + ["jruby"]
  end
end

task :build => "build:all"

namespace :prepare do
  desc "Build cross compiler for x64-mingw-ucrt aka RubyInstaller-3.1+"
  task "mingw64-ucrt" do
    sh(*RakeCompilerDock.docker_build_cmd, "-t", "larskanis/mingw64-ucrt:20.04", ".",
       chdir: "mingw64-ucrt")
  end
end

desc "Run tests"
task :test do
  sh %Q{ruby -w -W2 -I. -Ilib -e "#{Dir["test/test_*.rb"].map{|f| "require '#{f}';"}.join}" -- -v #{ENV['TESTOPTS']}}
end

desc "Update predefined_user_group.rb"
task :update_lists do
  def get_user_list(platform)
    puts "getting user list from #{platform} ..."
    `RCD_PLATFORM=#{platform} rake-compiler-dock bash -c "getent passwd"`.each_line.map do |line|
      line.chomp.split(":")[0]
    end.compact.reject(&:empty?) - [RakeCompilerDock::Starter.make_valid_user_name(`id -nu`.chomp)]
  end

  def get_group_list(platform)
    puts "getting group list from #{platform} ..."
    `RCD_PLATFORM=#{platform} rake-compiler-dock bash -c "getent group"`.each_line.map do |line|
      line.chomp.split(":")[0]
    end.compact.reject(&:empty?) - [RakeCompilerDock::Starter.make_valid_group_name(`id -ng`.chomp)]
  end

  users = platforms.flat_map { |platform, _| get_user_list(platform) }.uniq.sort
  groups = platforms.flat_map { |platform, _| get_group_list(platform) }.uniq.sort

  File.open("lib/rake_compiler_dock/predefined_user_group.rb", "w") do |fd|
    fd.puts <<-EOT
      # DO NOT EDIT - This file is generated per 'rake update_lists'
      module RakeCompilerDock
        PredefinedUsers = #{users.inspect}
        PredefinedGroups = #{groups.inspect}
      end
    EOT
  end
end

namespace :release do
  desc "push all docker images"
  task :images do
    image_name = RakeCompilerDock::Starter.container_image_name(rubyvm: "jruby")
    sh("docker", "push", image_name)

    platforms.each do |platform, _|
      image_name = RakeCompilerDock::Starter.container_image_name(platform: platform)
      sh("docker", "push", image_name)

      if image_name.include?("linux-gnu")
        sh("docker", "push", image_name.sub("linux-gnu", "linux"))
      end
    end
  end
end
