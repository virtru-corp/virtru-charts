# CKS Deployment via Helm

## Overview

This Helm chart will deploy Virtru's Customer Key Server (CKS).

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

There are a number of ways that Kubernetes secrets can be managed. If you do not have an existing external secret manager for your Kubernetes clusters, we recommend creating a secret manually outside of the context of this chart, which will then be referenced in your `values.yaml` file.

#### Creating a secret manually

The instructions will generally follow the [Kubernetes documentation here](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/). The commands in this section are suggestions based on a very standard configuration for the Virtru CKS.

To start, create a directory named `cks-secrets`, and within that directory, create two directories inside of `cks-secrets` with the following names:
* `hmac-auth`
* `cks-keys`

Inside of `hmac-auth`, create a file called `AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON`, and inside of `cks-keys`, create two files for your RSA public/private keypairs called `rsa001.pub` and `rsa001.pem`.

To quickly create this directory structure and the right files, run the following code block:
```
  # Make the secrets directory and navigate to it
  mkdir cks-secrets
  cd cks-secrets
  # Create the subdirectories
  mkdir hmac-auth
  mkdir cks-keys
  # Create the files inside each subdirectory
  touch hmac-auth/AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON
  touch cks-keys/rsa001.pub
  touch cks-keys/rsa001.pem
  # Navigate back to your working directory for your helm chart
  cd ..
  ```

Edit the values of each of these files to be the plaintext value of your respective secrets:

| Filename | Value |
| -------- | ----- |
| `hmac-auth/AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON` | `env/cks.env => AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON` |
| `cks-keys/rsa001.pub` | `keys/rsa001.pub` |
| `cks-keys/rsa001.pem` | `keys/rsa001.pem` |

To create your Kubernetes secrets from these directories, run the following commands:
```
kubectl create secret -n virtru generic cks-keys --from-file="./cks-secrets/cks-keys"
kubectl create secret -n virtru generic hmac-auth --from-file="./cks-secrets/hmac-auth"
```
### Updating `values.yaml` file

This section will detail potential changes that you will need to make to your `values.yaml` file.

#### `ingress`

To serve traffic appropriately, you must have an ingress controller for your CKS service. This is enabled by default, but you will need to update the host under `ingress.hosts.host` to match the FQDN of your CKS.

You may also need to add annotations for your ingress to use your CA signed certificate. 

#### `appSecrets`

The values for `appSecrets.virtruAuth.name` and `appSecrets.virtruKeys.name` should match the secret names you created for your HMAC auth and RSA keypairs.

### Installing the CKS

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your CKS. An example command is listed below:
```
helm install -n virtru -f ./values.yaml cks ./
```