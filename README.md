# USD-container
This is a containerized version of the [Universal Scene Description](https://graphics.pixar.com/usd/) toolset developed by Pixar.
Official sources for USD do not offer any compiled binaries which makes this container image a quick and easy to use alternative to building the tools yourself.
It can also be used for automating workflows. The versioning of this image follows the versioning of USD itself.

# Using this image
This image is publicly available on the [Docker Hub](https://hub.docker.com/r/struffel/pixar-usd) from where it can be pulled using the `docker pull` command:
```
# Pull the image
docker pull struffel/pixar-usd:22.03

# Run the image
# (The image starts a shell from which the usd toolkit and python3 can be started.)
docker run -it --rm struffel/pixar-usd:22.03

```
Documentation on the available tools can be found on [Pixar's website](https://graphics.pixar.com/usd/release/toolset.html).


# USDview
The default version of this image does not contain the graphical USDview application.
However, there is a separate (experimental) tag with the `-usdview` suffix which does launching the USDview utility using the `usdview` command.
This may require the use of an external X11 client like [vcxsrv](https://sourceforge.net/projects/vcxsrv/).
More examples and documentation regarding USDview will follow at a later point.

# Building the image yourself

The Dockerfile uses the [multi-stage-build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to allow building several versions of the image based on the official `Ubuntu:20.04` image.
Different versions can be passed as build targets. In addition, the `USD_VERSION` build argument must be set as well.
Here are a few examples for possible build commands:
```
# Builds and image with the USD tools, python3 and example/tutorial files.
docker build --build-arg USD_VERSION=21.11 --target=default -t usd:21.11 .

# Builds and image with the USD tools, python3, example/tutorial and the usdview application files.
docker build --build-arg USD_VERSION=22.05a --target=usdview -t usd:22.05a-usdview .
```
