echo "Add virtru-charts helm repo"
helm repo add virtru-charts \
   https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/
helm repo update
helm search repo

echo "Download sample entitlement policy"
mkdir entitlement-policy
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/Makefile -o entitlement-policy/Makefile
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/data.json -o entitlement-policy/data.json
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_default.rego -o entitlement-policy/entitlements_default.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_default_test.rego -o entitlement-policy/entitlements_default_test.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_service_fetch.rego -o entitlement-policy/entitlements_service_fetch.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/entitlements_service_test.rego -o entitlement-policy/entitlements_service_test.rego
curl -L https://raw.githubusercontent.com/opentdf/backend/main/containers/entitlement-pdp/entitlement-policy/input.json -o entitlement-policy/input.json

echo "Download embedded install script"
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/embedded-install.sh -o embedded-install.sh && chmod 755 embedded-install.sh

echo "Download sample chart overrides and configs"
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/sample-install-config.yaml -o sample-install-config.yaml
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/sample-values.yaml -o sample-values.yaml


echo "Install Istio"
curl -L https://raw.githubusercontent.com/virtru-corp/virtru-charts/$chartBranch/scp/quickstart/quickstart-istio.sh -o quickstart-istio.sh && chmod 755 quickstart-istio.sh
./quickstart-istio.sh

echo "Create namespace and enable istio injection"
kubectl create namespace $ns
kubectl label namespace $ns istio-injection=enabled

echo "Run embedded install with tls self signed cert"
./embedded-install.sh -h $INGRESS_HOSTNAME -e ./entitlement-policy -c ./sample-install-config.yaml -o ./sample-values.yaml -t true -u $GITHUB_USER -p $GITHUB_TOKEN


