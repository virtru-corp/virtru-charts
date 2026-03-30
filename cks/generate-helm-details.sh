#!/bin/bash

SCRIPT_DIR=$( dirname -- "$( readlink -f -- "$0"; )"; )
CKS_VERSION="$(head -1 "$SCRIPT_DIR"/VERSION | sed 's/ //g')"

RED="\033[1;31m"
BOLD="\033[1m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
RESET="\033[0m"
CLEAR="\033c"

# Defaults
PORT=9000
LOG_RSYS_ENABLED=false
LOG_CONSOLE_ENABLED=true
AUTH_TOKEN_STORAGE_TYPE="in-memory"
KEY_PROVIDER_TYPE="file"
KEY_PROVIDER_PATH="/app/keys"
HMAC_AUTH_ENABLED=false
JWT_AUTH_ENABLED=true
JWT_AUTH_AUDIENCE=""

# Yes or No Prompt
prompt () {
  while true; do
    read -p "$1 " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# ECC vs RSA Prompt
promptRsa () {
  while true; do
    read -p "Enter Key Type [RSA/ECC] (default RSA): " kt
    # Default to RSA if input is empty
    if [[ -z "$kt" ]]; then
      return 0
    fi

    # Check user input
    case $kt in
      [Rr][Ss][Aa]* ) return 0;;
      [Ee][Cc][Cc]* ) return 1;;
      * ) echo "Please answer RSA or ECC.";;
    esac
  done
}

# Create Directory (prompt if exists to overwrite)
mkdirCheck () {
 if [ -d "$1" ]; then
  if prompt "Directory \"$1\" already exist! Do you want to replace \"$1\" [yes/no]?"; then
    rm -rf $1
    mkdir -p $1
  fi
 else
  mkdir -p $1
 fi
}

printf "${CLEAR}${GREEN}****************************************\n            CKS SETUP WIZARD\n****************************************\n${RESET}\n"

# Verify that openssl is available in the path and executable
if ! command -v openssl &> /dev/null
then
    echo "openssl is required to setup CKS and could not be found."
    exit
fi

# Verify that uuidgen is available in the path and executable
if ! command -v uuidgen &> /dev/null
then
    echo "uuidgen is required setup CKS and could not be found."
    exit
fi

read -p "Enter Working Directory: " WORKING_DIR

# Create Directories
mkdirCheck $WORKING_DIR
mkdir -p $WORKING_DIR/{ssl,keys,env,token-store}

read -p "Define CKS URL (FQDN):
  Enter the URL the CKS will listen on.
  Enter URL [cks.domain.com]: " CKS_FQDN

read -p "Enter the support email for your CKS Deployment: " SUPPORT_EMAIL
read -p "Enter the support url for your CKS Deployment: " SUPPORT_URL

printf "\nWORKING DIR is $WORKING_DIR\n"
printf "CKS FQDN is $CKS_FQDN\n"
printf "SUPPORT_EMAIL is $SUPPORT_EMAIL\n"
printf "SUPPORT_URL is $SUPPORT_URL\n\n"

l=0

