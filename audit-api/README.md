## Parameters

### Image parameters

| Name               | Description       | Value                           |
| ------------------ | ----------------- | ------------------------------- |
| `image.repository` | Image repository  | `ghcr.io/virtru-corp/audit-api` |
| `image.pullPolicy` | Image Pull Policy | `Always`                        |
| `image.tag`        | Image tag         | `0.23.0`                        |

### imagePullSecrets Image Pull Secrets - Overrides Global

| Name                       | Description            | Value                   |
| -------------------------- | ---------------------- | ----------------------- |
| `imagePullSecrets[0].name` | Image Pull Secret Name | `audit-api-pull-secret` |

### Deployment Parameters

| Name                                  | Description                                                                                                            | Value            |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `nameOverride`                        | Override name of the chart                                                                                             | `""`             |
| `fullnameOverride`                    | Override the full name of the chart                                                                                    | `""`             |
| `config.db.host`                      | Postgresql DB Host                                                                                                     | `postgresql`     |
| `config.db.user`                      | Postgresql DB Username                                                                                                 | `audit_manager`  |
| `config.db.port`                      | Postgresql DB Port                                                                                                     | `5432`           |
| `config.db.dbName`                    | Postgresql DB Name                                                                                                     | `audit_database` |
| `config.db.sslMode`                   | Postgresql SSL Mode                                                                                                    | `disable`        |
| `config.platform.disableInternalAuth` | disable internal service auth                                                                                          | `true`           |
| `config.platform.defaultOrgId`        | orgId used for queries                                                                                                 | `nil`            |
| `config.secrets.dbPassword`           | Postgresql Database password - used if `config.existingSecret` is blank                                                | `nil`            |
| `serviceAccount.create`               | Specifies whether a service account should be created                                                                  | `true`           |
| `serviceAccount.annotations`          | Annotations to add to the service account                                                                              | `{}`             |
| `serviceAccount.name`                 | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""`             |

### podAnnotations Pod K8S Annotations

| Name                                   | Description                                                             | Value                                         |
| -------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------- |
| `podAnnotations.proxy.istio.io/config` | Istio Proxy Annotations                                                 | `{ "holdApplicationUntilProxyStarts": true }` |
| `podSecurityContext`                   | Values for deployment's `spec.template.spec.securityContext`            | `{}`                                          |
| `securityContext`                      | Values for deployment's `spec.template.spec.containers.securityContext` | `{}`                                          |

### service type of service and port to expose

| Name           | Description               | Value       |
| -------------- | ------------------------- | ----------- |
| `service.type` | type of service to create | `ClusterIP` |
| `service.port` | port to expose            | `8080`      |

### Istio AuthN/Z Parameters

| Name                                 | Description                                                                                                   | Value                     |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `istioAuth.enabled`                  | Turn on/off istio authentication configuration for services defined by the `istioAuth.policies` configuration | `true`                    |
| `istioAuth.internalJWTURL`           | Whether to compute and use internal keycloak jwks uri - default false                                         | `true`                    |
| `istioAuth.oidc.oidcExternalBaseUrl` | The external base url of the oidc provider                                                                    | `https://shp.example.com` |
| `istioAuth.oidc.oidcUrlPath`         | The path added to the base url to reach the oidc provider                                                     | `auth`                    |
| `istioAuth.oidc.keycloakRealm`       | If using keycloak - the realm name                                                                            | `tdf`                     |

### Secret Generation Parameters

| Name                                            | Description                                                               | Value          |
| ----------------------------------------------- | ------------------------------------------------------------------------- | -------------- |
| `secrets.imageCredentials`                      | Map of key (pull name) to auth information.  Each key creates a pull cred |                |
| `secrets.imageCredentials.pull-secret`          | Container registry auth for "install name"-pull-secret                    |                |
| `secrets.imageCredentials.pull-secret.registry` | Registry repo                                                             | `ghcr.io`      |
| `secrets.imageCredentials.pull-secret.username` | Registry Auth username                                                    | `username`     |
| `secrets.imageCredentials.pull-secret.password` | Registry Auth password                                                    | `password`     |
| `secrets.imageCredentials.pull-secret.email`    | Registry Auth email                                                       | `nope@nah.com` |

### Ingress Configuration

| Name                      | Description                        | Value   |
| ------------------------- | ---------------------------------- | ------- |
| `ingress.enabled`         | Enable ingress controller resource | `false` |
| `ingress.existingGateway` | Use an existing istio gateway      | `nil`   |
| `ingress.className`       | Ingress controller class name      | `""`    |
| `ingress.annotations`     | Ingress annotations                | `{}`    |

### ingress.hosts Ingress hostnames

| Name                                 | Description                                                                                                                                                                                                                                                                | Value                    |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `ingress.hosts[0].host`              | Ingress hostname                                                                                                                                                                                                                                                           | `chart-example.local`    |
| `ingress.hosts[0].paths[0].path`     | Ingress paths                                                                                                                                                                                                                                                              | `/`                      |
| `ingress.hosts[0].paths[0].pathType` | Ingress path type                                                                                                                                                                                                                                                          | `ImplementationSpecific` |
| `ingress.tls`                        | Ingress TLS configuration                                                                                                                                                                                                                                                  | `[]`                     |
| `autoscaling.enabled`                | Auto Scale deployment                                                                                                                                                                                                                                                      | `nil`                    |
| `resources`                          | Specify required limits for deploying this service to a pod.  We usually recommend not to specify default resources and to leave this as a conscious  choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. | `{}`                     |
| `nodeSelector`                       | Node labels for pod assignment                                                                                                                                                                                                                                             | `{}`                     |
| `tolerations`                        | Tolerations for nodes that have taints on them                                                                                                                                                                                                                             | `[]`                     |
| `affinity`                           | Pod scheduling preferences                                                                                                                                                                                                                                                 | `{}`                     |

### tags for depenencies

| Name              | Description                                   | Value  |
| ----------------- | --------------------------------------------- | ------ |
| `tags.fluent-bit` | Tag for fluent-bit dependency default is true | `true` |
