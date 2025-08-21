Docker image with compilers for ruby platform x64-mingw-ucrt
------------------

This Dockerfile builds compilers for Windows UCRT target.
It takes the mingw compiler provided by Debian/Ubuntu and configures and compiles them for UCRT.
Outputs are *.deb files of binutils, gcc and g++.
Rake-compiler-dock reads them from this image as part of its build process for the x64-mingw-ucrt platform.

The image is provided for arm64 and amd64 architectures.
They are built by the following command:

```sh
docker buildx build . -t larskanis/mingw64-ucrt:20.04 --platform linux/arm64,linux/amd64 --push
```


Create builder instance for two architectures
------------------

Building with qemu emulation fails currently with a segfault, so that it must be built by a builder instance with at least one remote node for the other architecture.
Building on native hardware is also much faster (~30 minutes) than on qemu.
A two-nodes builder requires obviously a ARM and a Intel/AMD device.
It can be created like this:

```sh
# Make sure the remote instance can be connected
$ docker -H ssh://isa info

# Create a new builder with the local instance
$ docker buildx create --name isayoga

# Add the remote instance
$ docker buildx create --name isayoga --append ssh://isa

# They are inactive from the start
$ docker buildx ls
NAME/NODE      DRIVER/ENDPOINT                   STATUS     BUILDKIT   PLATFORMS
isayoga        docker-container
 \_ isayoga0    \_ unix:///var/run/docker.sock   inactive
 \_ isayoga1    \_ ssh://isa                     inactive
default*       docker
 \_ default     \_ default                       running    v0.13.2    linux/arm64

# Bootstrap the instances
$ docker buildx inspect --bootstrap --builder isayoga

# Set the new builder as default
$ docker buildx use isayoga

# Now it should be default and in state "running"
$ docker buildx ls
NAME/NODE      DRIVER/ENDPOINT                   STATUS    BUILDKIT   PLATFORMS
isayoga*       docker-container
 \_ isayoga0    \_ unix:///var/run/docker.sock   running   v0.18.2    linux/arm64
 \_ isayoga1    \_ ssh://isa                     running   v0.18.2    linux/amd64, linux/amd64/v2, linux/amd64/v3, linux/386
default        docker
 \_ default     \_ default                       running   v0.13.2    linux/arm64
```
