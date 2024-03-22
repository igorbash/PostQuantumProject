We will demonstrate 3 servers: classic, pq only, hybrid and 2 clients: openssl and boringssl


1. Certificates creation for all types of servers - in each certs folder of each server:
    1.1. classic_server:

    
    - Create self signed CA with RSA, named classic CA
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey RSA -keyout /tmp/classic_CA.key -out /tmp/classic_CA.crt -nodes -subj "/CN=classic CA" -days 365
    - Create certificate request with RSA key for domain classic.com
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -new -newkey RSA -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=classic.com"
    - Create the server certificate and sign with the CA
    docker run -v .:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/classic_CA.crt -CAkey /tmp/classic_CA.key -CAcreateserial -days 365

    1.2. pq_server:

    - Create self signed CA with dilithium5, named pq CA 
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey dilithium5 -keyout /tmp/pq_CA.key -out /tmp/pq_CA.crt -nodes -subj "/CN=pq CA" -days 365
    - Create certificate request with dilithium3 key for domain pq.com
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -new -newkey dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=pq.com"
    - Create the server certificate and sign with the CA 
    docker run -v .:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/pq_CA.crt -CAkey /tmp/pq_CA.key -CAcreateserial -days 365

    1.3. hybrid_server:

    - Create self signed CA with p521_dilithium5, named hybrid CA
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey p521_dilithium5 -keyout /tmp/hybrid_CA.key -out /tmp/hybrid_CA.crt -nodes -subj "/CN=hybrid CA" -days 365
    - Create certificate request with p384_dilithium3 key for domain hybrid.com
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -new -newkey p384_dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=hybrid.com"
    - Create the server certificate and sign with the CA
    docker run -v .:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/hybrid_CA.crt -CAkey /tmp/hybrid_CA.key -CAcreateserial -days 365

    * We can use supported signing algorithms (classic and pq) and hybrid alogorithms. The list is in the following link: https://github.com/open-quantum-safe/openssl#authentication      

2. Copy all the ca files to both clients:
    2.1. cp ./*/certs/*_CA.crt .\openssl_client\ca\
    2.2. cp ./*/certs/*_CA.crt .\boringssl_client\ca\

3. The docker compose consists of:
    Run the docker compose:
    - docker-compose up -d
    * private network named test-network
    * 3 types of servers according to their signature algorithms: classic, pq, hybrid. The servers run nginx.
    * 2 clients that support pq algorithms - openssl client and boring ssl client

4. Client Tests:
    4.1. openssl client
        * oqs fork of openssl supports classic, pq only and hybrid signatures and KEM. Those commands will send https get request to each server:
        - GET request to classic server with ecdh (x25519) key exchange - works.
        docker-compose run -it --rm openssl_client  curl --cacert /opt/tmp/classic_CA.crt --curves x25519 https://classic.com:4433
        - GET request to pq server with kyber768 key exchange - works. 
        docker-compose run -it --rm openssl_client  curl --cacert /opt/tmp/pq_CA.crt --curves kyber768 https://pq.com:4434
        - GET request to hybrid server with hybrid sp521_kyber1024 key exchange - works. 
        docker-compose run -it --rm openssl_client  curl --cacert /opt/tmp/hybrid_CA.crt  --curves p521_kyber1024  https://hybrid.com:4435

    4.2. boringssl client
        * oqs fork of boringssl supports classic, pq only and hybrid KEM  but only classic and pq only Signatures. Those commands will send https get request to each server:
        - GET request to classic server with ecdh (x25519) key exchange - works.
        docker-compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: classic.com\r\nConnection: close\r\n\r\n' | bssl client -connect classic.com:4433 -curves x25519"
        - GET request to pq server with kyber768 key exchange - works. 
        docker-compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves kyber768"
        - GET request to pq server with hybrid p521_kyber1024 key exchange - works. 
        docker-compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: pq.com\r\nConnection: close\r\n\r\n' | bssl client -connect pq.com:4434 -curves p521_kyber1024"
        - GET request to hybrid server with x25519 key exchange - NOT WORKING (because boringssl does not support hybrid singatures)
        docker-compose run -it --rm boringssl_client sh -c "echo 'GET / HTTP/1.1\r\nHost: hybrid.com\r\nConnection: close\r\n\r\n' | bssl client -connect hybrid.com:4435 -curves x25519"
    
    * We can use any KEM (classic, hybrid, pq only) from the list: https://github.com/open-quantum-safe/oqs-provider#algorithms

5. Stop the docker compose:
    - docker-compose down
