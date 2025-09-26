FROM nginx:stable

# Crear usuario de desarrollo devuser
RUN useradd -m -d /home/devuser -s /bin/bash devuser \
    && sed -i -e "s/umask 022/umask 002/g" /home/devuser/.bashrc

# Ajustar permisos de Apache para devuser
RUN chown -R devuser:www-data /home/devuser \
    && chmod -R 775 /home/devuser

# Copia la plantilla
COPY config_files/site.conf.tpl /etc/nginx/templates/site.conf.tpl

# create folder de certificados
RUN mkdir -p /etc/nginx/ssl/

# Entry point
CMD /bin/bash -c "envsubst '$$DEV_DOMAIN $$PHP_VERSION' < /etc/nginx/templates/site.conf.tpl > /etc/nginx/conf.d/site.conf && nginx -g 'daemon off;'"
