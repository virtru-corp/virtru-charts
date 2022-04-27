# Gateway Deployment via Helm

## Overview

This Helm chart will deploy Virtru's email gateway. This chart can support deploying multiple different gateway modes and functions.

### Assumptions
* The namespace for the deployment is `virtru-test`
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

## Installation Steps
### Use cases

The first step will be to determine which gateway modes and functions you wish to utilize. The options are as follows:
* Outbound Encrypt (default option)
* Outbound Decrypt
* Outbound DLP (leverage Virtru's content scanning and DLP engine to determine if emails should be encrypted and if any additional security options should be leveraged)
* Inbound Encrypt
* Inbound Decrypt

### Create secrets

There are a number of ways that Kubernetes secrets can be managed. If you do not have an existing external secret manager for your Kubernetes clusters, we recommend creating a secret manually outside of the context of this chart, which will then be referenced in your `values.yaml` file.

#### Creating a secret manually

The instructions will generally follow the [Kubernetes documentation here](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/). The commands in this section are suggestions based on a very standard configuration for the Virtru gateway.

To start, create a directory named `gateway-secrets`, and within that directory, create files with each of the following names:
* Required
  * `gateway-amplitude-api-key` - Provided by Virtru
  * `gateway-api-token-name` - Provided by Virtru
  * `gateway-api-token-secret` - Provided by Virtru
* Optional (configuration specific)
  * If using X Header Authentication (default `true`)
    * `gateway-xheader-auth-secret` - The secret value to be added in your headers before sending mail to the gateway
  * If using SASL authentication upstream
    * `gateway-sasl-auth-upstream` - The auth path for your SMTP authentication to the next hop
  * If using SASL authentication downstream
    * `gateway-sasl-auth-downstream` - The auth path for your SMTP authentication from the previous hop to the Virtru gateway

Edit the values of each of these files to be the plaintext value of your respective secrets.

To create a Kubernetes secret from this directory, run the following command:
```
kubectl create secret -n virtru-test generic gateway-secrets --from-file="./gateway-secrets"
```

### Updating `values.yaml` file

This section will detail potential changes that you will need to make to your `values.yaml` file.

#### `gatewayModes`

For each gateway use case identified above, ensure that the specific mode's `enabled` key is toggled to true. The default ports are non-standard custom ports, but any port can be used as they all translate to port 25 internally on the pod.

#### `standardConfig`

* `gatewayHostname` - FQDN of the gateway
* `primaryMailingDomain` - Your primary email domain
* `gatewayTransportMaps` - Next hop for your gateway, defaults to Google SMTP Relay service
* `inboundRelayAddresses` - Determine IPs you wish to allow traffic into the gateway container from (default is open at the container level and to build firewall rules to only allow specific source IPs into the pod)
  * Default values for Gmail and Office 365 sending IPs included in the **Reference** section at the bottom of this document
* `headers.xHeaderAuthEnabled` - Defaults to true. If enabled, you must also set xHeaderAuthSecret and add the secret value to messages prior to hitting the gateway
*  `secrets.name` - The name of the secret you created in the previous steps (default `gateway-secrets`)

#### `additionalConfig` 

You may, depending on your mail routing needs, wish to update a few values in this section. Below are a few of the primary variables you may wish to adjust:
* `saslAuth.smtpDownstream.enabled` - This will enable SASL auth for your next hop. If you choose to enable this, you will need to create the `gateway-sasl-auth-upstream` file in your secret detailed above
* `decryptThenEncrypt` - If you are using a multi gateway approach (ex: decrypt email => Scan content => re-encrypt email), this should be set to 1 (true)

### Installing the gateway

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your gateway(s). An example command is listed below:
```
helm install -n virtru-test -f ./values.yaml gateway ./
```


### Additional Config to go live

Refer to standard documentation for Gateway configuration. You can get your endpoints to set as smart hosts by running the following command:
```
kubectl -n virtru-test get services
```
And there should be public endpoints you can use when relaying mail to your new gateways.

## Reference

### Variables in `values.yaml`

A full list of Virtru-specific variables in `values.yaml` can be found below:

| `values.yaml` | [Virtru Documentation value](https://support.virtru.com/hc/en-us/articles/115015789888-Customer-Hosted-Environment-Variables) |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `gatewayHostname` | `GATEWAY_HOSTNAME` |
| `primaryMailingDomain` | `GATEWAY_ORGANIZATION_DOMAIN` |
| `gatewayTransportMaps` | `GATEWAY_TRANSPORT_MAPS` |
| `inboundRelayAddresses` | `GATEWAY_RELAY_ADDRESSES` |
| `headers.xHeaderAuthEnabled` | `GATEWAY_XHEADER_AUTH_ENABLED` |
| `saslAuth.smtpDownstream.enabled` | `GATEWAY_SMTP_SASL_ENABLED_DOWNSTREAM` |
| `saslAuth.smtpDownstream.securityOptions` | `GATEWAY_SMTP_SASL_SECURITY_OPTIONS` |
| `saslAuth.smtpdUpwnstream.enabled` | `GATEWAY_SMTPD_SASL_ENABLED_UPSTREAM` |
| `saslAuth.smtpdUpwnstream.mechanisms` | `GATEWAY_SMTPD_SASL_MECHANISMS` |
| `maxQueueLifetime` | `MAX_QUEUE_LIFETIME` |
| `maxBackoffTime` | `MAX_BACKOFF_TIME` |
| `minBackoffTime` | `MIN_BACKOFF_TIME` |
| `queueRunDelay` | `QUEUE_RUN_DELAY` |
| `smtpdUseTls` | `GATEWAY_SMTPD_USE_TLS` |
| `smtpdSecurityLevel` | `GATEWAY_SMTPD_SECURITY_LEVEL` |
| `smtpdTlsComplianceUpstream.enabled` | N/A, toggles on `GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM` |
| `smtpdTlsComplianceUpstream.compliance` | `GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM` |
| `smtpUseTls` | `GATEWAY_SMTP_USE_TLS` |
| `smtpSecurityLevel` | `GATEWAY_SMTP_SECURITY_LEVEL` |
| `smtpTlsComplianceDownstream.enabled` | N/A, toggles on `GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM` |
| `smtpTlsComplianceDownstream.compliance` | `GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM` |
| `cks.keyProvider` | `GATEWAY_ENCRYPTION_KEY_PROVIDER` |
| `cks.sessionKeyExpiry` | `GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS` |
| `dlpRuleCache` | `GATEWAY_DLP_CACHE_DURATION` |
| `tlsPolicyMaps.enabled` | N/A, toggles on `GATEWAY_SMTP_TLS_POLICY_MAPS` |
| `tlsPolicyMaps.policyMaps` | `GATEWAY_SMTP_TLS_POLICY_MAPS` |
| `replaceFromEnabled` | `GATEWAY_REPLACEMENT_FROM_ENABLED` |
| `decryptPfpFiles` | `GATEWAY_DECRYPT_PERSISTENT_PROTECTED_ATTACHMENTS` |
| `decryptThenEncrypt` | `GATEWAY_DECRYPT_THEN_ENCRYPT` |
| `proxyProtocol` | `GATEWAY_PROXY_PROTOCOL` |
| `verboseLogging` | `GATEWAY_VERBOSE_LOGGING` |
| `cacheSmtpConnections.enabled` | `GATEWAY_SMTP_CACHE_CONNECTIONS` |
| `cacheSmtpConnections.connectionCacheTimeLimit` | `GATEWAY_SMTP_CONNECTION_CACHE_TIME_LIMIT` |

### `inboundRelayAddresses` values for Gmail and Office 365

| Mail Provider | CIDR Blocks |
| ------------- | ----------- |
| Gmail | 35.190.247.0/24,64.233.160.0/19,66.102.0.0/20,66.249.80.0/20,72.14.192.0/18,74.125.0.0/16,108.177.8.0/21,173.194.0.0/16,209.85.128.0/17,216.58.192.0/19,216.239.32.0/19,172.217.0.0/19,172.217.32.0/20,172.217.128.0/19,172.217.160.0/20,172.217.192.0/19,108.177.96.0/19,35.191.0.0/16,130.211.0.0/22 |
| Office 365 | 23.103.132.0/22,23.103.136.0/21,23.103.144.0/20,23.103.198.0/23,23.103.200.0/22,23.103.212.0/22,40.92.0.0/14,40.107.0.0/17,40.107.128.0/18,52.100.0.0/14,65.55.88.0/24,65.55.169.0/24,94.245.120.64/26,104.47.0.0/17,104.212.58.0/23,134.170.132.0/24,134.170.140.0/24,157.55.234.0/24,157.56.110.0/23,157.56.112.0/24,207.46.51.64/26,207.46.100.0/24,207.46.163.0/24,213.199.154.0/24,213.199.180.128/26,216.32.180.0/23 |