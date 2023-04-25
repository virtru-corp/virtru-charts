# opcr-policy

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Build and push an opa policy to an OCI registry

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../common-lib | common-lib | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backoffLimit | int | `5` |  |
| global.imagePullSecrets | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repo | string | `"ghcr.io/virtru-corp/postman-cli/opcr-policy"` |  |
| image.tag | string | `"sha-a2ff4f6"` |  |
| imagePullSecrets | string | `nil` |  |
| istioTerminationHack | bool | `false` |  |
| policyConfigMap | string | `nil` |  |
| secretRef | string | `nil` |  |
