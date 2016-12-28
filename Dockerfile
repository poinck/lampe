FROM ubuntu:15.10

RUN apt-get clean && \
    apt-get update && \
    apt-get -y install \
               libsoup2.4-dev \
               libgtk-3-dev \
               libjson-glib-dev \
               valac \
               make \
               gcc \
               apt-utils \
               libgl1-mesa-glx \
               libglapi-mesa \
               git

RUN git clone https://github.com/poinck/lampe.git && \
    cd lampe && \
    make && \
    make install

CMD /lampe/lampe-gtk
