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
    client_body_buffer_size  10M;
    client_max_body_size     20m;

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
  listen ${NGINX_HTTPS_PORT-"443"} http2;
  server_name _;
    
  access_log /var/log/nginx/access.log upstream_time;

  # https://ssl-config.mozilla.org/#server=nginx&server-version=1.17.1&config=intermediate
  # https://www.cloudinsidr.com/content/how-to-activate-http2-with-ssltls-encryption-in-nginx-for-secure-connections/#more-123
  ssl_certificate           ${SSL_CRT-"/secret/tls.crt"};
  ssl_certificate_key       ${SSL_KEY-"/secret/tls.key"};

  ssl on;
  ssl_session_cache  builtin:1000  shared:SSL:10m;

  # curl https://ssl-config.mozilla.org/ffdhe2048.txt > /path/to/dhparam.pem
  ssl_dhparam ${SSL_DH_PARAM-"/secret/dhparam.pem"};

  # Intermediate configuration
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers on;

  # HSTS (ngx_http_headers_module is required) (63072000 seconds)
  add_header Strict-Transport-Security "max-age=31536000" always;

  # OCSP stapling
  ssl_stapling on;
  ssl_stapling_verify on;

  # verify chain of trust of OCSP response using Root CA and Intermediate certs
  ssl_trusted_certificate ${SSL_CA_CERT-"/secret/ca.crt"};
    
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
