FROM alpine:3.7
MAINTAINER flandiGT <https://github.com/flandiGT/ansible-samba>

EXPOSE 445/tcp

ENV SAMBA_VERSION=4.7.4-r0

RUN apk add --update \
    samba-common-tools=${SAMBA_VERSION} \
    samba-client=${SAMBA_VERSION} \
    samba-server=${SAMBA_VERSION} \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["smbd", "--foreground", "--log-stdout"]
CMD []
