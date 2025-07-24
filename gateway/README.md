# Gateway Deployment via Helm

## Overview

This Helm chart will deploy Virtru's email gateway. This chart can support deploying multiple different gateway modes and functions. You can read this documentation on Virtru's support site here:

* [Kubernetes Prerequisites](https://support.virtru.com/hc/en-us/articles/5747171304855-Customer-Hosted-Kubernetes-cluster)
* [Gateway Helm Deployment](https://support.virtru.com/hc/en-us/articles/5746773139479-Customer-Hosted-Install-Kubernetes)

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

## Installation Steps

### Use cases

The first step will be to determine which gateway modes and functions you wish to utilize. The options are as follows:

* Outbound Encrypt (default option)
* Outbound Decrypt
* Outbound DLP (leverage Virtru's content scanning and DLP engine to determine if emails should be encrypted and if any additional security options should be leveraged)
* Inbound Encrypt
* Inbound Decrypt

### Create secrets

There are a number of ways that Kubernetes secrets can be managed. If you do not have an existing external secret manager for your Kubernetes clusters, you can create secrets by using the `appSecrets` section of the `values.yaml` file.

**Please note we strongly advise you consider using an external secrets manager. Creating secrets via the `values.yaml` is a default option to help get your gateway up and running more quickly.**

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

#### `appSecrets`

Set the values based on the information below:

* Required
  * `gateway-amplitude-api-key` - Provided by Virtru
  * `gateway-api-token-name` - Provided by Virtru
  * `gateway-api-token-secret` - Provided by Virtru
* Optional (configuration specific)
  * If using X Header Authentication (default `true`)
    * `gateway-xheader-auth-secret` - The secret value to be added in your headers before sending mail to the gateway (example: `123456789` would mean you have to have a header on every email sent to the gateway of `X-Header-Virtru-Auth:123456789`)
  * If using SASL authentication upstream
    * `gateway-sasl-auth-upstream` - The auth path for your SMTP authentication to the next hop (example: `smtp-relay.gmail.com=>gateway-service-account@example.com=>appSpecificPassword`)
  * If using SASL authentication downstream
    * `gateway-sasl-auth-downstream` - The auth path for your SMTP authentication from the previous hop to the Virtru gateway (example: `smtp-relay.gmail.com=>gateway-service-account@example.com=>appSpecificPassword`)
  * If using DKIM signing
    * `publicKey` - The public key from your DKIM record in your DNS
    * `privateKey` - The private key matching your DKIM record's public key
  * If using OAuth2 authentication (XOAUTH2)
    * `xoauth2.clientSecret` - OAuth2 client secret
    * `xoauth2.refreshToken` - OAuth2 refresh token
    * `xoauth2.accessToken` - Initial OAuth2 access token (will be automatically refreshed)
#### `additionalConfig`

You may, depending on your email needs, wish to update a few values in this section. Below are a few of the primary variables you may wish to adjust:

* `saslAuth.smtpDownstream.enabled` - This will enable SASL auth for your next hop. If you choose to enable this, you will need to create the `gateway-sasl-auth-upstream` file in your secret detailed above
* `decryptThenEncrypt` - If you are using a multi gateway approach (ex: decrypt email => Scan content => re-encrypt email), this should be set to 1 (true)
* `dkimSigning` - If you wish to have the gateway DKIM sign your emails, set enabled to `true`. You must have a public DKIM record for the selector you choose with a public key that matches the keys inputted into `appSecrets.dkimSigning`

### Installing the gateway

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your gateway(s). An example command is listed below:

```sh
helm install -n virtru -f ./values.yaml gateway ./ --create-namespace
```

### Additional Config to go live

Refer to standard documentation for Gateway configuration. You can get your endpoints to set as smart hosts by running the following command:
* If using OAuth2 authentication (XOAUTH2)
    * `xoauth2` - OAuth2 authentication settings for SMTP:
    * `enabled` - Enable XOAUTH2 support (default: `false`)
    * `clientId` - OAuth2 client ID obtained when registering your OAuth application
    * `domains` - Domains configured for OAuth2 (comma-separated)
    * `user` - User on behalf of whom to authenticate

```sh
kubectl -n virtru get services
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
| `dkimSigning.enabled` | N/A, toggles on `GATEWAY_DKIM_DOMAINS` |
| `dkimSigning.selector` | Generates the subdomain for `GATEWAY_DKIM_DOMAINS` (`<dkimSigning.selector>._domainkey.primaryMailingDomain`) |
| `xoauth2.enabled` | `GATEWAY_SMTP_SASL_ENABLED_XOAUTH2` |
| `xoauth2.clientId` | `GATEWAY_XOAUTH2_CLIENT_ID` |
| `xoauth2.domains` | `GATEWAY_XOAUTH2_DOMAINS` |
| `xoauth2.user` | `GATEWAY_XOAUTH2_USER` |
| - | `GATEWAY_SMTP_XOAUTH2_RELAY_HOST` (default smtp.gmail.com) |
| - | `GATEWAY_SMTP_XOAUTH2_RELAY_PORT` (default 587) |

### `inboundRelayAddresses` values for Gmail and Office 365

| Mail Provider | CIDR Blocks |
| ------------- | ----------- |
| Gmail | 35.190.247.0/24,64.233.160.0/19,66.102.0.0/20,66.249.80.0/20,72.14.192.0/18,74.125.0.0/16,108.177.8.0/21,173.194.0.0/16,209.85.128.0/17,216.58.192.0/19,216.239.32.0/19,172.217.0.0/19,172.217.32.0/20,172.217.128.0/19,172.217.160.0/20,172.217.192.0/19,108.177.96.0/19,35.191.0.0/16,130.211.0.0/22 |
| Office 365 | 23.103.132.0/22,23.103.136.0/21,23.103.144.0/20,23.103.198.0/23,23.103.200.0/22,23.103.212.0/22,40.92.0.0/14,40.107.0.0/17,40.107.128.0/18,52.100.0.0/14,65.55.88.0/24,65.55.169.0/24,94.245.120.64/26,104.47.0.0/17,104.212.58.0/23,134.170.132.0/24,134.170.140.0/24,157.55.234.0/24,157.56.110.0/23,157.56.112.0/24,207.46.51.64/26,207.46.100.0/24,207.46.163.0/24,213.199.154.0/24,213.199.180.128/26,216.32.180.0/23 

## Values Descriptions

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalConfig | object | `{"cacheSmtpConnections":{"connectionCacheTimeLimit":"5s","enabled":true},"cks":{"keyProvider":"CKS","sessionKeyExpiry":"360"},"decryptPfpFiles":"1","decryptThenEncrypt":"0","dkimSigning":{"enabled":false,"selector":"gw"},"dlpRuleCache":"30","maxBackoffTime":"45s","maxQueueLifetime":"5m","minBackoffTime":"30s","proxyProtocol":"0","queueRunDelay":"30s","replaceFromEnabled":"1","saslAuth":{"smtpDownstream":{"enabled":false,"securityOptions":"noanonymous"},"smtpdUpstream":{"enabled":false,"mechanisms":"PLAIN"}},"smtpSecurityLevel":"opportunistic","smtpTlsComplianceDownstream":{"compliance":"MEDIUM","enabled":false},"smtpUseTls":true,"smtpdSecurityLevel":"opportunistic","smtpdTlsComplianceUpstream":{"compliance":"MEDIUM","enabled":false},"smtpdUseTls":true,"tlsPolicyMaps":{"enabled":false,"policyMaps":"example.com=>none,example.net=>maybe"},"verboseLogging":"0"}` | See https://support.virtru.com/hc/en-us/articles/6204097329175-Reference-Kubernetes-Variables for reference. |
| affinity | object | `{}` | Optional: Affinity rules for pod scheduling. |
| appSecrets | object | `{"amplitudeToken":"<your-amplitude-token>","dkimSigning":{"privateKey":"<dkim-private-key>  \n","publicKey":"<dkim-public-key>  \n"},"gatewayApiSecret":"<your-api-secret>","gatewayApiTokenName":"<your-api-token>","headers":{"xHeaderAuthSecret":"<your-auth-secret-123456789>"},"saslAuth":{"smtpDownstream":{"accounts":"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"},"smtpdUpstream":{"accounts":"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"}}}` | a third party secret storage option. |
| appSecrets.amplitudeToken | string | `"<your-amplitude-token>"` | Token used for Amplitude analytics. Provided by Virtru. |
| appSecrets.dkimSigning | object | `{"privateKey":"<dkim-private-key>  \n","publicKey":"<dkim-public-key>  \n"}` | See https://support.virtru.com/hc/en-us/articles/24643801445527-Customer-Hosted-Kubernetes-DKIM-Signing. |
| appSecrets.dkimSigning.privateKey | string | `"<dkim-private-key>  \n"` | Private DKIM key used to sign outbound emails. |
| appSecrets.dkimSigning.publicKey | string | `"<dkim-public-key>  \n"` | Set additionalConfig.dkimSigning.enabled to true if configuring GW for DKIM. |
| appSecrets.gatewayApiSecret | string | `"<your-api-secret>"` | Secret value of the API token. Provided by Virtru. |
| appSecrets.gatewayApiTokenName | string | `"<your-api-token>"` | Name of the token used to authenticate API calls. Provided by Virtru. |
| appSecrets.headers.xHeaderAuthSecret | string | `"<your-auth-secret-123456789>"` | Only configure if standardConfig.headers.xHeaderAuthEnabled == true |
| appSecrets.saslAuth.smtpDownstream | object | `{"accounts":"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"}` | Optional: SMTP credentials for downstream authentication. |
| appSecrets.saslAuth.smtpDownstream.accounts | string | `"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"` | Only configure if additionalConfig.saslAuth.smtpDownstream.enabled == true |
| appSecrets.saslAuth.smtpdUpstream | object | `{"accounts":"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"}` | Optional: SMTP credentials for upstream authentication. |
| appSecrets.saslAuth.smtpdUpstream.accounts | string | `"<your-auth-path-smtp-relay.gmail.com=>service-account@example.com=>password>"` | Only configure if additionalConfig.saslAuth.smtpdUpstream.enabled == true |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Enable horizontal pod autoscaling. Defaults to false. |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas if autoscaling is enabled. |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas if autoscaling is enabled.  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Optional target average memory usage. |
| fullnameOverride | string | `""` |  |
| gatewayAccountsUrl | string | `"https://api.virtru.com/accounts"` | URL for Virtru Accounts API. |
| gatewayAcmUrl | string | `"https://api.virtru.com/acm"` | URL for Virtru ACM API. |
| gatewayModes | object | `{"inboundDecrypt":{"enabled":false,"name":"inbound-decrypt","port":9004},"inboundDlp":{"enabled":false,"name":"inbound-dlp","port":9006},"inboundEncrypt":{"enabled":false,"name":"inbound-encrypt","port":9003},"outboundDecrypt":{"enabled":false,"name":"outbound-decrypt","port":9002},"outboundDlp":{"enabled":false,"name":"outbound-dlp","port":9005},"outboundEncrypt":{"enabled":true,"name":"outbound-encrypt","port":9001}}` | Each enabled mode becomes a separate deployment, service, and configmap. |
| gatewayRemoteContentBaseUrl | string | `"https://secure.virtru.com/start"` | URL for remote content used by the gateway. |
| image | object | `{"pullPolicy":"Always","repository":"containers.virtru.com/gateway","tag":""}` | Image repository for the gateway. |
| image.tag | string | `""` | Optional override for image tag; defaults to Chart.yaml's appVersion. |
| ingress | object | `{"enabled":false}` | Enable or disable Kubernetes ingress resource. Defaults to false. |
| istioIngress | object | `{"enabled":false,"existingGateway":null,"gatewaySelectors":{"istio":"ingress"},"ingressHostnames":["*"],"name":"scp"}` | Optional Istio configurations. Defaults to false. |
| istioIngress.existingGateway | string | `nil` | Use an existing istio gateway |
| istioIngress.gatewaySelectors | object | `{"istio":"ingress"}` | Name of istio gateway selector |
| istioIngress.ingressHostnames | list | `["*"]` | Add FQDN, as best practice. |
| nameOverride | string | `""` | Optional: Override the default name of the chart and release. |
| nodeSelector | object | `{}` | Optional: Node selection constraints for scheduling pods. |
| persistentVolumes | object | `{"storageClassName":"standard","volumeSize":"1Gi"}` | the size of the volume below. |
| persistentVolumes.storageClassName | string | `"standard"` | Name of the Kubernetes StorageClass to use. |
| persistentVolumes.volumeSize | string | `"1Gi"` | Size of the persistent volume per mode deployment. Defaults to 1Gi. |
| podAnnotations | object | `{}` | Optional additional annotations for the pod. Defaults to emptyfor flexibility. |
| podSecurityContext | object | `{}` | Security context settings for the pod. Defaults to empty for flexibility. |
| replicaCount | int | `2` | Number of pod replicas to deploy for high availability. |
| resources | object | `{}` | Resource requests and limits for the containers. Defaults to empty for flexibility. |
| securityContext | object | `{}` | Security context settings for individual containers. Defaults to empty for flexibility. |
| service | object | `{"port":25,"type":"LoadBalancer"}` | Service type to be created. Defaults to LoadBalancer. |
| service.port | int | `25` | Defaults to port 25 for SMTP traffic. |
| serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Determines if a Service Account should be created. Defaults to false. |
| serviceAccount.annotations | object | `{}` | Optional: Annotations to add to the service account. |
| serviceAccount.name | string | `""` | Name of the service account to use; defaults to empty. If not set and create is true, a name is generated. |
| standardConfig | object | `{"gatewayHostname":"example.com","gatewayTransportMaps":"*=>[smtp-relay.gmail.com]:587","headers":{"xHeaderAuthEnabled":true},"inboundRelayAddresses":"0.0.0.0/0","primaryMailingDomain":"example.com"}` | Refer to https://support.virtru.com/hc/en-us/articles/6204097329175-Reference-Kubernetes-Variables for details on variables used. |
| standardConfig.gatewayHostname | string | `"example.com"` | Hostname used by the gateway. |
| standardConfig.gatewayTransportMaps | string | `"*=>[smtp-relay.gmail.com]:587"` | Next hop for Virtru gateway, typical mail flow is: mail server => Virtru gateway => back to your mail server => final delivery |
| standardConfig.headers | object | `{"xHeaderAuthEnabled":true}` | Secret managed in appSecrets.headers |
| standardConfig.inboundRelayAddresses | string | `"0.0.0.0/0"` | Default is open and to lock down firewall on the VPC |
| standardConfig.primaryMailingDomain | string | `"example.com"` | Primary mailing domain for the Gateway. |
| tolerations | list | `[]` | Optional: Tolerations for taints on nodes. |


### Note on Using OAuth2 and SASL Simultaneously

If you have both OAuth2 (`xoauth2.enabled: true`) and standard SASL downstream authentication (`saslAuth.smtpDownstream.enabled: true`) enabled, ensure they are configured for different domains or different mail paths. Otherwise, OAuth2 will take precedence.
