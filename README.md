# USD-container
This is a containerized version of the [Universal Scene Description](https://graphics.pixar.com/usd/) toolset developed by Pixar.
Official sources for USD do not offer any compiled binaries which makes this container image a quick and easy to use alternative to building the tools yourself.
It can also be used for automating workflows. 
The image is based on `Ubuntu:20.04` image and the versioning follows the versioning of USD itself.

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

# Flavors
This image comes in different flavors, indicated by the the suffix behind their tag, for example `22.03-usdview`.
The different flavors come with different configurations of USD:

| Suffix  | tools | python | examples | tutorials | usdview (experimental) | text editor (for `usdedit`) |
| ---  | --- | --- | --- | --- | --- | --- |
| (none) | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | nano |
| `-python`  | ❌ | ✔️ | ❌ | ❌ | ❌ | ❌ |
| `-usdview`  | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | gedit |

# USDview
The default version of this image does not contain the graphical USDview application.
However, there is a separate (experimental) tag with the `-usdview` suffix which does launching the USDview utility using the `usdview` command.
This may require the use of an external X11 client like [vcxsrv](https://sourceforge.net/projects/vcxsrv/).
More examples and documentation regarding USDview will follow at a later point.
![USDview running on Windows 10 via Docker Desktop and vcxsrv.](https://user-images.githubusercontent.com/31403260/175355715-c4e0eda3-67b7-4983-a836-e55ae35157f6.png)

# Building the image yourself

The Dockerfile uses the [multi-stage-build](https://docs.docker.com/develop/develop-images/multistage-build/) feature to allow building the different flavors.
Different flavors can be passed as build targets (`default`/`python`/`usdview`). In addition, the `USD_VERSION` build argument must be set as well.
Here are a few examples for possible build commands:
```
# Builds and image with the USD tools, python3 and example/tutorial files.
docker build --build-arg USD_VERSION=21.11 --target=default -t usd:21.11 .

# Builds and image with the USD tools, python3, example/tutorial and the usdview application files.
docker build --build-arg USD_VERSION=22.05a --target=usdview -t usd:22.05a-usdview .
```
# Credits/Licenses
[Pixar USD](https://github.com/PixarAnimationStudios/USD/blob/release/LICENSE.txt)
