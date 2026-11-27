ARG TZ=Europe/Madrid
ARG LANG_LOCALE=en_US.UTF-8
ARG SAGA_VERSION_TAG=saga-9.14.3
ARG DEBIAN_FRONTEND=noninteractive


# ============================================================================
# Builder
# ============================================================================

FROM ubuntu:resolute AS builder

ARG TZ
ARG LANG_LOCALE
ARG SAGA_VERSION_TAG
ARG DEBIAN_FRONTEND

ENV TZ="${TZ}"
ENV LANG="${LANG_LOCALE}"
ENV LC_ALL="${LANG_LOCALE}"

RUN apt-get update \
 && apt-get install -qy --no-install-recommends \
      git \
      make \
      pkg-config \
      cmake \
      build-essential \
      ca-certificates \
      locales \
      tzdata \
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
 && echo "${LANG_LOCALE} UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
 && echo "${TZ}" > /etc/timezone \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN TMPDIR="$(mktemp -d)" \
 && cd "$TMPDIR" \
 && git clone \
      --depth 1 \
      --branch "${SAGA_VERSION_TAG}" \
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


# ============================================================================
# Runtime
# ============================================================================

FROM ubuntu:resolute AS runtime

ARG TZ
ARG LANG_LOCALE
ARG SAGA_VERSION_TAG
ARG DEBIAN_FRONTEND

LABEL maintainer="Alberto Lázaro-López <alberto.lazaro@inia.csic.es>"
LABEL org.opencontainers.image.title="sagagis"
LABEL org.opencontainers.image.description="SAGA GIS Docker"
LABEL org.opencontainers.image.source="https://github.com/alazarolop/sagagis-docker"
LABEL org.opencontainers.image.version="${SAGA_VERSION_TAG}"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

ENV TZ="${TZ}"
ENV LANG="${LANG_LOCALE}"
ENV LC_ALL="${LANG_LOCALE}"

RUN apt-get update \
 && apt-get install -qy --no-install-recommends \
      locales \
      tzdata \
      libwxbase3.2-1 \
      libwxgtk3.2-1 \
      libgomp1 \
      libgdal38 \
      libproj25 \
      libtiff6 \
      libexpat1 \
      libcurl4 \
 && echo "${LANG_LOCALE} UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime \
 && echo "${TZ}" > /etc/timezone \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/saga /opt/saga

ENV PATH="/opt/saga/bin:${PATH}"

CMD ["saga_cmd"]