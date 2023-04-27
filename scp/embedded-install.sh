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

oidcExternalBaseUrlSetting="global.opentdf.common.oidcExternalBaseUrl=https://${ingressHostname}"
ingressHostnameSetting="global.opentdf.common.ingress.hostname=${ingressHostname}"

echo "#1 Deploy postgresql - from shp-embedded-postgresql directory"
helm upgrade --install -n $ns --create-namespace \
    -f shp-embedded-postgresql/values.yaml -f $overrideValues \
     shp-postgresql shp-embedded-postgresql

echo "#2 Wait for postgresql"
kubectl rollout status --watch --timeout=120s statefulset/postgresql -n $ns

echo "#3 Install Keycloak"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    -f shp-embedded-keycloak/values.yaml -f $overrideValues \
     shp-keycloak shp-embedded-keycloak

echo "#4 Wait for keycloak"
kubectl rollout status --watch --timeout=360s statefulset/keycloak -n $ns

echo "#5 Bootstrap keycloak users"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    --set-file bootstrap.configFile=$configFile \
    -f shp-keycloak-bootstrapper/values.yaml -f $overrideValues \
     shp-keycloak-bootstrapper shp-keycloak-bootstrapper

echo "#5 Wait for bootstrap job"
kubectl wait --for=condition=complete job/shp-keycloak-bootstrapper-job --timeout=120s -n $ns

echo "installing entitlement policy secret"
kubectl create secret generic scp-bootstrap-entitlement-policy --from-file=$entitlementPolicyLocation -n $ns

echo "#6 Install Self hosted platform"
helm upgrade --install -n $ns --create-namespace \
 --set secrets.imageCredentials[0].username="${imagePullUsername}" \
 --set secrets.imageCredentials[0].password="${imagePullPAT}" \
 --set $oidcExternalBaseUrlSetting \
 --set $ingressHostnameSetting \
 --set-file bootstrap.configFile=$configFile \
 --set ingress.tls.enabled=${tlsEnabled} \
 --set ingress.tls.secretName=${tlsSecret} \
 -f scp/values.yaml -f $overrideValues shp scp

echo "Wait for Configuration Artifact Bootstrapping"
kubectl wait --for=condition=complete job/shp-scp-configsvc-bootstrap --timeout=120s -n $ns
echo "Wait for Entitlement policy bundle publication"
kubectl wait --for=condition=complete job/shp-entitlement-policy-bootstrap --timeout=120s -n $ns
echo "Wait for attribute and entitlement Bootstrapping job"
kubectl wait --for=condition=complete job/shp-entitlement-attrdef-bootstrap  --timeout=120s -n $ns

# TODO - Run postman smoke tests
