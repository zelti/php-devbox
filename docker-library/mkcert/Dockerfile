# Dockerfile
FROM alpine/mkcert:latest

# Copiamos el entrypoint
COPY config_files/entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

VOLUME ["/etc/nginx/ssl"]

ENTRYPOINT ["/usr/local/bin/entrypoint"]