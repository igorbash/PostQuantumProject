#!/bin/bash

cd pqs_proxy

sudo docker compose up -d 
echo "Trying get site example.com with hybrid KEM when the site dont support it"
sudo docker compose run -it --rm client curl https://example.com --curves p521_kyber1024

echo ""Trying get site example.com with hybrid KEM using the proxy - will succeed: use wireshark to capture the traffic"
echo "Press Enter to continue..."
read  
sudo docker-compose run -it --rm client curl -x https://pqProxy.com:4433 https://example.com
sudo docker compose down
