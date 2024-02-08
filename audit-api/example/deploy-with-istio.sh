# Image Pull Username . e.g. GHCR Personal Access Token
imagePullUsername="changeme"
# Image pull username
imagePullPAT="changeme"
# Scale istiod downt to 0 then back up to 1
scaleIstio=false

chartRepo="virtru-charts"
auditChart="${chartRepo}/audit-api"
# For local install change to chart-version.tgz
# auditChart="../../audit-api-0.1.0.tgz"
# Is the platform in the same cluster as the audit-api deployment
while getopts "u:p:o:d:i" arg; do
  case $arg in
    u)
      imagePullUsername=${OPTARG}
      ;;
    p)
      imagePullPAT=${OPTARG}
      ;;
    o)
      overrideValues=${OPTARG}
      ;;
    d)
      chartsLocalDir=${OPTARG}
      ;;
    i)
      scaleIstio=true
      ;;
  esac
done

if [ ! -z "$chartsLocalDir" ]; then
  echo "Using local charts from ${chartsLocalDir}"
  auditChart="${chartsLocalDir}/audit-api-*.tgz"
fi


echo "Deploying with chart overrides = ${overrideValues}"

echo "#1 Deploy audit-api Service"
helm upgrade --install -n $ns --create-namespace \
  --set "secrets.imageCredentials.pull-secret.name"="ghcr" \
  --set "secrets.imageCredentials.pull-secret.username"="${imagePullUsername}" \
  --set "secrets.imageCredentials.pull-secret.password"="${imagePullPAT}" \
  --set "secrets.imageCredentials.pull-secret.email"="nope@nah.com" \
  --set "secrets.imageCredentials.pull-secret.registry"="ghcr.io" \
  -f $overrideValues \
  audit-api $auditChart

echo "#2 Wait for audit-api deployment rollout"
kubectl rollout status --watch --timeout=120s deployment/audit-api -n $ns


if $scaleIstio; then
  kubectl scale deployment istiod -n istio-system --replicas=0
  kubectl scale deployment istiod -n istio-system --replicas=1
fi
