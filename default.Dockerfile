FROM python:3.9-slim-bullseye as setup

ENV DEBIAN_FRONTEND=noninteractive

# USD release to download from GitHub
ARG USD_VERSION=22.05a

# Parameters for the build script
# True or False
ARG TUTORIALS=False
ARG EXAMPLES=False
ARG TOOLS=True
ARG PYTHON=True
#ARG USDVIEW=False
#ARG IMAGING=False
#ARG PTEX=False
#ARG OPENVDB=False
#ARG OPENIMAGEIO=False
#ARG OPENCOLORIO=False
#ARG ALEMBIC=False
#ARG HDF5=False
#ARG DRACO=False
#ARG MATERIALX=False

RUN apt-get -q update
RUN apt-get install -yq wget unzip
RUN mkdir $HOME/usd-gen $HOME/usd-inst
RUN wget -q -O $HOME/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip -q $HOME/usd-source.zip -d $HOME/usd-gen/

RUN apt-get install -yq libglew-dev libxrandr-dev libxcursor-dev libxinerama-dev libxi-dev libglib2.0-0
RUN apt-get install -yq python3-setuptools build-essential cmake
RUN pip install PySide2 PyOpenGL
#RUN apt-get install -y --no-install-recommends 	autoconf automake bzip2 		dpkg-dev 		file 		g++ 		gcc 		imagemagick 		libbz2-dev 		libc6-dev 		libcurl4-openssl-dev 		libdb-dev 		libevent-dev 		libffi-dev 		libgdbm-dev 		libglib2.0-dev 		libgmp-dev 		libjpeg-dev 		libkrb5-dev 		liblzma-dev 		libmagickcore-dev 		libmagickwand-dev 		libmaxminddb-dev 		libncurses5-dev 		libncursesw5-dev 		libpng-dev 		libpq-dev 		libreadline-dev 		libsqlite3-dev 		libssl-dev 		libtool 		libwebp-dev 		libxml2-dev 		libxslt-dev 		libyaml-dev 		make 		patch 		unzip 		xz-utils 		zlib1g-dev
RUN python3 $HOME/usd-gen/USD-$USD_VERSION/build_scripts/build_usd.py \
    --build $HOME/usd-gen/build \
    --src $HOME/usd-gen/USD-$USD_VERSION/src/$USD_VERSION $HOME/usd-inst \
    --build_examples $EXAMPLES \
    --build_tutorials $TUTORIALS \
    --build_tools $TOOLS \
    --build_python $PYTHON \
#    --build_usdview=${USDVIEW} \
#    --build_imaging=${IMAGING} \
#    --build_ptex=${PTEX} \
#    --build_openvdb=${OPENVDB} \
#    --build_openimageio=${OPENIMAGEIO} \
#    --build_opencolorio=${OPENCOLORIO} \
#    --build_alembic=${ALEMBIC} \
#    --build_hdf5=${HDF5} \
#    --build_draco=${DRACO} \
#    --build_materialx=${MATERIALX} \
    -v

RUN rm -rf $HOME/usd-gen $HOME/usd-source.zip
RUN apt-get remove -yq wget unzip python3-setuptools build-essential cmake
RUN apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y
#
#FROM scratch as final
CMD ["/bin/bash"]
#COPY --from=setup / /