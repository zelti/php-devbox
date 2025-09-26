FROM nginx:stable

# Create devuser with UID/GID 33
RUN adduser --uid 33 --ingroup www-data --home /home/devuser --shell /bin/bash --disabled-password --gecos "dev user" devuser \
    && mkdir -p /home/devuser/public_html \
    && chown -R devuser:www-data /home/devuser/public_html \
    && chmod -R 775 /home/devuser/public_html


# Copia la plantilla
COPY config_files/site.conf.tpl /etc/nginx/templates/site.conf.tpl

# create folder de certificados
RUN mkdir -p /etc/nginx/ssl/

# Entry point
CMD /bin/bash -c "envsubst '$$DEV_DOMAIN $$PHP_VERSION' < /etc/nginx/templates/site.conf.tpl > /etc/nginx/conf.d/site.conf && nginx -g 'daemon off;'"
