require 'rake_compiler_dock'
require 'rbconfig'
require 'test/unit'
begin
  require 'test/unit/notify'
rescue LoadError
end

class TestEnvironmentVariables
  module Common
    TEST_PLATFORM = ENV["TEST_PLATFORM"] || "x64-mingw-ucrt"
    IS_JRUBY = TEST_PLATFORM.to_s == "jruby"
    TEST_IMAGE_NAME = if IS_JRUBY
      RakeCompilerDock::Starter.container_image_name(rubyvm: "jruby")
    else
      RakeCompilerDock::Starter.container_image_name(platform: TEST_PLATFORM)
    end

    def rcd_env
      self.class.instance_variable_get("@rcd_env") || begin
        command = "env"
        output = %x(#{invocation(command)})

        env = output.split("\n").each_with_object({}) do |line, hash|
          hash[Regexp.last_match(1)] = Regexp.last_match(2).chomp if line =~ /\A(\w+)=(.*)\z/
        end

        self.class.instance_variable_set("@rcd_env", env)
      end
    end

    unless IS_JRUBY
      def test_RUBY_CC_VERSION
        df = File.read(File.expand_path("../../Dockerfile.mri.erb", __FILE__))
        df =~ /^ENV RUBY_CC_VERSION=(.*)$/
        assert_equal $1, rcd_env['RUBY_CC_VERSION']

        assert_equal RakeCompilerDock.ruby_cc_version, rcd_env['RUBY_CC_VERSION']
      end

      def test_RAKE_EXTENSION_TASK_NO_NATIVE
        assert_equal "true", rcd_env['RAKE_EXTENSION_TASK_NO_NATIVE']
      end

      def test_symlink_rake_compiler
        cmd = invocation("if test -h $HOME/.rake-compiler ; then echo yes ; else echo no ; fi")
        assert_equal("yes", %x(#{cmd}).strip)
      end

      def test_gem_directory
        cmd = invocation("if test -d $HOME/.gem ; then echo yes ; else echo no ; fi")
        assert_equal("yes", %x(#{cmd}).strip)
      end
    end
  end

  class UsingWrapper < Test::Unit::TestCase
    include Common

    def invocation(command)
      idir = File.join(File.dirname(__FILE__), '../lib')
      "RCD_PLATFORM=#{TEST_PLATFORM} RCD_RUBYVM=#{IS_JRUBY ? 'jruby' : 'mri'} #{RbConfig::CONFIG['RUBY_INSTALL_NAME']} -I#{idir.inspect} bin/rake-compiler-dock bash -c '#{command}'"
    end

    def test_HOST_RUBY_PLATFORM
      assert_equal RUBY_PLATFORM, rcd_env['RCD_HOST_RUBY_PLATFORM']
    end

    def test_HOST_RUBY_VERSION
      assert_equal RUBY_VERSION, rcd_env['RCD_HOST_RUBY_VERSION']
    end

    def test_IMAGE
      assert_equal TEST_IMAGE_NAME, rcd_env['RCD_IMAGE']
    end

    def test_PWD
      assert_equal Dir.pwd, rcd_env['PWD']
    end

    def test_SOURCE_DATE_EPOCH
      cmd = "SOURCE_DATE_EPOCH=1234567890 " + invocation("echo \$SOURCE_DATE_EPOCH")
      sde = %x(#{cmd}).strip
      assert_equal "1234567890", sde
    end
  end

  class AsIfContinuousIntegration < Test::Unit::TestCase
    include Common

    def invocation(command)
      "docker run --rm #{TEST_IMAGE_NAME} bash -c '#{command}'"
    end
  end
end
