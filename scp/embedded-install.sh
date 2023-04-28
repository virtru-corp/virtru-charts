# Does Istio ingress have tls enabled and requires cert setup
tlsEnabled="false"
# The existing secret for Istio Gateway TLS config
tlsSecret="null"
# Image Pull Username . e.g. GHCR Personal Access Token
imagePullUsername="changeme"
# Image pull username
imagePullPAT="changeme"
# Hostname for ingress
ingressHostname=""
# Entitlement policy location
entitlementPolicyLocation=""
# Config file location
configFile=""

chartRepo="virtru-charts"
postgresqlChart="${chartRepo}/shp-embedded-postgresql"
keycloakChart="${chartRepo}/shp-embedded-keycloak"
keycloakBootstrapperChart="${chartRepo}/shp-keycloak-bootstrapper"
scpChart="${chartRepo}/scp"
# For local install change to chart-version.tgz
#postgresqlChart="shp-embedded-postgresql-0.1.0.tgz"
#keycloakChart="shp-embedded-keycloak-0.1.0.tgz"
#keycloakBootstrapperChart="shp-keycloak-bootstrapper-0.1.2.tgz"
#scpChart="scp-0.1.3.tgz"
while getopts "h:t:s:u:p:e:c:o:" arg; do
  case $arg in
    t)
      tlsEnabled=${OPTARG}
      ;;
    s)
      tlsSecret=${OPTARG}
      ;;
    u)
      imagePullUsername=${OPTARG}
      ;;
    p)
      imagePullPAT=${OPTARG}
      ;;
    h)
      ingressHostname=${OPTARG}
      ;;
    e)
      entitlementPolicyLocation=${OPTARG}
      ;;
    c)
      configFile=${OPTARG}
      ;;
    o)
      overrideValues=${OPTARG}
      ;;
  esac
done
echo "Deploying to hostname=${ingressHostname}, with configFile=${configFile} and chart overrides = ${overrideValues}"
oidcExternalBaseUrlSetting="global.opentdf.common.oidcExternalBaseUrl=https://${ingressHostname}"
ingressHostnameSetting="global.opentdf.common.ingress.hostname=${ingressHostname}"

echo "#1 Deploy postgresql - from shp-embedded-postgresql directory"
helm upgrade --install -n $ns --create-namespace \
     -f $overrideValues \
     shp-postgresql $postgresqlChart

echo "#2 Wait for postgresql"
kubectl rollout status --watch --timeout=120s statefulset/postgresql -n $ns

echo "#3 Install Keycloak"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    -f $overrideValues \
     shp-keycloak $keycloakChart

echo "#4 Wait for keycloak"
kubectl rollout status --watch --timeout=360s statefulset/keycloak -n $ns

echo "#5 Bootstrap keycloak users"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    --set-file bootstrap.configFile=$configFile \
    -f $overrideValues \
     shp-keycloak-bootstrapper $keycloakBootstrapperChart

echo "#5 Wait for bootstrap job"
kubectl wait --for=condition=complete job/shp-keycloak-bootstrapper-job --timeout=120s -n $ns

echo "installing entitlement policy secret"
kubectl delete secret scp-bootstrap-entitlement-policy --ignore-not-found true -n $ns
kubectl create secret generic scp-bootstrap-entitlement-policy --from-file=$entitlementPolicyLocation -n $ns

echo "#6 Install Self hosted platform"
helm upgrade --install -n $ns --create-namespace \
 --set secrets.imageCredentials.pull-secret.username="${imagePullUsername}" \
 --set secrets.imageCredentials.pull-secret.password="${imagePullPAT}" \
 --set $oidcExternalBaseUrlSetting \
 --set $ingressHostnameSetting \
 --set-file bootstrap.configFile=$configFile \
 --set ingress.tls.enabled=${tlsEnabled} \
 --set ingress.tls.secretName=${tlsSecret} \
 -f $overrideValues shp $scpChart

echo "Wait for Configuration Artifact Bootstrapping"
kubectl wait --for=condition=complete job/shp-scp-configsvc-bootstrap --timeout=120s -n $ns
echo "Wait for Entitlement policy bundle publication"
kubectl wait --for=condition=complete job/shp-entitlement-policy-bootstrap --timeout=120s -n $ns
echo "Wait for attribute and entitlement Bootstrapping job"
kubectl wait --for=condition=complete job/shp-entitlement-attrdef-bootstrap  --timeout=120s -n $ns

kubectl scale deployment istiod -n istio-system --replicas=0
kubectl scale deployment istiod -n istio-system --replicas=1

## TODO - Run postman smoke tests
