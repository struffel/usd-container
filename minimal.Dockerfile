# --- BUILD PIXAR USD ---

FROM ubuntu:20.04 as setup-usd

ENV DEBIAN_FRONTEND=noninteractive
ENV USD_VERSION=21.11

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    unzip \
    wget \
    python3-dev \
    #libglu1-mesa-dev \
    #freeglut3-dev \
    #mesa-common-dev

RUN mkdir "/usd-setup"
RUN mkdir "/usd-artifacts"

RUN wget -O /usd-setup/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip /usd-setup/usd-source.zip -d /usd-setup

RUN python3 /usd-setup/USD-$USD_VERSION/build_scripts/build_usd.py --no-usdview /usd-artifacts
RUN rm -rf /usd-artifacts/build && rm -rf /usd-artifacts/src

# --- BUILD FINAL IMAGE ---

FROM ubuntu:20.04 as final

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-dev

RUN mkdir -p "/opt/PixarAnimationStudios/USD"

ENV PATH="/opt/PixarAnimationStudios/USD/bin:$PATH"
ENV PYTHONPATH="/opt/PixarAnimationStudios/USD/lib/python:$PYTHONPATH"

COPY --from=setup-usd /usd-artifacts /opt/PixarAnimationStudios/USD/

CMD /bin/bash