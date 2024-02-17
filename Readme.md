1. Create self signed certificate signed with signature type.
    1.1. Using openquantumsafe/curl docker image:
    """
    In Server/certs folder run:
     - docker run -v .:/tmp -it openquantumsafe/curl openssl req -x509 -new -newkey <SIG> -keyout /tmp/CA.key -out /tmp/CA.crt -nodes -subj "/CN=oqstest CA" -days 365
     - docker run -v .:/tmp -it openquantumsafe/curl openssl req -new -newkey <SIG> -keyout /tmp/server.key -out /tmp/server.csr -nodes -subj "/CN=<DOMAIN>"
     - docker run -v .:/tmp -it openquantumsafe/curl openssl x509 -req -in /tmp/server.csr -out /tmp/server.crt -CA /tmp/CA.crt -CAkey /tmp/CA.key -CAcreateserial -days 365
    """
    * The <SIG> algorithm can be one of the following: https://github.com/open-quantum-safe/openssl#authentication 
    * For the CA I used hybrid p521_dilithium5 and for the server I ulssed hybrid p384_dilithium3
    * I chose the domain server.com
    1.2. Copy CA.crt to Client/ca 

2. The docker compose consists of:
    - private network named test-network
    - server which is run using nginx and the certifcates we generated above and supports post quantum cryptography and TLS
    - client which uses curl which supports post quantum cryptography and TLS
    * Run docker-compose up -d

3. Enter the client container:
    - docker-compose run -it client 

4. Now curl to the server:
    - docker-compose run -it openssl_client
    - curl --cacert /opt/tmp/CA.crt --curves <KEM> https://server.com:4433
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
