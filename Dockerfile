# syntax=docker/dockerfile:1

########## PREPARATION STAGES

FROM ubuntu:20.04 as base
FROM base as prepare

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    build-essential \
    cmake

RUN mkdir "/usd-setup"
RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ARG USD_VERSION
RUN wget -q -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip -q /usd-setup/usd-source.zip -d /usd-setup

########## BUILD STAGES

FROM prepare as build-default

RUN  apt-get install -y \
    python3-dev \
    glew-utils

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
    /opt/PixarAnimationStudios/USD

RUN rm -rf /opt/PixarAnimationStudios/USD/build && rm -rf /opt/PixarAnimationStudios/USD/src

FROM prepare as build-usdview

ENV DISPLAY=host.docker.internal:0.0

RUN  apt-get install -y \
    python3-dev \
    python3-pip \
    glew-utils \
    qt5-default

RUN pip install PyOpenGL PySide2 numpy

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py \
    --no-tests \
    --examples \
    --tutorials \
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
    /opt/PixarAnimationStudios/USD

RUN rm -rf /opt/PixarAnimationStudios/USD/build && rm -rf /opt/PixarAnimationStudios/USD/src

########## FINALIZATION STAGES

FROM base as default

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-dev \
    glew-utils

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-default /opt/PixarAnimationStudios/USD /opt/PixarAnimationStudios/USD

CMD ["/bin/bash"]

FROM base as usdview

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=host.docker.internal:0.0

RUN apt-get update && apt-get install -y \
    python3-pip \
    glew-utils \
    qt5-default

RUN pip install PyOpenGL PySide2

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-usdview /opt/PixarAnimationStudios/USD /opt/PixarAnimationStudios/USD

CMD ["usdview","/opt/PixarAnimationStudios/USD/share/usd/tutorials/traversingStage/HelloWorld.usda"]