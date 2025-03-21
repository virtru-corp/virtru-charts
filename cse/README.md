
# CSE Deployment via Helm

## Overview

This Helm chart will deploy Virtru's key management server for Google Client Side Encryption. You can read this documentation on Virtru's support site here:

* [Kubernetes Prerequisites](https://support.virtru.com/hc/en-us/articles/5747194158999-Client-Side-Encryption-Kubernetes-cluster)
* [CSE Helm Deployment](https://support.virtru.com/hc/en-us/articles/5746813541911-Client-Side-Encryption-install-Kubernetes)

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

### Configure IDP

To use Google's CSE service, you must have a 3rd party identity provider configured to authenticate users to the CSE service. Documentation on Google's requirements can be found [here](https://support.google.com/a/answer/10743588?hl=en).

### Provision SSL Certificate

Virtru's KMS for Google CSE runs on a secure connection from Google to the service. The certificates, for this service, will be mounted into the running container. When filling out the `values.yaml` file in the section below, you will need the private key and certificate chain available to you.

### Updating `values.yaml` file

This section will detail potential changes that you will need to make to your `values.yaml` file.

#### `appConfig`

* `jwksAuthnIssuers` - A base-64 encoded map of accepted Authentication issuer ids (from the authentication JWT) to the URL where the issuer publishes its JSON Web Keyset. This is dictated via the IDP. In the example provided it is Google OAuth
  * Example command to base-64 encode:
  
    * ```sh
        echo '{ "https://accounts.google.com": "https://www.googleapis.com/oauth2/v3/certs" }' | base64
        ```

* `jwksAuthzIssuers` - A base-64 encoded map of accepted Authorization issuer ids (from the authorization JWT) to the URL where the issuer publishes its JSON Web Keyset. This is dictated by Google and is filled out by default
* `jwtAud` - A base-64 encoded JSON map of JWT audiences for authorization and authentication. The `authz` audience, which is sent by Google, will always be  `cse-authorization`, but the `authn` audience will be configured through the customer’s IDP. In the example provided the `authn` audience is Google OAuth
  * Example command to base-64 encode:

    * ```sh
        echo '{ "authn": "00000000000000000.apps.googleusercontent.com", "authz":"cse-authorization" }' | base64
        ```

* `jwtKaclsUrl` - URL for your CSE service. This should match the SSL certificate provisioned in the previous steps
* `useCks` - Default false. Switch to true if using a Virtru CKS in tandem with your CSE KMS
* `cksUrl` - Leave as default if not using CKS. If using CKS, this is the FQDN of your running CKS service (example: `https://cks.example.com`)
* `driveLabels` - Leave as default if not utilizing the Drive Labels integration. See `https://support.virtru.com/hc/en-us/articles/20411711509527-Reference-Virtru-Private-Keystore-for-Google-Workspace-CSE-Configuring-Drive-Labels-with-CSE` for more details




#### `appSecrets`

In the `appSecrets` section, the `hmac`, `secretKey`, and `cksHmac` (if using CKS) sections must be the plaintext values for your secrets, while in `ssl` you must base-64 encode the private key and certificate.

* `hmac.tokenId` - Provided by Virtru
* `hmac.tokenSecret` - Provided by Virtru
* `secretKey` - A named, base-64 encoded key for CSE encryption. Required if not using CKS. Format is `mykeyname:base64encodedkey`. See example below:
  * If your key's decoded value is `testkey`, your `secretKey` value should be `mysupersecretkey:dGVzdGtleQo=`, where `dGVzdGtleQo=` is `testkey` base-64 encoded.
  * Example command to get a randomly generated key into a local TXT file:

    * ```sh
        echo "my-key-name:$(openssl rand 32 | base64)" 2>&1 | tee cseSecret.txt
        ```

* `ssl.privateKey` - Your certificate's private key, base-64 encoded
* `ssl.certificate` - Your certificate's cert chain, base-64 encoded
* `cksHmac.tokenId` - The `tokenId` from your CKS configuration (only used if `useCks` is set to true)
* `cksHmac.tokenSecret` - The `encryptedToken secret` from your CKS configuration (only used if `useCks` is set to true)
* `googleApplicationCredentials` - Leave as default values. See `https://support.virtru.com/hc/en-us/articles/20411711509527-Reference-Virtru-Private-Keystore-for-Google-Workspace-CSE-Configuring-Drive-Labels-with-CSE` for more details.

#### `volumes`

Uncomment the default values that are prepopulated if utilizing the Drive Labels integration (See https://support.virtru.com/hc/en-us/articles/20411711509527-Reference-Virtru-Private-Keystore-for-Google-Workspace-CSE-Configuring-Drive-Labels-with-CSE)

### Installing the CSE

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your CSE. An example command is listed below:

```sh
helm install -n virtru -f ./values.yaml cse ./ --create-namespace
```

### Additional Config to go live

Refer to standard documentation for CSE configuration in Google Admin. You can get your endpoint for your DNS record by running the following command:

```sh
kubectl -n virtru get services
```

And there should be public endpoints you can use when relaying traffic from Google to your new CSE.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Node affinity rules for pod scheduling. |
| appConfig | object | `{"accountsUrl":"https://api.virtru.com/accounts/api","acmUrl":"https://api.virtru.com/acm/api","cksUrl":"https://cks.yourdomain.com","driveLabels":{"adminTime":"15","driveLabelsTime":"15","driveTime":"15","enabled":"false","serviceAccountEmail":"<your-drive-admin-email-address>"},"jwksAuthnIssuers":"base64 encoded authn issuers object","jwksAuthzIssuers":"eyAiZ3N1aXRlY3NlLXRva2VuaXNzdWVyLWRyaXZlQHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1kcml2ZUBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsImdzdWl0ZWNzZS10b2tlbmlzc3Vlci1tZWV0QHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1tZWV0QHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIiwiZ3N1aXRlY3NlLXRva2VuaXNzdWVyLWNhbGVuZGFyQHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1jYWxlbmRhckBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsImdzdWl0ZWNzZS10b2tlbmlzc3Vlci1nbWFpbEBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9zZXJ2aWNlX2FjY291bnRzL3YxL2p3ay9nc3VpdGVjc2UtdG9rZW5pc3N1ZXItZ21haWxAc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20iIH0K","jwtAud":"base64 encoded jwt audience object","jwtKaclsUrl":"https://fqdn.yourdomain.com","processNumberOverride":"5","useCks":"false","useSsl":"true"}` | Application Configuration |
| appConfig.cksUrl | string | `"https://cks.yourdomain.com"` | Optional: URL for the CKS if integrating with the Virtru CKS. |
| appConfig.driveLabels.enabled | string | `"false"` | Enable or disable Drive Labels integration. Defaults to false. See https://support.virtru.com/hc/en-us/articles/27150297991319-Reference-Drive-Label-Variables for more info. |
| appConfig.jwksAuthnIssuers | string | `"base64 encoded authn issuers object"` | Refer to https://support.virtru.com/hc/en-us/articles/4409220098199-Reference-Virtru-Private-Keystore-for-Google-Workspace-CSE-ENV-Variables for more information. |
| appConfig.jwksAuthzIssuers | string | `"eyAiZ3N1aXRlY3NlLXRva2VuaXNzdWVyLWRyaXZlQHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1kcml2ZUBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsImdzdWl0ZWNzZS10b2tlbmlzc3Vlci1tZWV0QHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1tZWV0QHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIiwiZ3N1aXRlY3NlLXRva2VuaXNzdWVyLWNhbGVuZGFyQHN5c3RlbS5nc2VydmljZWFjY291bnQuY29tIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3NlcnZpY2VfYWNjb3VudHMvdjEvandrL2dzdWl0ZWNzZS10b2tlbmlzc3Vlci1jYWxlbmRhckBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIsImdzdWl0ZWNzZS10b2tlbmlzc3Vlci1nbWFpbEBzeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbSI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9zZXJ2aWNlX2FjY291bnRzL3YxL2p3ay9nc3VpdGVjc2UtdG9rZW5pc3N1ZXItZ21haWxAc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20iIH0K"` | The default Google JWKS AUTHZ variables are provided below. |
| appConfig.jwtKaclsUrl | string | `"https://fqdn.yourdomain.com"` | The URL for KACLS JWT validation should be the FQDN for your CSE service. |
| appConfig.useCks | string | `"false"` | Enable or disable connection to the Virtru CKS. Defaults to false. |
| appSecrets | object | `{"cksHmac":{"tokenId":"from-your-cks","tokenSecret":"from-your-cks"},"googleApplicationCredentials":"/app/cse/credentials.json","hmac":{"tokenId":"provided-by-virtru","tokenSecret":"provided-by-virtru"},"secretKey":"secretkey:<base64-encoded-secret-key>","ssl":{"certificate":"<base64 private ssl cert>","privateKey":"<base64 private rsa key>"}}` | Application Secrets Configuration |
| appSecrets.cksHmac | object | `{"tokenId":"from-your-cks","tokenSecret":"from-your-cks"}` | Optional: Provide CKS tokenId and tokenSecret if integrating with the CKS.   |
| appSecrets.googleApplicationCredentials | string | `"/app/cse/credentials.json"` | Optional: For Google Drive Labels integration. Leave as-is if not using Drive Labels feature. |
| appSecrets.hmac | object | `{"tokenId":"provided-by-virtru","tokenSecret":"provided-by-virtru"}` | HMAC token for authentication will be provided to you by Virtru. |
| appSecrets.secretKey | string | `"secretkey:<base64-encoded-secret-key>"` | appSecrets.secretKey is required only if NOT using Virtru CKS. Must be in base64 format. Comment this out if using CKS. |
| appSecrets.ssl | object | `{"certificate":"<base64 private ssl cert>","privateKey":"<base64 private rsa key>"}` | SSL private key and certificate in base64 format. |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Horizontal pod scaling. Defaults to false. We recommend the customer adheres to their organization's policies for autoscaling. |
| autoscaling.maxReplicas | int | `100` | Maximum number of pod replicas. |
| autoscaling.minReplicas | int | `1` | Minimum number of pod replicas. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU utilization threshold for scaling. |
| deployment | object | `{"port":9000}` | Port exposed by the deployment. Defaults to 9000. |
| fullnameOverride | string | `""` |  |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"containers.virtru.com/cse","tag":""}` | Container image repository. Defaults to the Chart.yaml's appVersion. |
| ingress | object | `{"annotations":{},"enabled":false,"hosts":[{"host":"fqdn.yourdomain.com","paths":[{"backend":{"serviceName":"cse","servicePort":9000},"path":"/*","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress service is disabled by default. A load balancer service is created in its place. |
| ingress.annotations | object | `{}` | Custom annotations for the ingress resource. |
| ingress.hosts[0] | object | `{"host":"fqdn.yourdomain.com","paths":[{"backend":{"serviceName":"cse","servicePort":9000},"path":"/*","pathType":"ImplementationSpecific"}]}` | fqdn.yourdomain.com must match the FQDN of your CSE service. |
| ingress.tls | list | `[]` | Alternatively, appSecrets.ssl.privateKey and appSecrets.ssl.certificate can be used for TLS certificate configuration. |
| nameOverride | string | `""` | Optional name override for resources. |
| nodeSelector | object | `{}` | Specifies node labels for pod scheduling. |
| podAnnotations | object | `{}` | Custom annotations for pods. Defaults to empty. |
| podSecurityContext | object | `{}` | Security settings for the entire pod. |
| probes | object | `{"liveness":{"failureThreshold":2,"initialDelaySeconds":40,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10},"readiness":{"failureThreshold":2,"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}}` | Readiness probe settings to check if the pod is ready to receive traffic. |
| probes.liveness | object | `{"failureThreshold":2,"initialDelaySeconds":40,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":10}` | Liveness probe settings to restart the pod if it becomes unresponsive.   |
| replicaCount | int | `1` | Number of pod replicas to deploy. Default is 1. |
| resources | object | `{}` | CPU and memory resource limits and requests for the pod. Defaults to empty for flexibility. |
| securityContext | object | `{}` | Security settings for containers. We encourage you to follow your organization's security policies for compliance and security. |
| service | object | `{"annotations":{},"port":443,"protocol":"TCP","type":"LoadBalancer"}` | Determines the type of Kubernetes service. A load balancer is created by default. |
| service.type | string | `"LoadBalancer"` | Annotations for the Kubernetes service. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | A Kubernetes service account is created by default. A name is auto-generated if left blank. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. Defaults to empty. |
| testerPod | object | `{"annotations":{"helm.sh/hook":"test"},"enabled":false}` | Optional: Specifies if a test pod should be deployed. Defaults to false. |
| testerPod.annotations."helm.sh/hook" | string | `"test"` | Marks this pod as a Helm test hook. |
| tolerations | list | `[]` | List of tolerations to allow scheduling on tainted nodes. |
| volumes | list | `[]` | Uncomment lines below volumes and remove brackets if using the Drive Labels integration. |