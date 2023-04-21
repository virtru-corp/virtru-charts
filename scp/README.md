

# Installation
## Prerequisites:
- K8S Cluster; version TBD
- Helm; version TBD
- Istio Service Mesh + Istio Ingress Gateway: [See Istio Installation](./istio.md)

## Update Dependencies
```shell
helm repo add twuni https://helm.twun.io
helm dependency update .
```

## Secrets
Secrets are required with installation options:
1. Add your own manually or extend this chart.
1. Use the secret bootstrapping in this chart under the "secret" values.yaml key

## HELM Install/Upgrade 


## Bootstrapping deployment
- Keycloak users, entitlements, attribute definitions:  Done by customizing the configuration for the 
OpenTDF keycloak-bootstrap chart.
- Entitlement Policy: Built using an opcr cli job that builds, tests and pushes an OPA bundle to the docker
oci registry.  This is handled as part of the [opcr-policy Chart](./charts/opcr-policy)
- Database Schema: Handled by the postgres initdb secret with scripts populating OpenTDF schema and SHP
component schemas (Configuration).  [Example postgres schema bootstrapping secret](templates/bootstrap/postgres-initdb-secret.yaml)
  - These SQL scripts use templating; the OTDF schema scripts probably SHOULD be moved to that project.
- Configuration Service Artifacts: TBD

When using the provided bootstrapping a single file can be provided via the `.Values.bootstrap.configPath` option.

This YAML file's expected keys/structure:
- authorities: [See Attribute Definition Authorities](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L97)
- entitlements: [See entitlement list](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L103)
- attributeDefinitions: [See Attribute Definition list](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L124)

And keycloak client and users via values overrides:
```
secrets:
  keycloakBootstrap:
    #list of keycloak clients to be added
    clients:
      - clientId: 
        clientSecret: 
        #optional audience mapper
        audienceMappers:
          - my-aud
    users:
      - username: alice
        password: replaceme
      - username: bob
        password: replaceme   
```

### Demo Install
Install demo:
```shell
helm upgrade --install -n scp --create-namespace \
    -f values.yaml \ 
    -f <your deployment overrides values> scp .
```

## Un-install
```shell
helm uninstall scp -n scp
```
- Also remove PVCs if you want to remove persistent state

### Configuration Notes
- keycloak KC_HOSTNAME_URL, KC_HOSTNAME_ADMIN_URL are required to properly handle and avoid keycloak login loop
- Additional KC Features?:
  - KC_FEATURES=token-exchange,preview
- Quick and dirty script to get all images: 
  ```
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
  tr -s '[[:space:]]' '\n' |\
  sort |\
  uniq -c
  ```

## Parameters

### Common parameters - used as yaml anchors

| Name                                          | Description                        | Value                                                |
| --------------------------------------------- | ---------------------------------- | ---------------------------------------------------- |
| `commonParams.attrEndpoint`                   | Interal attribute service endpoint | `http://attributes:4020`                             |
| `commonParams.disableTracing`                 | Disable OTEL Tracing               | `true`                                               |
| `commonParams.entitlementPolicyBundleRepo`    | entitlement OPA Bundle Repo        | `scp-docker-registry:5000/entitlements-policybundle` |
| `commonParams.entitlementPolicyBundleTag`     | entitlement OPA Bundle tag         | `0.0.2`                                              |
| `commonParams.entilementPolicyOCIRegistryUrl` | OPA policy endpoint                | `https://scp-docker-registry:5000`                   |
| `commonParams.scpImagePullSecretName`         | common pull secret name            | `scp-pull-secret`                                    |
| `commonParams.imagePullSecrets[0].name`       | name of pull secret                | `scp-pull-secret`                                    |

### Name Parameters

| Name               | Description              | Value |
| ------------------ | ------------------------ | ----- |
| `nameOverride`     | Chart name override      | `""`  |
| `fullnameOverride` | Chart full name override | `""`  |

