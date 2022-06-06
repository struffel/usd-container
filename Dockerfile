# syntax=docker/dockerfile:1

########## DOWNLOAD STAGE

FROM ubuntu:20.04 as download

ENV DEBIAN_FRONTEND=noninteractive
ARG USD_VERSION

RUN apt-get update && apt-get install -y \
    unzip \
    wget 

RUN mkdir "/usd-setup"
RUN mkdir "/usd-artifacts"

RUN wget -q -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip -q /usd-setup/usd-source.zip -d /usd-setup

########## BUILD STAGES

FROM download as build-default

RUN  apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    libgl-dev 

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py \
    --no-tests \
    --no-examples \
    --no-tutorials \
    --tools \
    --no-docs \
    --python \
    --no-debug-python \
    --no-imaging \
    --no-ptex \
    --no-openvdb \
    --no-usdview \
    --no-embree \
    --no-prman \
    --no-openimageio \
    --no-alembic \
    --no-hdf5 \
    --no-draco \
    --no-materialx \
    /usd-artifacts

RUN rm -rf /usd-artifacts/build && rm -rf /usd-artifacts/src

FROM download as build-usdview

ENV DISPLAY=host.docker.internal:0.0

RUN  apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    python3-pip \
    libgl-dev \
    libglib2.0-0 \
    qt5-default

RUN pip install PyOpenGL PySide2

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py \
    --no-tests \
    --no-examples \
    --no-tutorials \
    --tools \
    --no-docs \
    --python \
    --no-debug-python \
    --usd-imaging \
    --no-ptex \
    --no-openvdb \
    --usdview \
    --no-embree \
    --no-prman \
    --no-openimageio \
    --no-alembic \
    --no-hdf5 \
    --no-draco \
    --no-materialx \
    /usd-artifacts

RUN rm -rf /usd-artifacts/build && rm -rf /usd-artifacts/src

########## FINALIZATION STAGE

FROM ubuntu:20.04 as default

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-dev \
    libgl-dev

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-default /usd-artifacts /opt/PixarAnimationStudios/USD/

CMD /bin/bash

FROM ubuntu:20.04 as usdview

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=host.docker.internal:0.0

RUN apt-get update && apt-get install -y \
    python3-pip \
    libgl-dev \
    libglib2.0-0 \
    qt5-default

RUN pip install PyOpenGL PySide2

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-usdview /usd-artifacts /opt/PixarAnimationStudios/USD/

CMD /bin/bash