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
