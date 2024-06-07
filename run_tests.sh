#!/bin/bash

echo "Creating classic server certificates"
echo "===================================="
echo "Creating self signed CA with RSA, named classic CA"
sudo docker run -u root -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey RSA -keyout /tmp/classic_CA.key -out /tmp/classic_CA.crt -nodes -subj "/CN=classic CA" -days 365
echo "Creating certificate request with RSA key for domain classic.com"
sudo docker run -u root -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey RSA -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=classic.com"
echo "Creating the server certificate and sign with the CA"
sudo docker run -u root -v ./tests/classic_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/classic_CA.crt -CAkey /tmp/classic_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Creating pq server certificates"
echo "===================================="
echo "Creating self signed CA with dilithium5, named pq CA" 
sudo docker run -u root -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey dilithium5 -keyout /tmp/pq_CA.key -out /tmp/pq_CA.crt -nodes -subj "/CN=pq CA" -days 365
echo "Creating certificate request with dilithium3 key for domain pq.com"
sudo docker run -u root -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=pq.com"
echo "Creating the server certificate and sign with the CA" 
sudo docker run -u root -v ./tests/pq_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/pq_CA.crt -CAkey /tmp/pq_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Creating hybrid server certificates"
echo "===================================="
echo "Creating self signed CA with p521_dilithium5, named hybrid CA"
sudo docker run -u root -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey p521_dilithium5 -keyout /tmp/hybrid_CA.key -out /tmp/hybrid_CA.crt -nodes -subj "/CN=hybrid CA" -days 365
echo "Creating certificate request with p384_dilithium3 key for domain hybrid.com"
sudo docker run -u root -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl req -new -newkey p384_dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=hybrid.com"
echo "Creating the server certificate and sign with the CA"
sudo docker run -u root -v ./tests/hybrid_server/certs/:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/hybrid_CA.crt -CAkey /tmp/hybrid_CA.key -CAcreateserial -days 365
echo "===================================="
echo "Copying ca files to BoringSSl client and openSSL client"
cp ./tests/*/certs/*_CA.crt ./tests/openssl_client/ca/
cp ./tests/*/certs/*_CA.crt ./tests/boringssl_client/ca/
echo "===================================="
echo "Running docker compose"
cd tests
sudo docker compose up -d
echo "===================================="
echo "Testing openSSL client"
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/classic_CA.crt --curves x25519 https://classic.com:4433
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/classic_CA.crt --curves kyber768 https://classic.com:4433
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/classic_CA.crt --curves x25519_kyber768 https://classic.com:4433
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/pq_CA.crt --curves x25519 https://pq.com:4434
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/pq_CA.crt --curves kyber768 https://pq.com:4434
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/pq_CA.crt --curves x25519_kyber768 https://pq.com:4434
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/hybrid_CA.crt  --curves x25519  https://hybrid.com:4435
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/hybrid_CA.crt  --curves kyber768  https://hybrid.com:4435
sudo docker compose run -u root -it --rm openssl_client  curl --cacert /opt/tmp/hybrid_CA.crt  --curves x25519_kyber768  https://hybrid.com:4435
echo "===================================="
echo "Testing boringSSL client"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: classic.com\r\nConnection: close\r\n\r\n' | bssl client -connect classic.com:4433 -curves x25519"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: classic.com\r\nConnection: close\r\n\r\n' | bssl client -connect classic.com:4433 -curves kyber768"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: classic.com\r\nConnection: close\r\n\r\n' | bssl client -connect classic.com:4433 -curves x25519_kyber768"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves x25519"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves kyber768"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves x25519_kyber768"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: hybrid.com\r\nConnection: close\r\n\r\n' | bssl client -connect hybrid.com:4435 -curves x25519"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: hybrid.com\r\nConnection: close\r\n\r\n' | bssl client -connect hybrid.com:4435 -curves kyber768"
sudo docker compose run -u root -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: hybrid.com\r\nConnection: close\r\n\r\n' | bssl client -connect hybrid.com:4435 -curves x25519_kyber768"
echo "===================================="
echo "Showing Results"
echo "Shutting Down"
sudo docker compose down
cd ..
