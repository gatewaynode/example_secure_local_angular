#!/usr/bin/env bash
#
# Make a basic angular app serve over HTTPS with self signed certs.
#
# This is derived from a couple of different sources:
# https://medium.com/@rubenvermeulen/running-angular-cli-over-https-with-a-trusted-certificate-4a0d5f92747a
# https://medium.com/@richardr39/using-angular-cli-to-serve-over-https-locally-70dab07417c8
# https://nodejs.org/en/knowledge/HTTP/servers/how-to-create-a-HTTPS-server/
#
# https://stackoverflow.com/questions/54453112/how-to-run-angular-with-https-when-by-default-it-runs-with-http
#
# Alternately the angular.json or angular-cli.json can have the "serve" section
# adjusted with the ssl boolean and the key and cert
# 
# "serve": {
#          "builder": "@angular-devkit/build-angular:dev-server",
#          "configurations": {
#            "production": {
#              "browserTarget": "angular-base:build:production"
#            },
#            "development": {
#              "browserTarget": "angular-base:build:development"
#            }
#          },
#          "defaultConfiguration": "development",
#          "options": 
#          {
#            "ssl": true,
#            "sslKey": "localhost.key",
#            "sslCert": "localhost.crt"
#          }
#        },
#
# For testing with the Karma framework we need to set the self signed keys in 
# karma.conf.js
#    // Required to load the TLS certs from files
#    var fs = require('fs');
#    ...
#    singleRun: false,
#    restartOnFileChange: true,
#    httpsServerOptions: {
#      key: fs.readFileSync('localhost.key', 'utf8'),
#      cert: fs.readFileSync('localhost.crt', 'utf8')
#    },
#    protocol: 'https'
#
#
# For non-interactively trusting the certificate, at least in Linux:
#
# sudo cp localhost.crt /usr/local/share/ca-certificates/
# sudo update-ca-certificates
#
# For more ways to non-interactively trust check here: https://unix.stackexchange.com/questions/90450/adding-a-self-signed-certificate-to-the-trusted-list
# There are differences between Debian and Redhat trust file layouts and operations

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
