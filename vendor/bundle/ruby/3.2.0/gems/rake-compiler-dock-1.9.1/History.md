# `rake-compiler/rake-compiler-dock` Changelog

## v1.9.1 / 2025-01-20

### Features

- Introduce `RakeCompilerDock.set_ruby_cc_version` to make it easier to set `RUBY_CC_VERSION` without hardcoding specific patch-level ruby versions. See the README for more deteails. #149, #150 @flavorjones


## v1.9.0 / 2025-01-19

### Changes

- Bump Ruby 3.3 to v3.3.7 (from v3.3.5). #147 @flavorjones
- The default `rbenv` ruby in the container is now Ruby v3.4.1 (previously the default was 3.1.6), which allows gems to drop Ruby 3.1 from their gemspecs. Fixes #145. #146 @flavorjones
- Ruby 3.4.x, 3.3.x, 3.2.x, 3.1.x, and 3.0.x are cross-compiled using Ruby v3.4.1. #146 @flavorjones

### CRuby container summary

- native rubies: 3.4.1 (default), 3.1.6, 2.5.9
- `RUBY_CC_VERSION=3.4.1:3.3.7:3.2.6:3.1.6:3.0.7:2.7.8:2.6.10:2.5.9:2.4.10`


## v1.8.0 / 2025-01-05

### Notable changes

All versions of Ruby in the build containers are the latest patch version. #135 @flavorjones
- `RUBY_CC_VERSION=3.4.1:3.3.5:3.2.6:3.1.6:3.0.7:2.7.8:2.6.10:2.5.9:2.4.10`

### Other changes

- Base ruby updated to v3.1.6 (from v3.1.3), which is now the default `rbenv` ruby.
- (Darwin) Set `OSXCROSS_PKG_CONFIG_USE_NATIVE_VARIABLES=1` to successfully build the 3.0 series.
- (Darwin) The linker flags include `-Wl,-flat_namespace` for 2.7, 3.0, 3.1, 3.2, 3.3, and 3.4 rubies. Previously this was only needed for 3.2+, but code backported to 2.7.7, 3.0.5, and 3.1.3 required it for those versions as well.

### CRuby container summary

- native rubies: 3.1.6 (default), 2.5.9
- `RUBY_CC_VERSION=3.4.1:3.3.5:3.2.6:3.1.6:3.0.7:2.7.8:2.6.10:2.5.9:2.4.10`


## v1.7.1 / 2025-01-03

- Bump rake-compiler dependency to v1.2.9 (from v1.2.5).
- Bump Ruby to v3.4.1 (from v3.4.0) to address `ruby_abi_version` issues.


## v1.7.0 / 2024-12-25

### Ruby 3.4 support

- Add Ruby 3.4.0 cross-compilation support.


## v1.7.0.rc1 / 2024-12-13

### Ruby 3.4 support

- Add Ruby 3.4.0-rc1 cross-compilation support.


## v1.6.0 / 2024-12-13

### Notable changes

#### Standardizing all Linux build images on Ubuntu

