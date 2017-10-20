#!/bin/sh
# Bundle the broker credentials into ${broker-secrets}
kubectl create secret generic broker-secrets \
--from-file=kafka.broker1.keystore.jks=kafka.broker1.keystore.jks \
--from-file=kafka.broker1.truststore.jks=kafka.broker1.truststore.jks \
--from-file=broker1_keystore_creds=broker1_keystore_creds \
--from-file=broker1_truststore_creds=broker1_truststore_creds \
--from-file=broker1_sslkey_creds=broker1_sslkey_creds