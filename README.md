# Apigee Internal IDP

## Overview

Apigee UE for OPDK comes with only SAML SSO. To adopt this for an on premise customer, they need have an IDP whch supports SAML2 SSO. This project tries to help you deploy an shibboleth idp and configure  EdgeUE with a local idp server

Further the local idp can either connect to openldap that comes with Apigee Installation or to your own directory services. Thus it makes the Apigee Edge UE available to on-premise for all customer base.


## Architecture 


## Getting Started


### Install Java and Set the JAVA_HOME 

sudo yum install java-1.8.0-openjdk -y

### Install Tomcat

```
cd apigee-tomcat
./install.sh
```


### Configure Tomcat with certificate

Tomcat is installed with a self signed certiticates in the install step. You can create jks from your certs and key by using these commands


```
mkdir -p /opt/apigee/apache-tomcat-idp/conf/certs
cd /opt/apigee/apache-tomcat-idp/conf/certs
```

- Self Signed
```
sudo openssl genrsa -aes256 -passout pass:Secret123 -out key.pem 2048
sudo openssl rsa -in key.pem -passin pass:Secret123  -out key.pem
sudo openssl req -x509 -sha256 -new -key key.pem -out cert.csr  -subj "/C=US/ST=FooState/L=FooLocation/O=Foobar/OU=FooUnit/CN=Foobar.com/emailAddress=foo@ba
r.com" -passin pass:Secret123
sudo openssl x509 -sha256 -days 365 -in cert.csr -signkey key.pem -out cert.pem -passin pass:Secret123
```
- Change to p12 format 
```
sudo openssl pkcs12 -export -in cert.pem -inkey key.pem -out cert.p12 -password pass:Secret123
```
- Change to keystore format from p12 cert. Specify other parameter as needed.
```
sudo keytool -importkeystore -srckeystore cert.p12  -srcstoretype PKCS12  -destkeystore cert.jks -deststoretype JKS -srcstorepass Secret123 -deststorepass Secret123
```

### Install shibboleth

- Create a config file and install shibboleth with the config file

```
IDP_HOSTNAME=localhost
IDP_PORT=8443
IDP_SCHEME=https
IDP_KEYSTORE_PASSWORD=Secret123
IDP_SEALER_KEYPASSWORD=Secret123
IDP_SEALER_STOREPASSWORD=Secret123
EDGE_UE_URL=http://146.148.109.38:3001
APIGEE_SSO_URL=http://146.148.109.38:9099
ADMIN_EMAIL=opdk@apigee.com
APIGEE_ADMINPW=Secret123
```

- Install shibboleth

```
cd shibboleth-idp
./install.sh idp-config.txt
```

### Start Apigee Internal Idp Service 
```
/opt/apigee/apache-tomcat-idp/etc/init.d/apigee-internal-idp start
```

### Stop Apigee Internal Idp Service 
```
/opt/apigee/apache-tomcat-idp/etc/init.d/apigee-internal-idp stop
```



## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.