In this release, we upgraded the base image for the `x86_64-linux-gnu` and `x86-linux-gnu` images from `manylinux2014` to `ubuntu:20.04`. (`manylinux2014` reached end-of-life earlier this year.) As a result, all of the build images are using the same base image, simplifying things considerably. (#122, #126) @flavorjones

⚠ **Note** there are two important changes due to this upgrade:

1. The minimum supported version of GLIBC for the `x86*-linux-gnu` images has increased from 2.17 to 2.29 for `x86_64` and `x86` architectures. (Note that GLIBC was already pinned to 2.29 for ARM architectures.)
2. Precompiled gems built with the `x86*linux-gnu` images are less likely to be compatible with Musl libc, and may segfault when run on Musl systems.

For (2) above, if you have been shipping a single `x86_64-linux` native gem for both GNU and Musl systems, **please make sure you test your gems on a Musl system before shipping them**. See the [actions workflow in flavorjones/ruby-c-extensions-explained](https://github.com/flavorjones/ruby-c-extensions-explained/blob/6619a0d94e627897838a79144704387db65a03bc/.github/workflows/precompiled.yml#L137) for an example of how to do this rigorously.


#### Ruby 3.3 support upgraded to `3.3.5`

Update Ruby 3.3 support from 3.3.0-rc1 to 3.3.5. Note that the 3.3.x releases are not usable until 3.3.5 because of https://bugs.ruby-lang.org/issues/20088.

⚠ **Note** that if you were specifying `3.3.0` in your `RUBY_CC_VERSION` environment variable, that string must be updated to `3.3.5`.


### Added

- Add support for the `SOURCE_DATE_EPOCH` environment variable, which can be used to create reproducible builds. (#128) @segiddins


## 1.5.2 / 2024-07-30

With CentOS 7 becoming EOL as of 2024-06-30, `yum` will no longer work in the `x86_64-linux-gnu` and
`x86-linux-gnu` images shipped with v1.5.1 and earlier.

In this release, we've updated the `manylinux2014` base image for the `x86_64-linux-gnu` and
`x86-linux-gnu` images to point at a version patched by `pypa` to use valid yum mirrors. See
https://github.com/pypa/manylinux/pull/1628 for more information.


## 1.5.1 / 2024-06-03

### Improvements

The `x86_64-linux-gnu` and `x86-linux-gnu` containers (based on `manylinux_2014`) now have a modern version of `pkg-config`, v0.29.2, installed on them in `/usr/local/bin/pkg-config`. The distro's version (v0.27.1) is still in `/usr/bin/pkg-config` if you need to fall back for some reason, but the newer version will be used by default and should be backwards-compatible. (#121, #123 by @flavorjones)


## 1.5.0 / 2024-02-25

### Notable changes

#### First-class Linux `musl` libc support

* Add Linux musl cross build targets `aarch64-linux-musl`, `arm-linux-musl`, `x86-linux-musl`, and `x86_64-linux-musl`. #75, #111 (@flavorjones)
* Add Linux cross build targets `aarch64-linux-gnu`, `arm-linux-gnu`, `x86-linux-gnu`, and `x86_64-linux-gnu`. #111 (@flavorjones)
* The cross build targets `aarch64-linux`, `arm-linux`, `x86-linux`, and `x86_64-linux` are now aliases for the `*-linux-gnu` targets. #111 (@flavorjones)

**Please read the README for details and caveats!**


### Improvements

* Predefined user and group list is more complete, and represents the union of users and groups across all RCD images.


### Changes to build containers

* Replace `rvm` with `rbenv` and `ruby-build` in the build containers.
  - `rvm` has been replaced by `rbenv` and `ruby-build`
    - no longer applying sendfile patches to bootstrap rubies
    - no longer updating gems belonging to the bootstrap rubies
  - user `rvm` no longer exists, replaced by `rubyuser`

Users of the `rake-compiler-dock` gem should not be affected by this change. However, users of the raw containers may be affected if there are assumptions about `rvm`.


1.4.0 / 2023-12-27
------------------

* Add Ruby 3.3.0-rc1 cross-compilation support. #109, #105 (@flavorjones)
* Update to rake-compiler 1.2.5. #108 (@flavorjones)


1.3.1 / 2023-10-14
------------------

* In the container, `strip` will re-codesign binaries on darwin. #104 (@flavorjones)
* Update to rake-compiler 1.2.2. #101 (@flavorjones)


1.3.0 / 2023-01-11
------------------

* Add Ruby 3.2 cross-compilation support.
* Update RVM installations to latest rubygems.
* Update to rake-compiler 1.2.1.
* Reduce pre-installed gems to only rake-compiler and bundler.
* Install yaml and ffi development headers in the base images, for psych and ffi gem compilation.
* Ensure autoconf is installed in the base iamges.
* Bump JRuby to 9.4.0.0
* Move docker images to ghcr.io/rake-compiler:
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-jruby`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-aarch64-linux`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-arm-linux`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-arm64-darwin`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x64-mingw-ucrt`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x64-mingw32`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x86-linux`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x86-mingw32`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x86_64-darwin`
  * `ghcr.io/rake-compiler/rake-compiler-dock-image:1.3.0-mri-x86_64-linux`
* Start publishing weekly image snapshots.


1.2.2 / 2022-06-27
------------------

* Fix ucrt libruby file naming for static build. #69


1.2.1 / 2022-03-17
------------------

* Fix testing for ruby C-API functions in mkmf. #65, #67
* Use openjdk 11 to make maven work on ubuntu 20.04. #64
* Remove x86_64-w64-mingw32-pkg-config from the x64-mingw-ucrt image. #63
* Add a patch for math.h to use gcc builtins and to improve compat with `musl` libc-based systems. #42


1.2.0 / 2022-01-04
------------------

* Add Ruby-3.1 as native rvm and cross ruby versions.
* Remove Ruby-2.2 and 2.3 from RUBY_CC_VERSION and cross rubies.
* Add Linux cross build targets "arm-linux" and "aarch64-linux".
* Add cross build target "x64-mingw-ucrt" for ruby-3.1 on Windows.
* Add `wget` and `git` to Linux image.
* Add `maven` to JRuby image.
* Update JRuby to 9.3.2.0
* Fix default value of platform for JRuby. #50
* Update openjdk version from 14 to 17
* Add a test gem and build and run it on all supported platforms on Github Actions.
* Allow alternative build command like `docker buildx build`
* Provide compiler-rt libraries for darwin builds. #60
* Extract build environment from `runas` into `rcd-env.sh` and loaded it in non-interactive non-login shells. #57


1.1.0 / 2020-12-29
------------------

* Use ManyLinux2014 as docker base image for linux targets.
  That way compatibility to very old linux dists can be provided, while still using modern compilers.
* Add macOS cross build targets "x86_64-darwin" and "arm64-darwin".
  They are based on MacOSX-SDK-11.1
* Add Ruby-3.0 as native rvm and cross ruby version.
* Remove Ruby-2.2 from RUBY_CC_VERSION and cross rubies.
* Update to Ubuntu-20.04 for Mingw and JRuby targets.
* Set `ExtensionTask#no_native=true` to fix issues with cross_compiling callback not being called.
  See discussion here: https://github.com/rake-compiler/rake-compiler/pull/171
* Allow setting an alternative dockerhub user per `DOCKERHUB_USER`.


1.0.1 / 2020-01-13
------------------

* Fix error when using rake-compiler-dock on non-tty STDIN. #31


1.0.0 / 2020-01-04
------------------
* Add ruby-2.7.0 cross ruby.
* Use per-target docker images.
  There are currently 5 docker images:
  * larskanis/rake-compiler-dock-mri-x86-mingw32
  * larskanis/rake-compiler-dock-mri-x64-mingw32
  * larskanis/rake-compiler-dock-mri-x86-linux
  * larskanis/rake-compiler-dock-mri-x86_64-linux
  * larskanis/rake-compiler-dock-jruby

  Since every image has only the taget specific compilers and rubies, care has to be taken, that only rake tasks are triggered, that belong to the specific target.
  See the README.md for more information.
* Ensure the separate docker images always use as much as possible common docker images layers to avoid increased download sizes.
* Pass GEM_PRIVATE_KEY_PASSPHRASE to the container.
* Update JRuby to 9.2.9.0 and native CRuby to 2.5.7.
* Create empty ~/.gem to be used for gem signing key.
* Ensure terminal is in cooked mode after build.
  This fixes terminal misconfiguration after parallel builds.
* Raise Windows-API to Vista (affects ruby < 2.6 only)
* Use posix pthread for mingw so that C++ standard library for thread could be available such as std::thread, std::mutex, so on.
* Make the system to have GLIBC 2.12 instead of 2.23 so that generated ruby package can run on CentOS 6 with GLIBC 2.12


0.7.2 / 2019-03-18
------------------
* Fix missing libruby.a of cross rubies. Fixes #26
* Downgrade to Ubuntu-16.04 for MRI base image. Fixes #25


0.7.1 / 2019-01-27
------------------
* Add bundler-2.x to image and keep bundler-1.x for compatibility with projects using a `Gemfile.lock` generated by bundler-1.x .


0.7.0 / 2018-12-26
------------------
* Add docker image for JRuby extensions, new option `:rubyvm` and `RCD_RUBYVM` environment variable
* Add ruby-2.6.0 cross ruby
* Remove ruby-2.0 and ruby-2.1 cross ruby
* Fix compatibility with JRuby on the host
* Update base image to Ubuntu-18.04.
* Update native ruby version to 2.5.3


0.6.3 / 2018-02-06
------------------
* Update base image to Ubuntu-17.10. Fixes #19, #17
* Update native ruby version to 2.5.0


0.6.2 / 2017-12-25
------------------
* Add ruby-2.5.0 cross ruby
* Update native ruby version to 2.4.3


0.6.1 / 2017-06-03
------------------
* Update base image from Ubuntu-16.10 to 17.04
* Update perinstalled gems (this solves an version conflict between hoe and rake)
* Update native ruby version


0.6.0 / 2016-12-26
------------------
* Remove Windows cross build environments for Ruby < 2.0.
* Add Windows cross build environment for Ruby-2.4.
* Add Linux cross build environment for Ruby-2.0 to 2.4.
* Update Windows gcc to 6.2.
* Update docker base image to Ubuntu-16.10.
* Update native rvm based ruby to 2.4.0.
* Respect MACHINE_DRIVER environment variable for docker-machine. #15
* Add RCD_WORKDIR and RCD_MOUNTDIR environment variables. #11
* Ignore non-unique UID or GID. #10


0.5.3 / 2016-09-02
------------------
* Fix 'docker-machine env' when running in Windows cmd shell


0.5.2 / 2016-03-16
------------------
* Fix exception when group id can not be retrieved. #14


0.5.1 / 2015-01-30
------------------
* Fix compatibility issue with bundler. #8
* Add a check for the current working directory on boot2docker / docker-machine. #7


0.5.0 / 2015-12-25
------------------
* Add cross ruby version 2.3.0.
* Replace RVM ruby version 2.2.2 with 2.3.0 and set it as default.
* Add support for docker-machine in addition to deprecated boot2docker.
* Drop runtime support for ruby-1.8. Cross build for 1.8 is still supported.


0.4.3 / 2015-07-09
------------------
* Ensure the user and group names doesn't clash with names in the image.


0.4.2 / 2015-07-04
------------------
* Describe use of environment variables in README.
* Provide RCD_IMAGE, RCD_HOST_RUBY_PLATFORM and RCD_HOST_RUBY_VERSION to the container.
* Add unzip tool to docker image.


0.4.1 / 2015-07-01
------------------
* Make rake-compiler-dock compatible to ruby-1.8 to ease the usage in gems still supporting 1.8.
* Use separate VERSION and IMAGE_VERSION, to avoid unnecessary image downloads.
* Finetune help texts and add FAQ links.


0.4.0 / 2015-06-29
------------------
* Add support for OS-X.
* Try boot2docker init and start, when docker is not available.
* Add colorized terminal output.
* Fix usage of STDIN for sending data/commands into the container.
* Limit gemspec to ruby-1.9.3 or newer.
* Allow spaces in user name and path on the host side.


0.3.1 / 2015-06-24
------------------
* Add :sigfw and :runas options.
* Don't stop the container on Ctrl-C when running interactively.
* Workaround an issue with sendfile() leading to broken files when using boot2docker on Windows.


0.3.0 / 2015-06-17
------------------
* Workaround an issue with broken DLLs when building on Windows.
* Print docker command line based on verbose flag of rake.
* Add check for docker and instructions for install.


0.2.0 / 2015-06-08
------------------
* Add a simple API for running commands within the rake-compiler-dock environment.
* Respect ftp, http and https_proxy settings from the host.
* Add wget to the image


0.1.0 / 2015-05-27
------------------
* first public release
