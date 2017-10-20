#!/bin/bash
# Create the necessary files for a (self-signed) SSL cluster
#set -o nounset \
#    -o errexit \
#    -o verbose \
#    -o xtrace

if [[ $# -eq 0 ]] ; then
	echo "Please specify password as first argument"
	exit 1
fi 

# Generate CA key
openssl req -new -x509 -keyout MYDOMAIN-ca.key -out MYDOMAIN-ca.crt -days 365 -subj '/CN=ca.mydomain.com/OU=DNA/O=CDK/L=Hometown/S=AK/C=US' -passin pass:$1 -passout pass:$1

# Kafkacat
openssl genrsa -des3 -passout "pass:$1" -out kafka.client.key 1024
openssl req -passin "pass:$1" -passout "pass:$1" -key kafka.client.key -new -out kafka.client.req -subj '/CN=kafkaclient.mydomain.com/OU=DNA/O=CDK/L=Hometown/S=AK/C=US'
openssl x509 -req -CA MYDOMAIN-ca.crt -CAkey MYDOMAIN-ca.key -in kafka.client.req -out kafka-client-ca-signed.pem -days 9999 -CAcreateserial -passin "pass:$1"



#for i in broker1 broker2 broker3 producer consumer
for i in broker1 producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i.kafka.mydomain.com, OU=DNA, O=CDK, L=Hometown, S=AK, C=US" \
				 -keystore kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass $1 \
				 -keypass $1

	# Create CSR, sign the key and import back into keystore
	keytool -keystore kafka.$i.keystore.jks -alias $i -certreq -file $i.csr -storepass $1 -keypass $1

	openssl x509 -req -CA MYDOMAIN-ca.crt -CAkey MYDOMAIN-ca.key -in $i.csr -out $i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:$1

	keytool -keystore kafka.$i.keystore.jks -alias CARoot -import -file MYDOMAIN-ca.crt -storepass $1 -keypass $1

	keytool -keystore kafka.$i.keystore.jks -alias $i -import -file $i-ca1-signed.crt -storepass $1 -keypass $1

	# Create truststore and import the CA cert.
	keytool -keystore kafka.$i.truststore.jks -alias CARoot -import -file MYDOMAIN-ca.crt -storepass $1 -keypass $1

  echo "$1" > ${i}_sslkey_creds
  echo "$1" > ${i}_keystore_creds
  echo "$1" > ${i}_truststore_creds
done
