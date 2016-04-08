upstream local {
	server ${BACKEND_IP}:${BACKEND_PORT} fail_timeout=10s;
}

server {
	listen ${NGINX_PORT};
  server_name _;
    
  location / {
  	proxy_pass   http://local;
    
   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;
    
    proxy_set_header  Host                ${DOLLAR}host;
    proxy_set_header  X-Real-IP           ${DOLLAR}remote_addr;
    proxy_set_header  X-Forwarded-Proto   ${DOLLAR}scheme;
    proxy_set_header  X-Forwarded-Host    ${DOLLAR}host;
    proxy_set_header  X-Forwarded-Server  ${DOLLAR}host;
    proxy_set_header  X-Forwarded-For     ${DOLLAR}proxy_add_x_forwarded_for;
  }           
}

{{ if (and (exists "${SSL_CRT}") (exists "${SSL_KEY}")) }}
server {
	listen ${NGINX_HTTPS_PORT};
  server_name _;
    
  ssl_certificate           ${SSL_CRT};
  ssl_certificate_key       ${SSL_KEY};

  ssl on;
  ssl_session_cache  builtin:1000  shared:SSL:10m;
  ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
  ssl_prefer_server_ciphers on;
    
  location / {
  	proxy_pass   http://local;
    
   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;
    
    proxy_set_header  Host                ${DOLLAR}host;
    proxy_set_header  X-Real-IP           ${DOLLAR}remote_addr;
    proxy_set_header  X-Forwarded-Proto   ${DOLLAR}scheme;
    proxy_set_header  X-Forwarded-Host    ${DOLLAR}host;
    proxy_set_header  X-Forwarded-Server  ${DOLLAR}host;
    proxy_set_header  X-Forwarded-For     ${DOLLAR}proxy_add_x_forwarded_for;
  }           
}
{{ end }}
