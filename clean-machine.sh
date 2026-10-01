#!/bin/bash

set -euo pipefail

sudo apt clean
sudo apt autoremove
# sudo apt autoremove --purge

sudo journalctl --vacuum-size=100M

# Find and remove old snap versions (if using snap)

if command -v snap; then
  snap list --all
cat <<EOT
  Use e.g.
sudo snap remove google-cloud-cli --revision=448
sudo snap remove snapd --revision=26382
  to remove disabled stuff
EOT
else
  echo "No snap found"
fi

if command -v docker; then
  docker system prune -a         # removes unused images, containers, volumes
  docker volume prune
else
  echo "No docker found"
fi


