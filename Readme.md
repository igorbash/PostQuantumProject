1. We will create certifactes for all types of servers - in each certs folder of each server:
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
    docker run -v .:/tmp -it openquantumsafe/curl openssl req -new -newkey p384_dilithium3 -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=hyrbid.com"
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

4. Now curl to the server:
    - docker-compose run -it openssl_client
    - curl --cacert /opt/tmp/CA.crt --curves KEM https://server.com:4433
    * KEM can be one of the following: 
    https://github.com/open-quantum-safe/oqs-provider#algorithms
    * I used kyber768
    * We can see that we get the nginx start page and the authentication and KEM works
    * using curl -v we can see more info

5. We will check now boringssl client:
    - docker-compose run -it boringssl_client
    - bssl client -curves kyber768 -connect server.com:4433
    * We will see the handshake failed, this is because boringssl does not support hybrid signatures, so we will check with server that it's certificate is signed only with quantum alogrithm
    * We will create new pki signed only with dilithium and move the new CA.crt to the boringssl_client folder
    - bssl client -curves kyber768 -connect server_quantum.com:4443
    * Now the connection has been made successfully

6. docker-compose down to stop and remove all the containers
