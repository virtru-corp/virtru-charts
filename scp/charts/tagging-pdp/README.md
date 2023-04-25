# tagging-pdp

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Tagging PDP Deployment

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../common-lib | common-lib | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.enabled | bool | `false` |  |
| config.configFile | string | `nil` |  |
| config.configSvc.artifactId | string | `"taggingpdp.test"` |  |
| config.configSvc.url | string | `"http://configuration:8080/configuration"` |  |
| config.logLevel | string | `"INFO"` |  |
| fullnameOverride | string | `""` | The fully qualified appname override |
| gateway.enabled | bool | `true` |  |
| gateway.image.pullPolicy | string | `"IfNotPresent"` |  |
| gateway.image.repo | string | `"ghcr.io/virtru-corp/tagging-pdp/tagging-pdp-grpc-gateway"` |  |
| gateway.image.tag | string | `"0.1.0"` |  |
| gateway.pathPrefix | string | `""` |  |
| gateway.podAnnotations | object | `{}` |  |
| gateway.port | int | `8080` |  |
| gateway.replicaCount | int | `1` |  |
| global.imagePullSecrets | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets[0] | string | `"replace_me"` |  |
| image.repo | string | `"ghcr.io/virtru-corp/tagging-pdp/tagging-pdp-grpc"` |  |
| image.tag | string | `"sha-470efff"` |  |
| nameOverride | string | `""` | Select a specific name for the resource, instead of the default, taggingpdp |
| podAnnotations | object | `{}` | Values for the deployment `spec.template.metadata.annotations` field |
| podSecurityContext | object | `{}` | Values for deployment's `spec.template.spec.securityContext` |
| replicaCount | int | `1` |  |
| securityContext | object | `{}` | Values for deployment's `spec.template.spec.containers.securityContext` |
| service.port | int | `15001` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
