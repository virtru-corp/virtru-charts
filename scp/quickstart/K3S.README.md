# K3S Quick Embedded Quickstart

## MacOSX - Install VM 
[Example](https://dev.to/chillaranand/local-kubernetes-cluster-with-k3s-on-mac-m1-i57)
### Install multipass
```
brew install --cask multipass
```
### Launch VM
```shell
multipass launch --name k3s --mem 8G --disk 40G --cpus 4
```
### Mount a directory for file sharing
```shell
multipass mount ./virtru-charts k3s:~/k8s
```
### Get Shell
```shell
multipass shell k3s
```
### Cleanup (After cluster use)
```shell
multipass delete k3s
multipass purge
```

## Create Cluster
Install and start K3s With traefik disabled.
```shell
curl -sfL https://get.k3s.io | sh -s - --disable=traefik --write-kubeconfig-mode 644
```
## Install helm
```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```
## Install Embedded Self Hosted Platform
[See base Quickstart Base Installation](./README.md)