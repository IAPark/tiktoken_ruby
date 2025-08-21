require "uri"
require "rbconfig"
require "rake_compiler_dock/colors"

module RakeCompilerDock
  class DockerCheck
    include Colors

    attr_reader :io
    attr_reader :pwd
    attr_reader :docker_command
    attr_accessor :machine_name

    def initialize(io, pwd, machine_name="rake-compiler-dock")
      @io = io
      @pwd = pwd
      @machine_name = machine_name

      if !io.tty? || (RUBY_PLATFORM=~/mingw|mswin/ && RUBY_VERSION[/^\d+/] < '2')
        disable_colors
      else
        enable_colors
      end

      docker_version

      unless ok?
        doma_version
        if doma_avail?
          io.puts
          io.puts yellow("docker-machine is available, but not ready to use. Trying to start.")

          doma_create
          if doma_create_ok?
            doma_start

            docker_version
          end
        else
          b2d_version

          if b2d_avail?
            io.puts
            io.puts yellow("boot2docker is available, but not ready to use. Trying to start.")

            b2d_init
            if b2d_init_ok?
              b2d_start

              docker_version
            end
          end
        end
      end
    end

    COMMANDS = %w[docker podman]
    def docker_version
      COMMANDS.find do |command|
        @docker_version_text, @docker_version_status = run("#{command} version")
        @docker_command = command
        @docker_version_status == 0
      end
    end

    def ok?
      @docker_version_status == 0 && @docker_version_text =~ /version/i && doma_pwd_ok?
    end

    def docker_client_avail?
      @docker_version_text =~ /version/
    end

    def doma_version
      @doma_version_text, @doma_version_status = run("docker-machine --version")
    end

    def doma_avail?
      @doma_version_status == 0 && @doma_version_text =~ /version/
    end

    def add_env_options(options, names)
      names.each do |name|
        if (v=ENV[name]) && !v.empty?
          options << ["--engine-env", "#{name}=#{ENV[name]}"]
        end
      end
      options
    end

    def doma_create
      options = add_env_options([], %w[ftp_proxy http_proxy https_proxy])
      driver = ENV['MACHINE_DRIVER'] || 'virtualbox'
      @doma_create_text, @doma_create_status = run("docker-machine create --driver #{driver.inspect} #{options.join(" ")} #{machine_name}", cmd: :visible, output: :visible)
    end

    def doma_create_ok?
      @doma_create_status == 0 || @doma_create_text =~ /already exists/
    end

    def doma_start
      @doma_start_text, @doma_start_status = run("docker-machine start #{machine_name}", cmd: :visible, output: :visible)
      @doma_env_set = false

      if doma_start_ok?
        @doma_env_text, @doma_env_status = run("docker-machine env #{machine_name} --shell bash --no-proxy")
        if @doma_env_status == 0 && set_env(@doma_env_text)
          @doma_env_set = true
        end
      end
    end

    def doma_start_ok?
      @doma_start_status == 0 || @doma_start_text =~ /already running/
    end

    def doma_env_ok?
      @doma_env_status == 0
    end

    def doma_has_env?
      @doma_env_set
    end

    def b2d_version
      @b2d_version_text = `boot2docker version 2>&1` rescue SystemCallError
      @b2d_version_status = $?.exitstatus
    end

    def b2d_avail?
      @b2d_version_status == 0 && @b2d_version_text =~ /version/
    end

    def b2d_init
      system("boot2docker init") rescue SystemCallError
      @b2d_init_status = $?.exitstatus
    end

    def b2d_init_ok?
      @b2d_init_status == 0
    end

    def b2d_start
      @b2d_start_text = `boot2docker start` rescue SystemCallError
      @b2d_start_status = $?.exitstatus
      @b2d_start_envset = false

      if @b2d_start_status == 0
        io.puts @b2d_start_text
        if set_env(@b2d_start_text)
          @b2d_start_envset = true
          io.puts yellow("Using above environment variables for starting #{machine_name}.")
        end
      end
    end

    def b2d_start_ok?
      @b2d_start_status == 0
    end

    def b2d_start_has_env?
      @b2d_start_envset
    end

    def host_os
      RbConfig::CONFIG['host_os']
    end

    def doma_pwd_ok?
      case host_os
      when /mingw|mswin/
        pwd =~ /^\/c\/users/i
      when /linux/
        true
      when /darwin/
        pwd =~ /^\/users/i
      end
    end

    def set_env(text)
      set = false
      text.scan(/(unset |Remove-Item Env:\\)(.+?)$/) do |_, key|
        ENV.delete(key)
        set = true
      end
      text.scan(/(export |\$Env:)(.+?)(="|=| = ")(.*?)(|\")$/) do |_, key, _, val, _|
        ENV[key] = val
        set = true
      end
      set
    end

    def help_text
      help = []
      if !ok? && docker_client_avail? && !doma_avail? && !b2d_avail?
        help << red("Docker client tools work, but connection to the local docker server failed.")
        case host_os
        when /linux/
          help << yellow("Please make sure the docker daemon is running.")
          help << ""
          help << yellow("On Ubuntu/Debian:")
          help << "   sudo service docker start"
          help << yellow("or")
          help << "   sudo service docker.io start"
          help << ""
          help << yellow("On Fedora/Centos/RHEL")
          help << "   sudo systemctl start docker"
          help << ""
          help << yellow("On SuSE")
          help << "   sudo systemctl start docker"
          help << ""
          help << yellow("Then re-check with '") + white("docker version") + yellow("'")
          help << yellow("or have a look at our FAQs: http://git.io/vm8AL")
        else
          help << yellow("    Please check why '") + white("docker version") + yellow("' fails")
          help << yellow("    or have a look at our FAQs: http://git.io/vm8AL")
        end
      elsif !ok? && !doma_avail? && !b2d_avail?
        case host_os
        when /mingw|mswin/
          help << red("Docker is not available.")
          help << yellow("Please download and install the docker-toolbox:")
          help << yellow("    https://www.docker.com/docker-toolbox")
        when /linux/
          help << red("Neither Docker nor Podman is available.")
          help << ""
          help << yellow("Install Docker on Ubuntu/Debian:")
          help << "    sudo apt-get install docker.io"
          help << ""
          help << yellow("Install Docker on Fedora/Centos/RHEL")
          help << "    sudo yum install docker"
          help << "    sudo systemctl start docker"
          help << ""
          help << yellow("Install Docker on SuSE")
          help << "    sudo zypper install docker"
          help << "    sudo systemctl start docker"
        when /darwin/
          help << red("Docker is not available.")
          help << yellow("Please install docker-machine per homebrew:")
          help << "    brew cask install virtualbox"
          help << "    brew install docker"
          help << "    brew install docker-machine"
          help << ""
          help << yellow("or download and install the official docker-toolbox:")
          help << yellow("    https://www.docker.com/docker-toolbox")
        else
          help << red("Docker is not available.")
        end
      elsif doma_avail?
        if !ok? && !doma_create_ok?
          help << red("docker-machine is installed but machine couldn't be created.")
          help << ""
          help << yellow("    Please check why '") + white("docker-machine create") + yellow("' fails")
          help << yellow("    or have a look at our FAQs: http://git.io/vRzIg")
        elsif !ok? && !doma_start_ok?
          help << red("docker-machine is installed but couldn't be started.")
          help << ""
          help << yellow("    Please check why '") + white("docker-machine start") + yellow("' fails.")
          help << yellow("    You might need to re-init with '") + white("docker-machine rm") + yellow("'")
          help << yellow("    or have a look at our FAQs: http://git.io/vRzIg")
        elsif !ok? && !doma_env_ok?
            help << red("docker-machine is installed and started, but 'docker-machine env' failed.")
            help << ""
            help << yellow("You might try to regenerate TLS certificates with:")
            help << "    docker-machine regenerate-certs #{machine_name}"
        elsif !ok? && !doma_pwd_ok?
          help << red("docker-machine can not mount the current working directory.")
          help << ""
          case host_os
          when /mingw|mswin/
            help << yellow("    Please move to a diretory below C:\\Users")
          when /darwin/
            help << yellow("    Please move to a diretory below /Users")
          end
        elsif !ok?
          help << red("docker-machine is installed and started, but 'docker version' failed.")
          help << ""

          if doma_has_env?
            help << yellow("    Please copy and paste following environment variables to your terminal")
            help += @doma_env_text.each_line.reject{|l| l=~/\s*#/ }.map{|l| "        #{l.chomp}" }
            help << yellow("    and check why '") + white("docker version") + yellow("' fails.")
          else
            help << yellow("    Please check why '") + white("docker version") + yellow("' fails.")
          end
          help << yellow("    You might also have a look at our FAQs: http://git.io/vRzIg")
        end
      elsif b2d_avail?
        if !ok? && !b2d_init_ok?
          help << red("boot2docker is installed but couldn't be initialized.")
          help << ""
          help << yellow("    Please check why '") + white("boot2docker init") + yellow("' fails")
          help << yellow("    or have a look at our FAQs: http://git.io/vm8Nr")
        elsif !ok? && !b2d_start_ok?
          help << red("boot2docker is installed but couldn't be started.")
          help << ""
          help << yellow("    Please check why '") + white("boot2docker start") + yellow("' fails.")
          help << yellow("    You might need to re-init with '") + white("boot2docker delete") + yellow("'")
          help << yellow("    or have a look at our FAQs: http://git.io/vm8Nr")
        elsif !ok? && !doma_pwd_ok?
          help << red("boot2docker can not mount the current working directory.")
          help << ""
          case host_os
          when /mingw|mswin/
            help << yellow("    Please move to a diretory below C:\\Users")
          when /darwin/
            help << yellow("    Please move to a diretory below /Users")
          end
        elsif !ok? && b2d_start_ok?
          help << red("boot2docker is installed and started, but 'docker version' failed.")
          help << ""
          if b2d_start_has_env?
            help << yellow("    Please copy and paste above environment variables to your terminal")
            help << yellow("    and check why '") + white("docker version") + yellow("' fails.")
          else
            help << yellow("    Please check why '") + white("docker version") + yellow("' fails.")
          end
          help << yellow("    You might need to re-init with '") + white("boot2docker delete") + yellow("'")
          help << yellow("    or have a look at our FAQs: http://git.io/vm8Nr")
        end
      end

      help.join("\n")
    end

    def print_help_text
      io.puts(help_text)
    end

    private

    def run(cmd, options={})
      if options[:cmd] == :visible
        io.puts "$ #{green(cmd)}"
      end

      if options[:output] == :visible
        text = String.new
        begin
          IO.popen("#{cmd} 2>&1") do |fd|
            while !fd.eof?
              t = fd.read_nonblock(1024)
              io.write t
              text << t
            end
          end
        rescue SystemCallError
          text = nil
        end
      else
        text = `#{cmd} 2>&1` rescue SystemCallError
      end
      [text, $?.exitstatus]
    end
  end
end
