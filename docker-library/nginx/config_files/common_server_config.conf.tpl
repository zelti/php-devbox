set $DEV_DOMAIN "${DEV_DOMAIN}"; 
set $PHP_VERSION "${PHP_VERSION}"; 

# Inicializa y llama al script Lua
set $docroot "UNDEFINED"; 
rewrite_by_lua_file /etc/nginx/lua/resolve_docroot.lua; 

root $docroot;
index index.php index.html;

# Deny access to hidden .php files
location ~ /\.ph(p[345]?|t|tml|ps)$ {
    deny all;
}

# Main location
location / {
    try_files $uri $uri/ =404;
}

# Dynamic PHP-FPM with Authorization headers
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_pass $php_backend:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_param HTTP_AUTHORIZATION $http_authorization;
}

# Websockets
location /ws/ {
    proxy_pass http://phpwebsocket:8080;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}