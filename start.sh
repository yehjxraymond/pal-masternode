#!/bin/bash
mkdir ~/data1
sudo mount /dev/nvme1n1 ~/data
sudo chown ubuntu ~/data

sudo docker-compose -f /home/ubuntu/pal-masternode/docker-compose.yml up -d