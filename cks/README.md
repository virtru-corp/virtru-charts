# CKS Deployment via Helm

## Overview

This Helm chart will deploy Virtru's Customer Key Server (CKS). You can read this documentation on Virtru's support site here:

* [Kubernetes Prerequisites](https://support.virtru.com/hc/en-us/articles/5747166730903-CKS-Kubernetes-cluster)
* [CKS Helm Deployment](https://support.virtru.com/hc/en-us/articles/5746713557015-CKS-Install-Kubernetes-)

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
| `hmac-auth` | `env/cks.env => AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON` |
| `rsa001.pub` | `keys/rsa001.pub` |
| `rsa001.pem` | `keys/rsa001.pem` |

You can have multiple RSA keypairs on your CKS as long as they follow the naming convention rsa###.pub and rsa###.pem for all public/private keypairs.

**Note: Indentation matters for a multiline string, ensure proper indentation for your CKS keys secrets.**

### Installing the CKS

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your CKS. An example command is listed below:

```sh
helm install -n virtru -f ./values.yaml cks ./ --create-namespace
```
