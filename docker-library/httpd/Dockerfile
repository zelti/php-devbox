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
    apache2 apache2-utils lua5.4  \
    && apt-get clean -y \
    && apt-get -qqy autoremove \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuraciones y scripts

RUN mkdir -p /etc/apache2/lua \
    && mkdir -p /etc/apache/ssl

COPY config_files/resolve_docroot.lua /etc/apache2/lua/resolve_docroot.lua
#Sites
COPY config_files/devlocal.conf /etc/apache2/sites-available/devlocal.conf
COPY config_files/devlocal_https.conf /etc/apache2/sites-available/devlocal_https.conf
#config
COPY config_files/php-fpm.conf /etc/apache2/conf-available/php-fpm.conf

RUN a2enmod http2 rewrite headers ssl actions proxy_fcgi alias proxy_http proxy_wstunnel lua \
    && a2enconf php-fpm \
    && a2ensite devlocal \
    && a2ensite devlocal_https 


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
