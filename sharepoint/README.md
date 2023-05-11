# Deployment

Install
```shell
helm dependency update
```
```shell
helm upgrade --install -n <namespace> --create-namespace \
    -f sharepoint/values.yaml \
     sharepoint sharepoint
```

```shell
helm template -n scp --create-namespace \
    -f sharepoint/values.yaml \
     sharepoint sharepoint
```

# Chart Values Documentation
Parameter documentation generated from [generator-for-helm](https://github.com/bitnami-labs/readme-generator-for-helm)
```shell
npm i https://github.com/bitnami-labs/readme-generator-for-helm
npx @bitnami/readme-generator-for-helm -v sharepoint/values.yaml -r sharepoint/README.md
```

## Parameters

### Global parameters

| Name                                        | Description                                                  | Value   |
| ------------------------------------------- | ------------------------------------------------------------ | ------- |
| `global.imagePullSecrets`                   | Image Pull Secrets                                           | `nil`   |
| `global.auth.organization`                  | Auth Organization for OIDC                                   | `tdf`   |
| `global.istioEnabled`                       | Istio enabled true/false                                     | `true`  |
| `global.opentdf.common.oidcExternalBaseUrl` |                                                              | `nil`   |
| `global.opentdf.common.oidcInternalBaseUrl` |                                                              | `nil`   |
| `global.opentdf.common.oidcUrlPath`         |                                                              | `auth`  |
| `global.opentdf.common.ingress.scheme`      | ingress schem                                                | `https` |
| `global.opentdf.common.ingress.hostname`    | ingress hostname                                             | `nil`   |
| `global.opentdf.common.postgres.host`       | postgres server's k8s name or global DNS for external server | `nil`   |
| `global.opentdf.common.postgres.port`       | postgres server port                                         | `nil`   |

### Image parameters

| Name               | Description                           | Value                                                                |
| ------------------ | ------------------------------------- | -------------------------------------------------------------------- |
| `imagePullSecrets` | Image Pull Secrets - Overrides Global | `nil`                                                                |
| `image.tag`        | Image tag                             | `sha-470efff`                                                        |
| `image.repo`       | Image repository                      | `ghcr.io/virtru-corp/sharepoint-webhooks/sharepoint-webhook-service` |
| `image.pullPolicy` | Image Pull Policy                     | `IfNotPresent`                                                       |

### Webhook Service Configuration

| Name                              | Description                                                             | Value                                     |
| --------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------- |
| `service.port`                    | Service port                                                            | `8080`                                    |
| `service.type`                    | Service Type                                                            | `ClusterIP`                               |
| `config.db.host`                  | Postgresql DB Host                                                      | `nil`                                     |
| `config.db.user`                  | Postgresql DB Username                                                  | `nil`                                     |
| `config.db.port`                  | Postgresql DB Port                                                      | `nil`                                     |
| `config.db.dbName`                | Postgresql DB Name                                                      | `nil`                                     |
| `config.db.sslMode`               | Postgresql SSL Mode                                                     | `disable`                                 |
| `config.auth.url`                 | OIDC Auth Endpoint - override global.opentdf.common.oidcExternalBaseUrl | `nil`                                     |
| `config.auth.org`                 | OIDC Organization - overrides global.auth.organization                  | `tdf`                                     |
| `config.auth.clientId`            | OIDC Client Id                                                          | `nil`                                     |
| `config.configSvc.url`            | Configuration Service Endpoint                                          | `http://configuration:8080/configuration` |
| `config.configSvc.artifactId`     | Configuration Artifact Identifier used by the sharepoint service        | `nil`                                     |
| `config.existingSecret`           | Existing Secret Name for secret env vars                                | `nil`                                     |
| `config.secrets.dbPassword`       | Postgresql Database password - used if `config.existingSecret` is blank | `nil`                                     |
| `config.secrets.oidcClientSecret` | OIDC Client Secret - used if `config.existingSecret` is blank           | `nil`                                     |

### Deployment Parameters

| Name                           | Description                                                                                                                                                                                                                                                                | Value  |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `nameOverride`                 | Override name of the chart                                                                                                                                                                                                                                                 | `""`   |
| `fullnameOverride`             | Override the full name of the chart                                                                                                                                                                                                                                        | `""`   |
| `podAnnotations`               | Pod K8S Annotations                                                                                                                                                                                                                                                        | `{}`   |
| `podSecurityContext`           | Values for deployment's `spec.template.spec.securityContext`                                                                                                                                                                                                               | `{}`   |
| `replicaCount`                 | Deployment Replica Count                                                                                                                                                                                                                                                   | `1`    |
| `securityContext`              | Values for deployment's `spec.template.spec.containers.securityContext`                                                                                                                                                                                                    |        |
| `securityContext.runAsNonRoot` | Security Context runAsNonRoot                                                                                                                                                                                                                                              | `true` |
| `securityContext.runAsUser`    | Security Context runAsUser                                                                                                                                                                                                                                                 | `1000` |
| `resources`                    | Specify required limits for deploying this service to a pod.  We usually recommend not to specify default resources and to leave this as a conscious  choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. | `{}`   |
| `nodeSelector`                 | Node labels for pod assignment                                                                                                                                                                                                                                             | `{}`   |
| `tolerations`                  | Tolerations for nodes that have taints on them                                                                                                                                                                                                                             | `[]`   |
| `affinity`                     | Pod scheduling preferences                                                                                                                                                                                                                                                 | `{}`   |
