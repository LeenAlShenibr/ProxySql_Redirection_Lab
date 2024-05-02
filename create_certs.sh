#!/bin/bash
set -e 

# Cert directory
rm -rf certs
mkdir -p certs

# CA Key + Cert
openssl req -x509 -newkey  ec:<(openssl ecparam -name prime256v1) -days 365 -nodes \
        -keyout certs/ca.key -out certs/ca.crt \
        -subj "/C=US/ST=NJ/L=T/O=CA/OU=TEST/CN=*.local/emailAddress=someone@gmail.com"

create_ca_signed_certs () {
    local domain="$1"

     # Create CSR & Key 
     openssl req -new -sha256  \
          -newkey ec:<(openssl ecparam -name prime256v1) -nodes -keyout certs/${domain}.key \
          -subj "/C=US/ST=NJ/L=T/O=CA/OU=Education/CN=${domain}" \
          -out certs/${domain}.csr     
     echo "Created key and csr for ${domain}"

     # Sign CSR 
     echo "subjectAltName=DNS:*.${domain},  DNS:${domain}" > certs/${domain}.ext
     openssl x509 -req \
          -in certs/${domain}.csr \
          -CA certs/ca.crt \
          -CAkey certs/ca.key \
          -CAcreateserial \
          -extfile certs/${domain}.ext \
          -out certs/${domain}.crt \
          -days 500 \
          -sha256
     echo "Signed certificate for ${domain}"

    #echo "Signed certificate"
    #openssl x509 -in certs/${domain}.crt -noout -text
}

# Create cert for *.local that's used by docker
create_ca_signed_certs local

# Change into expected names by DB
mv certs/local.key certs/wildcard.key
mv certs/local.crt certs/wildcard.crt
cp certs/ca.crt certs/cacert.crt