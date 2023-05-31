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
# Add security contexts to keycloak, configuration, and docker-registry
addSecurityContexts=false

chartRepo="virtru-charts"
postgresqlChart="${chartRepo}/shp-embedded-postgresql"
keycloakChart="${chartRepo}/shp-embedded-keycloak"
keycloakBootstrapperChart="${chartRepo}/shp-keycloak-bootstrapper"
shpChart="${chartRepo}/shp"
# For local install change to chart-version.tgz
#postgresqlChart="shp-embedded-postgresql-0.1.1.tgz"
#keycloakChart="shp-embedded-keycloak-0.1.4.tgz"
#keycloakBootstrapperChart="shp-keycloak-bootstrapper-0.1.4.tgz"
#shpChart="shp-0.1.8.tgz"
while getopts "h:t:s:u:p:e:c:o:k:l:ia" arg; do
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
      ;;
    a)
      addSecurityContexts=true
      ;;
  esac
done

if [ ! -z "$chartsLocalDir" ]; then
  echo "Using local charts from ${chartsLocalDir}"
  postgresqlChart="${chartsLocalDir}/shp-embedded-postgresql-*.tgz"
  keycloakChart="${chartsLocalDir}/shp-embedded-keycloak-*.tgz"
  keycloakBootstrapperChart="${chartsLocalDir}/shp-keycloak-bootstrapper-*.tgz"
  shpChart="${chartsLocalDir}/shp-*.tgz"
fi

pullSecretArgs=()
if [ ! -z "$imagePullUsername" ] && [ ! "$imagePullUsername" = "null" ]; then
  echo "Setting pull secret args"
  shpImagePullSecretName="shp-pull-secret"
  pullSecretArgs+=("--set" "access-pep.existingImagePullSecret=${shpImagePullSecretName}"
                  "--set" "access-pep.useImagePullSecret=true"
                  "--set" "configuration.server.imagePullSecrets[0].name=${shpImagePullSecretName}"
                  "--set" "entitlement-policy-bootstrap.imagePullSecrets[0].name=${shpImagePullSecretName}"
                  "--set" "tagging-pdp.image.pullSecrets[0].name=${shpImagePullSecretName}"
                  "--set" "gloabl.imagePullSecrets[0].name=${shpImagePullSecretName}"
                  "--set" "bootstrap.configsvc.job.imagePullSecrets[0].name=${shpImagePullSecretName}"
                  )
fi

echo "Setting override value files"
SAVEIFS=$IFS
IFS=$','
overrideValuesArray=($overrideValues)
IFS=$SAVEIFS
overrideValuesArgs=()
for i in "${overrideValuesArray[@]}"
do
	overrideValuesArgs+=("-f" "$i")
done
# Checks and warnings
if [[ -z $overrideValues ]]; then
  echo "\nERROR: Chart Overrides Value required; set using the -o flag"
  exit 1;
fi
if [[ -z $ingressHostname ]]; then
  echo "\nERROR: Ingress hostname required; set using the -h flag"
  exit 1;
fi
if [[ -z $configFile ]]; then
  echo "\nERROR: Platform configuration file path required; set using the -c flag"
  exit 1;
fi
if [[ -z $entitlementPolicyLocation ]]; then
  echo "\nERROR: Entitlement policy directory path required; set using the -e flag"
  exit 1;
fi
if [[ -z $imagePullUsername ]] ; then
  echo "\n------WARNING: Pull credential username NOT provided - an existing image pull secret must exist in the cluster and be referenced in chart values; otherwise set with -u flag\n"
fi
if [[ -z $imagePullPAT ]] ; then
  echo "\n------WARNING: Image Pull credential password  NOT provided - an existing image pull secret must exist in the cluster and be referenced in chart values; otherwise set with -p flag\n"
fi

