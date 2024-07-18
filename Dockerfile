ARG JAVA_VERSION=21

FROM amazoncorretto:${JAVA_VERSION}-al2023

WORKDIR /build

ARG SWIPL_VERSION=9.3.8

RUN dnf install -y \
  gcc \
  gcc-c++ \
  git \
  tar \
  gzip \
  cmake \
  ninja-build \
  libunwind \
  gperftools-devel \
  freetype-devel \
  gmp-devel \
  jpackage-utils \
  libICE-devel \
  libjpeg-turbo-devel \
  libSM-devel \
  ncurses-devel \
  openssl-devel \
  pkgconfig \
  readline-devel \
  libedit-devel \
  zlib-devel \
  uuid-devel \
  libarchive-devel \
  libyaml-devel &> /dev/null

RUN mkdir -p /var/task && \
    git clone https://github.com/SWI-Prolog/swipl-devel.git && \
    cd swipl-devel && \
    git checkout V${SWIPL_VERSION} && \
    git submodule update --init && \
    git submodule update --init packages/jpl && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=PGO \
          -DSWIPL_PACKAGES_X=OFF \
          -DSWIPL_PACKAGES_ODBC=OFF \
          -DBUILD_TESTING=OFF \
          -DINSTALL_TESTS=OFF \
          -DINSTALL_DOCUMENTATION=OFF \
          -DSWIPL_SHARED_LIB=ON \
          -DUSE_TCMALLOC=OFF \
          -DCMAKE_INSTALL_PREFIX=/var/task \
          -G Ninja \
          .. && \
    ninja && \
    ninja install

FROM public.ecr.aws/lambda/java:${JAVA_VERSION}
RUN dnf install -y \
  libedit && \
  dnf clean all  &> /dev/null
COPY --from=0 /var/task/lib /var/task/lib
ENV SWI_HOME_DIR=/var/task/lib/swipl
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/var/task/lib/swipl/lib/x86_64-linux
ENV JAVA_OPTS=-Djava.library.path=/var/task/lib/swipl/lib/x86_64-linux
