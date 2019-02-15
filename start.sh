#!/bin/bash
mkdir ~/data1
sudo mount /dev/nvme1n1 ~/data
sudo chown ubuntu ~/data

docker-compose up -d