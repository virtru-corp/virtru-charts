

# Installation
## Prerequisites:
- K8S Cluster; version TBD
- Helm; version TBD
- Istio Service Mesh + Istio Ingress Gateway: [See Istio Installation](./istio.md)
  - Add istion injection to the namespace (required for MTLS and use of Istio based Authentication/Authorization):
    ```
    kubectl label namespace <ns> istio-injection=enabled
    ```
- PostgreSQL database.  For **Non-Production** in-cluster PostgreSQL deployment, [See embedded Postgresql chart](./../platform-embedded-postgresql/README.md)
- Keycloak or other OIDC Provider.  For **Non-Production** in-cluster Keycloak deployment, [See embedded Keycloak chart](./../platform-embedded-keycloak/README.md)

## Update Dependencies
```shell
helm repo add twuni https://helm.twun.io
helm dependency update .
```

## Secrets
Secret Management is generally in 2 categories:
1. Add your own out-of-band from this helm chart and reference the existing secrets as value overrides.
1. Use the secret bootstrapping available in this chart using the parameters under the secrets section of value overrides

## Bootstrapping Data
This chart provides a mechanism to bootstrap data into various services.  A configuration input file is
used to feed Helm templates generating secrets which are then and mounted as volumes to service-specific
bootstrapping jobs.

The configuration file is identified by the `bootstrap.configFile` chart value parameter with yaml schema 
assumes to follow the example below:

```shell
# List of attribute authorities
authorities:
  # name of attribute authority
  - http://demo.com

# List of entitlements per username.
entitlements:
  alice:
    - http://demo.com/attr/IntellectualProperty/value/TradeSecret
  bob:
    - http://demo.com/attr/IntellectualProperty/value/Confidential

# List of attribute definitions (per OpenTDF Attributes Service Schema)
attributeDefinitions: 
  - authority: http://demo.com
    name: IntellectualProperty
    rule: hierarchy
    state: published
    order: [ "TradeSecret","Confidential" ]

#List of configuration artifacts to be loaded     
configArtifacts:
  - name: chat.us
    yamlRefKey: chatConfig
    contentType: "application/yaml"
    externalFileRef:

#Chat configuration payload
chatConfig:
  - someKey: someData
  
  
```
### Attribute Definitions and Entitlements
A Bootstrapping Job to load Attribute Definitions and Entitlements can be turned on/off via the `bootstrap.attrDefOrEntitlements` parameter

The bootstrapping config file is sourced for authority, attribute definition and entitlements that is then loaded into the platform.

### Configuration Service Artifacts
A Bootstrapping Job load one or more configuration artifacts into the configuration service is controlled by the `bootstrap.configsvc.enabled` parameter.

When true, a job is create to load the configuration artifacts as identified in the bootrapping config file.

### Entitlement Policy
Entitlement Policy Bundle (OPA Policy Bundle) can be loaded as part of a bootstrapping job; and enabled/disabled using the `bootstrap.entitlementPolicy` parameter

When enabled, a job is created and configured via the `entitlement-policy-bootstrap` parameter section.

`entitlement-policy-bootstrap.policyGlobPattern` is used to provide a Glob Pattern to a directory of OPA Policy 
artifacts.  These are copied to a volume and then used to build and publish an OPA Bundle to the configured
OCI Registry.


## Generic Helm Install
```shell
helm upgrade --install -n shp --create-namespace \
    -f values.yaml \ 
    -f <your deployment overrides values> platform .
```

## Embedded Install Example
[See Embedded Installation Example](./embeddedInstall.README.md)

## Un-install Example
```shell
helm uninstall platform -n shp
```
- Also remove PVCs if you want to remove persistent state

## Testing the Chart
[See Smoketesting deployment documentation](./tests/README.md)

