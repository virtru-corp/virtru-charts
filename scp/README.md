

# Installation
## Prerequisites:
- K8S Cluster; version TBD
- Helm; version TBD
- Istio Service Mesh + Istio Ingress Gateway: [See Istio Installation](./istio.md)
  - Add istion injection to the namespace:
    ```
    kubectl label namespace <ns> istio-injection=enabled
    ```

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
- Entitlement Policy: Built using an opcr cli job that builds, tests and pushes an OPA bundle to the docker
oci registry.  This is handled as part of the [opcr-policy Chart](./charts/opcr-policy)
- Database Schema: Handled by the postgres initdb secret with scripts populating OpenTDF schema and SHP
component schemas (Configuration).  [Example postgres schema bootstrapping secret](../shp-embedded-postgresql/templates/postgres-initdb-secret.yaml)
  - These SQL scripts use templating; the OTDF schema scripts probably SHOULD be moved to that project.
- Configuration Service Artifacts: TBD

When using the provided bootstrapping a single file can be provided via the `.Values.bootstrap.configPath` option.

This YAML file's expected keys/structure:
- authorities: [See Attribute Definition Authorities](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L97)
- entitlements: [See entitlement list](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L103)
- attributeDefinitions: [See Attribute Definition list](https://github.com/opentdf/backend/blob/main/charts/keycloak-bootstrap/values.yaml#L124)


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
- Quick and dirty script to get all images: 
  ```
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
  tr -s '[[:space:]]' '\n' |\
  sort |\
  uniq -c
  ```


Parameter documentation generated from [generator-for-helm](https://github.com/bitnami-labs/readme-generator-for-helm)
```shell
npm i https://github.com/bitnami-labs/readme-generator-for-helm
npx @bitnami/readme-generator-for-helm -v scp/values.yaml -r scp/README.md
```

## Parameters

### Common parameters - used as yaml anchors

| Name                                          | Description                                        | Value                                                |
| --------------------------------------------- | -------------------------------------------------- | ---------------------------------------------------- |
| `commonParams.attrEndpoint`                   | Interal attribute service endpoint                 | `http://attributes:4020`                             |
| `commonParams.disableTracing`                 | Disable OTEL Tracing                               | `true`                                               |
| `commonParams.entitlementPolicyBundleRepo`    | entitlement OPA Bundle Repo                        | `scp-docker-registry:5000/entitlements-policybundle` |
| `commonParams.entitlementPolicyBundleTag`     | entitlement OPA Bundle tag                         | `0.0.2`                                              |
| `commonParams.entilementPolicyOCIRegistryUrl` | OPA policy endpoint                                | `https://scp-docker-registry:5000`                   |
| `commonParams.scpImagePullSecretName`         | common pull secret name                            | `scp-pull-secret`                                    |
| `commonParams.imagePullSecrets[0].name`       | name of pull secret                                | `scp-pull-secret`                                    |
| `commonParams.jobWaitForIstio`                | Job needs to wait for istio and exit appropriately | `true`                                               |

### Name Parameters

| Name               | Description              | Value |
| ------------------ | ------------------------ | ----- |
| `nameOverride`     | Chart name override      | `""`  |
| `fullnameOverride` | Chart full name override | `""`  |

### Embedded Service Deployment

| Name                | Description                | Value  |
| ------------------- | -------------------------- | ------ |
| `embedded.keycloak` | Is keycloak in the cluster | `true` |

### Keycloak Configuration

| Name                 | Description                          | Value  |
| -------------------- | ------------------------------------ | ------ |
| `keycloak.inCluster` | If using keycloak - is it in cluster | `true` |
| `keycloak.realm`     | If using keycloak - the realm name   | `tdf`  |

### Attribute Definition and Entitlement bootstrap parameters

| Name                                                | Description                                                                  | Value                                         |
| --------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------- |
| `bootstrap.entitlement-attrdef-bootstrap`           | Should entitlements and/or attributes be bootstrapped.                       | `true`                                        |
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
| `global.istioEnabled`     | Istio enabled true/false       | `true`    |

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

| Name                                                | Description                                                                    | Value                                                |
| --------------------------------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------- |
| `entitlement-policy-bootstrap.policyGlobPattern`    | The Glob Pattern to the entitlement policy source data . e.g. rego + data.json | `configs/fed-demo/entitlement-policy/*`              |
| `entitlement-policy-bootstrap.bundleRepo`           | Bundle repository                                                              | `scp-docker-registry:5000/entitlements-policybundle` |
| `entitlement-policy-bootstrap.bundleTag`            | Bundle Tag                                                                     | `0.0.2`                                              |
| `entitlement-policy-bootstrap.OCIRegistryUrl`       | URL of OCI registry to publish to                                              | `https://scp-docker-registry:5000`                   |
| `entitlement-policy-bootstrap.policyConfigMap`      | Config map name used to inject env varibles into the job                       | `scp-bootstrap-entitlement-cm`                       |
| `entitlement-policy-bootstrap.policyDataSecretRef`  | Secret name used to mount policy artifacts into the job                        | `scp-bootstrap-entitlement-policy`                   |
| `entitlement-policy-bootstrap.istioTerminationHack` | Set istio on/off                                                               | `true`                                               |
| `entitlement-policy-bootstrap.image.tag`            | ocpr container tag                                                             | `sha-531eea2`                                        |

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

### Keycloak Bootstrap Chart Overrides

| Name                                                  | Description                                           | Value                                |
| ----------------------------------------------------- | ----------------------------------------------------- | ------------------------------------ |
| `entitlement-attrdef-bootstrap.entitlements.hostname` | Entitlement svc hostname                              | `http://entitlements:4030`           |
| `entitlement-attrdef-bootstrap.entitlements.realms`   | Entitlement override realms                           | `nil`                                |
| `entitlement-attrdef-bootstrap.existingConfigSecret`  | Secret name used to Mount bootstrapping data          | `scp-keycloakbootstrap-config`       |
| `entitlement-attrdef-bootstrap.istioTerminationHack`  | Set istio on/off                                      | `true`                               |
| `entitlement-attrdef-bootstrap.secretRef`             | Secret for bootstrap job env variables.               | `name: scp-keycloakbootstrap-secret` |
| `entitlement-attrdef-bootstrap.attributes.hostname`   | Attribute service endpoint accessible to boostrap job | `http://attributes:4020`             |
| `entitlement-attrdef-bootstrap.attributes.realm`      | Realm for OIDC client auth to attribute service       | `tdf`                                |
| `entitlement-attrdef-bootstrap.attributes.clientId`   | OIDC client ID used to auth to attribute service      | `dcr-test`                           |

### Docker Registry Configuration

| Name                                  | Description                                           | Value                       |
| ------------------------------------- | ----------------------------------------------------- | --------------------------- |
| `docker-registry.enabled`             | Enable docker registry                                | `true`                      |
| `docker-registry.persistence.enabled` | Persistence Enabled Flag                              | `true`                      |
| `docker-registry.persistence.size`    | Size of volume                                        | `1Gi`                       |
| `docker-registry.tlsSecretName`       | Secret name containing TLS Certs used by the registry | `scp-docker-registry-certs` |

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
