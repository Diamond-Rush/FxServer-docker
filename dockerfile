FROM ubuntu:24.04 AS builder

ARG FXSERVER_VERSION=25770-8ddccd4e4dfd6a760ce18651656463f961cc4761

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -fsSL \
    "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FXSERVER_VERSION}/fx.tar.xz" \
    -o fx.tar.xz \
    && mkdir -p /opt/fxserver/server \
    && tar xf fx.tar.xz -C /opt/fxserver/server \
    && rm fx.tar.xz

FROM ubuntu:24.04 AS runtime

LABEL maintainer="iharsh02" \
    description="FXServer (RedM) with txAdmin" \
    version="1.0"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /root/.bash_history

RUN groupadd -g 1001 fxserver && \
    useradd -u 1001 -g fxserver -m -s /bin/bash fxserver

COPY --from=builder /opt/fxserver/server /opt/fxserver/server

RUN mkdir -p /opt/fxserver/server-data \
    /opt/fxserver/txData && \
    chown -R fxserver:fxserver /opt/fxserver

COPY --chown=fxserver:fxserver entrypoint.sh /opt/fxserver/entrypoint.sh
RUN chmod +x /opt/fxserver/entrypoint.sh

WORKDIR /opt/fxserver


EXPOSE 30120/tcp 30120/udp 40120

ENTRYPOINT ["/opt/fxserver/entrypoint.sh"]
