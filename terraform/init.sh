#!/bin/bash
echo "STARTED" > ~/init
sudo apt -y update

# Install docker
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"
sudo apt -y update
sudo apt -y install docker-ce docker-ce-cli containerd.io

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Mount disk volumne
# sudo mkfs -t xfs /dev/nvme1n1
mkdir ~/data
sudo mount /dev/nvme1n1 ~/data
sudo chown ubuntu ~/data

# Clone pal repo
git clone https://github.com/yehjxraymond/pal-masternode.git
cd pal-masternode