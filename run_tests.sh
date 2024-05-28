#!/bin/bash

echo "Creating classic server certificates"
echo "===================================="
echo "Creating self signed CA with RSA, named classic CA"
sudo docker run -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey RSA -keyout /tmp/classic_CA.key -out /tmp/classic_CA.crt -nodes -subj "/CN=classic CA" -days 365
echo "Creating certificate request with RSA key for domain classic.com"
sudo docker run -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey RSA -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=classic.com"
echo "Creating the server certificate and sign with the CA"
sudo docker run -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/classic_CA.crt -CAkey /tmp/classic_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Creating pq server certificates"
echo "===================================="
echo "Creating self signed CA with dilithium5, named pq CA" 
sudo docker run -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey dilithium5 -keyout /tmp/pq_CA.key -out /tmp/pq_CA.crt -nodes -subj "/CN=pq CA" -days 365
echo "Creating certificate request with dilithium3 key for domain pq.com"
sudo docker run -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=pq.com"
echo "Creating the server certificate and sign with the CA" 
sudo docker run -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/pq_CA.crt -CAkey /tmp/pq_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Creating hybrid server certificates"
echo "===================================="
echo "Creating self signed CA with p521_dilithium5, named hybrid CA"
sudo docker run -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey p521_dilithium5 -keyout /tmp/hybrid_CA.key -out /tmp/hybrid_CA.crt -nodes -subj "/CN=hybrid CA" -days 365
echo "Creating certificate request with p384_dilithium3 key for domain hybrid.com"
sudo docker run -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey p384_dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=hybrid.com"
echo "Creating the server certificate and sign with the CA"
sudo docker run -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/hybrid_CA.crt -CAkey /tmp/hybrid_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Copying ca files to BoringSSl client and openSSL client"
cp ./tests/*/certs/*_CA.crt .\openssl_client\ca\
cp ./tests/*/certs/*_CA.crt .\boringssl_client\ca\
echo "===================================="
echo "Running docker compose"
cd tests
sudo docker compose -d
echo "===================================="
echo "Testing openSSL client"
echo "GET request to classic server with ecdh (x25519) key exchange - works."
sudo docker compose run -it --rm openssl_client  curl --cacert /opt/tmp/classic_CA.crt --curves x25519 https://classic.com:4433
echo "GET request to pq server with kyber768 key exchange - works."
sudo docker compose run -it --rm openssl_client  curl --cacert /opt/tmp/pq_CA.crt --curves kyber768 https://pq.com:4434
echo "GET request to hybrid server with hybrid sp521_kyber1024 key exchange - works."
sudo docker compose run -it --rm openssl_client  curl --cacert /opt/tmp/hybrid_CA.crt  --curves p521_kyber1024  https://hybrid.com:4435
echo "===================================="
echo "Testing boringSSL client"
echo "GET request to classic server with ecdh (x25519) key exchange - works."
sudo docker compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: classic.com\r\nConnection: close\r\n\r\n' | bssl client -connect classic.com:4433 -curves x25519"
echo "GET request to pq server with kyber768 key exchange - works."
sudo docker compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves kyber768"
echo "GET request to pq server with hybrid p521_kyber1024 key exchange - works." 
sudo docker compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves p521_kyber1024"
echo "GET request to hybrid server with x25519 key exchange - NOT WORKING (because boringssl does not support hybrid singatures)"
sudo docker compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: hybrid.com\r\nConnection: close\r\n\r\n' | bssl client -connect hybrid.com:4435 -curves x25519"
echo "===================================="
echo "Shutting Down"
sudo docker compose down
cd ..
