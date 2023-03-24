

# Installation
Prerequisites:
- K8S Cluster; version TBD
- Helm; version TBD
- Istio Service Mesh + Istio Ingress Gateway: [See Istio Installation](./istio.md)

Install the SCP chart into the scp namespace
```shell
helm dependency update .
```

helm install w overrides for ghcr:
```shell
helm upgrade --install -n scp --create-namespace \
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