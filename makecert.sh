#!/usr/bin/env bash
#
# Usage: dev_signed_cert.sh HOSTNAME
#
# Creates a CA cert and then generates an SSL certificate signed by that CA for the
# given hostname.
#
# After running this, add the generated dev_cert_ca.cert.pem to the trusted root
# authorities in your browser / client system.
#

set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NAME=${1:-localhost}

CA_KEY=$DIR/dev_cert_ca.key.pem

[ -f $CA_KEY ] || openssl genrsa -des3 -out $CA_KEY 2048

CA_CERT=$DIR/dev_cert_ca.cert.pem

[ -f $CA_CERT ] || openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days 365 -out $CA_CERT

HOST_KEY=$DIR/$NAME.key.pem

[ -f $HOST_KEY ] || openssl genrsa -out $HOST_KEY 2048

HOST_CERT=$DIR/$NAME.cert.pem

if ! [ -f $HOST_CERT ] ; then
    HOST_CSR=$DIR/$NAME.csr.pem
    [ -f $HOST_CSR ] || openssl req -new -key $HOST_KEY -out $HOST_CSR
    HOST_EXT=$DIR/$NAME.ext

    openssl x509 -req -in $HOST_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial \
        -out $HOST_CERT -days 365 -sha256 -extfile $HOST_EXT

fi
