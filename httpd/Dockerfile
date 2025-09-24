FROM debian:bookworm
LABEL maintainer="Yostin Vargas"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Santiago

# Optimizar APT y paquetes base
RUN echo "APT::Install-Recommends false;" >> /etc/apt/apt.conf.d/00recommends \
    && echo "APT::Install-Suggests false;" >> /etc/apt/apt.conf.d/00recommends \
    && echo "APT::AutoRemove::RecommendsImportant false;" >> /etc/apt/apt.conf.d/00recommends \
    && echo "APT::AutoRemove::SuggestsImportant false;" >> /etc/apt/apt.conf.d/00recommends \
    && apt-get -qq update \
    && apt-get -yqq upgrade \
    && apt-get -yqq --no-install-recommends install \
    curl vim nano-tiny apt-transport-https ca-certificates jq openssl cron \
    apache2 apache2-utils \
    && apt-get clean -y \
    && apt-get -qqy autoremove \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuraciones y scripts
COPY conf/* /tmp/apache/conf/
COPY sites/* /tmp/apache/sites/

# Certificados locales autofirmados (ajusta *.dev.local a tus dominios)
RUN mkdir -p /etc/apache2/ssl.key /etc/apache2/ssl.crt /home/test/www-ssl/resources \
    && touch /home/test/www-ssl/index.html \
    && echo "<?php phpinfo(); ?>" > /home/test/www-ssl/resources/info.php \
    && openssl genrsa -out /etc/apache2/ssl.key/devlocal.key 2048 \
    && openssl req -new -x509 -days 3650 \
    -key /etc/apache2/ssl.key/devlocal.key \
    -subj "/CN=*.dev.local/O=PhpDev/L=Santiago/ST=Santiago/C=CL" \
    -out /etc/apache2/ssl.crt/devlocal.crt

# Configuración de Apache
RUN mv /tmp/apache/conf/php-fpm.conf /etc/apache2/conf-available/php-fpm.conf \
    && mv /tmp/apache/sites/* /etc/apache2/sites-available/ \
    && a2enmod http2 rewrite headers ssl actions proxy_fcgi alias proxy_http proxy_wstunnel \
    && a2enconf php-fpm \
    && a2ensite devlocal \
    && a2ensite devlocal_https \
    && rm -rf /tmp/*

# Crear usuario de desarrollo devuser
RUN useradd -m -d /home/devuser -s /bin/bash devuser \
    && sed -i -e "s/umask 022/umask 002/g" /home/devuser/.bashrc

# Ajustar permisos de Apache para devuser
RUN chown -R devuser:www-data /var/www/ /home/devuser \
    && chmod -R 775 /var/www/ /home/devuser


RUN chown root:www-data /etc/apache2/sites-available/*.conf \
    && chmod 664 /etc/apache2/sites-available/*.conf

WORKDIR /home/devuser

EXPOSE 80 443

CMD ["apache2ctl", "-D", "FOREGROUND"]
