#!/bin/bash

set -euo pipefail

LOGFILE=~/data/certbot/ssl-creation.log

log() {
  echo "$(date +"%Y-%m-%d %T") - $1" | tee -a $LOGFILE
}

log "Starting SSL certificate creation"

sudo rm -rf ~/data/certbot
mkdir -p ~/data/certbot/conf ~/data/certbot/www/.well-known/acme-challenge

log "Running temporary Nginx container"
docker run -d --name certbot-webserver -v ~/data/certbot/www:/usr/share/nginx/html:ro -p 80:80 nginx

log "Running certbot"
docker run --rm \
  -v ~/data/certbot/conf:/etc/letsencrypt \
  -v ~/data/certbot/www:/var/www/certbot \
  certbot/certbot \
  certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email tausifo3.14@gmail.com \
  --agree-tos \
  --no-eff-email \
  -d cavewomen.coelor.com | tee -a $LOGFILE

log "Stopping temporary Nginx container"
docker stop certbot-webserver
docker rm certbot-webserver

sudo chmod -R 755 ~/data/certbot
log "SSL certificate creation completed"
