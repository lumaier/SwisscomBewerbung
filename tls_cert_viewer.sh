#!/bin/bash

# set the URL and standard port for TLS
URL=$1
PORT=443

echo ""
echo "====== Server Certificate for $URL ======"
echo ""

# retrieve the certificate and save it in intermediate file (PEM format)
echo | openssl s_client -connect $URL:$PORT 2>/dev/null | openssl x509 -outform pem > certificate.pem

# display most important certificate information
echo "Issuer:"
openssl x509 -in certificate.pem -noout -issuer | sed 's/[^=]*=//'
echo ""

echo "Subject:"
openssl x509 -in certificate.pem -noout -subject | sed 's/[^=]*=//'
echo ""

echo "Subject alternative names"
openssl x509 -in certificate.pem -noout -text | grep -A1 'Subject Alternative Name' | tail -n1 | sed 's/DNS://g' | sed 's/^[[:space:]]*//'
echo ""

echo "Issue date:"
openssl x509 -in certificate.pem -noout -startdate | sed 's/[^=]*=//'
echo ""

echo "Expiration date:"
openssl x509 -in certificate.pem -noout -enddate | sed 's/[^=]*=//'
echo ""

openssl x509 -in certificate.pem -noout -sigopt no_pubkey -text | tac |  sed -n '1,/Signature/p' | tac | sed 's/^[[:space:]]*//'
echo ""

echo "Certificate digest:"
echo "SHA256":
openssl x509 -in certificate.pem -noout -sha256 -fingerprint | awk -F= '{print $2}' | sed 's/ //g'
echo "SHA1":
openssl x509 -in certificate.pem -noout -sha1 -fingerprint | awk -F= '{print $2}' | sed 's/ //g'
echo ""

echo "Public key:"
openssl x509 -in certificate.pem -noout -pubkey
echo ""

openssl x509 -in certificate.pem -noout -text | sed -n '/Subject Public Key Info/,/X509v3 extensions/{/x509v3 extensions/!p}' | sed '$d' | sed 's/^[[:space:]]*//'
echo ""

# remove the certificate file
rm certificate.pem