Parameter documentation generated from [generator-for-helm](https://github.com/bitnami-labs/readme-generator-for-helm)
```shell
npm i https://github.com/bitnami-labs/readme-generator-for-helm
npx @bitnami/readme-generator-for-helm -v platform/values.yaml -r platform/README.md
```

## Parameters

### Common parameters - used as yaml anchors

| Name                                          | Description                                        | Value                                            |
| --------------------------------------------- | -------------------------------------------------- | ------------------------------------------------ |
| `commonParams.attrEndpoint`                   | Interal attribute service endpoint                 | `http://attributes:4020`                         |
| `commonParams.disableTracing`                 | Disable OTEL Tracing                               | `true`                                           |
| `commonParams.entitlementPolicyBundleRepo`    | entitlement OPA Bundle Repo                        | `docker-registry:5000/entitlements-policybundle` |
| `commonParams.entitlementPolicyBundleTag`     | entitlement OPA Bundle tag                         | `0.0.2`                                          |
| `commonParams.entilementPolicyOCIRegistryUrl` | OPA policy endpoint                                | `https://docker-registry:5000`                   |
| `commonParams.platformImagePullSecretName`    | common pull secret name                            | `nil`                                            |
| `commonParams.imagePullSecrets[0].name`       | name of pull secret                                | `nil`                                            |
| `commonParams.jobWaitForIstio`                | Job needs to wait for istio and exit appropriately | `true`                                           |

### General / Misc Parameters

| Name                | Description                        | Value  |
| ------------------- | ---------------------------------- | ------ |
| `nameOverride`      | Chart name override                | `""`   |
| `fullnameOverride`  | Chart full name override           | `""`   |
| `embedded.keycloak` | Is keycloak in the cluster         | `true` |
| `keycloak.realm`    | If using keycloak - the realm name | `tdf`  |

### Attribute Definition and Entitlement bootstrap parameters

| Name                                                | Description                                                                               | Value                                         |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------------- |
| `bootstrap.attrDefOrEntitlements`                   | Should entitlements and/or attributes be bootstrapped.                                    | `true`                                        |
| `bootstrap.configsvc.enabled`                       | Enable configuration service artifact bootstrapping                                       | `true`                                        |
| `bootstrap.configsvc.job.name`                      | Name of the job                                                                           | `configsvc-bootstrap`                         |
| `bootstrap.configsvc.job.image.repo`                | Image repository                                                                          | `ghcr.io/virtru-corp/postman-cli/opcr-policy` |
| `bootstrap.configsvc.job.image.tag`                 | Image tag                                                                                 | `sha-531eea2`                                 |
| `bootstrap.configsvc.job.image.pullPolicy`          | Image pull policy                                                                         | `IfNotPresent`                                |
| `bootstrap.configsvc.job.backoffLimit`              | Job backoff limit                                                                         | `5`                                           |
| `bootstrap.configsvc.job.configVolumeSecretRefName` | Secret name used to mount configuration artifacts used by the job                         | `platform-bootstrap-configsvc`                |
| `bootstrap.configsvc.job.envSecretRef`              | secret for environment variables                                                          | `nil`                                         |
| `bootstrap.configFile`                              | The configuration file content (set using --set-file bootstrap.configFile=yourconfig.yaml | `nil`                                         |
| `bootstrap.entitlementPolicy`                       | Should entitlement policy be bootstrapped                                                 | `true`                                        |

### Ingress Configuration

| Name                         | Description                    | Value      |
| ---------------------------- | ------------------------------ | ---------- |
| `ingress.existingGateway`    | Use an existing istio gateway  | `nil`      |
| `ingress.gatewaySelector`    | Name of istio gateway selector | `ingress`  |
| `ingress.name`               | Name base for istio resources  | `platform` |
| `ingress.tls.enabled`        | Require Gateway to use tls     | `false`    |
| `ingress.tls.existingSecret` | Use existing TLS Secret        | `nil`      |

### Istio AuthN/Z Parameters

| Name                       | Description                                                                                                            | Value  |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------ |
| `istioAuth.enabled`        | Turn on/off istio authentication configuration for services defined by the `istioAuth.policies` configuration          | `true` |
| `istioAuth.internalJWTURL` | Whether to compute and use internal keycloak jwks uri - default false                                                  | `true` |
| `istioAuth.policies`       | List of in format : [ {name: <k8s compliant resource name part>, selectorLabels: yaml template for selector labels } ] |        |
| `global.istioEnabled`      | Istio enabled true/false                                                                                               | `true` |
| `global.imagePullSecrets`  | global pull secrets                                                                                                    | `nil`  |

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
| `access-pep.existingImagePullSecret`                  | Existing pull secret for the image                       | `nil`                                       |
| `access-pep.image.repo`                               | Image Rep                                                | `ghcr.io/virtru-corp/access-pep/access-pep` |
| `access-pep.image.tag`                                | Image tag                                                | `sha-cac697c`                               |
| `access-pep.config.disableTracing`                    | disable tracing flag                                     | `true`                                      |
| `access-pep.config.attrAuthorityHost`                 | Attribute Service Endpoint                               | `http://attributes:4020`                    |
| `access-pep.config.entitlementPdpHost`                | entitlement pdp endpoint                                 | `http://entitlement-pdp:3355`               |
| `access-pep.config.keycloakAttrAuthorityClientID`     | OIDC client id                                           | `tdf-client`                                |
| `access-pep.config.keycloakAttrAuthorityClientSecret` | Sets client secret to empty - to be overridden by secret | `nil`                                       |

### Attribute Chart Overrides

| Name                          | Description                                | Value                              |
| ----------------------------- | ------------------------------------------ | ---------------------------------- |
| `attributes.fullnameOverride` | Attribute Service Name Override            | `attributes`                       |
| `attributes.secretRef`        | Secrets for environment variable injection | `name: platform-attributes-secret` |

### Configuration Chart Overrides

| Name                                     | Description                               | Value                      |
| ---------------------------------------- | ----------------------------------------- | -------------------------- |
| `configuration.enabled`                  | Configuration Service enabled flag        | `true`                     |
| `configuration.fullnameOverride`         | Configuration svc name override           | `configuration`            |
| `configuration.server.image.tag`         | Configuration Service Image Tag           | `0.3.6`                    |
| `configuration.server.secretRef`         | Configuration Service Secrets Ref         | `name: platform-configsvc` |
| `configuration.server.postgres.host`     | hostname of postgres                      | `postgresql`               |
| `configuration.server.postgres.password` | password for postgres - should not be set | `nil`                      |
| `configuration.server.imagePullSecrets`  | Pull secrets for configuration service    | `nil`                      |

### Entitlement Policy Bootstrap Job parameters

| Name                                                | Description                                                                                                                                                                                                                                                                                                   | Value                                            |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `entitlement-policy-bootstrap.bundleRepo`           | Bundle repository                                                                                                                                                                                                                                                                                             | `docker-registry:5000/entitlements-policybundle` |
| `entitlement-policy-bootstrap.bundleTag`            | Bundle Tag                                                                                                                                                                                                                                                                                                    | `0.0.2`                                          |
| `entitlement-policy-bootstrap.OCIRegistryUrl`       | URL of OCI registry to publish to                                                                                                                                                                                                                                                                             | `https://docker-registry:5000`                   |
| `entitlement-policy-bootstrap.policyConfigMap`      | Config map name used to inject env varibles into the job                                                                                                                                                                                                                                                      | `platform-bootstrap-entitlement-cm`              |
| `entitlement-policy-bootstrap.policyDataSecretRef`  | Secret name used to mount policy artifacts into the job. To support source files outside this chart a secret created separate from this chart is required. Example to mount all files in directory: kubectl create secret generic platform-bootstrap-entitlement-policy --from-file=pathTo/entitlement-policy | `platform-bootstrap-entitlement-policy`          |
| `entitlement-policy-bootstrap.imagePullSecrets`     | Pull secrets for entitlement policy bootstrap                                                                                                                                                                                                                                                                 | `nil`                                            |
| `entitlement-policy-bootstrap.istioTerminationHack` | Set istio on/off                                                                                                                                                                                                                                                                                              | `true`                                           |
| `entitlement-policy-bootstrap.image.tag`            | ocpr container tag                                                                                                                                                                                                                                                                                            | `sha-531eea2`                                    |

### Entitlement PDP Chart Overrides

| Name                                                | Description                                              | Value                                            |
| --------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------ |
| `entitlement-pdp.fullnameOverride`                  | Entitlement PDP name override                            | `entitlement-pdp`                                |
| `entitlement-pdp.opaConfig.policy.useStaticPolicy`  | Use static policy flag - false to pull from oci registry | `false`                                          |
| `entitlement-pdp.opaConfig.policy.allowInsecureTLS` | Allow insecure comms to oci registry                     | `true`                                           |
| `entitlement-pdp.opaConfig.policy.OCIRegistryUrl`   | OCI registry url                                         | `https://docker-registry:5000`                   |
| `entitlement-pdp.opaConfig.policy.bundleRepo`       | OCI Bundle Repo                                          | `docker-registry:5000/entitlements-policybundle` |
| `entitlement-pdp.opaConfig.policy.bundleTag`        | OCI bundle tag                                           | `0.0.2`                                          |
| `entitlement-pdp.config.disableTracing`             | Disable tracing flag                                     | `true`                                           |
| `entitlement-pdp.secretRef`                         | Secrets for env variables.                               | `name: platform-entitlement-pdp-secret`          |

### Entitlement Store Chart Overrides

| Name                                 | Description                       | Value                                     |
| ------------------------------------ | --------------------------------- | ----------------------------------------- |
| `entitlement-store.fullnameOverride` | Entitlement Store name override   | `entitlement-store`                       |
| `entitlement-store.secretRef`        | Secrets for environment variables | `name: platform-entitlement-store-secret` |

### Entitlement Chart Overrides

| Name                            | Description                                    | Value                                    |
| ------------------------------- | ---------------------------------------------- | ---------------------------------------- |
| `entitlements.fullnameOverride` | Entitlements Name Override                     | `entitlements`                           |
| `entitlements.secretRef`        | Entitlements Secrets for environment variables | `name: platform-entitlements-secret    ` |

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

### Attribute Definition / Entitlements Bootstrap Chart Overrides

| Name                                                  | Description                                           | Value                                     |
| ----------------------------------------------------- | ----------------------------------------------------- | ----------------------------------------- |
| `entitlement-attrdef-bootstrap.entitlements.hostname` | Entitlement svc hostname                              | `http://entitlements:4030`                |
| `entitlement-attrdef-bootstrap.entitlements.realms`   | Entitlement override realms                           | `nil`                                     |
| `entitlement-attrdef-bootstrap.existingConfigSecret`  | Secret name used to Mount bootstrapping data          | `platform-keycloakbootstrap-config`       |
| `entitlement-attrdef-bootstrap.istioTerminationHack`  | Set istio on/off                                      | `true`                                    |
| `entitlement-attrdef-bootstrap.secretRef`             | Secret for bootstrap job env variables.               | `name: platform-keycloakbootstrap-secret` |
| `entitlement-attrdef-bootstrap.attributes.hostname`   | Attribute service endpoint accessible to boostrap job | `http://attributes:4020`                  |
| `entitlement-attrdef-bootstrap.attributes.realm`      | Realm for OIDC client auth to attribute service       | `tdf`                                     |
| `entitlement-attrdef-bootstrap.attributes.clientId`   | OIDC client ID used to auth to attribute service      | `dcr-test`                                |

### Docker Registry Configuration

| Name                                  | Description                                           | Value                            |
| ------------------------------------- | ----------------------------------------------------- | -------------------------------- |
| `docker-registry.enabled`             | Enable docker registry                                | `true`                           |
| `docker-registry.fullnameOverride`    | Override name of service                              | `docker-registry`                |
| `docker-registry.persistence.enabled` | Persistence Enabled Flag                              | `true`                           |
| `docker-registry.persistence.size`    | Size of volume                                        | `1Gi`                            |
| `docker-registry.tlsSecretName`       | Secret name containing TLS Certs used by the registry | `platform-docker-registry-certs` |

### Secret Generation Parameters

| Name                                            | Description                                                                                    | Value          |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------- |
| `secrets.enabled`                               | Generate secrets from the values provided below.  If false, another bootstrapping              | `true`         |
| `secrets.postgresql.dbPassword`                 | password for postgres user                                                                     | `nil`          |
| `secrets.attributes.clientSecret`               | oidc client secret used by attributes svc to auth to idp and enforce svc authorization         | `nil`          |
| `secrets.attributes.dbPassword`                 | postgres password for attributes svc user                                                      | `nil`          |
| `secrets.configuration.dbPassword`              | postgres password for config svc user                                                          | `nil`          |
| `secrets.entitlementStore.dbPassword`           | postgres password for entitlement-store svc user                                               | `nil`          |
| `secrets.entitlements.clientSecret`             | oidc client secret used by entitlements svc to auth to idp and enforce svc authorization       | `nil`          |
| `secrets.entitlements.dbPassword`               | postgres password for entitlements svc user                                                    | `nil`          |
| `secrets.keycloak.adminUsername`                | Optional for bootstrapping - keycloak username for user with admin role                        | `nil`          |
| `secrets.keycloak.adminPassword`                | Optional for bootstrapping - keycloak password for user with admin role                        | `nil`          |
| `secrets.keycloakBootstrap.attributesUsername`  | username for attribute service auth                                                            | `nil`          |
| `secrets.keycloakBootstrap.attributesPassword`  | password for attribute service auth                                                            | `nil`          |
| `secrets.keycloakBootstrap.users`               | list of users to be added [{"username":"","password":""}]                                      | `nil`          |
| `secrets.keycloakBootstrap.clients`             | list of custom oidc clients added [{"clientId":<>,"clientSecret":"","audienceMappers":["aud]}] | `nil`          |
| `secrets.keycloakBootstrap.clientSecret`        | client secret assigned to standard bootstrapper clients                                        | `nil`          |
| `secrets.keycloakBootstrap.customConfig`        | Override for custom config to none                                                             | `nil`          |
| `secrets.opaPolicyPullSecret`                   | oci registry pull secret for OPA policy                                                        | `nil`          |
| `secrets.taggingPDP.clientSecret`               | OIDC Client Secret for Tagging PDP                                                             | `nil`          |
| `secrets.imageCredentials`                      | Map of key (pull name) to auth information.  Each key creates a pull cred                      |                |
| `secrets.imageCredentials.pull-secret`          | Container registry auth for "install name"-pull-secret                                         |                |
| `secrets.imageCredentials.pull-secret.registry` | Registry repo                                                                                  | `ghcr.io`      |
| `secrets.imageCredentials.pull-secret.username` | Registry Auth username                                                                         | `username`     |
| `secrets.imageCredentials.pull-secret.password` | Registry Auth password                                                                         | `password`     |
| `secrets.imageCredentials.pull-secret.email`    | Registry Auth email                                                                            | `nope@nah.com` |

### Tagging PDP Chart Overrides

| Name                                | Description                           | Value                         |
| ----------------------------------- | ------------------------------------- | ----------------------------- |
| `tagging-pdp.enabled`               | enabled flag                          | `true`                        |
| `tagging-pdp.fullnameOverride`      | override name                         | `tagging-pdp`                 |
| `tagging-pdp.image.tag`             | Tagging PDP Image Tag                 | `sha-6a63938`                 |
| `tagging-pdp.image.pullSecrets`     | TaggingPDP image pull secrets         | `nil`                         |
| `tagging-pdp.gateway.enabled`       | Tagging PDP Rest Gateway enabled flag | `true`                        |
| `tagging-pdp.gateway.pathPrefix`    | tagging-pdp svc prefix                | `tagging-pdp`                 |
| `tagging-pdp.config.attrSvc.url`    | Set the attribute service url         | `http://attributes:4020`      |
| `tagging-pdp.config.oidcSecretName` | Use existing secret for OIDC Creds    | `platform-tagging-pdp-secret` |
| `tagging-pdp.config.oidcClientId`   | OIDC Client ID for tagging pdp        | `shp-tagging-pdp`             |
| `tdfAdminUsername`                  | The admin user created for tdf.       | `tdf-admin`                   |

