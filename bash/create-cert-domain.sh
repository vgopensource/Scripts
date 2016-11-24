#!/bin/bash

#Required
domain=$1
commonname=$domain

#Change to your company details
country=GB
state=Nottingham
locality=Nottinghamshire
organization=XenStack.Reseller
organizationalunit=IT
email=info@xenstack.net

#Optional
password=dummypassword


if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi


# Create Directory
mkdir /opt/xenstack-script/newdomains/vhosts/$domain

# Change into Domain Directory
cd /opt/xenstack-script/newdomains/vhosts/$domain/

echo "Creating Configuration Files"

#Copy Configuration Files for Vhosts
cp /opt/xenstack-script/newdomains/vhosts/sample-vhost/portal.xenstack.net.conf /opt/xenstack-script/newdomains/vhosts/$domain/$domain.conf

#Copy SSL Configuration Files for Vhosts
cp /opt/xenstack-script/newdomains/vhosts/sample-vhost/portal-ssl.xenstack.net.conf /opt/xenstack-script/newdomains/vhosts/$domain/$domain-ssl.conf



echo "Changing Values in Configuration Files"

#Change in HTTP File
sed -i -e 's/portal.xenstack.net/'$domain'/g' /opt/xenstack-script/newdomains/vhosts/$domain/$domain.conf


#Change in HTTPS SSL File
sed -i -e 's/portal.xenstack.net/'$domain'/g' /opt/xenstack-script/newdomains/vhosts/$domain/$domain-ssl.conf



# Change into Domain Directory
cd /opt/xenstack-script/newdomains/vhosts/$domain/

echo "Generating key request for $domain"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out $domain.key 2048 -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in $domain.key -passin pass:$password -out $domain.key


#Create the request
echo "Creating CSR"
openssl req -new -key $domain.key -out $domain.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"


#Create Self Signed Certificate
echo "Creating Certificate"
openssl x509 -req -days 365 -in $domain.csr -signkey $domain.key -out $domain.crt

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat $domain.csr

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $domain.key

echo
echo "---------------------------"
echo "-----Below is your Cert-----"
echo "---------------------------"
echo
cat $domain.crt

while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo "$LINE"
done
