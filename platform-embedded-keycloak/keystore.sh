#!/bin/bash

echo "Loading Keystore script with keystore: ${JKS_TRUSTSTORE_PATH}"


function init_keystore(){
  if [[ ! -f "${JKS_TRUSTSTORE_PATH}" ]]; then
    local SYSTEM_CACERTS="/etc/pki/java/cacerts"
    echo "INFO  [container.initialization] (keystore-autoconfiguration) Creating Keycloak trust store at: ${JKS_TRUSTSTORE_PATH}."
    if keytool -v -list -keystore "${SYSTEM_CACERTS}" -storepass "changeit" > /dev/null; then
      keytool -importkeystore -noprompt \
          -srckeystore "${SYSTEM_CACERTS}" \
          -destkeystore "${JKS_TRUSTSTORE_PATH}" \
          -srcstoretype jks \
          -deststoretype jks \
          -storepass "${JKS_TRUSTSTORE_PASSWORD}" \
          -srcstorepass "changeit"
    fi
  fi
}

function import_key(){
  # Import a PEM formatted cert (path as argument 1) to the keycloak keystore.
  # If no keystore exists, a new one is created and primed with all system CA certs
  local CERT_FILE=$1
  init_keystore
  echo "Import ${CERT_FILE}"
  echo "INFO  [container.initialization] (keystore-autoconfiguration) Import '${CERT_FILE}' into ${JKS_TRUSTSTORE_PATH}"
  keytool -importcert -noprompt \
      -keystore "${JKS_TRUSTSTORE_PATH}" \
      -file "${CERT_FILE}" \
      -storepass "${JKS_TRUSTSTORE_PASSWORD}" \
      -alias "service-${i}" >& /dev/null
}
