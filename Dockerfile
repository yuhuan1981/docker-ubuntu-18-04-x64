# This docker file contains build environment
FROM ubuntu:18.04
MAINTAINER Stovba Volodymyr <netpanik@apriorit.com>

ENV DEBIAN_FRONTEND noninteractive

#uncomment all src repositories
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y && apt-get install -y apt-transport-https curl xxd lsb-core bison++ libprocps-dev libxalan-c-dev \
libxerces-c-dev libnl-3-dev subversion gdb libcrypto++-dev libpcre++-dev \
uuid-dev libsnappy-dev build-essential libboost-all-dev cmake maven libicu-dev \
zlib1g-dev liblog4cpp5-dev libncurses5-dev libselinux1-dev wget libsqlite3-dev google-mock \
libvirt-dev libmysqlclient-dev qtbase5-dev qtdeclarative5-dev libblkid-dev giblib-dev libimlib2-dev \
libglib2.0-dev libgtk-3-dev libcanberra-gtk3-dev jq libssl1.0-dev unzip postgresql-client git valgrind

RUN apt-get install -y libgtest-dev
RUN cd /usr/src/gtest/ && cmake . && make && cp *.a /usr/lib

#Install MS ODBC Driver and Libraries
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#Ubuntu 18.04
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update 
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

# optional: for bcp and sqlcmd
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools
# optional: for unixODBC development headers
RUN apt-get -y install unixodbc-dev

#Install postgres odbc and replace relative path by full path to odbc driver (fix not found odbc driver error)
RUN apt-get -y install odbc-postgresql && sed -i 's/psqlodbcw.so/\/usr\/lib\/x86_64-linux-gnu\/odbc\/psqlodbcw.so/g' /etc/odbcinst.ini

# poco
RUN cd /tmp && git clone -b "poco-1.9.0" https://github.com/pocoproject/poco.git && cd poco/ && mkdir cmake-build && cd cmake-build && sed -i '/project(Poco)/a SET(CMAKE_INSTALL_RPATH "\$ORIGIN")' ../CMakeLists.txt && cmake .. -DCMAKE_BUILD_TYPE=RELEASE && cmake --build . && make DESTDIR=/opt/apriorit-poco all install

# grpc depends
RUN apt-get -y install build-essential autoconf libtool pkg-config libgflags-dev libgtest-dev clang libc++-dev

# grpc
RUN cd /tmp && git clone -b "v1.13.x" https://github.com/grpc/grpc && cd grpc && git submodule update --init && make && make install && cd third_party/protobuf && make install

