## Parameters

### Image parameters

| Name               | Description       | Value                           |
| ------------------ | ----------------- | ------------------------------- |
| `image.repository` | Image repository  | `ghcr.io/virtru-corp/audit-api` |
| `image.pullPolicy` | Image Pull Policy | `Always`                        |
| `image.tag`        | Image tag         | `0.22.0-8057e1b`                |

### imagePullSecrets Image Pull Secrets - Overrides Global

| Name                       | Description            | Value                  |
| -------------------------- | ---------------------- | ---------------------- |
| `imagePullSecrets[0].name` | Image Pull Secret Name | `platform-pull-secret` |

### Deployment Parameters

| Name                         | Description                                                                                                            | Value            |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `nameOverride`               | Override name of the chart                                                                                             | `""`             |
| `fullnameOverride`           | Override the full name of the chart                                                                                    | `""`             |
| `config.db.host`             | Postgresql DB Host                                                                                                     | `postgresql`     |
| `config.db.user`             | Postgresql DB Username                                                                                                 | `audit_manager`  |
| `config.db.port`             | Postgresql DB Port                                                                                                     | `5432`           |
| `config.db.dbName`           | Postgresql DB Name                                                                                                     | `audit_database` |
| `config.db.sslMode`          | Postgresql SSL Mode                                                                                                    | `disable`        |
| `config.secrets.dbPassword`  | Postgresql Database password - used if `config.existingSecret` is blank                                                | `nil`            |
| `serviceAccount.create`      | Specifies whether a service account should be created                                                                  | `true`           |
| `serviceAccount.annotations` | Annotations to add to the service account                                                                              | `{}`             |
| `serviceAccount.name`        | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""`             |

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

### Ingress Configuration

| Name                  | Description                        | Value   |
| --------------------- | ---------------------------------- | ------- |
| `ingress.enabled`     | Enable ingress controller resource | `false` |
| `ingress.className`   | Ingress controller class name      | `""`    |
| `ingress.annotations` | Ingress annotations                | `{}`    |

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
