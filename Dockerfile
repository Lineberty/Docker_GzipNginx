FROM nginx:1.9

MAINTAINER Lineberty "itadmin@lineberty.com"

COPY ./conf.d/default.conf.tpl /etc/nginx/conf.d/default.conf.tpl
COPY ./conf.d/gzip.conf /etc/nginx/conf.d/gzip.conf

EXPOSE 80

ENV DOLLAR='$'

ENV NGINX_PORT=80
ENV BACKEND_IP=127.0.0.1
ENV BACKEND_PORT=8080

CMD /bin/bash -c "envsubst < /etc/nginx/conf.d/default.conf.tpl > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"