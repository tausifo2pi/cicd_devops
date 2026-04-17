#!/bin/bash

# Log file
LOGFILE=~/data/certbot/ssl-creation.log

log() {
  echo "$(date +"%Y-%m-%d %T") - $1" | tee -a $LOGFILE
}

log "Starting SSL certificate creation or renewal process"

# Create necessary directories (no deletion)
log "Ensuring directories for certbot exist"
mkdir -p ~/data/certbot/conf ~/data/certbot/www/.well-known/acme-challenge

# Run a temporary Nginx container to handle the HTTP challenge
log "Running temporary Nginx container"
docker run -d --name certbot-webserver -v ~/data/certbot/www:/usr/share/nginx/html:ro -p 80:80 nginx

# Run certbot to obtain or renew the SSL certificate
log "Running certbot to obtain or renew the SSL certificate"
docker run --rm -it \
  -v ~/data/certbot/conf:/etc/letsencrypt \
  -v ~/data/certbot/www:/var/www/certbot \
  certbot/certbot \
  certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email tausifo3.14@gmail.com \
  --agree-tos \
  --no-eff-email \
  -d treez-automation.sparkscann.com | tee -a $LOGFILE

# Stop and remove the temporary Nginx container
log "Stopping and removing temporary Nginx container"
docker stop certbot-webserver
docker rm certbot-webserver

# Set the correct permissions for the certbot directories and files
log "Setting correct permissions for certbot directories and files"
sudo chmod -R 755 ~/data/certbot

# End logging
log "SSL certificate creation or renewal process completed"
