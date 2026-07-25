#!/bin/bash
set -e

# Objectif : copier la clé ssh publique de la machine jenkins vers la machine ubuntu-target

# 0. Nettoyer l'ancienne entrée known_hosts sur l'hôte (si elle existe)
ssh-keygen -f "$HOME/.ssh/known_hosts" -R '172.19.0.11' 2>/dev/null || true

# 1. Suppression de l'ancienne clé si elle existe
docker exec -u root jenkins /bin/bash -c "rm -f /var/jenkins_home/.ssh/id_ed25519*"

# 2. Générer la clé SSH sur le driver jenkins
docker exec jenkins /bin/bash -c "ssh-keygen -t ed25519 -C 'jenkins@driver' -f /var/jenkins_home/.ssh/id_ed25519 -N ''"

# 3. Configuration des permissions
docker exec jenkins /bin/bash -c "chmod 600 /var/jenkins_home/.ssh/id_ed25519"

# 4. Extraire la clé publique du conteneur vers un fichier local sur ubuntu-lab
docker exec jenkins bash -c "cat /var/jenkins_home/.ssh/id_ed25519.pub" > jenkins_id_ed25519.pub

# 5. Copier la clé du conteneur jenkins vers le target ubuntu-target
cat jenkins_id_ed25519.pub | sshpass -p "test" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@172.19.0.11 "mkdir -p /root/.ssh && cat >> /root/.ssh/authorized_keys"

# 6. Configuration des permissions sur ubuntu-target
sshpass -p "test" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@172.19.0.11 "chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys"
