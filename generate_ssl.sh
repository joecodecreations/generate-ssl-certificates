#!/bin/bash/

#VARIABLES

#set random password 1024 length
PASSWORD=$(openssl rand -base64 1024)
#folder for the certs
FOLDER="./certs"
FILE="server"

#if we are missing either they key or crt
if [ ! -f $FOLDER/"$FILE".key  ] || [ ! -f $FOLDER/"$FILE".crt  ]; then

      #removes existing keys if any exist
      rm $FOLDER/"$FILE".crt 2> /dev/null
      rm $FOLDER/"$FILE".key 2> /dev/null

      #make our directory for the certs
      mkdir $FOLDER 2> /dev/null

      #start SSL generation
      echo '...........generating '"$FILE"'.key'
      openssl genrsa -des3 -out "$FOLDER"/"$FILE".key  -passout pass:"$PASSWORD" 1024 2> /dev/null
      echo "$FILE"'.key generated!\n'
      echo '...........creating '"$FILE"'.csr'
      openssl req -new -key "$FOLDER"/"$FILE".key -passin pass:"$PASSWORD"  -out "$FOLDER"/"$FILE".csr  -subj  "/C=GB/ST=North Carolina/L=Raleigh/O=Red Hat/OU=redhat/CN=redhat.com" 2> /dev/null
      echo "$FILE"'.csr created!\n'
      echo '...........creating '"$FILE"'.key.org'
      cp "$FOLDER"/"$FILE".key "$FOLDER"/"$FILE".key.org && openssl rsa -in "$FOLDER"/"$FILE".key.org -passin pass:"$PASSWORD" -out "$FOLDER"/"$FILE".key -passout pass:"$PASSWORD" 2> /dev/null
      echo 'key generated!\n'
      echo '...........Creating '"$FILE"'.crt'
      openssl x509 -req -days 365 -in "$FOLDER"/"$FILE".csr -signkey "$FOLDER"/"$FILE".key -out "$FOLDER"/"$FILE".crt
      echo "$FILE"'.crt created!\n'
      echo '......cleaning up'
      #cleanup unused files
      rm "$FOLDER"/"$FILE".csr "$FOLDER"/"$FILE".key.org
      echo 'cleanup finished!\n'
      echo 'SSL files created and installed! - DONE'
else
      #Both Key and crt present - do nothing
      echo 'SSL Already Installed...Continuing'
fi