### Embedded Service Deployment

| Name                  | Description                     | Value  |
| --------------------- | ------------------------------- | ------ |
| `embedded.keycloak`   | Use an embedded keycloak or not | `true` |
| `embedded.postgresql` | Use an embedded postgres or not | `true` |

### Keycloak bootstrap parameters

| Name                                                | Description                                                                  | Value                                         |
| --------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------- |
| `bootstrap.keycloak`                                | Should keycloak bootstrap be enabled                                         | `true`                                        |
| `bootstrap.configsvc.enabled`                       | Enable configuration service artifact bootstrapping                          | `true`                                        |
| `bootstrap.configsvc.job.name`                      | Name of the job                                                              | `configsvc-bootstrap`                         |
| `bootstrap.configsvc.job.image.repo`                | Image repository                                                             | `ghcr.io/virtru-corp/postman-cli/opcr-policy` |
| `bootstrap.configsvc.job.image.tag`                 | Image tag                                                                    | `sha-531eea2`                                 |
| `bootstrap.configsvc.job.image.pullPolicy`          | Image pull policy                                                            | `IfNotPresent`                                |
| `bootstrap.configsvc.job.backoffLimit`              | Job backoff limit                                                            | `5`                                           |
| `bootstrap.configsvc.job.configVolumeSecretRefName` | Secret name used to mount configuration artifacts used by the job            | `scp-bootstrap-configsvc`                     |
| `bootstrap.configsvc.job.envSecretRef`              | secret for environment variables                                             | `nil`                                         |
| `bootstrap.configPath`                              | The path to the install configuration file (relative to the chart directory) | `nil`                                         |
| `bootstrap.entitlementPolicy`                       | Should entitlement policy be bootstrapped                                    | `true`                                        |

### Ingress Configuration

| Name                      | Description                    | Value     |
| ------------------------- | ------------------------------ | --------- |
| `ingress.existingGateway` | Use an existing istio gateway  | `nil`     |
| `ingress.gatewaySelector` | Name of istio gateway selector | `ingress` |
| `ingress.name`            | Name base for istio resources  | `scp`     |

### ABACUS Chart Overrides

| Name                      | Description             | Value     |
| ------------------------- | ----------------------- | --------- |
| `abacus.enabled`          | abacus enabled flag     | `true`    |
| `abacus.basePath`         | path to abcus           | `/abacus` |
| `abacus.fullnameOverride` | Override name of abacus | `abacus`  |

### Access-PEP Chart Overrides

| Name                                                  | Description                                              | Value                                       |
| ----------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------- |
| `access-pep.enabled`                                  | Enable access-pep flag                                   | `true`                                      |
| `access-pep.name`                                     | Name override                                            | `access-pep`                                |
| `access-pep.existingImagePullSecret`                  | Existing pull secret for the image                       | `scp-pull-secret`                           |
| `access-pep.image.repo`                               | Image Rep                                                | `ghcr.io/virtru-corp/access-pep/access-pep` |
| `access-pep.image.tag`                                | Image tag                                                | `sha-cac697c`                               |
| `access-pep.config.disableTracing`                    | disable tracing flag                                     | `true`                                      |
| `access-pep.config.attrAuthorityHost`                 | Attribute Service Endpoint                               | `http://attributes:4020`                    |
| `access-pep.config.entitlementPdpHost`                | entitlement pdp endpoint                                 | `http://entitlement-pdp:3355`               |
| `access-pep.config.keycloakAttrAuthorityClientID`     | OIDC client id                                           | `tdf-client`                                |
| `access-pep.config.keycloakAttrAuthorityClientSecret` | Sets client secret to empty - to be overridden by secret | `nil`                                       |

### Attribute Chart Overrides

