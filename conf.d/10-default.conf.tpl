upstream local {
	server ${BACKEND_IP-"127.0.0.1"}:${BACKEND_PORT-"8080"} fail_timeout=10s;
}

map \$http_sec_websocket_key \$upgr {
    ""      "";           # If the Sec-Websocket-Key header is empty, send no upgrade header
    default "websocket";  # If the header is present, set Upgrade to "websocket"
}

map \$http_sec_websocket_key \$conn {
    ""      \$http_connection;  # If no Sec-Websocket-Key header exists, set $conn to the incoming Connection header
    default "upgrade";         # Otherwise, set $conn to upgrade
}

server {
	listen ${NGINX_PORT-"80"};
  server_name _;

  access_log /var/log/nginx/access.log upstream_time;
    
  location / {
  	proxy_pass   http://local;
    
   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;

    # only for upload
    client_max_body_size     50m;

    proxy_http_version 1.1;
    proxy_set_header  Upgrade \$upgr;
    proxy_set_header  Connection \$conn;
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
  ssl_protocols  TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
  ssl_prefer_server_ciphers on;
    
  location / {
  	proxy_pass   http://local;

  	# only for upload
    client_max_body_size 20m;

   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;

    proxy_http_version 1.1;
    proxy_set_header   Upgrade $upgr;
    proxy_set_header   Connection $conn;
    proxy_set_header   Host                \$host;
    proxy_set_header   X-Real-IP           \$remote_addr;
    proxy_set_header   X-Forwarded-Proto   \$scheme;
    proxy_set_header   X-Forwarded-Host    \$host;
    proxy_set_header   X-Forwarded-Server  \$host;
    proxy_set_header   X-Forwarded-For     \$proxy_add_x_forwarded_for;
  }

  location /api/api_booking/user/tickets/sse {
  	proxy_pass   http://local;

  	# only for upload
    client_max_body_size 20m;

   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;

    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade $upgr;
    proxy_set_header   Connection $conn;
    proxy_set_header   Host                \$host;
    proxy_set_header   X-Real-IP           \$remote_addr;
    proxy_set_header   X-Forwarded-Proto   \$scheme;
    proxy_set_header   X-Forwarded-Host    \$host;
    proxy_set_header   X-Forwarded-Server  \$host;
    proxy_set_header   X-Forwarded-For     \$proxy_add_x_forwarded_for;
  }

  location /api/api_validation/queues/[0-9a-zA-Z\-_]+/tickets/[0-9a-zA-Z\-_]+/sse {
  	proxy_pass   http://local;

  	# only for upload
    client_max_body_size 20m;

   	proxy_read_timeout    90;
   	proxy_connect_timeout 90;
   	proxy_redirect        off;

    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade $upgr;
    proxy_set_header   Connection $conn;
    proxy_set_header   Host                \$host;
    proxy_set_header   X-Real-IP           \$remote_addr;
    proxy_set_header   X-Forwarded-Proto   \$scheme;
    proxy_set_header   X-Forwarded-Host    \$host;
    proxy_set_header   X-Forwarded-Server  \$host;
    proxy_set_header   X-Forwarded-For     \$proxy_add_x_forwarded_for;
  }
}
{{ end }}
