#!/bin/sh
if [[ $# -eq 0 ]] ; then
	echo "Please specify host:port"
	exit 1
fi 
openssl s_client -debug -connect $1 -tls1