# syntax=docker/dockerfile:1

FROM ubuntu:22.04 as setup

ENV DEBIAN_FRONTEND=noninteractive
ARG USD_VERSION

RUN apt-get update && apt-get install -y \
    gcc \
    cmake \
    python3-dev \
    python3-pip \
    python-setuptools \
    libglew-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxi-dev

RUN pip install PySide2 PyOpenGL

RUN mkdir "/usd-setup"
RUN mkdir "/usd-artifacts"

RUN wget -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip /usd-setup/usd-source.zip -d /usd-setup

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py -v --no-examples --no-tutorials --tools --python --no-usdview --no-imaging --no-ptex --no-openvdb --no-openimageio --no-opencolorio --no-alembic --no-hdf5 --no-draco --no-materialx /usd-artifacts
RUN rm -rf /usd-artifacts/build && rm -rf /usd-artifacts/src