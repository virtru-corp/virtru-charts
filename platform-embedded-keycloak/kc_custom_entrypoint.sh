#!/bin/bash

CUSTOM_ARGS=""
# This is the same as the default value of log-gelf-timestamp-format in Keycloak
# This could be improve by retrieving the actual value if this is modified
LOG_TIMESTAMP_FORMAT="+%F %T,%3N"

MYDIR="$(dirname "$(readlink -f "$0")")"
source $MYDIR/keystore.sh

autogenerate_keystores() {
    local CUSTOM_TLS_ARGS=""

    # Inspired by https://github.com/keycloak/keycloak-containers/blob/main/server/tools/x509.sh
    local -r X509_CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"

    pushd /tmp >& /dev/null

    # X509 is a whitespace delimited list of cert file paths.
    CERTS=($X509_CA_BUNDLE)
    echo "$(date "$LOG_TIMESTAMP_FORMAT") INFO  [container.initialization] (keystore-autoconfiguration) Keycloak certs to add to keystore: ${CERTS}."
    init_keystore
    for (( i=0;  i < ${#CERTS[@]};  i++ )); do
        CERT_FILE=${CERTS[$i]}
        import_key $CERT_FILE
    done

    if [[ -f "${JKS_TRUSTSTORE_PATH}" ]]; then
        echo "$(date "$LOG_TIMESTAMP_FORMAT") INFO  [container.initialization] (keystore-autoconfiguration) Keycloak truststore successfully created at: ${JKS_TRUSTSTORE_PATH}."
        CUSTOM_TLS_ARGS+="--spi-truststore-file-file=${JKS_TRUSTSTORE_PATH} --spi-truststore-file-password=${JKS_TRUSTSTORE_PASSWORD}"
    else
        echo "$(date "$LOG_TIMESTAMP_FORMAT") ERROR  [container.initialization] (keystore-autoconfiguration) Keycloak truststore not created at: ${JKS_TRUSTSTORE_PATH}." >&2
    fi

    popd >& /dev/null
    CUSTOM_ARGS+=${CUSTOM_TLS_ARGS}
}

autogenerate_keystores

# Start Keycloak with the default entrypoint
exec /opt/keycloak/bin/kc.sh ${CUSTOM_ARGS} $@
exit $?