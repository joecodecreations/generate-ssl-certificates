#!/bin/bash/

# VARIABLES
AUTOMATED="FALSE" # If FALSE, It will prompt you with questions. Otherwise set to TRUE and edit variables on lines 9-14

if [ "$AUTOMATED" = "TRUE" ];
then
  # IF No Prompt, Modify These vairables
    DOMAIN="codecreations.net" #Enter your website domain (without http://www)
    COMPANY="joecodecreations" #Enter your company Name
    CITY="Raleigh" #enter Your city
    STATE="North Carolina" #Enter your etate
    FOLDER="./certs" #the folder we will create to put the certificates in
    FILE="server" # The name of the files we will create (ie. server.key, server.crt, server.csr)
else
  echo "Enter your website domain (without http://www) then press [Enter]:"
  read DOMAIN

  echo "Enter your company name then press [Enter]:"
  read COMPANY

  echo "Enter your city then press [Enter]:"
  read CITY

  echo "Enter your State then press [Enter]:"
  read STATE

  echo "What folder do you want your certificates to be put into, Default is ./certs:, then press [Enter]"
  read FOLDERENTER

if [[ ! "$FOLDERENTER" ]]; then
    FOLDER="./certs"
  else
    FOLDER="$FOLDERENTER"
  fi

  echo "Enter the file names to be used, default is server (ie. server.key, server.crt, server.csr), then press [Enter]"
  read FILEENTER

if [[ ! "$FILEENTER" ]]; then
   FILE="server"
  else
   FILE="$FILEENTER"
  fi
fi
# Other Variables
  PASSWORD=$(openssl rand -base64 1024) #Create a random password to use with 1024 length


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
      openssl req -new -key "$FOLDER"/"$FILE".key -passin pass:"$PASSWORD"  -out "$FOLDER"/"$FILE".csr  -subj  "/C=GB/ST=$STATE/L=$CITY/O=$COMPANY/OU=$COMPANY/CN=$DOMAIN" 2> /dev/null
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
