require 'rake_compiler_dock'
require 'rbconfig'
require 'test/unit'

class TestVersions < Test::Unit::TestCase
  def test_cross_rubies
    cross = RakeCompilerDock.cross_rubies
    assert_operator(cross, :is_a?, Hash)
    cross.each do |minor, patch|
      assert_match(/^\d+\.\d+$/, minor)
      assert_match(/^\d+\.\d+\.\d+$/, patch)
    end
  end

  def test_ruby_cc_versions_no_args
    cross = RakeCompilerDock.cross_rubies
    expected = cross.values.sort.reverse.join(":")

    assert_equal(expected, RakeCompilerDock.ruby_cc_version)
  end

  def test_ruby_cc_versions_strings
    cross = RakeCompilerDock.cross_rubies

    expected = cross["3.4"]
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("3.4"))

    expected = [cross["3.4"], cross["3.2"]].join(":")
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("3.4", "3.2"))

    expected = [cross["3.4"], cross["3.2"]].join(":")
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("3.2", "3.4"))

    assert_raises do
      RakeCompilerDock.ruby_cc_version("9.8")
    end

    assert_raises do
      RakeCompilerDock.ruby_cc_version("foo")
    end
  end

  def test_ruby_cc_versions_requirements
    cross = RakeCompilerDock.cross_rubies

    expected = cross["3.4"]
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("~> 3.4"))
    assert_equal(expected, RakeCompilerDock.ruby_cc_version(Gem::Requirement.new("~> 3.4")))

    expected = [cross["3.4"], cross["3.3"], cross["3.2"]].join(":")
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("~> 3.2"))
    assert_equal(expected, RakeCompilerDock.ruby_cc_version(Gem::Requirement.new("~> 3.2")))

    expected = [cross["3.4"], cross["3.2"]].join(":")
    assert_equal(expected, RakeCompilerDock.ruby_cc_version("~> 3.2.0", "~> 3.4.0"))
    assert_equal(expected, RakeCompilerDock.ruby_cc_version(Gem::Requirement.new("~> 3.2.0"), Gem::Requirement.new("~> 3.4.0")))

    expected = [cross["3.4"], cross["3.3"], cross["3.2"]].join(":")
    assert_equal(expected, RakeCompilerDock.ruby_cc_version(">= 3.2"))
    assert_equal(expected, RakeCompilerDock.ruby_cc_version(Gem::Requirement.new(">= 3.2")))

    assert_raises do
      RakeCompilerDock.ruby_cc_version(Gem::Requirement.new("> 9.8"))
    end
  end

  def test_set_ruby_cc_versions
    original_ruby_cc_versions = ENV["RUBY_CC_VERSION"]
    cross = RakeCompilerDock.cross_rubies

    RakeCompilerDock.set_ruby_cc_version(Gem::Requirement.new("~> 3.2.0"), Gem::Requirement.new("~> 3.4.0"))
    assert_equal([cross["3.4"], cross["3.2"]].join(":"), ENV["RUBY_CC_VERSION"])

    RakeCompilerDock.set_ruby_cc_version("~> 3.2.0", "~> 3.4.0")
    assert_equal([cross["3.4"], cross["3.2"]].join(":"), ENV["RUBY_CC_VERSION"])

    RakeCompilerDock.set_ruby_cc_version("~> 3.1")
    assert_equal([cross["3.4"], cross["3.3"], cross["3.2"], cross["3.1"]].join(":"), ENV["RUBY_CC_VERSION"])
  ensure
    ENV["RUBY_CC_VERSION"] = original_ruby_cc_versions
  end
end
