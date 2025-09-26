# ======================
# Nginx configuration
# ======================
# This configuration uses environment variables from Docker (.env file):
#   - $DEV_DOMAIN   : sets the base development domain (e.g., dev.local)
#   - $PHP_VERSION   : sets the default PHP version (e.g., 83 or 84)
# These variables are replaced at container startup via `envsubst`:
#   envsubst '$DEV_DOMAIN $PHP_VERSION' < site.conf.tpl > /etc/nginx/conf.d/site.conf
# ==============================================================================


# Map to decide PHP backend based on hostname
map $host $php_backend {
    "~--p83\.${DEV_DOMAIN}$" "php83dev";
    "~--p84\.${DEV_DOMAIN}$" "php84dev";
    default "php${PHP_VERSION}";
}
# Resolve dynamic subdirectories
map $host $docroot {
    "~^(?<path>.+)--p[0-9]{2}\.${DEV_DOMAIN}$" "/home/devuser/public_html/${path//--//}";
    "~^(?<path>.+)\.${DEV_DOMAIN}$" "/home/devuser/public_html/${path//--//}";
}
map $subdomains $dotroot {
    default "/home/devuser/public_html";
    "~^(?<parts>.+)$" "/home/devuser/public_html/${parts//./\/}";
}


# ======================
# HTTP - port 80
# ======================
server {
    listen 80;
    server_name ~^(?<subdomains>.+)\.${DEV_DOMAIN}$;

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
}

# ======================
# HTTPS - port 443
# ======================
server {
    listen 443 ssl;
    server_name ~^(?<subdomains>.+)\.${DEV_DOMAIN}$;

    ssl_certificate     /etc/nginx/ssl/php-devbox.pem;  # certificate
    ssl_certificate_key /etc/nginx/ssl/php-devbox.key;  # private key

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
}
