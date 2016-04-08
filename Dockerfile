FROM nginx:1.9

MAINTAINER Lineberty "itadmin@lineberty.com"

COPY ./conf.d/default.conf.tpl /etc/nginx/conf.d/default.conf.tpl
COPY ./conf.d/gzip.conf /etc/nginx/conf.d/gzip.conf

EXPOSE 80

ENV DOLLAR='$'

ENV NGINX_PORT=80
ENV NGINX_HTTPS_PORT=443
ENV BACKEND_IP=127.0.0.1
ENV BACKEND_PORT=8080
ENV SSL_CRT=/secret/tls.crt
ENV SSL_KEY=/secret/tls.key

CMD /bin/bash -c "envsubst < /etc/nginx/conf.d/default.conf.tpl > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"