#!/bin/sh

echo "[!] Starting Supervisor"

supervisord -n -c /etc/supervisor/conf.d/supervisord.conf