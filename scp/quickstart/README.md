# Overview
Quickstart to deploy istio + scp from scratch

# Setup
### Set variables
- ns: k8s namespace to be created and used as the install target
- chartBranch: branch name for github.com/virtru-charts 
- GITHUB_USERNAME: ghcr username
- GITHUB_TOKEN: ghcr access token
- INGRESS_HOSTNAME: local deployment hostname
```shell
export chartBranch=main
export ns=scp
export GITHUB_USERNAME=replaceme
export GITHUB_TOKEN=replaceme
export INGRESS_HOSTNAME=scp.virtru.local
```

# Install
Download and execute full install script
```shell
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/full-quick-start-install.sh -o full-quick-start-install.sh .sh && chmod 755 full-quick-start-install.sh 
./full-quick-start-install.sh    
```
- [Above referenced script](./full-quickstart-install.sh) installs:
  - istio, 
  - istio-ingress 
  - the platform
  - self-signed cert for tls ingress
- Example exposed ingress endpoints:
  - https://$INGRESS_HOSTNAME/abacus/
  - https://$INGRESS_HOSTNAME/auth/