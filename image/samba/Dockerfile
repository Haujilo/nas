FROM alpine:edge

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
  apk --no-cache add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

ADD ./smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp

CMD ["smbd", "-FS", "--no-process-group"]
