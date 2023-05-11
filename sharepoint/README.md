# Deployment

## Install Chart
```shell
helm dependency update
```
Install from source in this repo:
```shell
helm upgrade --install -n <namespace> --create-namespace \
    -f sharepoint/values.yaml \
     sharepoint sharepoint
```
Install from published chart:
- add repo
    ```shell
    helm repo add virtru-charts \
        https://raw.githubusercontent.com/virtru-corp/virtru-charts/main/
    ```
- update repo
    ```shell
    helm repo update
    helm search repo 
    ```
- install chart
    ```
    helm upgrade --install -n <namespace> --create-namespace \
        -f <overrides-file> \
        sharepoint virtru-charts/sharepoint
    ```

### Example - Using generated service secrets and image pull credentials.
The example:
- sets the private key to value in `sharepoint/example/privateKey.pfx`
- create image pull credentials named "ghcr" for github container registry with username/password 

```shell
helm upgrade --install -n <namespace> --create-namespace \
    --set "imageCredentials[0].name"="ghcr" \
    --set "imageCredentials[0].username"="${GITHUB_USERNAME}" \
    --set "imageCredentials[0].password"="${GITHUB_TOKEN}" \
    --set "imageCredentials[0].email"="nope@nah.com" \
    --set "imageCredentials[0].registry"="ghcr.io" \
    --set-file config.sharepointPfx=sharepoint/example/privateKey.pfx \
    -f sharepoint/values.yaml \
    -f sharepoint/example/example-values.yaml \
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

| Name               | Description                                                                                                                             | Value                                                                |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `imagePullSecrets` | Image Pull Secrets - Overrides Global                                                                                                   | `nil`                                                                |
| `image.tag`        | Image tag                                                                                                                               | `sha-470efff`                                                        |
| `image.repo`       | Image repository                                                                                                                        | `ghcr.io/virtru-corp/sharepoint-webhooks/sharepoint-webhook-service` |
| `image.pullPolicy` | Image Pull Policy                                                                                                                       | `IfNotPresent`                                                       |
| `imageCredentials` | - If `imagePullSecrets` is NOT set and this is, image pull secrets are generated from this list. list [{name,registry,password, email}] | `[]`                                                                 |

### Webhook Service Configuration

| Name                              | Description                                                                                  | Value                                     |
| --------------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------- |
| `service.port`                    | Service port                                                                                 | `8080`                                    |
| `service.type`                    | Service Type                                                                                 | `ClusterIP`                               |
| `config.db.host`                  | Postgresql DB Host                                                                           | `nil`                                     |
| `config.db.user`                  | Postgresql DB Username                                                                       | `nil`                                     |
| `config.db.port`                  | Postgresql DB Port                                                                           | `nil`                                     |
| `config.db.dbName`                | Postgresql DB Name                                                                           | `nil`                                     |
| `config.db.sslMode`               | Postgresql SSL Mode                                                                          | `disable`                                 |
| `config.auth.url`                 | OIDC Auth Endpoint - override global.opentdf.common.oidcExternalBaseUrl                      | `nil`                                     |
| `config.auth.org`                 | OIDC Organization - overrides global.auth.organization                                       | `tdf`                                     |
| `config.auth.clientId`            | OIDC Client Id                                                                               | `nil`                                     |
| `config.configSvc.url`            | Configuration Service Endpoint                                                               | `http://configuration:8080/configuration` |
| `config.configSvc.artifactId`     | Configuration Artifact Identifier used by the sharepoint service                             | `sharepoint`                              |
| `config.existingSecret`           | Existing Secret Name for secret env vars                                                     | `nil`                                     |
| `config.sharepointPfx`            | Set the Private Key PFX used in Sharepoint Authentication - use --set-file to set this value | `nil`                                     |
| `config.secrets.dbPassword`       | Postgresql Database password - used if `config.existingSecret` is blank                      | `nil`                                     |
| `config.secrets.oidcClientSecret` | OIDC Client Secret - used if `config.existingSecret` is blank                                | `nil`                                     |

### Ingress Configuration

| Name                            | Description                                           | Value          |
| ------------------------------- | ----------------------------------------------------- | -------------- |
| `ingress.istio.enabled`         | Enable istio ingress, overrides `global.istioEnabled` | `true`         |
| `ingress.istio.existingGateway` | Name of an exiting ingress gateway to use             | `nil`          |
| `ingress.istio.ingressSelector` | Selector of ingress gateway                           | `ingress`      |
| `ingress.istio.ingressPrefix`   | Ingress path to expose in the Virtual Service         | `/sharepoint/` |

### Deployment Parameters

| Name                           | Description                                                                                                                                                                                                                                                                | Value  |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| `nameOverride`                 | Override name of the chart                                                                                                                                                                                                                                                 | `""`   |
| `fullnameOverride`             | Override the full name of the chart                                                                                                                                                                                                                                        | `""`   |
| `podAnnotations`               | Pod K8S Annotations                                                                                                                                                                                                                                                        | `{}`   |
| `podSecurityContext`           | Values for deployment's `spec.template.spec.securityContext`                                                                                                                                                                                                               | `{}`   |
| `autoscaling.enabled`          | Auto Scale deployment                                                                                                                                                                                                                                                      | `nil`  |
| `serviceAccount.create`        | Specifies whether a service account should be created                                                                                                                                                                                                                      | `true` |
| `serviceAccount.annotations`   | Annotations to add to the service account                                                                                                                                                                                                                                  | `{}`   |
| `serviceAccount.name`          | The name of the service account to use. If not set and create is true, a name is generated using the fullname template                                                                                                                                                     | `nil`  |
| `replicaCount`                 | Deployment Replica Count                                                                                                                                                                                                                                                   | `1`    |
| `securityContext`              | Values for deployment's `spec.template.spec.containers.securityContext`                                                                                                                                                                                                    |        |
| `securityContext.runAsNonRoot` | Security Context runAsNonRoot                                                                                                                                                                                                                                              | `true` |
| `securityContext.runAsUser`    | Security Context runAsUser                                                                                                                                                                                                                                                 | `1000` |
| `resources`                    | Specify required limits for deploying this service to a pod.  We usually recommend not to specify default resources and to leave this as a conscious  choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. | `{}`   |
| `nodeSelector`                 | Node labels for pod assignment                                                                                                                                                                                                                                             | `{}`   |
| `tolerations`                  | Tolerations for nodes that have taints on them                                                                                                                                                                                                                             | `[]`   |
| `affinity`                     | Pod scheduling preferences                                                                                                                                                                                                                                                 | `{}`   |
