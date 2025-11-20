# Dockerfile for portfolio web app

# Since this app is pure static content with zero build dependencies, 
# I’m not introducing unnecessary multi-stage builds or npm tooling.
# Instead I focused on production polish: non-root Nginx, metadata, health checks,
# and keeping the image as small and secure as possible.

FROM nginx:1.29.3-alpine

# Security best practice: upgrade OS packages (requires root)
USER root
RUN apk update && apk upgrade --no-cache

# Create temp directories for nginx runtime (writable by non-root)
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R 101:101 /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

# Copy website files
COPY . /usr/share/nginx/html

# Align file ownership with nginx non-root user (UID 101)
RUN chown -R 101:101 /usr/share/nginx/html \
    && chown -R 101:101 /var/cache/nginx \
    && chown -R 101:101 /var/log/nginx

# Remove default nginx config — I’m replacing it with my custom one
RUN rm /etc/nginx/conf.d/default.conf

# Copy my custom nginx config (config hardening + non-root compatible paths)
COPY nginx.conf /etc/nginx/nginx.conf

# Drop to non-root for runtime
USER 101

# Optional metadata Labels (OCI compliant)
LABEL org.opencontainers.image.title="Opsfolio - Interview App" \
      org.opencontainers.image.description="Refined DevSecOps portfolio project evolved from a technical interview challenge." \
      org.opencontainers.image.authors="Akingbade Omosebi" \
      org.opencontainers.image.version="2.0.0"

# Expose non-privileged HTTP port
EXPOSE 8080

# Health check for container liveness
HEALTHCHECK CMD wget --spider -q http://localhost:8080 || exit 1

# Start nginx in the foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
