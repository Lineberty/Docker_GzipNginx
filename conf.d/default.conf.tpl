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