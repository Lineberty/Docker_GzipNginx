upstream local {
	server ${BACKEND_IP-"127.0.0.1"}:${BACKEND_PORT-"8080"} fail_timeout=10s;
}

server {
	listen ${NGINX_PORT-"80"};
  server_name _;

  access_log /var/log/nginx/access.log upstream_time;
    
  location / {
    client_max_body_size 20m;
  	proxy_pass   http://local;
    
   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;
    
    proxy_set_header  Host                \$host;
    proxy_set_header  X-Real-IP           \$remote_addr;
    proxy_set_header  X-Forwarded-Proto   \$scheme;
    proxy_set_header  X-Forwarded-Host    \$host;
    proxy_set_header  X-Forwarded-Server  \$host;
    proxy_set_header  X-Forwarded-For     \$proxy_add_x_forwarded_for;
  }           
}

{{ if (and (exists "../../../${SSL_CRT-"/secret/tls.crt"}") (exists "../../../${SSL_KEY-"/secret/tls.key"}")) }}
server {
	listen ${NGINX_HTTPS_PORT-"443"};
  server_name _;
    
  access_log /var/log/nginx/access.log upstream_time;

  ssl_certificate           ${SSL_CRT-"/secret/tls.crt"};
  ssl_certificate_key       ${SSL_KEY-"/secret/tls.key"};

  ssl on;
  ssl_session_cache  builtin:1000  shared:SSL:10m;
  ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
  ssl_prefer_server_ciphers on;
    
  location / {
    client_max_body_size 20m;
  	proxy_pass   http://local;
    
   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;
    
    proxy_set_header  Host                \$host;
    proxy_set_header  X-Real-IP           \$remote_addr;
    proxy_set_header  X-Forwarded-Proto   \$scheme;
    proxy_set_header  X-Forwarded-Host    \$host;
    proxy_set_header  X-Forwarded-Server  \$host;
    proxy_set_header  X-Forwarded-For     \$proxy_add_x_forwarded_for;
  }           
}
{{ end }}
