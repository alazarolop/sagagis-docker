FROM ubuntu:resolute AS builder

LABEL maintainer="Alberto Lázaro-López <alberto.lazaro@inia.csic.es>"
LABEL org.opencontainers.image.source="https://github.com/alazarolop/sagagis-docker"

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Madrid
ARG LANG_LOCALE=en_US.UTF-8
ARG SAGA_VERSION_TAG="saga-9.14.3"

ENV TZ="${TZ}"
ENV LANG="${LANG_LOCALE}"
ENV LC_ALL="${LANG_LOCALE}"

# grep -Ri "find_package(" ..
RUN apt-get update \
   && apt-get install -qy --no-install-recommends \
      git \
      make \
      pkg-config \
      cmake \
      build-essential \
      ca-certificates \
      libgomp1 \
      libwxgtk3.2-dev \
      libvigraimpex-dev \
      libgdal-dev \
      libproj-dev \
      python3-dev \
      swig \
      libhdf5-dev \
      unixodbc-dev \
      libpq-dev \
      libmysqlclient-dev \
      libhpdf-dev \
      libcurl4-openssl-dev \
      libopencv-dev \
      libtiff-dev \
      wx-common \
      libogdi-dev \
      locales \
   && update-ca-certificates \
   && rm -rf /var/lib/apt/lists/* \
   && echo "${LANG_LOCALE} UTF-8" >> /etc/locale.gen \
   && locale-gen \
   && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
   && echo "${TZ}" > /etc/timezone

RUN apt-get update \
 && apt-get install -y --no-install-recommends locales tzdata \
 && locale-gen \
 && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo "${TZ}" > /etc/timezone

RUN TMPDIR=$(mktemp -d) \
 && cd "$TMPDIR" \
 && git clone \
      --depth 1 \
      --branch "$SAGA_VERSION_TAG" \
      https://git.code.sf.net/p/saga-gis/code \
      saga-gis-code \
 && cd saga-gis-code/saga-gis \
 && mkdir build \
 && cd build \
 && cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/saga \
      -DCMAKE_INSTALL_RPATH=/opt/saga/lib \
 && cmake --build . --parallel "$(nproc)" \
 && cmake --install . \
 && rm -rf "$TMPDIR"

# ---

FROM ubuntu:resolute AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# ldd /opt/saga/bin/saga_cmd
# ldd /opt/saga/lib/libsaga_api.so.9
RUN apt-get update \
 && apt-get install -qy --no-install-recommends \
   libwxbase3.2-1 \
   libwxgtk3.2-1 \
   libgomp1 \
   libgdal38 \
   libproj25 \
   libtiff6 \
   libexpat1 \
   libcurl4 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/saga /opt/saga

ENV PATH="/opt/saga/bin:${PATH}"

CMD ["saga_cmd"]