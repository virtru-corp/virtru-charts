# Setup
## Add chart repo and download charts
### Set chartBranch variable
```shell
export chartBranch=main
```
### Add virtru-charts helm repo
```
helm repo add virtru-charts \
   https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/
helm repo update
helm search repo 
```
## Create sample entitlement policy
Copy standalone entitlement policy example from OpenTDF:
```shell
mkdir entitlement-policy
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/Makefile -o entitlement-policy/Makefile
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/data.json -o entitlement-policy/data.json
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_default.rego -o entitlement-policy/entitlements_default.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_default_test.rego -o entitlement-policy/entitlements_default_test.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_service_fetch.rego -o entitlement-policy/entitlements_service_fetch.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_service_test.rego -o entitlement-policy/entitlements_service_test.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/input.json -o entitlement-policy/input.json
```
## Download embedded install script
```shell
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/embedded-install.sh -o embedded-install.sh && chmod 755 embedded-install.sh
```

## Optional - use sample values files
```shell
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/sample-install-config.yaml -o sample-install-config.yaml
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/sample-values.yaml -o sample-values.yaml
```

# Install
## Install istio
```shell
./quickstart-istio.sh    
```
## Install Self Hosted platform
```shell
export ns=scp
export GITHUB_USERNAME=replaceme
export GITHUB_TOKEN=replaceme
export INGRESS_HOSTNAME=scp.virtru.local
`
kubectl create namespace $ns
kubectl label namespace $ns istio-injection=enabled
./embedded-install.sh -u $GITHUB_USER -p $GITHUB_TOKEN -h $INGRESS_HOSTNAME -e ./entitlement-policy -c ./sample-install-config.yaml -o ./sample-values.yaml
```
Enabled local TLS via self-signed cert:
```
./embedded-install.sh -u $GITHUB_USER -p $GITHUB_TOKEN -h $INGRESS_HOSTNAME -e ./entitlement-policy -c ./sample-install-config.yaml -o ./sample-values.yaml -t true
```