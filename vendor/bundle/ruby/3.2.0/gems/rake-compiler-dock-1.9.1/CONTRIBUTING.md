# Contributing

This document is intended for the rake-compiler-dock contributors.

## Cutting a release

- prep
  - [ ] make sure CI is green!
  - [ ] update `History.md` and `lib/rake_compiler_dock/version.rb`
  - [ ] commit and create a git tag
- option 1: build locally
  - build
    - [ ] run the steps below to generate the images locally
    - [ ] run `gem build rake-compiler-dock`
  - push
    - [ ] run `bundle exec rake release:images`
    - [ ] run `gem push pkg/rake-compiler-dock*gem`
    - [ ] run `git push && git push --tags`
- option 2: build with github actions
  - build and push images from github actions
    - [ ] run `git push && git push --tags`
    - [ ] wait for CI to go green on the tag
    - [ ] go to the [release-images pipeline][] and run the workflow on the tag
  - build the gem locally and push it
    - [ ] locally, run `gem build rake-compiler-dock`
    - [ ] run `gem push pkg/rake-compiler-dock*gem`
- announce
  - [ ] create a release at https://github.com/rake-compiler/rake-compiler-dock/releases

[release-images pipeline]: https://github.com/rake-compiler/rake-compiler-dock/actions/workflows/release-images.yml


## Building a versioned image

We want to preserve the cache if we can, so patch releases don't change _all_ the layers. There are a few ways to do this.


### Using local docker

If you're going to keep your local docker cache, around, you can run things in parallel:

```
bundle exec rake build
```


### Use a custom docker command

If you're a pro and want to run a custom command and still run things in parallel:

```
export RCD_DOCKER_BUILD="docker build --arg1 --arg2"
bundle exec rake build
```


### Using the buildx backend and cache

Here's one way to leverage the buildx cache, which will turn off parallel builds but generates an external cache directory that can be saved and re-used:

```
export RCD_USE_BUILDX_CACHE=t
docker buildx create --use --driver=docker-container
bundle exec rake build
```

