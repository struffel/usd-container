FROM centos:7.9.2009

RUN yum install -y wget unzip

RUN mkdir $HOME/usd-gen $HOME/usd-inst
RUN wget -q -O $HOME/usd-source.zip https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v$USD_VERSION.zip
RUN unzip -q $HOME/usd-source.zip -d $HOME/usd-gen/

RUN yum install -y gcc gcc-c++ make 
