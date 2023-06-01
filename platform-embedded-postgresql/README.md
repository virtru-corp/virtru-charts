## Parameters

### Postgresql Chart Overrides

| Name                                      | Description                                | Value                                                          |
| ----------------------------------------- | ------------------------------------------ | -------------------------------------------------------------- |
| `postgresql.fullnameOverride`             | Postgresql Name override                   | `postgresql`                                                   |
| `postgresql.image.debug`                  | Debug Flag                                 | `true`                                                         |
| `postgresql.image.tag`                    | Image Tag                                  | `11`                                                           |
| `postgresql.auth.existingSecret`          | Existing secret for postgres auth settings | `{{ include "postgresql.primary.fullname" . }}-secret
`        |
| `postgresql.primary.initdb.user`          | user for init script execution             | `postgres`                                                     |
| `postgresql.primary.initdb.scriptsSecret` | Secret containing init db scripts          | `{{ include "postgresql.primary.fullname" . }}-initdb-secret
` |

### Secret Generation Parameters

| Name                                  | Description                                      | Value |
| ------------------------------------- | ------------------------------------------------ | ----- |
| `secrets.postgres.dbPassword`         | password for postgres user                       | `nil` |
| `secrets.attributes.dbPassword`       | postgres password for attributes svc user        | `nil` |
| `secrets.configuration.dbPassword`    | postgres password for config svc user            | `nil` |
| `secrets.entitlementStore.dbPassword` | postgres password for entitlement-store svc user | `nil` |
| `secrets.entitlements.dbPassword`     | postgres password for entitlements svc user      | `nil` |
| `secrets.keycloak.dbPassword`         | postgres password for keycloak svc user          | `nil` |
| `secrets.sharepoint.dbPassword`       | postgres password for sharepoint svc user        | `nil` |
