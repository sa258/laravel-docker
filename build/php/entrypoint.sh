#!/bin/sh

role=${CONTAINER_ROLE:-fpm}
ENV=${APP_ENV:-local}

echo "Start service as ${CONTAINER_ROLE}"

if [ "$role" = "fpm" ]; then
    
    echo "[!] Starting Supervisor"
    
    nohup supervisord -n -c /etc/supervisor/conf.d/supervisord.conf &

    echo "[!] Starting PHP FPM"
    php-fpm
fi