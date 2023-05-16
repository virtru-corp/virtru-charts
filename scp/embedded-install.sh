# Does Istio ingress have tls enabled and requires cert setup
tlsEnabled="false"
# The existing secret for Istio Gateway TLS config
tlsSecret="null"
# Image Pull Username . e.g. GHCR Personal Access Token
imagePullUsername=""
# Image pull username
imagePullPAT=""
# Hostname for ingress
ingressHostname=""
# Entitlement policy location
entitlementPolicyLocation=""
# Config file location; set using -c arg
configFile=""
# Location (directory) to keycloak trusted certs - optional ; set using -k arg
certificateLocation=""
# Location (directory) of charts - optional ; set using -l arg
chartsLocalDir=""
# Scale istiod downt to 0 then back up to 1
scaleIstio=false

chartRepo="virtru-charts"
postgresqlChart="${chartRepo}/shp-embedded-postgresql"
keycloakChart="${chartRepo}/shp-embedded-keycloak"
keycloakBootstrapperChart="${chartRepo}/shp-keycloak-bootstrapper"
scpChart="${chartRepo}/scp"
# For local install change to chart-version.tgz
#postgresqlChart="shp-embedded-postgresql-0.1.1.tgz"
#keycloakChart="shp-embedded-keycloak-0.1.1.tgz"
#keycloakBootstrapperChart="shp-keycloak-bootstrapper-0.1.3.tgz"
#scpChart="scp-0.1.6.tgz"
while getopts "h:t:s:u:p:e:c:o:k:i" arg; do
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
    k)
      certificateLocation=${OPTARG}
      ;;
    l)
      chartsLocalDir=${OPTARG}
      ;;
    i)
      scaleIstio=true
  esac
done

if [ ! -z "$chartsLocalDir" ]; then
  echo "Using local charts from ${chartsLocalDir}"
  postgresqlChart="${chartsLocalDir}/shp-embedded-postgresql-*.tgz"
  keycloakChart="${chartsLocalDir}/shp-embedded-keycloak-*.tgz"
  keycloakBootstrapperChart="${chartsLocalDir}/shp-keycloak-bootstrapper-*.tgz"
  scpChart="${chartsLocalDir}/scp-*.tgz"
fi

pullSecretArgs=()
if [ ! -z "$imagePullUsername" ]; then
  echo "Setting pull secret args"
  scpImagePullSecretName="scp-pull-secret"
  imagePullSecrets="[{\"name\":\"${scpImagePullSecretName}\"}]"
  pullSecretArgs+=("--set" "access-pdp.existingImagePullSecret=${scpImagePullSecretName}"
                  "--set" "access-pdp.useImagePullSecret=true"
                  "--set" "configuration.server.imagePullSecrets=${imagePullSecrets}"
                  "--set" "entitlement-policy-bootstrap.imagePullSecrets=${imagePullSecrets}"
                  "--set" "tagging-pdp.image.pullSecrets=${imagePullSecrets}"
                  "--set" "gloabl.imagePullSecrets=${imagePullSecrets}")
fi

echo "Deploying to hostname=${ingressHostname}, with configFile=${configFile} and chart overrides = ${overrideValues}"
oidcExternalBaseUrlSetting="global.opentdf.common.oidcExternalBaseUrl=https://${ingressHostname}"
ingressHostnameSetting="global.opentdf.common.ingress.hostname=${ingressHostname}"

echo "#1 Deploy postgresql - from shp-embedded-postgresql directory"
helm upgrade --install -n $ns --create-namespace \
     -f $overrideValues \
     shp-postgresql $postgresqlChart

echo "#2 Wait for postgresql"
kubectl rollout status --watch --timeout=120s statefulset/postgresql -n $ns


if [ ! -z "$certificateLocation" ]
then
  echo "Installing keycloak-certs-secret from $certificateLocation"
  kubectl delete secret keycloak-certs-secret --ignore-not-found true -n $ns
  kubectl create secret generic keycloak-certs-secret --from-file=$certificateLocation -n $ns
fi

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
 "${pullSecretArgs[@]}" \
 -f $overrideValues shp $scpChart

echo "Wait for Configuration Artifact Bootstrapping"
kubectl wait --for=condition=complete job/shp-scp-configsvc-bootstrap --timeout=120s -n $ns
echo "Wait for Entitlement policy bundle publication"
kubectl wait --for=condition=complete job/shp-entitlement-policy-bootstrap --timeout=120s -n $ns
echo "Wait for attribute and entitlement Bootstrapping job"
kubectl wait --for=condition=complete job/shp-entitlement-attrdef-bootstrap  --timeout=120s -n $ns

if [ $scaleIstio ]; then
  kubectl scale deployment istiod -n istio-system --replicas=0
  kubectl scale deployment istiod -n istio-system --replicas=1
fi

## TODO - Run postman smoke tests