# Log variables
echo "---------------"
echo "Deploying with:"
echo "----------------"
echo "hostname: ${ingressHostname}"
echo "configuration file: ${configFile}"
echo "chart override files: ${overrideValuesArgs[*]}"
echo "entitlement policy location: ${entitlementPolicyLocation}"
echo "istio gateway tls: ${tlsEnabled}"
echo "keycloak truststore certificate location: ${certificateLocation}"
echo "scale istio deployment: ${scaleIstio}"
echo "add security contexts: ${addSecurityContexts}"
echo "----------------"

oidcExternalBaseUrlSetting="global.opentdf.common.oidcExternalBaseUrl=https://${ingressHostname}"
ingressHostnameSetting="global.opentdf.common.ingress.hostname=${ingressHostname}"

echo "#1 Deploy postgresql - from $postgresqlChart"
helm upgrade --install -n $ns --create-namespace \
     "${overrideValuesArgs[@]}" \
     shp-postgresql $postgresqlChart

echo "#2 Wait for postgresql"
kubectl rollout status --watch --timeout=120s statefulset/postgresql -n $ns


if [ ! -z "$certificateLocation" ]
then
  echo "Installing keycloak-certs-secret from $certificateLocation"
  kubectl delete secret keycloak-certs-secret --ignore-not-found true -n $ns
  kubectl create secret generic keycloak-certs-secret --from-file=$certificateLocation -n $ns
fi

securityContextArgs=()
if $addSecurityContexts; then
  securityContextArgs+=("--set" "keycloak.podSecurityContext.fsGroup=1000"
                        "--set" "keycloak.securityContext.runAsUser=1000"
                        "--set" "keycloak.securityContext.runAsNonRoot=true")
fi

echo "#3 Install Keycloak"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    "${securityContextArgs[@]}" \
    "${overrideValuesArgs[@]}" \
     shp-keycloak $keycloakChart

echo "#4 Wait for keycloak"
kubectl rollout status --watch --timeout=360s statefulset/keycloak -n $ns

echo "#5 Bootstrap keycloak users"
helm upgrade --install -n $ns --create-namespace \
    --set $oidcExternalBaseUrlSetting \
    --set $ingressHostnameSetting \
    --set-file bootstrap.configFile=$configFile \
    "${overrideValuesArgs[@]}" \
     shp-keycloak-bootstrapper $keycloakBootstrapperChart

echo "#5 Wait for bootstrap job"
kubectl wait --for=condition=complete job/shp-keycloak-bootstrapper-job --timeout=120s -n $ns

echo "installing entitlement policy secret"
kubectl delete secret shp-bootstrap-entitlement-policy --ignore-not-found true -n $ns
kubectl create secret generic shp-bootstrap-entitlement-policy --from-file=$entitlementPolicyLocation -n $ns

securityContextArgs=()
if $addSecurityContexts; then
  securityContextArgs+=("--set" "docker-registry.securityContext.enabled=true"
                        "--set" "docker-registry.securityContext.runAsUser=1000"
                        "--set" "docker-registry.securityContext.fsGroup=1000"
                        "--set" "configuration.server.securityContext.runAsUser=1000"
                        "--set" "configuration.server.securityContext.runAsNonRoot=true")
fi

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
 "${securityContextArgs[@]}" \
 "${overrideValuesArgs[@]}" \
 shp $shpChart

echo "Wait for Configuration Artifact Bootstrapping"
kubectl wait --for=condition=complete job/shp-shp-configsvc-bootstrap --timeout=120s -n $ns
echo "Wait for Entitlement policy bundle publication"
kubectl wait --for=condition=complete job/shp-entitlement-policy-bootstrap --timeout=120s -n $ns
echo "Wait for attribute and entitlement Bootstrapping job"
kubectl wait --for=condition=complete job/shp-entitlement-attrdef-bootstrap  --timeout=120s -n $ns

if $scaleIstio; then
  kubectl scale deployment istiod -n istio-system --replicas=0
  kubectl scale deployment istiod -n istio-system --replicas=1
fi

## TODO - Run postman smoke tests
