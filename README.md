# Apigee Internal IDP

## Overview

Apigee UE for OPDK comes with only SAML SSO. To adopt this for an on premise customer, they need have an IDP whch supports SAML2 SSO. This project tries to help you deploy an shibboleth idp and configure  EdgeUE with a local idp server

Further the local idp can either connect to openldap that comes with Apigee Installation or to your own directory service. Thus it makes the Apigee Edge UE available to on-premise for customer base who don't have an SAML2 based IDP.


## Getting Started


### Supported/Tested Software

- centos 7.x
- open jdk 1.8
- Tomcat 8.5.34

### Prerequisites
- Install java 1.8
```
sudo yum install java-1.8.0-openjdk -y
```
- Set JAVA_HOME 
```
export JAVA_HOME=/usr/lib/jvm/jre
```
- Edge Setup

There should be existing edge setup. The idp hooks to the same openldap that comes installed with edge. The idp can be installed on same machine as edge management server or you can install idp on an aio setup.

### Install Tomcat

```
cd apigee-tomcat
./install.sh
```


### Configure Tomcat with certificates

The initial install command installs self signed certificates for convinience. However if you want to redo the certificate or use your own certificates, follow these steps


- Create your own Self Signed
```
mkdir -p /opt/apigee/apache-tomcat-idp/conf/certs
cd /opt/apigee/apache-tomcat-idp/conf/certs
sudo openssl genrsa -aes256 -passout pass:Secret123 -out key.pem 2048
sudo openssl rsa -in key.pem -passin pass:Secret123  -out key.pem
sudo openssl req -x509 -sha256 -new -key key.pem -out cert.csr  -subj "/C=US/ST=FooState/L=FooLocation/O=Foobar/OU=FooUnit/CN=Foobar.com/emailAddress=foo@ba
r.com" -passin pass:Secret123
sudo openssl x509 -sha256 -days 365 -in cert.csr -signkey key.pem -out cert.pem -passin pass:Secret123
```

- Change to p12 format from cert and key
```
sudo openssl pkcs12 -export -in cert.pem -inkey key.pem -out cert.p12 -password pass:Secret123
```
- Change to keystore format from p12 cert. Specify other parameter as needed.
```
sudo keytool -importkeystore -srckeystore cert.p12  -srcstoretype PKCS12  -destkeystore cert.jks -deststoretype JKS -srcstorepass Secret123 -deststorepass Secret123
```

- Edit  /opt/apigee/apache-tomcat-idp/conf/server.xml and change accordingly
```
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol" 
                    maxThreads="150" SSLEnabled="true" scheme="https" secure="true" 
                    clientAuth="false" sslProtocol="TLS" 
                    keystoreFile="conf/certs/cert.jks" keystorePass="Secret123">
    </Connector>
```

### Install shibboleth

- Create a config file and install shibboleth with the config file

```
IDP_HOSTNAME=<public hostname>
IDP_PORT=8443
IDP_SCHEME=https
IDP_SEALER_PASSWORD=Secret123
IDP_KEYSTORE_PASSWORD=Secret123
IDP_SEALER_KEYPASSWORD=Secret123
IDP_SEALER_STOREPASSWORD=Secret123
LDAP_HOSTNAME=localhost
LDAP_PORT=10389
EDGE_UE_URL=http://<hostname>:3001
APIGEE_ADMINPW=Secret123
```

- Install shibboleth
```
cd shibboleth-idp
./install.sh idp-config.txt
```

### Changes routes in edge-management-ui

There are some changes in routes that needs to be done to allow forgot password link to work. This script needs to be executed in the new edge ue box.

```
cd edge-management-ui
./configure.sh
```

### Start Apigee Internal Idp Service

```
/opt/apigee/apache-tomcat-idp/etc/init.d/apache-tomact-idp start
```

### Stop Apigee Internal Idp Service

```
/opt/apigee/apache-tomcat-idp/etc/init.d/apache-tomact-idp stop
```

### Get the metadata of Internal idp

You should be able to access the idp metadata:
```
curl -k https://<idp-hostname>:<idp-port>/idp/shibboleth
```

### Configue UE with this idp

Follow the documentation [here] https://docs.apigee.com/private-cloud/v4.18.05/installing-beta-release-edge-new-unified-experience


### Run user
The current installation runs the idp as apigee user. To change it, edit apigee-env.sh in both apache-tomcat and shibboleth-idp and redo the install.sh script.


## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.