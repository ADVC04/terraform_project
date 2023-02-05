#!/bin/bash
sudo yum update -y && sudo yum install -y java
# sudo usermod -aG docker ec2-user

# # install docker-compose 
# sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose