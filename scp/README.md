

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
    keycloak:
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