| Name                          | Description                                | Value                         |
| ----------------------------- | ------------------------------------------ | ----------------------------- |
| `attributes.fullnameOverride` | Attribute Service Name Override            | `attributes`                  |
| `attributes.secretRef`        | Secrets for environment variable injection | `name: scp-attributes-secret` |

### Configuration Chart Overrides

| Name                                     | Description                               | Value                 |
| ---------------------------------------- | ----------------------------------------- | --------------------- |
| `configuration.enabled`                  | Configuration Service enabled flag        | `true`                |
| `configuration.fullnameOverride`         | Configuration svc name override           | `configuration`       |
| `configuration.server.image.tag`         | Configuration Service Image Tag           | `0.3.5`               |
| `configuration.server.secretRef`         | Configuration Service Secrets Ref         | `name: scp-configsvc` |
| `configuration.server.postgres.host`     | hostname of postgres                      | `postgresql`          |
| `configuration.server.postgres.password` | password for postgres - should not be set | `nil`                 |

### Entitlement Policy Bootstrap Job parameters

| Name                                               | Description                                                                    | Value                                                |
| -------------------------------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------- |
| `entitlement-policy-bootstrap.policyGlobPattern`   | The Glob Pattern to the entitlement policy source data . e.g. rego + data.json | `configs/fed-demo/entitlement-policy/*`              |
| `entitlement-policy-bootstrap.bundleRepo`          | Bundle repository                                                              | `scp-docker-registry:5000/entitlements-policybundle` |
| `entitlement-policy-bootstrap.bundleTag`           | Bundle Tag                                                                     | `0.0.2`                                              |
| `entitlement-policy-bootstrap.OCIRegistryUrl`      | URL of OCI registry to publish to                                              | `https://scp-docker-registry:5000`                   |
| `entitlement-policy-bootstrap.policyConfigMap`     | Config map name used to inject env varibles into the job                       | `scp-bootstrap-entitlement-cm`                       |
| `entitlement-policy-bootstrap.policyDataSecretRef` | Secret name used to mount policy artifacts into the job                        | `scp-bootstrap-entitlement-policy`                   |
| `entitlement-policy-bootstrap.image.tag`           | ocpr container tag                                                             | `sha-531eea2`                                        |

### Entitlement PDP Chart Overrides

| Name                                                | Description                                              | Value                                                |
| --------------------------------------------------- | -------------------------------------------------------- | ---------------------------------------------------- |
| `entitlement-pdp.fullnameOverride`                  | Entitlement PDP name override                            | `entitlement-pdp`                                    |
| `entitlement-pdp.opaConfig.policy.useStaticPolicy`  | Use static policy flag - false to pull from oci registry | `false`                                              |
| `entitlement-pdp.opaConfig.policy.allowInsecureTLS` | Allow insecure comms to oci registry                     | `true`                                               |
| `entitlement-pdp.opaConfig.policy.OCIRegistryUrl`   | OCI registry url                                         | `https://scp-docker-registry:5000`                   |
| `entitlement-pdp.opaConfig.policy.bundleRepo`       | OCI Bundle Repo                                          | `scp-docker-registry:5000/entitlements-policybundle` |
| `entitlement-pdp.opaConfig.policy.bundleTag`        | OCI bundle tag                                           | `0.0.2`                                              |
| `entitlement-pdp.config.disableTracing`             | Disable tracing flag                                     | `true`                                               |
| `entitlement-pdp.secretRef`                         | Secrets for env variables.                               | `name: scp-entitlement-pdp-secret`                   |

### Entitlement Store Chart Overrides

| Name                                 | Description                       | Value                                |
| ------------------------------------ | --------------------------------- | ------------------------------------ |
| `entitlement-store.fullnameOverride` | Entitlement Store name override   | `entitlement-store`                  |
| `entitlement-store.secretRef`        | Secrets for environment variables | `name: scp-entitlement-store-secret` |

### Entitlement Chart Overrides

