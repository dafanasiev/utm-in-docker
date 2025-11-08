# [none|rutoken|mskey|jacarta]
ARG TOKEN_TYPE=rutoken

FROM ubuntu:20.04 AS base
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
    set -xe \
    && dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install -y \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libpcsclite1:i386 \
    libssl1.1:i386 \
    curl \
    pcsc-tools \
    usbutils \
    supervisor \
    acl \
    wget \
    unzip \
    libusb-1.0-0 \
    libpcsclite1 \
    pcscd \
    opensc \
    python3 \
    python3-pip \
    software-properties-common \
    libengine-pkcs11-openssl \
    gnutls-bin \
    iproute2 \
    inetutils-ping \
    inetutils-traceroute

FROM base AS utm
ARG TOKEN_TYPE

# rutoken (https://dev.rutoken.ru/pages/viewpage.action?pageId=142508509)
# packages: https://repo.rutoken.ru/repository/apt/dists/stable/main/binary-i386/Packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,source=dist,target=/dist \
    set -xue \
 && cat /dist/rutoken.asc | gpg --dearmor | tee /usr/share/keyrings/rutoken.gpg > /dev/null \
 && echo 'deb [signed-by=/usr/share/keyrings/rutoken.gpg] https://repo.rutoken.ru/apt/ stable main' > /etc/apt/sources.list.d/rutoken.list \
 && apt-get update \
 && apt-get install -y \
#    librtpkcs11ecp \
    librtpkcs11ecp:i386

# utm (https://fskatr.gov.ru/egais/podkljuchenie_k_sisteme_egais)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/root/.launchpadlib \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,source=dist,target=/dist \
    set -xue \
 && mv /usr/bin/lsusb /usr/bin/lsusb.bak \
 && echo '#!/usr/bin/bash' > /usr/bin/lsusb \
 && if [ "${TOKEN_TYPE}" = "none" ]; then echo '' >> /usr/bin/lsusb; fi \
 && if [ "${TOKEN_TYPE}" = "rutoken" ]; then echo "echo 'Bus 002 Device 002: ID 0a89:0030 Aktiv Rutoken ECP'" >> /usr/bin/lsusb; fi \
 && if [ "${TOKEN_TYPE}" = "mskey" ]; then echo "echo 'Bus 002 Device 002: ID 2ce4:0030 mskey'" >> /usr/bin/lsusb; fi \
 && if [ "${TOKEN_TYPE}" = "jacarta" ]; then echo "echo 'Bus 002 Device 002: ID 24dc:0030 jacarta'" >> /usr/bin/lsusb; fi \
 && echo '' >> /usr/bin/lsusb \
 && chmod +x /usr/bin/lsusb \
 && mv /usr/bin/supervisorctl /usr/bin/supervisorctl.bak \
 && echo '#!/usr/bin/bash' > /usr/bin/supervisorctl \
 && chmod +x /usr/bin/supervisorctl \
 && dpkg -i /dist/u-trans-*.deb || (apt-get install -f -y && dpkg -i /dist/u-trans-*.deb) \
 && mv /usr/bin/supervisorctl.bak /usr/bin/supervisorctl \
 && mv /usr/bin/lsusb.bak /usr/bin/lsusb \
 && mkdir -p /var/log/supervisor /var/run/supervisor

COPY ./rootfs /

FROM utm AS final
EXPOSE 8080
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

