#!/usr/bin/env bash
#
# Make a basic angular app serve over HTTPS with self signed certs.
#

echo "[req]
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
C = US
ST = Atlanta
L = Atlanta
O = My Organisation
OU = My Organisational Unit
emailAddress = email@domain.com
CN = localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost" > certificate.cnf

sed -i 's/\"ng serve\",$/\"ng serve --ssl --ssl-key localhost.key --ssl-cert localhost.crt\",/g' package.json

openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -keyout localhost.key -days 3560 -out localhost.crt -config certificate.cnf
