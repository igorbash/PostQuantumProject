#!/bin/bash
openssl req -newkey rsa:4096 -nodes -keyout server.key -x509 -sha256 -days 365 -subj "/C=US/ST=WA/L=SEATTLE/O=MyCompany/OU=MyDivision/CN=pqs_proxy.com" -addext "subjectAltName = DNS:pqs_proxy.com" -out server.crt