| Name                            | Description                                    | Value                               |
| ------------------------------- | ---------------------------------------------- | ----------------------------------- |
| `entitlements.fullnameOverride` | Entitlements Name Override                     | `entitlements`                      |
| `entitlements.secretRef`        | Entitlements Secrets for environment variables | `name: scp-entitlements-secret    ` |

### Entity Resolution Chart Overrides

| Name                                       | Description                     | Value               |
| ------------------------------------------ | ------------------------------- | ------------------- |
| `entity-resolution.fullnameOverride`       | Entity Resolution Name override | `entity-resolution` |
| `entity-resolution.config.disableTracing`  | Disable Tracing Flag            | `true`              |
| `entity-resolution.config.keycloak.legacy` | Legacy Keycloak Tracing Flag    | `true`              |

### KAS Chart Overrides

| Name                     | Description                           | Value                    |
| ------------------------ | ------------------------------------- | ------------------------ |
| `kas.fullnameOverride`   | KAS Name Override                     | `kas`                    |
| `kas.endpoints.attrHost` | Attributes hostname accessible to KAS | `http://attributes:4020` |
| `kas.pdp.verbose`        | Verbose Logging Flag                  | `true`                   |
| `kas.pdp.disableTracing` | Disable tracing flag                  | `true`                   |

### Keycloak Chart Overrides

| Name                                 | Description                           | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------ | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keycloak.fullnameOverride`          | keycloak name override                | `keycloak`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `keycloak.image.repository`          | Keycloak Image Repo                   | `ghcr.io/opentdf/keycloak`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `keycloak.image.tag`                 | Keycloak Image Tag                    | `main`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `keycloak.image.pullPolicy`          | Keycloak Image pull policy            | `IfNotPresent`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `keycloak.command`                   | Command to start the keycloak service | `["/opt/keycloak/bin/kc.sh","--verbose","start-dev","--http-relative-path","/auth"]`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `keycloak.postgresql.enabled`        | Use keycloak deployed postgres flag   | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `keycloak.externalDatabase.database` | Database name                         | `keycloak_database`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `keycloak.extraEnv`                  | Extra environment variables.          | `- name: CLAIMS_URL
  value: http://entitlement-pdp:3355/entitlements
- name: JAVA_OPTS_APPEND
  value: -Djgroups.dns.query={{ include "keycloak.fullname" . }}-headless
- name: KC_DB
  value: postgres
- name: KC_DB_URL_PORT
  value: "5432"
- name: KC_LOG_LEVEL
  value: INFO
- name: KC_HOSTNAME_STRICT
  value: "false"
- name: KC_HOSTNAME_STRICT_BACKCHANNEL
  value: "false"
- name: KC_HOSTNAME_STRICT_HTTPS
  value: "false"
- name: KC_HOSTNAME_URL
  value: {{ ( include "keycloak.externalUrl" . ) | quote }}
- name: KC_HOSTNAME_ADMIN_URL
  value: {{ ( include "keycloak.externalUrl" . ) | quote }}
- name: KC_HTTP_ENABLED
  value: "true"
- name: KC_FEATURES
  value: "preview,token-exchange"` |
| `keycloak.extraEnvFrom`              | Extra Environment From Reference YAML | `- secretRef:
    name: scp-keycloak-secret`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

### Keycloak Bootstrap Chart Overrides

| Name                                       | Description                                           | Value                                |
| ------------------------------------------ | ----------------------------------------------------- | ------------------------------------ |
| `keycloak-bootstrap.entitlements.hostname` | Entitlement svc hostname                              | `http://entitlements:4030`           |
| `keycloak-bootstrap.entitlements.realms`   | Entitlement override realms                           | `nil`                                |
| `keycloak-bootstrap.existingConfigSecret`  | Secret name used to Mount bootstrapping data          | `scp-keycloakbootstrap-config`       |
| `keycloak-bootstrap.secretRef`             | Secret for bootstrap job env variables.               | `name: scp-keycloakbootstrap-secret` |
| `keycloak-bootstrap.attributes.hostname`   | Attribute service endpoint accessible to boostrap job | `http://attributes:4020`             |
| `keycloak-bootstrap.attributes.realm`      | Realm for OIDC client auth to attribute service       | `tdf`                                |
| `keycloak-bootstrap.attributes.clientId`   | OIDC client ID used to auth to attribute service      | `dcr-test`                           |

