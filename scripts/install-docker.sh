#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
# Check If Maria Has Been Installed

if [ -f /home/vagrant/.devkit_java_docker ]
then
    echo "Docker already installed."
    exit 0
fi

# Add Docker PPA

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update

# Install Docker

apt-get install -y docker-ce
usermod -aG docker vagrant

if [ "$1" != "" ]; then
    echo "{ \"registry-mirrors\": $1 }" > /etc/docker/daemon.json
    systemctl restart docker.service
fi

touch /home/vagrant/.devkit_java_docker
