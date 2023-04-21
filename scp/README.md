

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

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| abacus.basePath | string | `"/abacus"` |  |
| abacus.enabled | bool | `true` | abacus enabled flag |
| abacus.fullnameOverride | string | `"abacus"` |  |
| abacus.ingress.enabled | bool | `false` |  |
| access-pep.config | object | `{"attrAuthorityHost":"http://attributes:4020","disableTracing":"true","entitlementPdpHost":"http://entitlement-pdp:3355","keycloakAttrAuthorityClientID":"tdf-client","keycloakAttrAuthorityClientSecret":null}` | Access Pep configuration |
| access-pep.enabled | bool | `true` | Enable access-pep flag |
| access-pep.existingImagePullSecret | string | `"scp-pull-secret"` | Existing pull secrets |
| access-pep.image.repo | string | `"ghcr.io/virtru-corp/access-pep/access-pep"` |  |
| access-pep.image.tag | string | `"sha-cac697c"` |  |
| access-pep.name | string | `"access-pep"` | Name override |
| attributes | object | `{"fullnameOverride":"attributes","secretRef":"name: scp-attributes-secret"}` | Attribute Chart Overrides |
| attributes.fullnameOverride | string | `"attributes"` | Attribute Service Name Override |
| bootstrap.configPath | string | `nil` |  |
| bootstrap.configsvc.enabled | bool | `true` |  |
| bootstrap.configsvc.job.backoffLimit | int | `5` |  |
| bootstrap.configsvc.job.configVolumeSecretRefName | string | `"scp-bootstrap-configsvc"` |  |
| bootstrap.configsvc.job.envSecretRef | string | `nil` |  |
| bootstrap.configsvc.job.image.pullPolicy | string | `"IfNotPresent"` |  |
| bootstrap.configsvc.job.image.repo | string | `"ghcr.io/virtru-corp/postman-cli/opcr-policy"` |  |
| bootstrap.configsvc.job.image.tag | string | `"sha-531eea2"` |  |
| bootstrap.configsvc.job.name | string | `"configsvc-bootstrap"` |  |
| bootstrap.entitlementPolicy | bool | `true` |  |
| bootstrap.keycloak | bool | `true` |  |
| commonParams | object | `{"attrEndpoint":"http://attributes:4020","disableTracing":"true","entilementPolicyOCIRegistryUrl":"https://scp-docker-registry:5000","entitlementPolicyBundleRepo":"scp-docker-registry:5000/entitlements-policybundle","entitlementPolicyBundleTag":"0.0.2","imagePullSecrets":[{"name":"scp-pull-secret"}],"scpImagePullSecretName":"scp-pull-secret"}` | Some yaml anchor definitions for convenience |
| configuration | object | `{"enabled":true,"fullnameOverride":"configuration","server":{"image":{"tag":"0.3.5"},"imagePullSecrets":[{"name":"scp-pull-secret"}],"postgres":{"host":"postgresql","password":null},"secretRef":"name: scp-configsvc"}}` | Configuration Chart Overrides |
| configuration.enabled | bool | `true` | Configuration Service enabled flag |
| configuration.fullnameOverride | string | `"configuration"` | Configuration svc name override |
| docker-registry.enabled | bool | `true` |  |
| docker-registry.persistence.enabled | bool | `true` |  |
| docker-registry.persistence.size | string | `"1Gi"` |  |
| docker-registry.tlsSecretName | string | `"scp-docker-registry-certs"` |  |
| embedded.keycloak | bool | `true` | Use an embedded keycloak or not |
| embedded.postgresql | bool | `true` | Use an embedded postgres or not |
| entitlement-pdp | object | `{"config":{"disableTracing":"true"},"fullnameOverride":"entitlement-pdp","opaConfig":{"policy":{"OCIRegistryUrl":"https://scp-docker-registry:5000","allowInsecureTLS":true,"bundleRepo":"scp-docker-registry:5000/entitlements-policybundle","bundleTag":"0.0.2","useStaticPolicy":false}},"secretRef":"name: scp-entitlement-pdp-secret"}` | Entitlement PDP Chart Overrides |
| entitlement-pdp.fullnameOverride | string | `"entitlement-pdp"` | Entitlement PDP name override |
| entitlement-pdp.opaConfig.policy.bundleRepo | string | `"scp-docker-registry:5000/entitlements-policybundle"` | Resource path to use to download bundle from configured service |
| entitlement-pdp.opaConfig.policy.useStaticPolicy | bool | `false` | Use static policy flag - false to pull from oci registry |
| entitlement-policy-bootstrap | object | `{"OCIRegistryUrl":"https://scp-docker-registry:5000","bundleRepo":"scp-docker-registry:5000/entitlements-policybundle","bundleTag":"0.0.2","image":{"tag":"sha-531eea2"},"imagePullSecrets":[{"name":"scp-pull-secret"}],"policyConfigMap":"scp-bootstrap-entitlement-cm","policyDataSecretRef":"scp-bootstrap-entitlement-policy","policyGlobPattern":"configs/fed-demo/entitlement-policy/*"}` | Entitlement Policy Bootstrap |
| entitlement-store.fullnameOverride | string | `"entitlement-store"` | Entitlement Store name override |
| entitlement-store.secretRef | string | `"name: scp-entitlement-store-secret"` |  |
| entitlements.fullnameOverride | string | `"entitlements"` | Entitlements Name Override |
| entitlements.secretRef | string | `"name: scp-entitlements-secret    "` |  |
| entity-resolution.config.disableTracing | string | `"true"` |  |
| entity-resolution.config.keycloak.legacy | bool | `true` |  |
| entity-resolution.fullnameOverride | string | `"entity-resolution"` | Entity Resolution Name override |
| fullnameOverride | string | `""` |  |
| global.opentdf.common.ingress.hostname | string | `"scp.virtrudemos.com"` |  |
| global.opentdf.common.ingress.scheme | string | `"https"` |  |
| global.opentdf.common.oidcExternalBaseUrl | string | `"https://scp.virtrudemos.com"` |  |
| global.opentdf.common.oidcInternalBaseUrl | string | `"http://keycloak-http"` |  |
| global.opentdf.common.oidcUrlPath | string | `"auth"` |  |
| global.opentdf.common.postgres.database | string | `"tdf_database"` | The database name within the given server |
| global.opentdf.common.postgres.host | string | `"postgresql"` | postgres server's k8s name or global DNS for external server |
| global.opentdf.common.postgres.port | int | `5432` | postgres server port |
| ingress.existingGateway | string | `nil` |  |
| ingress.gatewaySelector | string | `"ingress"` |  |
| ingress.name | string | `"scp"` |  |
| kas.endpoints.attrHost | string | `"http://attributes:4020"` | Attributes hostname accessible to KAS |
| kas.fullnameOverride | string | `"kas"` | KAS Name Override |
| kas.pdp.disableTracing | string | `"true"` | Disable tracing flag |
| kas.pdp.verbose | string | `"true"` |  |
| keycloak-bootstrap.attributes.clientId | string | `"dcr-test"` |  |
| keycloak-bootstrap.attributes.hostname | string | `"http://attributes:4020"` |  |
| keycloak-bootstrap.attributes.realm | string | `"tdf"` |  |
| keycloak-bootstrap.entitlements.hostname | string | `"http://entitlements:4030"` |  |
| keycloak-bootstrap.entitlements.realms | string | `nil` |  |
| keycloak-bootstrap.existingConfigSecret | string | `"scp-keycloakbootstrap-config"` |  |
| keycloak-bootstrap.secretRef | string | `"name: scp-keycloakbootstrap-secret"` |  |
| keycloak.command | list | `["/opt/keycloak/bin/kc.sh","--verbose","start-dev","--http-relative-path","/auth"]` | Command to start the keycloak service |
| keycloak.externalDatabase.database | string | `"keycloak_database"` |  |
| keycloak.extraEnv | string | `"- name: CLAIMS_URL\n  value: http://entitlement-pdp:3355/entitlements\n- name: JAVA_OPTS_APPEND\n  value: -Djgroups.dns.query={{ include \"keycloak.fullname\" . }}-headless\n- name: KC_DB\n  value: postgres\n- name: KC_DB_URL_PORT\n  value: \"5432\"\n- name: KC_LOG_LEVEL\n  value: INFO\n- name: KC_HOSTNAME_STRICT\n  value: \"false\"\n- name: KC_HOSTNAME_STRICT_BACKCHANNEL\n  value: \"false\"\n- name: KC_HOSTNAME_STRICT_HTTPS\n  value: \"false\"\n- name: KC_HOSTNAME_URL\n  value: {{ ( include \"keycloak.externalUrl\" . ) | quote }}\n- name: KC_HOSTNAME_ADMIN_URL\n  value: {{ ( include \"keycloak.externalUrl\" . ) | quote }}\n- name: KC_HTTP_ENABLED\n  value: \"true\"\n- name: KC_FEATURES\n  value: \"preview,token-exchange\""` | Extra environment variables. |
| keycloak.extraEnvFrom | string | `"- secretRef:\n    name: scp-keycloak-secret"` |  |
| keycloak.fullnameOverride | string | `"keycloak"` | keycloak name override |
| keycloak.image.pullPolicy | string | `"IfNotPresent"` |  |
| keycloak.image.repository | string | `"ghcr.io/opentdf/keycloak"` |  |
| keycloak.image.tag | string | `"main"` |  |
| keycloak.postgresql.enabled | bool | `false` |  |
| nameOverride | string | `""` |  |
| postgresql.auth.existingSecret | string | `"{{ include \"postgresql.primary.fullname\" . }}-secret\n"` |  |
| postgresql.fullnameOverride | string | `"postgresql"` |  |
| postgresql.image.debug | bool | `true` |  |
| postgresql.image.tag | string | `"11"` |  |
| postgresql.primary.initdb.scriptsSecret | string | `"{{ include \"postgresql.primary.fullname\" . }}-initdb-secret\n"` |  |
| postgresql.primary.initdb.user | string | `"postgres"` |  |
| secrets | object | `{"attributes":{"clientSecret":null,"dbPassword":null},"configuration":{"dbPassword":null},"enabled":true,"entitlementStore":{"dbPassword":null},"entitlements":{"clientSecret":null,"dbPassword":null},"imageCredentials":[{"email":"nope@nah.com","name":"scp-pull-secret","password":"password","registry":"ghcr.io","username":"username"}],"keycloak":{"adminPassword":null,"adminUsername":null,"dbPassword":null},"keycloakBootstrap":{"attributesPassword":null,"attributesUsername":null,"clientSecret":null,"clients":null,"customConfig":null,"users":null},"opaPolicyPullSecret":null,"postgresql":{"dbPassword":null}}` | Templates for generating secrets |
| secrets.attributes.clientSecret | string | `nil` | oidc client secret used by attributes svc to auth to idp and enforce svc authorization |
| secrets.attributes.dbPassword | string | `nil` | postgres password for attributes svc user |
| secrets.configuration.dbPassword | string | `nil` | postgres password for config svc user |
| secrets.enabled | bool | `true` | Generate secrets from the values provided below.  If false, another bootstrapping mechanism for secrets is required. |
| secrets.entitlementStore.dbPassword | string | `nil` | postgres password for entitlement-store svc user |
| secrets.entitlements.clientSecret | string | `nil` | oidc client secret used by entitlements svc to auth to idp and enforce svc authorization |
| secrets.entitlements.dbPassword | string | `nil` | postgres password for entitlements svc user |
| secrets.imageCredentials | list | `[{"email":"nope@nah.com","name":"scp-pull-secret","password":"password","registry":"ghcr.io","username":"username"}]` | Image pull credentials. |
| secrets.keycloak.adminPassword | string | `nil` | Keycloak admin user's password |
| secrets.keycloak.adminUsername | string | `nil` | keycloak admin user's username |
| secrets.keycloak.dbPassword | string | `nil` | postgres password for keycloak svc user |
| secrets.keycloakBootstrap.attributesPassword | string | `nil` | password for attribute service auth |
| secrets.keycloakBootstrap.attributesUsername | string | `nil` | username for attribute service auth |
| secrets.keycloakBootstrap.clientSecret | string | `nil` | client secret assigned to standard bootstrapper clients |
| secrets.keycloakBootstrap.clients | string | `nil` | list of custom oidc clients to add |
| secrets.keycloakBootstrap.users | string | `nil` | list of users to be added |
| secrets.opaPolicyPullSecret | string | `nil` | oci registry pull secret for OPA policy |
| secrets.postgresql.dbPassword | string | `nil` | password for postgres user |
| tagging-pdp | object | `{"enabled":true,"fullnameOverride":"tagging-pdp","gateway":{"enabled":true,"image":{"tag":"sha-e28d7ee"},"pathPrefix":"tagging-pdp"},"image":{"pullSecrets":[{"name":"scp-pull-secret"}],"tag":"sha-470efff"}}` | Tagging PDP Chart Overrides |
| tdfAdminUsername | string | `"tdf-admin"` | The admin user created for tdf. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)

