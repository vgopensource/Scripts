#!/bin/bash
 
file="/opt/mnt/domains/alldomains.txt"
Default_HTTP_File="/etc/apache2/sites-available/portal.xenstack.net.conf"
Default_HTTPS_FILE="/etc/apache2/sites-available/portal-ssl.xenstack.net.conf"
Apache_File_Location="/etc/apache2/sites-available"
staging_dns="staging.xenstack.net"
ETC_HOSTS="/etc/hosts"
dir_root="/var/www/html"
enabled_site="/etc/apache2/sites-enabled"
 
if [ -f "$file" ]
 
then
 
        echo "$file found."
 
        while read -r line
 
        do
 
          name="$line"
 
          HTTP_Domain="$name.conf"
 
          SSL_Domain="$name-ssl.conf"
 
          echo "Name read from file - $name"
 
          cd $Apache_File_Location
 
          echo $pwd
 
          if [ -f "$HTTP_Domain" ]
          then
              echo "Domains $file already exists skipping now"
 
          else
              echo "Domain Doesn't exist , Creating the domain"
 
              touch  "$Apache_File_Location/$name.conf"
 
              cp $Default_HTTP_File $name.conf
 
              sed -i -e "s/${staging_dns}/${name}/g" $HTTP_Domain
 
              touch  "$Apache_File_Location/$name-ssl.conf"
 
              cp $Default_HTTPS_FILE $name-ssl.conf
 
              sed -i -e "s/${staging_dns}/${name}/g" $SSL_Domain
 
              if [ -n "$(grep $name $ETC_HOSTS)" ]
 
              then
 
                  echo "$name already exists : $(grep $name $ETC_HOSTS)"
 
              else
                  echo "10.71.1.12  $name" >> /etc/hosts
                  echo "10.71.1.35  owncloud.$name" >> /etc/hosts
                  echo "10.71.1.10  client.$name" >> /etc/hosts
 
              fi
 
              mkdir -p "$dir_root/$name"
 
              cd $enabled_site
 
              sudo a2ensite $HTTP_Domain
 
              sudo a2ensite $SSL_Domain
 
              sudo service apache2 reload
           fi
 
 
        done < "$file"
 
else
        echo "$file not found."
fi