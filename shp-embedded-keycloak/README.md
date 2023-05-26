# Overview
Helm Chart deployment of keycloak with OpenTDF keycloak image, default keycloak chart values and with a custom entrypoint
script to mount certificates into the keycloak truststore.

Parameter documentation generated from [generator-for-helm](https://github.com/bitnami-labs/readme-generator-for-helm)
```shell
npm i https://github.com/bitnami-labs/readme-generator-for-helm
npx @bitnami/readme-generator-for-helm -v shp-embedded-keycloak/values.yaml -r shp-embedded-keycloak/README.md
```

## Parameters

### Keycloak Chart Overrides

| Name                                 | Description                                                                                                                                    | Value                                                                          |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `keycloak.fullnameOverride`          | keycloak name override                                                                                                                         | `keycloak`                                                                     |
| `keycloak.image.repository`          | Keycloak Image Repo                                                                                                                            | `ghcr.io/opentdf/keycloak`                                                     |
| `keycloak.image.tag`                 | Keycloak Image Tag                                                                                                                             | `21.0.1-1.3.0`                                                                 |
| `keycloak.image.pullPolicy`          | Keycloak Image pull policy                                                                                                                     | `IfNotPresent`                                                                 |
| `keycloak.command`                   | Command to start the keycloak service                                                                                                          | `["/opt/keycloak/custom_bin/kc_custom_entrypoint.sh","--verbose","start-dev"]` |
| `keycloak.postgresql.enabled`        | Use keycloak deployed postgres flag                                                                                                            | `false`                                                                        |
| `keycloak.externalDatabase.database` | Database name                                                                                                                                  | `keycloak_database`                                                            |
| `keycloak.extraEnv`                  | Extra environment variables.                                                                                                                   | `{{ include "shp.embedded.keycloak.extraEnv" . }}`                             |
| `keycloak.extraEnvFrom`              | Extra Environment From Reference YAML                                                                                                          | `{{ include "shp.embedded.keycloak.extraEnvFrom" . }}`                         |
| `keycloak.extraVolumes`              | Extra Volume YAML                                                                                                                              | `{{ include "shp.embedded.keycloak.extraVolumes" . }}`                         |
| `keycloak.extraVolumeMounts`         | Extra Volume Mounts YAML                                                                                                                       | `{{ include "shp.embedded.keycloak.extraVolumeMounts" .}}`                     |
| `keycloak.trustedCertSecret`         | Name of an existing secret containing certs to be added to the keycloak truststore. (keycloak prefix is used since its part of an include tpl) | `nil`                                                                          |
| `secrets.keycloak.dbPassword`        | postgres password for keycloak svc user                                                                                                        | `nil`                                                                          |
| `secrets.keycloak.adminUsername`     | keycloak admin user's username                                                                                                                 | `nil`                                                                          |
| `secrets.keycloak.adminPassword`     | Keycloak admin user's password                                                                                                                 | `nil`                                                                          |

## Keycloak Truststore
[A custom entrypoint](./kc_custom_entrypoint.sh) is used to bootstrap certificates as defined in the `X509_CA_BUNDLE`
environment variable.  This value is populated through the introspection of the secret's data defined by the `trustedCertSecret` values override.

If this value is set, a secret with this name should exist and contain data corresponding to key=cert file name, value = cert

The following example creates a secret containing all certs in the directory `foo` that
can later be used to mount the certs into the trust store by setting `trustCertSecret` to foo-secret:

```shell
kubectl create secret generic foo-secret --from-file=./foo
```

Example self-signed pem creation:
```shell
openssl req -new -newkey rsa:4096 -nodes -keyout test.key -out test.csr -subj "/C=US/ST=Home/L=Home/O=mycorp/OU=myorg/CN=caroot.keycloak-http"
openssl x509 -req -sha256 -days 365 -in test.csr -signkey test.key -out test.pem
```