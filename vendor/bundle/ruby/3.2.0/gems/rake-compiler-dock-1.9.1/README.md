# rake-compiler-dock

**Easy to use and reliable cross compiler environment for building Windows, Linux, Mac and JRuby binary gems.**

It provides cross compilers and Ruby environments for 2.4 and newer versions of the [RubyInstaller](http://rubyinstaller.org/) and Linux runtime environments.
They are prepared for use with [rake-compiler](https://github.com/rake-compiler/rake-compiler).
It is used by [many gems with C or JRuby extentions](https://github.com/rake-compiler/rake-compiler-dock/wiki/Projects-using-rake-compiler-dock).

This is kind of successor of [rake-compiler-dev-box](https://github.com/tjschuck/rake-compiler-dev-box).
It is wrapped as a gem for easier setup, usage and integration and is based on lightweight Docker containers.
It is also more reliable, since the underlying docker images are versioned and immutable.

## Supported platforms

The following platforms are supported for cross-compilation by rake-compiler-dock:

- `aarch64-linux` and `aarch64-linux-gnu`
- `aarch64-linux-musl`
- `arm-linux` and `arm-linux-gnu`
- `arm-linux-musl`
- `arm64-darwin`
- `jruby`
- `x64-mingw-ucrt`
- `x64-mingw32`
- `x86-linux` and `x86-linux-gnu`
- `x86-linux-musl`
- `x86-mingw32`
- `x86_64-darwin`
- `x86_64-linux` and `x86_64-linux-gnu`
- `x86_64-linux-musl`

### Windows

`x64-mingw-ucrt` should be used for Ruby 3.1 and later on windows. `x64-mingw32` should be used for Ruby 3.0 and earlier. This is to match the [changed platform of RubyInstaller-3.1](https://rubyinstaller.org/2021/12/31/rubyinstaller-3.1.0-1-released.html).

### Linux GNU and Musl

Platform names with a `*-linux` suffix are aliases for `*-linux-gnu`, since the Rubygems default is to assume `gnu` if no libc is specified.

Some C extensions may not require separate GNU and Musl builds, in which case it's acceptable to ship a single `*-linux` gem to cover both platforms. We recommend you set up automated testing for both GNU and Musl to determine whether you need to ship distinct native gems for these platforms (see [`flavorjones/ruby-c-extensions-explained`](https://github.com/flavorjones/ruby-c-extensions-explained/blob/main/.github/workflows/precompiled.yml) for an example of how to set up testing pipelines on Github Actions).


## Linux GNU and Musl: important details

### Summary

If you ship `-linux-gnu` and `-linux-musl` gems:

- Use rake-compiler `>= 1.2.7` to build your gems
- Recommend your musl users have bundler `>= 2.5.6`
- Require your linux users to have rubygems `>= 3.3.22` and bundler `>= 2.3.21`

⚠ DO NOT ship a `-linux-musl` gem with a `-linux` gem. See https://github.com/rake-compiler/rake-compiler-dock/issues/117 for more context.


### Warning about combining `-linux-musl` with other linux native platforms

After [evaluating many ruby, rubygems, and bundler versions](https://github.com/rake-compiler/rake-compiler-dock/issues/117), we strongly recommend that gem maintainers choose one of the following two options:

- ship a `-linux` platform gem that works for both gnu and musl systems if you can,
- or ship both `-linux-gnu` and `-linux-musl` platform gems

Do NOT ship `-linux` and `-linux-musl` gems together, some versions of bundler or rubygems will not work properly for your users.


### Warning about required versions of rubygems

The `*-linux-gnu` and `*-linux-musl` platform gems require Rubygems 3.3.22 or later (or Bundler 2.3.21 or later) at installation time.

Ruby version 3.1 and later ship with a sufficient Rubygems version. For earlier versions of Ruby, here are the versions of Rubygems you should recommend to your users:

- ruby: "3.0", rubygems: "3.5.5" # or possibly higher
- ruby: "2.7", rubygems: "3.4.22"
- ruby: "2.6", rubygems: "3.4.22"
- ruby: "2.5", rubygems: "3.3.26"
- ruby: "2.4", rubygems: "3.3.26"

**It's strongly suggested that you use rake-compiler v1.2.7 or later to build `linux-musl` and/or `linux-gnu` native gems.** That version of rake-compiler sets `required_rubygems_version` automatically in the native platform gems' gemspecs.


### Warning about required versions of bundler

Finally, there is a known bug in bundler `< 2.5.6` that may make it difficult for users on musl systems to resolve their `linux-musl` dependencies correctly. You can read a description of this problem at https://github.com/rubygems/rubygems/issues/7432, but in summary **you should recommend your musl users have bundler v2.5.6 or later**.


## Installation

Install docker [following the instructions on the docker website](https://docs.docker.com/engine/install/) ... or install [docker-toolbox for Windows and OSX](https://github.com/docker/toolbox/releases) or boot2docker on [Windows](https://github.com/boot2docker/windows-installer/releases) or [OS X](https://github.com/boot2docker/osx-installer/releases) .

Install rake-compiler-dock as a gem. The docker image is downloaded later on demand:

    $ gem install rake-compiler-dock

... or build your own gem and docker image:

    $ git clone https://github.com/rake-compiler/rake-compiler-dock
    $ rake install


## Usage

Rake-compiler-dock provides the necessary tools to build Ruby extensions for Windows and Linux written in C and C++ and JRuby written in Java.
It is intended to be used in conjunction with [rake-compiler's](https://github.com/rake-compiler/rake-compiler) cross build capability.
Your Rakefile should enable cross compilation like so:

```ruby
exttask = Rake::ExtensionTask.new('my_extension', my_gem_spec) do |ext|
  ext.cross_compile = true
  ext.cross_platform = %w[x86-mingw32 x64-mingw-ucrt x64-mingw32 x86-linux x86_64-linux x86_64-darwin arm64-darwin]
end
```

where you should choose your platforms from the list in the "Supported platforms" section.

See below, how to invoke cross builds in your Rakefile.

Additionally it may also be used to build ffi based binary gems like [libusb](https://github.com/larskanis/libusb), but currently doesn't provide any additional build helpers for this use case, beyond docker invocation and cross compilers.

### Interactive Usage

Rake-compiler-dock offers the shell command `rake-compiler-dock` and a [ruby API](http://www.rubydoc.info/gems/rake-compiler-dock/RakeCompilerDock) for issuing commands within the docker image, described below.

`rake-compiler-dock` without arguments starts an interactive shell session.
This is best suited to try out and debug a build.
It mounts the current working directory into the docker environment.
All changes below the current working directory are shared with the host.
But note, that all other changes to the file system of the container are dropped at the end of the session - the docker image is static for a given version.
`rake-compiler-dock` can also take the build command(s) from STDIN or as command arguments.

All commands are executed with the same user and group of the host.
This is done by copying user account data into the container and sudo to it.

To build x86 Windows and x86_64 Linux binary gems interactively, it can be called like this:

    user@host:$ cd your-gem-dir/
    user@host:$ rake-compiler-dock   # this enters a container with an interactive shell for x86 Windows (default)
    user@5b53794ada92:$ bundle
    user@5b53794ada92:$ rake cross native gem
    user@5b53794ada92:$ exit
    user@host:$ ls pkg/*.gem
    your-gem-1.0.0.gem  your-gem-1.0.0-x86-mingw32.gem

    user@host:$ RCD_PLATFORM=x86_64-linux-gnu rake-compiler-dock   # this enters a container for amd64 Linux GNU target
    user@adc55b2b92a9:$ bundle
    user@adc55b2b92a9:$ rake cross native gem
    user@adc55b2b92a9:$ exit
    user@host:$ ls pkg/*.gem
    your-gem-1.0.0.gem  your-gem-1.0.0-x86_64-linux-gnu.gem

Or non-interactive:

    user@host:$ rake-compiler-dock bash -c "bundle && rake cross native gem"

The environment variable `RUBY_CC_VERSION` is predefined as described [below](#environment-variables).

If necessary, additional software can be installed, prior to the build command.
This is local to the running session, only.

For Windows and Mac:

    sudo apt-get update && sudo apt-get install your-package

For Linux:

    sudo yum install your-package

You can also choose between different executable ruby versions by `rbenv shell <version>` .
The current default is 3.1.

### JRuby support

Rake-compiler-dock offers a dedicated docker image for JRuby.
JRuby doesn't need a complicated cross build environment like C-ruby, but using Rake-compiler-dock for JRuby makes building binary gems more consistent.

To build java binary gems interactively, it can be called like this:

    user@host:$ cd your-gem-dir/
    user@host:$ RCD_RUBYVM=jruby rake-compiler-dock   # this enters a container with an interactive shell
    user@5b53794ada92:$ ruby -v
    jruby 9.2.5.0 (2.5.0) 2018-12-06 6d5a228 OpenJDK 64-Bit Server VM 10.0.2+13-Ubuntu-1ubuntu0.18.04.4 on 10.0.2+13-Ubuntu-1ubuntu0.18.04.4 +jit [linux-x86_64]
    user@5b53794ada92:$ bundle
    user@5b53794ada92:$ rake java gem
    user@5b53794ada92:$ exit
    user@host:$ ls pkg/*.gem
    your-gem-1.0.0.gem  your-gem-1.0.0-java.gem

### Add to your Rakefile

To make the build process reproducible for other parties, it is recommended to add rake-compiler-dock to your Rakefile.
This can be done like this:

```ruby
PLATFORMS = %w[
  aarch64-linux-gnu
  aarch64-linux-musl
  arm-linux-gnu
  arm-linux-musl
  arm64-darwin
  x64-mingw-ucrt
  x64-mingw32
  x86-linux-gnu
  x86-linux-musl
  x86-mingw32
  x86_64-darwin
  x86_64-linux-gnu
  x86_64-linux-musl
]
task 'gem:native' do
  require 'rake_compiler_dock'
  sh "bundle package --all"   # Avoid repeated downloads of gems by using gem files from the host.
  PLATFORMS.each do |plat|
    RakeCompilerDock.sh "bundle --local && rake native:#{plat} gem", platform: plat
  end
  RakeCompilerDock.sh "bundle --local && rake java gem", rubyvm: :jruby
end
```

This runs the `bundle` and `rake` commands once for each platform.
That is once for the jruby gems and 6 times for the specified MRI platforms.

### Run builds in parallel

rake-compiler-dock uses dedicated docker images per build target (since rake-compiler-dock-1.0).
Because each target runs in a separate docker container, it is simple to run all targets in parallel.
The following example defines `rake gem:native` as a multitask and separates the preparation which should run only once.
It also shows how gem signing can be done with parallel builds.
Please note, that parallel builds only work reliable, if the specific platform gem is requested (instead of just "rake gem").

```ruby
  namespace "gem" do
    task 'prepare' do
      require 'rake_compiler_dock'
      require 'io/console'
      sh "bundle package --all"
      sh "cp ~/.gem/gem-*.pem build/gem/ || true"
      ENV["GEM_PRIVATE_KEY_PASSPHRASE"] = STDIN.getpass("Enter passphrase of gem signature key: ")
    end

    exttask.cross_platform.each do |plat|
      desc "Build all native binary gems in parallel"
      multitask 'native' => plat

      desc "Build the native gem for #{plat}"
      task plat => 'prepare' do
        RakeCompilerDock.sh <<-EOT, platform: plat
          (cp build/gem/gem-*.pem ~/.gem/ || true) &&
          bundle --local &&
          rake native:#{plat} pkg/#{exttask.gem_spec.full_name}-#{plat}.gem
        EOT
      end
    end
  end
```

### Add to your Gemfile

Rake-compiler-dock uses [semantic versioning](http://semver.org/), so you should add it into your Gemfile, to make sure, that future changes will not break your build.

```ruby
gem 'rake-compiler-dock', '~> 1.2'
```

See [the wiki](https://github.com/rake-compiler/rake-compiler-dock/wiki/Projects-using-rake-compiler-dock) for projects which make use of rake-compiler-dock.

### As a CI System Container

The OCI images provided by rake-compiler-dock can be used without the `rake-compiler-dock` gem or wrapper. This may be useful if your CI pipeline is building native gems.

For example, a Github Actions job might look like this:

``` yaml
jobs:
  native-gem:
    name: "native-gem"
    runs-on: ubuntu-latest
    container:
      image: "ghcr.io/rake-compiler/rake-compiler-dock-image:1.2.2-mri-x86_64-linux-gnu"
    steps:
      - uses: actions/checkout@v2
      - run: bundle install && bundle exec rake gem:x86_64-linux-gnu:rcd
      - uses: actions/upload-artifact@v2
        with:
          name: native-gem
          path: gems
          retention-days: 1
```

Where the referenced rake task might be defined by something like:

``` ruby
cross_platforms = ["x64-mingw32", "x86_64-linux", "x86_64-darwin", "arm64-darwin"]

namespace "gem" do
  cross_platforms.each do |platform|
    namespace platform do
      task "rcd" do
        Rake::Task["native:#{platform}"].invoke
        Rake::Task["pkg/#{rcee_precompiled_spec.full_name}-#{Gem::Platform.new(platform)}.gem"].invoke
      end
    end
  end
end

```

For an example of rake tasks that support this style of invocation, visit https://github.com/flavorjones/ruby-c-extensions-explained/tree/main/precompiled


### Living on the edge: using weekly snapshots

OCI images snapshotted from `main` are published weekly to Github Container Registry with the string "snapshot" in place of the version number in the tag name, e.g.:

- `ghcr.io/rake-compiler/rake-compiler-dock-image:snapshot-mri-x86_64-linux-gnu`

These images are intended for integration testing. They may not work properly and should not be considered production ready.


## Environment Variables

Rake-compiler-dock makes use of several environment variables.

The following variables are recognized by rake-compiler-dock:

* `RCD_RUBYVM` - The ruby VM and toolchain to be used.
    Must be one of `mri`, `jruby`.
* `RCD_PLATFORM` - The target rubygems platform.
    Must be a space separated list out of the platforms listed under "Supported platforms" above.
    It is ignored when `rubyvm` is set to `:jruby`.
* `RCD_IMAGE` - The docker image that is downloaded and started.
    Defaults to "ghcr.io/rake-compiler/rake-compiler-dock-image:IMAGE_VERSION-PLATFORM" with an image version that is determined by the gem version.

The following variables are passed through to the docker container without modification:

* `http_proxy`, `https_proxy`, `ftp_proxy` - See [Frequently asked questions](https://github.com/rake-compiler/rake-compiler-dock/wiki/FAQ) for more details.
* `GEM_PRIVATE_KEY_PASSPHRASE` - To avoid interactive password prompts in the container.

The following variables are provided to the running docker container:

* `RCD_IMAGE` - The full docker image name the container is running on.
* `RCD_HOST_RUBY_PLATFORM` - The `RUBY_PLATFORM` of the host ruby.
* `RCD_HOST_RUBY_VERSION` - The `RUBY_VERSION` of the host ruby.
* `RUBY_CC_VERSION` - The target ruby versions for rake-compiler.
    The default is defined in the [Dockerfile](https://github.com/rake-compiler/rake-compiler-dock/blob/94770238d68d71df5f70abe76097451a575ce46c/Dockerfile.mri.erb#L229), but can be changed as a parameter to rake.
* `RCD_MOUNTDIR` - The directory which is mounted into the docker container.
    Defaults to pwd.
* `RCD_WORKDIR` - The working directory within the docker container.
    Defaults to pwd.

Other environment variables can be set or passed through to the container like this:

```ruby
RakeCompilerDock.sh "rake cross native gem OPENSSL_VERSION=#{ENV['OPENSSL_VERSION']}"
```

### Choosing specific Ruby versions to support

If you only want to precompile for certain Ruby versions, you can specify those versions by overwriting the `RUBY_CC_VERSION` environment variable.

For example, if you wanted to only support Ruby 3.4 and 3.3, you might set this variable to:

``` ruby
ENV["RUBY_CC_VERSION"] = "3.4.1:3.3.7"
```

In practice, though, hardcoding these versions is brittle because the patch versions in the container may very from release to release.

A more robust way to do this is to use `RakeCompilerDock.ruby_cc_version` which accepts an array of Ruby minor versions or patch version requirements.

``` ruby
RakeCompilerDock.ruby_cc_version("3.3", "3.4")
# => "3.4.1:3.3.7"

RakeCompilerDock.ruby_cc_version("~> 3.4.0", "~> 3.3.0")
# => "3.4.1:3.3.7"

RakeCompilerDock.ruby_cc_version("~> 3.3")
# => "3.4.1:3.3.7"
```

So you can either set the environment variable directly:

``` ruby
ENV["RUBY_CC_VERSION"] = RakeCompilerDock.ruby_cc_version("~> 3.1")
```

or do the same thing using the `set_ruby_cc_version` convenience method:

``` ruby
RakeCompilerDock.set_ruby_cc_version("~> 3.1") # equivalent to the above assignment
```



## More information

See [Frequently asked questions](https://github.com/rake-compiler/rake-compiler-dock/wiki/FAQ) and [![Join the chat at https://gitter.im/larskanis/rake-compiler-dock](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/larskanis/rake-compiler-dock?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


## Contributing

1. Fork it ( https://github.com/rake-compiler/rake-compiler-dock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
