# frozen_string_literal: true

require "minitest/autorun"
require "rcd_test"

class TestBasic < Minitest::Test

  def test_do_something
    assert_equal "something has been done", RcdTest.do_something
  end

  def test_check_darwin_compiler_rt_symbol_resolution
    skip("jruby should not run libc-specific tests") if RUBY_ENGINE == "jruby"

    if RUBY_PLATFORM.include?("darwin")
      assert(RcdTest.darwin_builtin_available?)
    else
      e = assert_raises(RuntimeError) { RcdTest.darwin_builtin_available? }
      assert_equal("__builtin_available is not defined", e.message)
    end
  end

  def test_floating_point_classification_macros
    skip("jruby should not run libc-specific tests") if RUBY_ENGINE == "jruby"

    refute(RcdTest.isinf?(42.0))
    assert(RcdTest.isinf?(Float::INFINITY))
    refute(RcdTest.isnan?(42.0))
    assert(RcdTest.isnan?(Float::NAN))
  end

  def test_largefile_op_removed_from_musl
    skip("jruby should not run libc-specific tests") if RUBY_ENGINE == "jruby"

    is_linux = RUBY_PLATFORM.include?("linux")
    assert_equal(is_linux, RcdTest.largefile_op_removed_from_musl)
  end
end
