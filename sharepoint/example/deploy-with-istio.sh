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
# Location to sharepoint private key
sharepointPrivateKey=""

chartRepo="virtru-charts"
sharepointChart="${chartRepo}/sharepoint"
# For local install change to chart-version.tgz
sharepointChart="sharepoint-0.1.0.tgz"
# Is the platform in the same cluster as the sharepoint deployment
platformLocal=""
while getopts "h:t:s:u:p:o:k:l" arg; do
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
    o)
      overrideValues=${OPTARG}
      ;;
    k)
      sharepointPrivateKey=${OPTARG}
      ;;
    l)
      platformLocal="true"
      ;;
  esac
done
echo "Deploying to hostname=${ingressHostname} with chart overrides = ${overrideValues}"
configAuthUrl="https://${ingressHostname}"
# If this is deployed in the same cluster then use internal url
if [ ! -z "$platformLocal" ]; then
  configAuthUrl="http://keycloak-http"
  echo "Setting configAuthUrl to internal address ${configAuthUrl}"
fi

echo "#1 Deploy Sharepoint Service"
helm upgrade --install -n $ns --create-namespace \
  --set "imageCredentials[0].name"="ghcr" \
  --set "imageCredentials[0].username"="${imagePullUsername}" \
  --set "imageCredentials[0].password"="${imagePullPAT}" \
  --set "imageCredentials[0].email"="nope@nah.com" \
  --set "imageCredentials[0].registry"="ghcr.io" \
  --set config.auth.url="${configAuthUrl}" \
  --set ingress.hostname="${ingressHostname}" \
  --set ingress.istio.enabled=true \
  --set-file config.sharepointPfx=${sharepointPrivateKey} \
  -f $overrideValues \
  sharepoint $sharepointChart

echo "#2 Wait for sharepoit deployment rollout"
kubectl rollout status --watch --timeout=120s deployment/sharepoint -n $ns


kubectl scale deployment istiod -n istio-system --replicas=0
kubectl scale deployment istiod -n istio-system --replicas=1
