#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "env name not define"
    exit 1
fi

ENV=$1

cd /home/project/ec || { echo "Failed to change directory"; exit 1; }

echo "[!] Deploying docker container"
./dock $ENV build || { echo "Docker deployment failed"; exit 1; }

echo "[!] Installing PHP dependencies"
./dock $ENV composer install || { echo "PHP dependency installation failed"; exit 1; }

echo "[!] Installing JS dependencies"
./dock $ENV npm install || { echo "JS dependency installation failed"; exit 1; }

echo "[!] Creating APP Build"
./dock $ENV npm run build || { echo "APP build creation failed"; exit 1; }

echo "[!] Running Migration"
./dock $ENV artisan migrate --force || { echo "Database migration failed"; exit 1; }

echo "[!] Running Optimization"
./dock $ENV artisan optimize || { echo "Optimization failed"; exit 1; }

echo "[!] Restarting FPM"
docker restart ec-ec-fpm-1

echo "[!] Deployment successful!"
