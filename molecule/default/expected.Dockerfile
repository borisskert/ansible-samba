FROM alpine:3.11

MAINTAINER borisskert <boris.skert@gmail.com>

ENV SAMBA_VERSION=4.11

RUN apk --no-cache --no-progress upgrade && \
apk --no-cache --no-progress add \
bash \
supervisor \
samba~=${SAMBA_VERSION} \
samba-common-tools~=${SAMBA_VERSION}

COPY add-samba-user.sh /add-samba-user.sh
COPY update-samba-user-password.sh /update-samba-user-password.sh
COPY supervisord.conf /supervisord.conf

VOLUME ["/etc", "/var/lib/samba", "/var/log/samba", "/var/cache/samba", "/run/samba", "/storages", "/home"]

EXPOSE 135/tcp 137/udp 138/udp 139/tcp 445/tcp

ENTRYPOINT ["supervisord", "-c", "/supervisord.conf"]
