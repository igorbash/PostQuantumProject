#!/bin/bash

cd pq_proxy

sudo docker compose up -d 
echo "Trying get site wtfismyip.com with hybrid KEM when the site dont support it"
sudo docker compose run -it --rm client curl https://wtfismyip.com/json --curves x25519_kyber768

echo "Trying get site wtfismyip.com with hybrid KEM using the proxy - will succeed: use wireshark to capture the traffic"
echo "Press Enter to continue..."
read  
sudo docker compose run -it --rm client curl -x https://pqProxy.com:4433 https://wtfismyip.com/json --curves x25519_kyber768
sudo docker compose down
