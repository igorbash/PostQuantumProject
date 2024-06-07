Requirements:
    - docker
    - docker compose
    - linux system (Everything can run on windows or mac because of the dockers)

The project consists of 3 parts:

    1. Demonstration of 3 different servers - classic, pq only, hybrid, and 2 different clients - openSSL and boringSSL - all are forks of OQS and can support post quantum cryptography. The difference is in their certificates.
    * OQS = open quantum safe - opensource project to support quantum safe algorithms in openssl and more.

    2. Post Quantum Proxy

    3. Post Quantum Https forward proxy for chrome

================== PQ servers and clients tests ====================
- to run all the tests simply run - ./run_tests.sh
-  We can see the results clearly in the table shown after the script run.
Description:
a. First there is a certificates creation using the following commands:
    - self signed CA creation
    openssl req -x509 -new -newkey [SIG_ALG] -keyout CA.key -out CA.crt -nodes -subj "/CN=CA" -days 365
    - Create certificate request with [SIG_ALG]:
    openssl req -new -newkey [SIG_ALG] -keyout server.key -out server.csr -nodes -subj "/CN=server.com"
    - Create the server certificate and sign with the CA
    openssl x509 -req -in server.csr -out server.crt -CA CA.crt -CAkey CA.key -CAcreateserial -days 365

    * [SIG_ALG] can be classic, hybrid or post quantum only - The list is in the following link: https://github.com/open-quantum-safe/openssl#authentication      
b. Running http get requests using 2 different clients: openSSL and boringSSL.
    * openSSL supports - classic, hybrid and postquantum signatures and KEM.
    * boringSSL supports - classic signatures only and classic hybrid and postquantum only KEM.
    a. To use openSSL: curl --cacert CA.crt --curves [KEM] https://server.com:4433
    b. To use boringSSL: bssl client -connect example.com:4433 -curves [KEM]
    * [KEM] can be classic, hybrid or post quantum only - the list: https://github.com/open-quantum-safe/oqs-provider#algorithms.


* For now, classical algorithms are safe. But when they won't, attacker could decrypt old data they saved. So the best option is to use at least Hybrid KEMS for our data to be secure in the future to (if someone collects it). The use of hybrid signatures can be delayed.
* Full commands using dockers are in the script
================== PQ Proxy ====================

We will demonstrate the use of post quantum safe gateway, which would allow us to be protected against quantum eavedroppers on our traffic.
Our client would be openssl client that support postquanutm KEM and signatrues.
Our server would be the domain example.com that is not have support for post quantum algorithms.
We would use https proxy - pqsProxy.com, that would send our requests to the internet, but the connection between the client and the proxy would be quantum Safe.

1. In folder pqs_proxy, we have client and proxy. Client will be oqs openssl. Proxy would be oqs apache to support the hybrid tls and would do the requests for the client with the classic and not quantum safe servers (example.com for example)
2. We created hybrid certificates for the proxy and self signed using CA we created.
3. The docker compose would start the client and proxy and also wireshark to see the traffic
4. run and test:
    - docker-compose up -d
    - We try to get example.com using hybrid method - it won't work 
    docker-compose run -it --rm client curl https://wtfismyip.com/json --curves p521_kyber1024
    - Now we using the proxy, which supports quantum safe algorithms. The client will do the TLS with the proxy in quantum safe way, and the proxy will do the TLS with the server, in classic way, and return the result to the client. 
    docker-compose run -it --rm client curl -x https://pqProxy.com:4433 https://example.com
    - To watch the traffic and see the handshakes we can use wireshark.
    We would see: 
    * First handshake between client and proxy succeeds by using hybrid method.
    * Second handshake betwwen proxy and server succeeds by using classic method.

* We can run the script run_pqs_proxy.sh to run the proxy and client and then watch the traffic in wireshark

==========================Chrome PQ Proxy===================================

We will create our proxy to use with chrome. Chrome supports only hybrid KEM so we will use classic certificate.
* To create local certificates use the script chrome_pq_proxy/create_certs.sh - put the created scripts in chrome_pq_proxy/proxy/certs
* Start the docker compose and run chrome using the script run_chrome.sh:
    Will start chrome using our proxy
* This can be used in cloud and use real certificates.

-- In the cloud:
1. Create real certificates and put them in chrome_pq_proxy/proxy/certs
2. run docker-compose up -d from the chrome_pq_proxy folder
3. set up the proxy domain in your computer with port 4433