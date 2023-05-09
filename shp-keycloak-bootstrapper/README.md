## Parameters

### Keycloak Bootstrap Chart Overrides

| Name                                           | Description                                                                                    | Value                                     |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `keycloak-bootstrap.nameOverride`              | set the name of the job                                                                        | `job`                                     |
| `keycloak-bootstrap.entitlements.hostname`     | Entitlement svc hostname                                                                       | `http://entitlements:4030`                |
| `keycloak-bootstrap.entitlements.realms`       | Entitlement override realms                                                                    | `nil`                                     |
| `keycloak-bootstrap.existingConfigSecret`      | Secret name used to Mount bootstrapping data                                                   | `shp-kcbs-keycloakbootstrap-config`       |
| `keycloak-bootstrap.istioTerminationHack`      | Set istio on/off                                                                               | `true`                                    |
| `keycloak-bootstrap.secretRef`                 | Secret for bootstrap job env variables.                                                        | `name: shp-kcbs-keycloakbootstrap-secret` |
| `keycloak-bootstrap.attributes.hostname`       | Attribute service endpoint accessible to boostrap job                                          | `http://attributes:4020`                  |
| `keycloak-bootstrap.attributes.realm`          | Realm for OIDC client auth to attribute service                                                | `tdf`                                     |
| `keycloak-bootstrap.attributes.clientId`       | OIDC client ID used to auth to attribute service                                               | `dcr-test`                                |
| `bootstrap.configFile`                         | The configuration file - set using --set-file bootstrap.configFile=configFilePath              | `nil`                                     |
| `secrets.keycloakBootstrap.attributesUsername` | username for attribute service auth                                                            | `nil`                                     |
| `secrets.keycloakBootstrap.attributesPassword` | password for attribute service auth                                                            | `nil`                                     |
| `secrets.keycloakBootstrap.users`              | list of users to be added [{"username":"","password":""}]                                      | `nil`                                     |
| `secrets.keycloakBootstrap.clients`            | list of custom oidc clients added [{"clientId":<>,"clientSecret":"","audienceMappers":["aud]}] | `nil`                                     |
| `secrets.keycloakBootstrap.clientSecret`       | client secret assigned to standard bootstrapper clients                                        | `nil`                                     |
| `secrets.keycloakBootstrap.customConfig`       | Override for custom config to none                                                             | `nil`                                     |
| `tdfAdminUsername`                             | The admin user created for tdf.                                                                | `tdf-admin`                               |
