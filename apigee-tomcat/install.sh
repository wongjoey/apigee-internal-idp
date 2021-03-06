#/bin/bash
groupadd -r apigee
useradd -r -g apigee -d /opt/apigee -s /sbin/nologin -c "Apigee platform user" apigee
mkdir -p /opt/apigee/etc/
touch /opt/apigee/etc/defaults.sh
source /opt/apigee/etc/defaults.sh
source apigee-env.sh
#This scripts downloads the latest version of tomcat and install under /opt/apigee directories
curl -o /opt/apigee/apache-tomcat-8.5.34.tar.gz https://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz
tar -xvf /opt/apigee/apache-tomcat-8.5.34.tar.gz -C /opt/apigee/
rm -fr /opt/apigee/apache-tomcat-8.5.34.tar.gz
ln -s  /opt/apigee/apache-tomcat-8.5.34  /opt/apigee/apache-tomcat-idp
cp -fr conf/server.xml /opt/apigee/apache-tomcat-idp/conf/server.xml
mkdir -p /opt/apigee/apache-tomcat-idp/conf/Catalina/localhost/
cp -fr conf/Catalina/localhost/idp.xml /opt/apigee/apache-tomcat-idp/conf/Catalina/localhost/
##Install self signed certs
mkdir -p  /opt/apigee/apache-tomcat-idp/conf/certs
cd /opt/apigee/apache-tomcat-idp/conf/certs
rm -fr *
sudo openssl genrsa -aes256 -passout pass:Secret123 -out key.pem 2048
sudo openssl rsa -in key.pem -passin pass:Secret123  -out key.pem
sudo openssl req -x509 -sha256 -new -key key.pem -out cert.csr  -subj "/C=US/ST=FooState/L=FooLocation/O=Foobar/OU=FooUnit/CN=Foobar.com/emailAddress=foo@ba
r.com" -passin pass:Secret123
sudo openssl x509 -sha256 -days 365 -in cert.csr -signkey key.pem -out cert.pem -passin pass:Secret123
sudo openssl pkcs12 -export -in cert.pem -inkey key.pem -out cert.p12 -password pass:Secret123
sudo keytool -importkeystore -srckeystore cert.p12  -srcstoretype PKCS12  -destkeystore cert.jks -deststoretype JKS -srcstorepass Secret123 -deststorepass Secret123
### Copying run scripts
cd -
echo 'export JAVA_OPTS="$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Xms1024m -Xmx2048m -XX:PermSize=32m"' > /opt/apigee/apache-tomcat-idp/bin/setenv.sh
chmod +x /opt/apigee/apache-tomcat-idp/bin/setenv.sh
mkdir -p /opt/apigee/apache-tomcat-idp/lib
cp -fr apigee-env.sh /opt/apigee/apache-tomcat-idp/lib/
mkdir -p /opt/apigee/apache-tomcat-idp/etc/init.d
cp -fr etc/init.d/apache-tomact-idp /opt/apigee/apache-tomcat-idp/etc/init.d/
chmod +x /opt/apigee/apache-tomcat-idp/etc/init.d/apache-tomact-idp
chown -R ${RUN_USER}:${RUN_GROUP} /opt/apigee/apache-tomcat-idp/