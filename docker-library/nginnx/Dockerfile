FROM nginx:alpine

# Copia la plantilla
COPY config_files/site.conf.tpl /etc/nginx/templates/site.conf.tpl

# Copia certificados
RUN mkdir -p /etc/nginx/ssl/

# Entry point
CMD envsubst '$DEV_DOMAIN $PHP_VERSION' < /etc/nginx/templates/site.conf.tpl > /etc/nginx/conf.d/site.conf && nginx -g 'daemon off;'