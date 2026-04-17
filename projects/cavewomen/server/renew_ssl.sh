#!/bin/bash

set -euo pipefail

LOGFILE=~/data/certbot/ssl-renewal.log

log() {
  echo "$(date +"%Y-%m-%d %T") - $1" | tee -a $LOGFILE
}

log "Starting SSL renewal"

docker run --rm \
  -v ~/data/certbot/conf:/etc/letsencrypt \
  -v ~/data/certbot/www:/var/www/certbot \
  certbot/certbot renew --non-interactive --quiet | tee -a $LOGFILE

docker exec $(docker ps -qf "name=nginx") nginx -s reload

log "SSL renewal completed"
