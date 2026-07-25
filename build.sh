#!/bin/bash
set -e

echo "=== Build Jenkins ==="
docker compose build jenkins

#echo "=== Extraction clé publique ==="
#docker run --rm jenkins-ansible:v1 cat /var/jenkins_home/.ssh/id_ed25519.pub > id_ed25519.pub

echo "=== Build ubuntu-target ==="
docker compose build ubuntu-target

echo "=== Lancement ==="
docker compose up -d

echo "=== Vérification ==="
docker ps

echo "=== Copie de la clé SSH jenkins -> ubuntu-target"
./copyssh.sh