### Docker Registry Configuration

| Name                                  | Description                                           | Value                       |
| ------------------------------------- | ----------------------------------------------------- | --------------------------- |
| `docker-registry.enabled`             | Enable docker registry                                | `true`                      |
| `docker-registry.persistence.enabled` | Persistence Enabled Flag                              | `true`                      |
| `docker-registry.persistence.size`    | Size of volume                                        | `1Gi`                       |
| `docker-registry.tlsSecretName`       | Secret name containing TLS Certs used by the registry | `scp-docker-registry-certs` |

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

| Name                                           | Description                                                                                    | Value  |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------- | ------ |
| `secrets.enabled`                              | Generate secrets from the values provided below.  If false, another bootstrapping              | `true` |
| `secrets.postgresql.dbPassword`                | password for postgres user                                                                     | `nil`  |
| `secrets.attributes.clientSecret`              | oidc client secret used by attributes svc to auth to idp and enforce svc authorization         | `nil`  |
| `secrets.attributes.dbPassword`                | postgres password for attributes svc user                                                      | `nil`  |
| `secrets.configuration.dbPassword`             | postgres password for config svc user                                                          | `nil`  |
| `secrets.entitlementStore.dbPassword`          | postgres password for entitlement-store svc user                                               | `nil`  |
| `secrets.entitlements.clientSecret`            | oidc client secret used by entitlements svc to auth to idp and enforce svc authorization       | `nil`  |
| `secrets.entitlements.dbPassword`              | postgres password for entitlements svc user                                                    | `nil`  |
| `secrets.keycloak.dbPassword`                  | postgres password for keycloak svc user                                                        | `nil`  |
| `secrets.keycloak.adminUsername`               | keycloak admin user's username                                                                 | `nil`  |
| `secrets.keycloak.adminPassword`               | Keycloak admin user's password                                                                 | `nil`  |
| `secrets.keycloakBootstrap.attributesUsername` | username for attribute service auth                                                            | `nil`  |
| `secrets.keycloakBootstrap.attributesPassword` | password for attribute service auth                                                            | `nil`  |
| `secrets.keycloakBootstrap.users`              | list of users to be added [{"username":"","password":""}]                                      | `nil`  |
| `secrets.keycloakBootstrap.clients`            | list of custom oidc clients added [{"clientId":<>,"clientSecret":"","audienceMappers":["aud]}] | `nil`  |
| `secrets.keycloakBootstrap.clientSecret`       | client secret assigned to standard bootstrapper clients                                        | `nil`  |
| `secrets.keycloakBootstrap.customConfig`       | Override for custom config to none                                                             | `nil`  |
| `secrets.opaPolicyPullSecret`                  | oci registry pull secret for OPA policy                                                        | `nil`  |

### Tagging PDP Chart Overrides

| Name                             | Description                           | Value         |
| -------------------------------- | ------------------------------------- | ------------- |
| `tagging-pdp.enabled`            | enabled flag                          | `true`        |
| `tagging-pdp.fullnameOverride`   | override name                         | `tagging-pdp` |
| `tagging-pdp.image.tag`          | Tagging PDP Image Tag                 | `sha-470efff` |
| `tagging-pdp.gateway.enabled`    | Tagging PDP Rest Gateway enabled flag | `true`        |
| `tagging-pdp.gateway.pathPrefix` | tagging-pdp svc prefix                | `tagging-pdp` |
| `tdfAdminUsername`               | The admin user created for tdf.       | `tdf-admin`   |
