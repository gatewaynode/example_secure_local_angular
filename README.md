# Example of Making Angular Secure with TLS Certificates and the HTTPS protocol

This is a default Angular project modified to run development and tests using self signed certificates.  As implied this requires 2 different configuration changes to the Angular project, changing the angular.json file for development serving and changing the karma.conf.js file for testing.  It is also required to either have some self signed certs for `localhost` or generate them using `openssl`.

So most of this project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 12.1.3, so any deviation from that needs to be considered and adapted for.

## Step 1: Generating self signed certificates

Normally I would recommend the excellent [mkcert](https://github.com/filosottile/mkcert) package to create a local CA and generate the certs off that local CA.  But sometimes you just can't do that, so if you can find openssl on your dev system here's a way to leverage that.

```bash
openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes -keyout localhost.key -days 3560 -out localhost.crt -config certificate.cnf
```

Now add these two lines to your `.gitignore` file:

```bash
*.crt
*.key
```

This parameter soup will generate two files, `localhost.key` and `localhost.crt`.  The `.key` file is very sensitive, always considered private, and should never be shared.  The `.crt` file is a public certificate in the x509 format and can be shared, but out of a sense of consistency for security, should never be in code.

## Step 2: Set Angular to serve locally with TLS(HTTPS protocol)

The Angular general configuration file needs to be modified to contain an `options` section which will contain: a boolean flag to serve SSL, a location for the certificate private key file, and a location for the public x509 certificate file.

The server configuration section is going to be in `angular.json` or `angular-cli.json` depending on your version.  The changes are in the `"options"` sub array.

```json
       ...
       "serve": {
         "builder": "@angular-devkit/build-angular:dev-server",
         "configurations": {
           "production": {
             "browserTarget": "angular-base:build:production"
           },
           "development": {
             "browserTarget": "angular-base:build:development"
           }
         },
         "defaultConfiguration": "development",
         "options": 
         {
           "ssl": true,
           "sslKey": "localhost.key",
           "sslCert": "localhost.crt"
         }
       },
```

## Step 3: Set Angular test runners to run with TLS(HTTPS)

By default this will be in `karma.conf.js` but more likely you'll want to add this to the Cypress config, more on that later.  This just covers the Karma conf file.

At the top of the `karma.conf.js` file add this require statement below the opening comments.

```javascript
// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html

// Required to load the TLS certs from files
var fs = require('fs');
...
```

And add this set of options at the bottom (starting with `httpsServerOptions`):

```javascript
    ...
    singleRun: false,
    restartOnFileChange: true,
    httpsServerOptions: {
      key: fs.readFileSync('localhost.key', 'utf8'),
      cert: fs.readFileSync('localhost.crt', 'utf8')
    },
    protocol: 'https'
  });
};
```

# Conclusion

And that's it.  Now your local angular server should work over HTTPS (and only HTTPS), and your tests should run over HTTPS.