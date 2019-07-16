FROM nginx:1.17.1-alpine

MAINTAINER Lineberty "itadmin@lineberty.com"

# Install wget and install/updates certificates
RUN apk update \
 && apk add  \
    bash \
    ca-certificates \
    wget \
 && rm -rf /var/cache/apk/*
 
ENV SIGIL_VERSION 0.4.0
 
RUN wget -O- https://github.com/gliderlabs/sigil/releases/download/v${SIGIL_VERSION}/sigil_${SIGIL_VERSION}_Linux_x86_64.tgz | tar xzC /usr/local/bin

COPY ./conf.d/00-log.conf /etc/nginx/conf.d/00-log.conf
COPY ./conf.d/10-default.conf.tpl /etc/nginx/conf.d/10-default.conf.tpl
COPY ./conf.d/20-gzip.conf /etc/nginx/conf.d/20-gzip.conf
RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD /bin/bash -c "/usr/local/bin/sigil -p -f /etc/nginx/conf.d/10-default.conf.tpl > /etc/nginx/conf.d/10-default.conf && nginx -g 'daemon off;'"