while [ $l -ne 36 ]; do
  read -p "Enter your Virtru Org ID: " JWT_AUTH_AUDIENCE

  l=${#JWT_AUTH_AUDIENCE}

  if [ $l -ne 36 ]; then
    printf "This is not a valid Virtru Org ID.\n"
  fi
done

printf "\nRequests from Virtru to your CKS are authenticated with JWTs.\n"
printf "Authentication via HMACs may be enabled to support requests from CSE to CKS.\n\n"

if prompt "Do you want to enable auth via HMAC [yes/no]?"; then
  HMAC_AUTH_ENABLED=true
fi

# Change to the Working Directory specified by the User
cd $WORKING_DIR

# Generate the Self-Signed Certificate
openssl req -x509 -newkey rsa:2048 -nodes -keyout ./ssl/${CKS_FQDN}.key -out ./ssl/${CKS_FQDN}.crt -days 365

# Combine Key and Certificate
cat ./ssl/${CKS_FQDN}.key `find ./ssl/ -type f \( -name "${CKS_FQDN}*.csr" -or -name "${CKS_FQDN}*.crt" \)` `find ./ssl/ -type f \( ! -name "${CKS_FQDN}*" -and ! -name "ssl.pem" \)` > ./ssl/ssl.pem
chmod 644 ./ssl/${CKS_FQDN}.key

# Generate ECC or RSA key pair based on user input
if promptRsa; then
  KEY_TYPE="RSA"

  # Set Key Path for RSA
  PRIV_KEY_PATH="./keys/rsa_001.pem"
  PUB_KEY_PATH="./keys/rsa_001.pub"
  # Generate RSA Key Pair
  openssl genrsa -out $PRIV_KEY_PATH 2048
  openssl rsa -in $PRIV_KEY_PATH -outform PEM -pubout -out $PUB_KEY_PATH
  
  FINGERPRINT=$(openssl rsa -in $PUB_KEY_PATH -pubin -outform der | openssl dgst -sha256 -binary | base64)
  FINGERPRINT=$(echo ${FINGERPRINT//[+]/-})
  FINGERPRINT=$(echo ${FINGERPRINT//[\/]/_})
  FINGERPRINT=$(echo ${FINGERPRINT//[=]/''})

  chmod 644 $PRIV_KEY_PATH
  chmod 644 $PUB_KEY_PATH
else
  KEY_TYPE="ECC"

  # Set Key Path for ECC
  PRIV_KEY_PATH="./keys/ecc_p256_001.pem"
  PUB_KEY_PATH="./keys/ecc_p256_001.pub"

  # Generate an ECC Key Pair
  openssl ecparam -name prime256v1 -genkey -noout | openssl pkcs8 -topk8 -nocrypt -out $PRIV_KEY_PATH
  openssl ec -in $PRIV_KEY_PATH -pubout -out $PUB_KEY_PATH

  FINGERPRINT=$(openssl ec -in $PUB_KEY_PATH -pubin -outform der | openssl dgst -sha256 -binary | base64)
  FINGERPRINT=$(echo ${FINGERPRINT//[+]/-})
  FINGERPRINT=$(echo ${FINGERPRINT//[\/]/_})
  FINGERPRINT=$(echo ${FINGERPRINT//[=]/''})

  chmod 644 $PRIV_KEY_PATH
  chmod 644 $PUB_KEY_PATH
fi

SECRET_B64_FINAL=""
TOKEN_ID=""
TOKEN_JSON=""

# Create Token (replicating the same logic in the CKS Setup Wizard)
if [ "$HMAC_AUTH_ENABLED" = true ]; then
  UUID1=$(uuidgen | tr -d '-')
  UUID2=$(uuidgen | tr -d '-')
  SECRET=$(printf "%s%s" $UUID1 $UUID2)
  SECRET_B64=$(echo -n "$SECRET" | openssl dgst -sha384 -binary | base64)
  SECRET_B64_FINAL=$(echo ${SECRET_B64//[+]/-})
  SECRET_B64_FINAL=$(echo ${SECRET_B64_FINAL//[\/]/_})

  DATE_STR=$(date +%Y-%m-%d)
  TOKEN_ID=$(printf "virtru-%s@token.virtru.com" $DATE_STR)

  # Create the Tokens File
  TOKEN_JSON=$(printf '[{"displayName": "Token For the Virtru ACM to access this CKS", "tokenId": "%s", "lastModified": "2016-01-01T23:48:18.064Z", "created": "2016-01-01T23:48:18.064Z", "state": "active", "version": "1.0.0", "attributes": [{"value": "virtru", "key": "virtru:data:creator"}, {"value": "admin@virtru.com", "key": "virtru:data:owner"}, {"value": "service", "key": "virtru:service:type"}], "encryptedToken": {"secret": "%s"}}]' "$TOKEN_ID" "$SECRET_B64_FINAL")

  touch ./token-store/tokens.json
  echo "$TOKEN_JSON" >> ./token-store/tokens.json
fi

# Create the Environment File
# This is not needed for the helm deployment
#touch ./env/cks.env

# Write the Environment File
# This is not needed for the helm deployment
#printf "PORT=%s\n" $PORT >> ./env/cks.env
#printf "LOG_RSYSLOG_ENABLED=%s\n" $LOG_RSYS_ENABLED >> ./env/cks.env
#printf "LOG_CONSOLE_ENABLED=%s\n" $LOG_CONSOLE_ENABLED >> ./env/cks.env
#printf "KEY_PROVIDER_TYPE=%s\n" $KEY_PROVIDER_TYPE >> ./env/cks.env
#printf "KEY_PROVIDER_PATH=%s\n" $KEY_PROVIDER_PATH >> ./env/cks.env
#printf "HTTPS_KEY_PATH=%s\n" /app/ssl/$CKS_FQDN.key >> ./env/cks.env
#printf "HTTPS_CERT_PATH=%s\n" /app/ssl/$CKS_FQDN.crt >> ./env/cks.env
#printf "HMAC_AUTH_ENABLED=%s\n" $HMAC_AUTH_ENABLED >> ./env/cks.env
#printf "JWT_AUTH_ENABLED=%s\n" $JWT_AUTH_ENABLED >> ./env/cks.env

#if [ "$HMAC_AUTH_ENABLED" = true ]; then
#  printf "AUTH_TOKEN_STORAGE_TYPE=%s\n" $AUTH_TOKEN_STORAGE_TYPE >> ./env/cks.env
#  printf "AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON=%s\n" "$TOKEN_JSON" >> ./env/cks.env
#fi

#if [ "$JWT_AUTH_ENABLED" = true ]; then
#  printf "JWT_AUTH_AUDIENCE=%s\n" $JWT_AUTH_AUDIENCE >> ./env/cks.env
#fi

# Print Summary
printf "Summary:\n\n"
printf "\tInstallation\n"
printf "\tRoot Directory: %s\n\n" $(pwd)
printf "\tTransport Security\n"
printf "\tCKS URL (FQDN): %s\n" $CKS_FQDN
printf "\tCertificate Expiration Date: %s\n\n" "$(openssl x509 -enddate -noout -in ./ssl/ssl.pem)"
printf "\tCKS Rewrap Key\n"
printf "\tKey Mode: generate\n"
printf "\tKey Path: %s/keys\n" $(pwd)
printf "\tKey Fingerprint: %s\n\n" "$FINGERPRINT"
printf "\tAuth\n"
printf "\tJWT Enabled: %s\n" "$JWT_AUTH_ENABLED"
printf "\tHMAC Enabled: %s\n" "$HMAC_AUTH_ENABLED"
printf "\tVirtru Org ID: %s\n\n" "$JWT_AUTH_AUDIENCE"
printf "\tTroubleshooting\n"
printf "\tSupport URL: %s\n" $SUPPORT_URL
printf "\tSupport Email: %s\n" $SUPPORT_EMAIL

TOKEN_INFO=$(printf '{"support_url": "%s", "host": "%s", "admin_email": "%s", "auth": {"secret": "%s", "key": "%s"}}' "$SUPPORT_URL" "$CKS_FQDN" "$SUPPORT_EMAIL" "$SECRET_B64_FINAL" "$TOKEN_ID")

# Create the Send to Virtru File
mkdir -p cks_info

if [ "$HMAC_AUTH_ENABLED" = true ]; then
  touch ./cks_info/token_info.json
  echo "$TOKEN_INFO" >> ./cks_info/token_info.json
fi

if [ "$KEY_TYPE" = "ECC" ]; then
  cp $PUB_KEY_PATH ./cks_info/ecc_p256_001.pub
else 
  cp $PUB_KEY_PATH ./cks_info/rsa_001.pub
fi

tar -zcvf send_to_virtru.tar.gz ./cks_info

rm -rf ./cks_info

# Create the Run File
#touch ./run.sh

#echo "docker run --name Virtru_CKS --interactive --tty --detach --restart unless-stopped --env-file "$WORKING_DIR"/env/cks.env -p 443:$PORT --mount type=bind,source="$WORKING_DIR"/keys,target="$KEY_PROVIDER_PATH" --mount type=bind,source="$WORKING_DIR"/ssl,target=/app/ssl containers.virtru.com/cks:v"$CKS_VERSION" serve" > ./run.sh