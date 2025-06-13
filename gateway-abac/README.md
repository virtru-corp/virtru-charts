# gateway-abac

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.5](https://img.shields.io/badge/AppVersion-v2.0.5-informational?style=flat-square)

A Helm chart for the Virtru Data Protection Gateway powered by the Virtru Data Security Platform.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Virtru | <support@virtru.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| abacCreateLegacyTdfs | bool | `true` |  |
| abacEncryptEmail | bool | `true` | Controls whether encryption is enabled in encrypt mode. If this is set to false, the gateway will not encrypt emails. |
| abacEncryptEmailBody | bool | `true` | Controls whether the email body is encrypted in encrypt mode |
| abacExtraCas | list | `[]` | A list of additional Certificate Authorities(CAs) to trust when communicating with the platform in PEM format |
| abacIgnoreKasAllowlist | bool | `false` | Useful for testing, but should not be used in production because authorization tokens can be sent to malicious KAS servers if gateway processes a maliciously crafted TDF. |
| abacKasAllowlist | list | `[]` | A list of KAS URLs that are allowed to be used for decryption. This is used in addition to the kas-registry defined in platform policy. |
| abacOidcClientId | string | `""` | The client-id that gateway should use to communicate with the platform |
| abacPlaintextConnection | bool | `false` | Controls whether communication with the platform is over a plaintext connection |
| abacPlatformEndpoint | string | `""` | The URL where the platform is deployed. Hostname and port |
| abacTaggingPdpAssertionType | string | `"urn:nato:stanag:5636:A:1:elements:json"` | The assertion type to use, currently `urn:us:gov:ic:edh` or `urn:nato:stanag:5636:A:1:elements:json`. |
| abacTaggingPdpEndpoint | string | `""` | The URL where the taggingService is deployed. Hostname and port |
| abacTrimBlockedRecipients | bool | `true` | Controls whether recipients that are not entitled to receive an email are removed. |
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| cacheSmtpConnections | bool | `true` | This setting controls whether the gateway should cache outgoing SMTP connections. true to cache everything,   false to not cache anything, or a comma-separated list of domains to cache connections for |
| cacheSmtpConnectionsTimeLimit | string | `"5s"` | The amount of time to cache outgoing SMTP connections for |
| dkimSelector | string | `""` | The selector for the DKIM key to use for mail |
| fullnameOverride | string | `""` |  |
| gatewayHostname | string | `""` | The hostname that the gateway should use. A self-signed certificate will be generated for this hostname |
| gatewayMode | string | `"encrypt"` | The mode the gateway should run in, either encrypt or decrypt |
| gatewayTopology | string | `"inbound"` | The topology the gateway should run in, either inbound or outbound |
| gatewayTransportMaps | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.opentdf.io/platform/gateway"` |  |
| image.tag | string | `""` |  |
| inboundRelayAddresses | string | `"0.0.0.0/0"` |  |
| ingress.enabled | bool | `false` |  |
| logLevel | string | `"info"` |  |
| maxBackoffTime | string | `"45s"` | The maximum amount of time the gateway will wait before retrying a message (postfix maximal_backoff_time) |
| maxQueueLifetime | string | `"5m"` | The maximum amount of time a message can stay in the queue before being bounced (postfix maximal_queue_lifetime) |
| minBackoffTime | string | `"30s"` | The minimum amount of time the gateway will wait before retrying a message (postfix minimal_backoff_time) |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistentVolumeSize | string | `"1Gi"` | The size of the persistent volume that we use to store the email queue |
| persistentVolumeStorageClassName | string | `"standard"` | The storage class to use for the persistent volume that we use to store the email queue |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| primaryMailingDomain | string | `""` | The domain we use to rewrite the from address for inbound mail. This allows us to deliver email that is   authenticated by DKIM. In order for this to work DKIM must be set up for this domain |
| proxyProtocol | bool | `false` | Controls whether the gateway should use the proxy protocol |
| queueRunDelay | string | `"30s"` | The amount of time the gateway will wait before checking the queue for messages to send (postfix queue_run_delay) |
| replaceFromEnabled | bool | `false` | Controls whether the gateway should replace the from address with the authenticated address |
| replicaCount | int | `2` |  |
| resources | object | `{}` |  |
| saslDownstreamSecurityOptions | string | `"noanonymous"` | The security options the gateway should use when authenticating downstream |
| saslUpstreamMechanisms | string | `"PLAIN"` | The mechanisms the gateway should use when receiving email |
| securityContext | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.port | int | `25` |  |
| service.type | string | `"LoadBalancer"` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `"default"` |  |
| smtpSecurityLevel | string | `"mandatory"` | The security level the gateway should use when sending mail, either `mandatory` or `opportunistic`. To use `mandatory` smtpUseTls must be true. `mandatory` corresponds to a postfix level of `encrypt` while `opportunistic` corresponds to a postfix level of `may`. |
| smtpTlsComplianceDownstream | string | `"MEDIUM"` | The compliance level the gateway should use when sending mail downstream |
| smtpUseTls | bool | `true` | Controls whether the gateway should use TLS when sending mail |
| smtpdSecurityLevel | string | `"mandatory"` | The security level the gateway should use when receiving mail, either `mandatory` or `opportunistic`. To use `mandatory` smtpdUseTls must be true. `mandatory` corresponds to a postfix level of `encrypt` while `opportunistic` corresponds to a postfix level of `may`. `mandatory` also implies that authentication may only take place over TLS (`smtpd_tls_auth_only` = yes) |
| smtpdTlsComplianceUpstream | string | `"MEDIUM"` | The compliance level the gateway should use when receiving mail upstream |
| smtpdUseTls | bool | `true` | Controls whether the gateway should use TLS when receiving mail |
| tlsPolicyMaps | string | `""` | This setting maps domains to TLS policies. e.g. example.com=>may,example.net=>encrypt. Valid policies   can be found here: https://www.postfix.org/TLS_README.html#client_tls_policy |
| tolerations | list | `[]` |  |
| verboseLogging | bool | `false` | Controls whether the gateway should log verbose information |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
