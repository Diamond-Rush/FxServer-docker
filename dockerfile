FROM ubuntu:24.04

LABEL maintainer="iharsh02" \
    description="FXServer (FiveM/RedM) with txAdmin - Pterodactyl compatible" \
    version="2.0"

# Install only the minimal runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    tar \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pterodactyl requires a 'container' user with UID 1000 and home at /home/container
# Ubuntu 24.04 already has an 'ubuntu' user with UID 1000, so we remove it first
RUN userdel -r ubuntu || true && \
    useradd -m -d /home/container -u 1000 -s /bin/bash container

USER container
ENV USER=container \
    HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 30120/tcp 30120/udp 40120/tcp

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
