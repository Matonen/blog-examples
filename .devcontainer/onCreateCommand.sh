#!/bin/sh
set -eo

echo "installing sqlcmd utility..."

curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

sudo wget -qO /etc/apt/sources.list.d/microsoft-prod.list https://packages.microsoft.com/config/ubuntu/22.04/prod.list
sudo apt-get update
sudo apt-get install sqlcmd

echo "done"