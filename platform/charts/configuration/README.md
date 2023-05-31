# OpenTDF Configuration Chart

A Helm chart fo OpenTDF Configuration, a service for providing configuration to applications and other services.

This chart requires [Istio](https://istio.io) Service Mesh to be installed.

## Database

Use an external PostgreSQL database

```sql
CREATE DATABASE tdf_database;
-- use above database
CREATE SCHEMA IF NOT EXISTS scp_configuration;

CREATE TABLE IF NOT EXISTS scp_configuration.configuration
(
    id        VARCHAR PRIMARY KEY,
    bytes     BYTEA NOT NULL,
    modified  VARCHAR NOT NULL
);
-- user
CREATE ROLE scp_configuration_manager WITH LOGIN PASSWORD 'myPostgresPassword';
GRANT USAGE ON SCHEMA scp_configuration TO scp_configuration_manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA scp_configuration TO scp_configuration_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA scp_configuration TO scp_configuration_manager;
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| server.affinity | object | `{}` | Pod scheduling preferences |
| server.autoscaling.enabled | bool | `false` |  |
| server.image.pullPolicy | string | `"IfNotPresent"` | The container's `imagePullPolicy` |
| server.image.repository | string | `"ghcr.io/virtru-corp/enterprise-tdf/scp-configuration"` | The image selector, also called the 'image name' in k8s documentation and 'image repository' in docker's guides. |
| server.image.tag | string | `nil` | `Chart.AppVersion` will be used for image tag, override here if needed |
| server.imagePullSecrets | string | `nil` | JSON passed to the deployment's `template.spec.imagePullSecrets`. Overrides `global.opentdf.common.imagePullSecrets` |
| server.name | string | `"server"` |  |
| server.nodeSelector | object | `{}` | Node labels for pod assignment |
| server.podAnnotations | object | `{}` | Values for the deployment `spec.template.metadata.annotations` field |
| server.podSecurityContext | object | `{}` | Values for deployment's `spec.template.spec.securityContext` |
| server.postgres.database | string | `"tdf_database"` |  |
| server.postgres.host | string | `""` |  |
| server.postgres.port | int | `5432` |  |
| server.postgres.user | string | `"scp_configuration_manager"` |  |
| server.replicaCount | int | `1` |  |
| server.resources | object | `{}` | Specify required limits for deploying this service to a pod. We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. |
| server.secretRef | string | `nil` |  |
| server.securityContext | object | `{"runAsNonRoot":true,"runAsUser":1000}` | Values for deployment's `spec.template.spec.containers.securityContext` |
| server.service.port | int | `8080` | Port to assign to the `http` port |
| server.service.type | string | `"ClusterIP"` | Service `spec.type` |
| server.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| server.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| server.serviceAccount.name | string | `nil` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| server.tolerations | list | `[]` | Tolerations for nodes that have taints on them |

