#!/bin/bash

echo "Installing requirements"
# Add Docker's official GPG key:
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt -y install git
sudo snap install --classic certbot


git clone https://github.com/igorbash/PostQuantumProject.git
tar -xf PostQuantumProject/pq_proxy.tar -C ./
mv chrome_pq_proxy pq_proxy
rm -rf PostQuantumProject

echo "Creating certificate for domain $1"
sudo certbot certonly --standalone -d $1 --non-interactive --agree-tos -m webmaster@$1
sudo cp /etc/letsencrypt/live/$1/fullchain.pem pq_proxy/proxy/certs/server.crt 
sudo cp /etc/letsencrypt/live/$1/privkey.pem pq_proxy/proxy/certs/server.key

echo "Running server on port 4433"
cd pq_proxy
sudo docker compose up -d
echo "To stop the server enter the following command: cd pq_proxy; sudo docker compose down"