# CKS Deployment via Helm

## Overview

This Helm chart will deploy Virtru's Customer Key Server (CKS). You can read this documentation on Virtru's support site here:

* [Kubernetes Prerequisites](https://support.virtru.com/hc/en-us/articles/5747166730903-CKS-Kubernetes-cluster)
* [CKS Helm Deployment](https://support.virtru.com/hc/en-us/articles/5746713557015-CKS-Install-Kubernetes-)

### v1.2.0 Upgrade Notes

**Relevant to users leveraging `.Values.externalAppSecrets`**

Upgrading from `< v1.2.0` to `>= v1.2.0` chart version while using the `.Values.externalAppSecrets` requires your in-cluster external-secrets operator to be on v0.16.0+. In chart version v1.2.0+, upgrades to the `ExternalSecrets` object to use `external-secrets.io/v1` apiVersion have been made. Previously the external secret created used `external-secrets.io/v1beta1`.

This upgrade in line with external-secrets operator no longer serving v1beta1 APIs in v0.17.0+. v1 APIs were promoted in v0.16.0, and will be the default in Virtru provided charts moving forward.

### Assumptions

* The namespace for the deployment is `virtru`
* The secrets directory is created in the same working directory for the helm chart

## Prerequisites

These are the requirements before getting started with this chart:

* Virtru provisioned organization with licenses for your email users.
* Kubernetes cluster provisioned in the environment of your choosing. Links to common cloud provider documentation below.
  * [AWS cluster creation](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
  * [GCP cluster creation](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster)
  * [Azure cluster creation](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal)
* [Helm is installed](https://helm.sh/docs/intro/install/) on your terminal.
* Your terminal is connected to your Kubernetes cluster and ready to use `kubectl`
* You have a CA signed certificate provisioned for your CKS FQDN
* You have generated an RSA keypair and CKS Auth token on your local machine

## Installation Steps

### Create secrets

There are a number of ways that Kubernetes secrets can be managed. If you do not have an existing external secret manager for your Kubernetes clusters, you can create secrets by using the `appSecrets` section of the `values.yaml` file.

**Please note we strongly advise you consider using an external secrets manager. Creating secrets via the `values.yaml` is a default option to help get your CKS up and running more quickly.**

### Updating `values.yaml` file

This section will detail potential changes that you will need to make to your `values.yaml` file.

#### `ingress`

To serve traffic appropriately, you must have an ingress controller for your CKS service. This is enabled by default, but you will need to update the host under `ingress.hosts.host` to match the FQDN of your CKS.

Depending on your environment, you will need to add annotations to:

* Apply your CA signed certificate
* Designate load balancer configurations
* Expose your load balancer to the internet

#### `appSecrets`

Update your secrets to match the values from your local CKS config as mapped below.

| Filename | Value from CKS setup script |
| -------- | --------------------------- |
| `hmac-auth`  | `env/cks.env => AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON` |
| `rsa001.pub` | `keys/rsa001.pub` |
| `rsa001.pem` | `keys/rsa001.pem` |

You can have multiple RSA keypairs on your CKS as long as they follow the naming convention rsa###.pub and rsa###.pem for all public/private keypairs.

**Note: Indentation matters for a multiline string, ensure proper indentation for your CKS keys secrets.**

### Installing the CKS

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your CKS. An example command is listed below:

```sh
helm install -n virtru -f ./values.yaml cks ./ --create-namespace
```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Optional: Controls scheduling rules to optimize workload distribution. |
| appConfig | object | `{"authTokenStoreageMemoryEncoding":"base64","authTokenStoreageType":"in-memory","hmacAuthEnabled":true,"jwtAuthEnabled":true,"jwtAuthIssuer":"https://api.virtru.com","jwtAuthJwksPath":"/acm/api/jwks","keyProviderType":"file","logRsyslogEnabled":false,"logStdoutEnabled":true,"noKeysRule":"importPEM","privateKeyPath":"/run/secrets/rsa001.pem","publicKeyPath":"/run/secrets/rsa001.pub","virtruOrgId":"<your org id>"}` | Application Configuration |
| appConfig.virtruOrgId | string | `"<your org id>"` | The orgId will be provided to you by your Virtru representative. |
| appSecrets | object | `{"virtruAuth":{"data":{"authTokenJson":"<base64-encoded-JSON-from-your-CKS>"},"name":"hmac-auth"},"virtruKeys":{"data":{"rsa001.pem":"<rsa001 private key>\n","rsa001.pub":"<rsa001 public key>\n"},"mountPath":"/app/keys","name":"cks-keys"}}` | Secrets Management  |
| appSecrets.virtruAuth.data.authTokenJson | string | `"<base64-encoded-JSON-from-your-CKS>"` | This base64-encoded value for authTokenJson can be generated by running these steps here: https://support.virtru.com/hc/en-us/articles/17797745877655-Virtru-Private-Keystore-for-Virtru-Solutions-Install-First-Instance-Linux-Server |
| appSecrets.virtruKeys.data."rsa001.pub" | string | `"<rsa001 public key>\n"` | The values for rsa001.pub and rsa001.pem can be generated by running these steps here: https://support.virtru.com/hc/en-us/articles/17797745877655-Virtru-Private-Keystore-for-Virtru-Solutions-Install-First-Instance-Linux-Server |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling is disabled by default. |
| autoscaling.maxReplicas | int | `100` | Maximum number of pods |
| autoscaling.minReplicas | int | `1` | Minimum number of pods |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling. Default is 80% |
| deployment | object | `{"port":9000}` | Internal application port used for the deployment. |
| deployment.port | int | `9000` | The CKS will use the default internal port 9000. |
| fullnameOverride | string | `""` | Optional override for the full resource name. |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"containers.virtru.com/cks","tag":""}` | For version, see https://support.virtru.com/hc/en-us/articles/360034039233-Release-Notes-Virtru-Private-Keystore-for-Virtru-Solutions-Formerly-Virtru-Customer-Key-Server-CKS. |
| ingress | object | `{"annotations":null,"enabled":true,"hosts":[{"host":"fqdn.yourdomain.com","paths":[{"backend":{"serviceName":"cks","servicePort":443},"path":"/*","pathType":"ImplementationSpecific"}]}],"tls":[]}` | This is enabled by default. |
| ingress.hosts[0] | object | `{"host":"fqdn.yourdomain.com","paths":[{"backend":{"serviceName":"cks","servicePort":443},"path":"/*","pathType":"ImplementationSpecific"}]}` | Change fqdn.yourdomain.com to match the FQDN of your CKS. |
| nameOverride | string | `""` | Optional name override for the CKS release. |
| nodeSelector | object | `{}` | Optional: Specifies node labels for pod placement. |
| podAnnotations | object | `{}` | Optional annotations for pods, useful for monitoring or automation. |
| podSecurityContext | object | `{}` | Defines security settings at the pod level (e.g., group permissions). Defaults to empty, can be customized to better fit your organization's needs. |
| replicaCount | int | `3` | Number of instances (pods) to run for the application. Default is 3 but can be customized to fit your org's needs. |
| resources | object | `{}` | Allows defining CPU/memory limits and requests for the application. Defaults to empty for flexibility. |
| revisionHistoryLimit | int | `10` | Number of old deployments retained for rollback purposes. Default is 10. |
| securityContext | object | `{}` | Defines security settings at the container level, such as running as a non-root user. Defaults to empty for flexibility. |
| service | object | `{"annotations":{},"port":443,"protocol":"TCP","type":"ClusterIP"}` | Service Configuration |
| service.type | string | `"ClusterIP"` | Service type is ClusterIP by default. |
| serviceAccount.annotations | object | `{}` | Metadata annotations to add to the service account. Defaults to empty. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. A service account is created by default. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is set to true, a name is generated using the fullname template. |
| testerPod | object | `{"annotations":{"helm.sh/hook":"test"},"enabled":true}` | Test pod is created by default. |
| tolerations | list | `[]` | Optional: Defines tolerations to allow pods to be scheduled on tainted nodes. |