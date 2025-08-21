require 'rake_compiler_dock'
require 'test/unit'
begin
  require 'test/unit/notify'
rescue LoadError
end

class TestStarter < Test::Unit::TestCase
  include RakeCompilerDock

  def test_make_valid_user_name
    assert_equal "mouse-click", Starter.make_valid_user_name("Mouse-Click")
    assert_equal "very_very_very_l-ame_with_spaces", Starter.make_valid_user_name("Very very very long name with spaces")
    assert_equal "_halt", Starter.make_valid_user_name("halt")
    assert_equal "_rubyuser", Starter.make_valid_user_name("rubyuser")
    assert_equal "staff", Starter.make_valid_user_name("staff")
    assert_equal "a", Starter.make_valid_user_name("a")
    assert_equal "_", Starter.make_valid_user_name("")
    assert_equal "_", Starter.make_valid_user_name(nil)
  end

  def test_make_valid_group_name
    assert_equal "mouse-click", Starter.make_valid_group_name("Mouse-Click")
    assert_equal "very_very_very_l-ame_with_spaces", Starter.make_valid_group_name("Very very very long name with spaces")
    assert_equal "halt", Starter.make_valid_group_name("halt")
    assert_equal "_rubyuser", Starter.make_valid_group_name("rubyuser")
    assert_equal "_staff", Starter.make_valid_group_name("staff")
    assert_equal "a", Starter.make_valid_group_name("a")
    assert_equal "_", Starter.make_valid_group_name("")
    assert_equal "_", Starter.make_valid_group_name(nil)
  end

  def test_container_image_name
    # with env vars
    with_env({"RCD_IMAGE" => "env-var-value"}) do
      assert_equal("env-var-value", Starter.container_image_name)
    end
    with_env({"RAKE_COMPILER_DOCK_IMAGE" => "env-var-value"}) do
      assert_equal("env-var-value", Starter.container_image_name)
    end

    # with image option
    assert_equal("option-value", Starter.container_image_name({:image => "option-value"}))

    # with env var and image option, image option wins
    with_env({"RCD_IMAGE" => "env-var-value"}) do
      assert_equal("option-value", Starter.container_image_name({:image => "option-value"}))
    end

    # mri platform arg
    assert_equal(
      "ghcr.io/rake-compiler/rake-compiler-dock-image:#{IMAGE_VERSION}-mri-platform-option-value",
      Starter.container_image_name({:platform => "platform-option-value"}),
    )

    # jruby rubyvm arg
    assert_equal(
      "ghcr.io/rake-compiler/rake-compiler-dock-image:#{IMAGE_VERSION}-jruby",
      Starter.container_image_name({:rubyvm => "jruby"}),
    )

    # jruby platform arg
    assert_equal(
      "ghcr.io/rake-compiler/rake-compiler-dock-image:#{IMAGE_VERSION}-jruby",
      Starter.container_image_name({:platform => "jruby"}),
    )

    # container registry env var
    with_env({"CONTAINER_REGISTRY" => "registry-value"}) do
      assert_equal(
        "registry-value/rake-compiler-dock-image:#{IMAGE_VERSION}-mri-x86_64-darwin",
        Starter.container_image_name({:platform => "x86_64-darwin"}),
      )
    end

    # snapshots
    assert_equal(
      "ghcr.io/rake-compiler/rake-compiler-dock-image:snapshot-mri-x86_64-darwin",
      Starter.container_image_name({:platform =>"x86_64-darwin", :version => "snapshot"}),
    )
  end

  def test_container_registry
    assert_equal("ghcr.io/rake-compiler", Starter.container_registry)

    with_env({"CONTAINER_REGISTRY" => "env-var-value"}) do
      assert_equal("env-var-value", Starter.container_registry)
    end
  end

  def test_container_rubyvm
    # no args
    assert_equal("mri", Starter.container_rubyvm)

    # with env var
    with_env({"RCD_RUBYVM" => "env-var-value"}) do
      assert_equal("env-var-value", Starter.container_rubyvm)
    end

    # with rubyvm option
    assert_equal("option-value", Starter.container_rubyvm({:rubyvm => "option-value"}))

    # with rubyvm option and env var, rubyvm option wins
    with_env({"RCD_RUBYVM" => "env-var-value"}) do
      assert_equal("option-value", Starter.container_rubyvm({:rubyvm => "option-value"}))
    end

    # with jruby platform option
    assert_equal("jruby", Starter.container_rubyvm({:platform => "jruby"}))
  end

  def test_container_jrubyvm?
    assert(Starter.container_jrubyvm?({:rubyvm => "jruby"}))
    assert(Starter.container_jrubyvm?({:platform => "jruby"}))
    refute(Starter.container_jrubyvm?({:rubyvm => "mri"}))
    refute(Starter.container_jrubyvm?({:platform => "x86_64-linux-gnu"}))
  end

  def test_platforms
    # no args
    assert_equal("x86-mingw32 x64-mingw32", Starter.platforms)

    # with env var
    with_env({"RCD_PLATFORM" => "env-var-value"}) do
      assert_equal("env-var-value", Starter.platforms)
    end

    # with platform option
    assert_equal("option-value", Starter.platforms({:platform => "option-value"}))

    # with platform option and env var, platform option wins
    with_env({"RCD_PLATFORM" => "arm64-darwin"}) do
      assert_equal("option-value", Starter.platforms({:platform => "option-value"}))
    end

    # when options rubyvm is set to jruby
    assert_equal("jruby", Starter.platforms({:rubyvm => "jruby"}))
  end

  def with_env(env = {})
    original_env = {}
    env.each do |k, v|
      original_env[k] = ENV[k]
      ENV[k] = v
    end
    yield
  ensure
    original_env.each do |k, v|
      ENV[k] = v
    end
  end
end
