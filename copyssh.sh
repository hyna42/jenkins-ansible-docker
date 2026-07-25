# Objectif : copier la clé ssh publique de la machine jenkins vers la machine ubuntu-target

# 1. Générer la clé SSH sur le driver jenkins
docker exec -u root jenkins /bin/bash -c \ "ssh-keygen -t ed25519 -C 'jenkins@driver' -f ~/.ssh/id_ed25519 -N ''"

# 2. Copier la clé publique id_ed25519.pub jenkins vers le target ubuntu-target
sshpass -p "test" ssh-copy-id -i /home/hyna/.ssh/id_ed25519.pub root@172.19.0.11
