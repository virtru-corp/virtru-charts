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
### Optional Mount a directory(s) for file sharing into the VM
```shell
multipass mount ./mydir k3s:~/k8s
```
### Get Shell
```shell
multipass shell k3s
```
### Set hostnames
1. Get ip address of VM: `multipass info k3s`
- Set an additional hostname on the VM's /etc/hosts = ingress hostname for the deployment
- Set entry on local machine for VM's IP -> ingress hostname

### Example - shp.virtru.local
- Mac Host:  
    ```
    192.168.64.5    shp.virtru.local
    ```
- Multipass VM:
    ```shell
    127.0.0.1 shp.virtru.local
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

Notes:
- If this is a local deployment append the `-t true` flag to the call to the install script to 
generate a self-signed tls certifcate for the deployment
- Add entry to /etc/hosts/ for deployment hostname (shp.virtru.local in the example)
- Trust - Self-Signed Certificate for browsing / local client use over SSL