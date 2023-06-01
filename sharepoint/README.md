# Deployment

## Install Chart

### Prerequisites 
- A postgresql database.  See [Example role/db creation](../platform-embedded-postgresql/templates/_sql.sharepoint.tpl)
- A Deployed TDF Platform See [TDF Platform](../scp)
- SharePoint Configuration Artifact uploaded to platform configuration service.
- Istio - Optional

### Install from source in this repo
```shell
helm dependency update
```
```shell
helm upgrade --install -n <namespace> --create-namespace \
    -f sharepoint/values.yaml \
     sharepoint sharepoint
```

### Install from published chart
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
This example deploys the chart using an example shell script; example from base directory of the repo.

This assumes [Prerequisites](#prerequisites) have been completed.</a>

```shell
export ns=scp
helm template -n scp \
    --set "imageCredentials[0].name"="ghcr" \
    --set "imageCredentials[0].username"="${GITHUB_USERNAME}" \
    --set "imageCredentials[0].password"="${GITHUB_TOKEN}" \
    --set "imageCredentials[0].email"="nope@nah.com" \
    --set "imageCredentials[0].registry"="ghcr.io" \
    --set-file config.privateKeyPfx=sharepoint/example/privateKey.pfx \
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
| `image.tag`        | Image tag                                                                                                                               | `sha-b51ffd3`                                                        |
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

### Bootstrap Configuration

| Name                             | Description                                                                                                                                        | Value                                         |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `bootstrap.enabled`              | Enable Flag for Sharepoint Configuration Bootstrapping                                                                                             | `false`                                       |
| `bootstrap.configFile`           | Configuration yaml for configuration artifacts. Use --set-file bootstrap.configFile=XXX. Expected yaml schema see scp/docs/config_file_schema.json | `nil`                                         |
| `bootstrap.job.name`             | Name of the job to bootstrap sharepoint configuration                                                                                              | `config-bootstrap`                            |
| `bootstrap.job.image.repo`       | Image repository                                                                                                                                   | `ghcr.io/virtru-corp/postman-cli/opcr-policy` |
| `bootstrap.job.image.tag`        | Image tag                                                                                                                                          | `sha-531eea2`                                 |
| `bootstrap.job.image.pullPolicy` | Image pull policy                                                                                                                                  | `IfNotPresent`                                |
| `bootstrap.job.backoffLimit`     | Job backoff limit                                                                                                                                  | `5`                                           |
| `bootstrap.job.envSecretRef`     | secret for environment variables                                                                                                                   | `nil`                                         |
| `bootstrap.job.waitForIstio`     | Istio Mesh is active                                                                                                                               | `true`                                        |

### Ingress Configuration

| Name                               | Description                                                                        | Value          |
| ---------------------------------- | ---------------------------------------------------------------------------------- | -------------- |
| `ingress.hostname`                 | the ingress hostname                                                               | `nil`          |
| `ingress.istio.enabled`            | Enable istio ingress, overrides `global.istioEnabled`                              | `true`         |
| `ingress.istio.existingGateway`    | Name of an exiting ingress gateway to use                                          | `nil`          |
| `ingress.istio.ingressSelector`    | Selector of ingress gateway                                                        | `ingress`      |
| `ingress.istio.ingressPrefix`      | Ingress path to expose in the Virtual Service                                      | `/sharepoint/` |
| `ingress.istio.tls.enabled`        | Is TLS enabled on the gateway. Typically this is handled by a vendor load balancer | `nil`          |
| `ingress.istio.tls.existingSecret` | Name of Existing tls secret to be used.                                            | `nil`          |

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
