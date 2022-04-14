# syntax=docker/dockerfile:1
# --- BUILD PIXAR USD ---

FROM ubuntu:22.04 as setup-usd

ENV DEBIAN_FRONTEND=noninteractive
ARG USD_VERSION

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    unzip \
    wget \
    python3-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev

RUN mkdir "/usd-setup"
RUN mkdir "/usd-artifacts"

RUN wget -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip /usd-setup/usd-source.zip -d /usd-setup

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py -v --no-examples --no-tutorials --tools --python --no-usdview --no-imaging --no-ptex --no-openvdb --no-openimageio --no-opencolorio --no-alembic --no-hdf5 --no-draco --no-materialx /usd-artifacts
RUN rm -rf /usd-artifacts/build
RUN rm -rf /usd-artifacts/src

# --- BUILD FINAL IMAGE ---

FROM ubuntu:22.04 as final

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-dev \
	libglu1-mesa \
	freeglut3 \
	unzip

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=setup-usd /usd-artifacts /opt/PixarAnimationStudios/USD/