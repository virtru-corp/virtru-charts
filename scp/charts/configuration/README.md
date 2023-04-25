# OpenTDF Configuration Chart

A Helm chart fo OpenTDF Configuration, a service for providing configuration to applications and other services.

This chart requires [Istio](https://istio.io) Service Mesh to be installed.

This chart has a Redis HA dependency from here: https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha

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
| externalRedis.existingSecret | string | `""` | The name of an existing secret with Redis credentials (must contain key `redis-password`). When it's set, the `externalRedis.password` parameter is ignored |
| externalRedis.host | string | `""` | External Redis server host |
| externalRedis.password | string | `""` | External Redis password |
| externalRedis.port | int | `6379` | External Redis server port |
| externalRedis.secretAnnotations | object | `{}` | External Redis Secret annotations |
| externalRedis.username | string | `""` | External Redis username |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| redis-ha.enabled | bool | `false` | Enables the Redis HA subchart and disables the custom Redis single node deployment |
| redis-ha.exporter.enabled | bool | `false` | Enable Prometheus redis-exporter sidecar |
| redis-ha.exporter.image | string | `"public.ecr.aws/bitnami/redis-exporter"` | Repository to use for the redis-exporter |
| redis-ha.exporter.tag | string | `"1.45.0"` | Tag to use for the redis-exporter |
| redis-ha.haproxy.enabled | bool | `false` | Enabled HAProxy LoadBalancing/Proxy |
| redis-ha.haproxy.metrics.enabled | bool | `false` | HAProxy enable prometheus metric scraping |
| redis-ha.hardAntiAffinity | bool | `false` |  |
| redis-ha.image.tag | string | `"7.0.9-alpine"` | Redis tag |
| redis-ha.networkPolicy.enabled | bool | `true` |  |
| redis-ha.persistentVolume.enabled | bool | `false` | Configures persistence on Redis nodes |
| redis-ha.redis.config | object | See [values.yaml] | Any valid redis config options in this section will be applied to each server (see `redis-ha` chart) |
| redis-ha.redis.config.save | string | `'""'` | Will save the DB if both the given number of seconds and the given number of write operations against the DB occurred. `""`  is disabled |
| redis-ha.redis.masterGroupName | string | `"scp-configuration"` | Redis convention for naming the cluster group: must match `^[\\w-\\.]+$` and can be templated |
| redis-ha.topologySpreadConstraints.enabled | bool | `false` | Enable Redis HA topology spread constraints |
| redis-ha.topologySpreadConstraints.maxSkew | string | `""` (defaults to `1`) | Max skew of pods tolerated |
| redis-ha.topologySpreadConstraints.topologyKey | string | `""` (defaults to `topology.kubernetes.io/zone`) | Topology key for spread |
| redis-ha.topologySpreadConstraints.whenUnsatisfiable | string | `""` (defaults to `ScheduleAnyway`) | Enforcement policy, hard or soft |
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
| server.redis.host | string | `""` |  |
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

