

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
| abacus.enabled | bool | `true` |  |
| abacus.fullnameOverride | string | `"abacus"` |  |
| abacus.ingress.enabled | bool | `false` |  |
| access-pep.config.attrAuthorityHost | string | `"http://attributes:4020"` |  |
| access-pep.config.disableTracing | string | `"true"` |  |
| access-pep.config.entitlementPdpHost | string | `"http://entitlement-pdp:3355"` |  |
| access-pep.config.keycloakAttrAuthorityClientID | string | `"tdf-client"` |  |
| access-pep.config.keycloakAttrAuthorityClientSecret | string | `nil` |  |
| access-pep.enabled | bool | `true` |  |
| access-pep.existingImagePullSecret | string | `"scp-pull-secret"` |  |
| access-pep.image.repo | string | `"ghcr.io/virtru-corp/access-pep/access-pep"` |  |
| access-pep.image.tag | string | `"sha-cac697c"` |  |
| access-pep.name | string | `"access-pep"` |  |
| attributes.fullnameOverride | string | `"attributes"` |  |
| attributes.secretRef | string | `"name: scp-attributes-secret"` |  |
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
| commonParams.attrEndpoint | string | `"http://attributes:4020"` |  |
| commonParams.disableTracing | string | `"true"` |  |
| commonParams.entilementPolicyOCIRegistryUrl | string | `"https://scp-docker-registry:5000"` |  |
| commonParams.entitlementPolicyBundleRepo | string | `"scp-docker-registry:5000/entitlements-policybundle"` |  |
| commonParams.entitlementPolicyBundleTag | string | `"0.0.2"` |  |
| commonParams.imagePullSecrets[0].name | string | `"scp-pull-secret"` |  |
| commonParams.scpImagePullSecretName | string | `"scp-pull-secret"` |  |
| configuration.enabled | bool | `true` |  |
| configuration.fullnameOverride | string | `"configuration"` |  |
| configuration.server.image.tag | string | `"0.3.5"` |  |
| configuration.server.imagePullSecrets[0].name | string | `"scp-pull-secret"` |  |
| configuration.server.postgres.host | string | `"postgresql"` |  |
| configuration.server.postgres.password | string | `nil` |  |
| configuration.server.secretRef | string | `"name: scp-configsvc"` |  |
| docker-registry.enabled | bool | `true` |  |
| docker-registry.persistence.enabled | bool | `true` |  |
| docker-registry.persistence.size | string | `"1Gi"` |  |
| docker-registry.tlsSecretName | string | `"scp-docker-registry-certs"` |  |
| embedded.keycloak | bool | `true` | Use an embedded keycloak or not |
| embedded.postgresql | bool | `true` | Use an embedded postgres or not |
| entitlement-pdp.config.disableTracing | string | `"true"` |  |
| entitlement-pdp.fullnameOverride | string | `"entitlement-pdp"` |  |
| entitlement-pdp.opaConfig.policy.OCIRegistryUrl | string | `"https://scp-docker-registry:5000"` |  |
| entitlement-pdp.opaConfig.policy.allowInsecureTLS | bool | `true` |  |
| entitlement-pdp.opaConfig.policy.bundleRepo | string | `"scp-docker-registry:5000/entitlements-policybundle"` | Resource path to use to download bundle from configured service |
| entitlement-pdp.opaConfig.policy.bundleTag | string | `"0.0.2"` |  |
| entitlement-pdp.opaConfig.policy.useStaticPolicy | bool | `false` |  |
| entitlement-pdp.secretRef | string | `"name: scp-entitlement-pdp-secret"` |  |
| entitlement-policy-bootstrap.OCIRegistryUrl | string | `"https://scp-docker-registry:5000"` |  |
| entitlement-policy-bootstrap.bundleRepo | string | `"scp-docker-registry:5000/entitlements-policybundle"` |  |
| entitlement-policy-bootstrap.bundleTag | string | `"0.0.2"` |  |
| entitlement-policy-bootstrap.image.tag | string | `"sha-531eea2"` |  |
| entitlement-policy-bootstrap.imagePullSecrets[0].name | string | `"scp-pull-secret"` |  |
| entitlement-policy-bootstrap.policyConfigMap | string | `"scp-bootstrap-entitlement-cm"` |  |
| entitlement-policy-bootstrap.policyDataSecretRef | string | `"scp-bootstrap-entitlement-policy"` |  |
| entitlement-policy-bootstrap.policyGlobPattern | string | `"configs/fed-demo/entitlement-policy/*"` |  |
| entitlement-store.fullnameOverride | string | `"entitlement-store"` |  |
| entitlement-store.secretRef | string | `"name: scp-entitlement-store-secret"` |  |
| entitlements.fullnameOverride | string | `"entitlements"` |  |
| entitlements.secretRef | string | `"name: scp-entitlements-secret    "` |  |
| entity-resolution.config.disableTracing | string | `"true"` |  |
| entity-resolution.config.keycloak.legacy | bool | `true` |  |
| entity-resolution.fullnameOverride | string | `"entity-resolution"` |  |
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
| kas.endpoints.attrHost | string | `"http://attributes:4020"` |  |
| kas.fullnameOverride | string | `"kas"` |  |
| kas.pdp.disableTracing | string | `"true"` |  |
| kas.pdp.verbose | string | `"true"` |  |
| keycloak-bootstrap.attributes.clientId | string | `"dcr-test"` |  |
| keycloak-bootstrap.attributes.hostname | string | `"http://attributes:4020"` |  |
| keycloak-bootstrap.attributes.realm | string | `"tdf"` |  |
| keycloak-bootstrap.entitlements.hostname | string | `"http://entitlements:4030"` |  |
| keycloak-bootstrap.entitlements.realms | string | `nil` |  |
| keycloak-bootstrap.existingConfigSecret | string | `"scp-keycloakbootstrap-config"` |  |
| keycloak-bootstrap.secretRef | string | `"name: scp-keycloakbootstrap-secret"` |  |
| keycloak.command[0] | string | `"/opt/keycloak/bin/kc.sh"` |  |
| keycloak.command[1] | string | `"--verbose"` |  |
| keycloak.command[2] | string | `"start-dev"` |  |
| keycloak.command[3] | string | `"--http-relative-path"` |  |
| keycloak.command[4] | string | `"/auth"` |  |
| keycloak.externalDatabase.database | string | `"keycloak_database"` |  |
| keycloak.extraEnv | string | `"- name: CLAIMS_URL\n  value: http://entitlement-pdp:3355/entitlements\n- name: JAVA_OPTS_APPEND\n  value: -Djgroups.dns.query={{ include \"keycloak.fullname\" . }}-headless\n- name: KC_DB\n  value: postgres\n- name: KC_DB_URL_PORT\n  value: \"5432\"\n- name: KC_LOG_LEVEL\n  value: INFO\n- name: KC_HOSTNAME_STRICT\n  value: \"false\"\n- name: KC_HOSTNAME_STRICT_BACKCHANNEL\n  value: \"false\"\n- name: KC_HOSTNAME_STRICT_HTTPS\n  value: \"false\"\n- name: KC_HOSTNAME_URL\n  value: {{ ( include \"keycloak.externalUrl\" . ) | quote }}\n- name: KC_HOSTNAME_ADMIN_URL\n  value: {{ ( include \"keycloak.externalUrl\" . ) | quote }}\n- name: KC_HTTP_ENABLED\n  value: \"true\"\n- name: KC_FEATURES\n  value: \"preview,token-exchange\""` |  |
| keycloak.extraEnvFrom | string | `"- secretRef:\n    name: scp-keycloak-secret"` |  |
| keycloak.fullnameOverride | string | `"keycloak"` |  |
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
| secrets.attributes.clientSecret | string | `nil` |  |
| secrets.attributes.dbPassword | string | `nil` |  |
| secrets.configuration.dbPassword | string | `nil` |  |
| secrets.enabled | bool | `true` |  |
| secrets.entitlementStore.dbPassword | string | `nil` |  |
| secrets.entitlements.clientSecret | string | `nil` |  |
| secrets.entitlements.dbPassword | string | `nil` |  |
| secrets.imageCredentials[0].email | string | `"nope@nah.com"` |  |
| secrets.imageCredentials[0].name | string | `"scp-pull-secret"` |  |
| secrets.imageCredentials[0].password | string | `"password"` |  |
| secrets.imageCredentials[0].registry | string | `"ghcr.io"` |  |
| secrets.imageCredentials[0].username | string | `"username"` |  |
| secrets.keycloak.adminPassword | string | `nil` |  |
| secrets.keycloak.adminUsername | string | `nil` |  |
| secrets.keycloak.dbPassword | string | `nil` |  |
| secrets.keycloakBootstrap.attributesPassword | string | `nil` |  |
| secrets.keycloakBootstrap.attributesUsername | string | `nil` |  |
| secrets.keycloakBootstrap.clientSecret | string | `nil` |  |
| secrets.keycloakBootstrap.clients | string | `nil` |  |
| secrets.keycloakBootstrap.customConfig | string | `nil` |  |
| secrets.keycloakBootstrap.users | string | `nil` |  |
| secrets.opaPolicyPullSecret | string | `nil` |  |
| secrets.postgresql.dbPassword | string | `nil` |  |
| tagging-pdp.enabled | bool | `true` |  |
| tagging-pdp.fullnameOverride | string | `"tagging-pdp"` |  |
| tagging-pdp.gateway.enabled | bool | `true` |  |
| tagging-pdp.gateway.image.tag | string | `"sha-e28d7ee"` |  |
| tagging-pdp.gateway.pathPrefix | string | `"tagging-pdp"` |  |
| tagging-pdp.image.pullSecrets[0].name | string | `"scp-pull-secret"` |  |
| tagging-pdp.image.tag | string | `"sha-470efff"` |  |
| tdfAdminUsername | string | `"tdf-admin"` |  |


