# Dockerfile for portfolio web app

#Because my app is pure static content with no build dependencies, I will not introduce unnecessary stages or tools like npm.
#Instead, I focused on production polish, I will run Nginx as a non-root user, add metadata and a healthcheck for monitoring, and keep the image small.
#This keeps it clean and secure while still being deployment-ready.

# Base image: lightweight Nginx Alpine
FROM nginx:1.27-alpine

# Copy website files into Nginx's default HTML folder
COPY . /usr/share/nginx/html

# Optional: fix ownership to match existing nginx user which is prsent in nginx
RUN chown -R 101:101 /usr/share/nginx/html

# Security patch best practice: keep OS packages updated
RUN apk update && apk upgrade --no-cache

# Optional metadata labels
LABEL org.opencontainers.image.title="Opsfolio - Interview App" \
      org.opencontainers.image.description="Refined DevSecOps portfolio project evolved from a technical interview challenge." \
      org.opencontainers.image.authors="Akingbade Omosebi" \
      org.opencontainers.image.version="2.0.0"


# Expose port 80 for HTTP
EXPOSE 80


# Added Health check (optional but good practice for container life)
HEALTHCHECK CMD wget --spider -q http://localhost:80 || exit 1

# Start Nginx in the foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
