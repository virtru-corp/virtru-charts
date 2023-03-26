

# Installation
Prerequisites:
- K8S Cluster; version TBD
- Helm; version TBD
- Istio Service Mesh + Istio Ingress Gateway: [See Istio Installation](./istio.md)

Install the SCP chart into the scp namespace
```shell
helm repo add twuni https://helm.twun.io
helm dependency update .
```

helm install w overrides for ghcr:
```shell
helm upgrade --install -n scp --create-namespace \
    --set entity-resolution.secret.keycloak.clientSecret=replaceme \
    --set access-pep.imageCredentials.username=replaceme \
    --set access-pep.imageCredentials.username=replaceme \
    --set access-pep.imageCredentials.password=replaceme_gh_pat scp .
```

```shell
helm uninstall scp -n scp
```

Notes:
- To get past keycloak login loop; need to override backend.keycloak envs to add admin url. [Ref](https://www.keycloak.org/server/hostname#_example_scenarios)
- Need to add audience mapper for access-pep: [Final result](./docs/kc_accesspep_aud_mapper.png)
  1. Keycloak admin login 
  1. Goto TDF realm
  1. Goto Client Scopes->Create Client Scope
  1. Enter name = access-pep-aud -> save
  1. Mappers -> Configure new mapper -> Audience :
  1. name = access-pep-aud-mapper
  1. included custom audience = access-pep
  1. Add to access token = enabled
- For testing access-pep a client must be updated to use, See:
  
  1. [Step 1](./docs/access-pep-client_1.png)
  1. [Step 2](./docs/access-pep-client_2.png)
  1. [Step 3](./docs/access-pep-client_3.png)
- Entity resolution
  - disableTracing not turned off
  - The client secret for entity resolution is not set by default
- Entitlement PDP: 
  - Policy stored in a private docker registry
  - Build new policy. e.g. from
    - [Reference](https://github.com/virtru-corp/federal-scp-platform/tree/main/entitlement-policy)
    - make policybuild
    - port forward docker registry: `kubectl port-forward svc/scp-docker-registry 5000:5000`
    - make policypushinsecure
- Additional KC Features?:
  - KC_FEATURES=token-exchange,preview

Using GRPC UI For Tagging Service:

Note, the UI is a bit flaky when using binary content. You need to click in the binary content after file upload.

- With reflection
  ```shell
  ~/go/bin/grpcui scp.virtrudemos.com:443
  ```
- Without server reflection - provide paths to protos.
  ```
  ~/go/bin/grpcui -proto ~/development/tagging-pdp/proto/src/main/proto/tagging-pdp.proto -import-path ~/development/tagging-pdp/proto/src/main/proto scp.virtrudemos.com:443
  ```