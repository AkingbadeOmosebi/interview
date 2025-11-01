# Dockerfile for portfolio web app

# Base image: lightweight Nginx Alpine
FROM nginx:1.27-alpine

# Copy website files into Nginx's default HTML folder
COPY . /usr/share/nginx/html

# Optional: fix ownership to match existing nginx user which is prsent in nginx
RUN chown -R 101:101 /usr/share/nginx/html

# Optional metadata labels
LABEL org.opencontainers.image.title="Portfolio Web App" \
      org.opencontainers.image.description="Static Portfolio HTML/CSS/JS website served by Nginx" \
      org.opencontainers.image.authors="Akingbade Omosebi" \
      org.opencontainers.image.version="1.0.0"

# Expose port 80 for HTTP
EXPOSE 80

# Start Nginx in the foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
