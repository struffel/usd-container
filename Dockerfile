# syntax=docker/dockerfile:1

FROM ubuntu:22.10 as base

ARG USD_VERSION
ARG APT_PYTHON_VERSION=3.10.*
ARG APT_CMAKE_VERSION=3.24.*

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=host.docker.internal:0.0

########## PREPARATION STAGES

FROM base as prepare-build

RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    build-essential \
    cmake=$APT_CMAKE_VERSION

RUN mkdir "/usd-setup"
RUN mkdir -p "/opt/PixarAnimationStudios/USD"

RUN wget -q -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip -q /usd-setup/usd-source.zip -d /usd-setup

########## BUILD STAGES

FROM prepare-build as build-default

RUN  apt-get install -y \
    python3-dev=$APT_PYTHON_VERSION \
    libc6 \
    libgl1 \
    libglew2.2

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py \
    --no-tests \
    --examples \
    --tutorials \
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

FROM prepare-build as build-usdview

ENV DISPLAY=host.docker.internal:0.0

RUN  apt-get install -y \
    python3-dev=$APT_PYTHON_VERSION \
    python3-pip\
    libc6 \
    libgl1 \
    libglew2.2 \
    libx11-6 \
    qtchooser \
	qtbase5-dev

RUN pip install PyOpenGL PySide6 numpy

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

FROM prepare-build as build-python

RUN  apt-get install -y \
    python3-dev=$APT_PYTHON_VERSION \
    libc6 \
    libgl1 \
    libglew2.2

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py \
    --no-tests \
    --no-examples \
    --no-tutorials \
    --no-tools \
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

########## FINALIZATION STAGES

FROM base as usdview

RUN apt-get update && apt-get install -y \
    python3-pip \
    libc6 \
    libgl1 \
    libglew2.2 \
    libx11-6 \
    qtbase5-dev \
	qtchooser \
    gedit

RUN pip install PyOpenGL PySide6 numpy

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV EDITOR="gedit"
ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-usdview /opt/PixarAnimationStudios/USD /opt/PixarAnimationStudios/USD
WORKDIR "/home"

CMD ["usdview","/opt/PixarAnimationStudios/USD/share/usd/tutorials/traversingStage/HelloWorld.usda"]

FROM base as python

RUN apt-get update && apt-get install -y \
    python3-dev=$APT_PYTHON_VERSION \
    libc6 \
    libgl1 \
    libglew2.2

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-python /opt/PixarAnimationStudios/USD /opt/PixarAnimationStudios/USD
WORKDIR "/home"

CMD ["python3"]

FROM base as default

RUN apt-get update && apt-get install -y \
    python3-dev=$APT_PYTHON_VERSION \
    libc6 \
    libgl1 \
    libglew2.2 \
    nano

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV EDITOR="nano"
ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=build-default /opt/PixarAnimationStudios/USD /opt/PixarAnimationStudios/USD
WORKDIR "/home"

CMD ["/bin/bash"]