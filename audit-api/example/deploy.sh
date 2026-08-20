# Image Pull Username . e.g. GHCR Personal Access Token
imagePullUsername="changeme"
# Image pull username
imagePullPAT="changeme"

while getopts ":u:p:" arg; do
  case $arg in
    u)
      imagePullUsername=${OPTARG}
      ;;
    p)
      imagePullPAT=${OPTARG}
      ;;
  esac
done

echo "#1 Deploy audit-api Service"
helm upgrade --install -n $ns --create-namespace \
  --set "secrets.imageCredentials.pull-secret.name"="ghcr" \
  --set "secrets.imageCredentials.pull-secret.username"="${imagePullUsername}" \
  --set "secrets.imageCredentials.pull-secret.password"="${imagePullPAT}" \
  --set "secrets.imageCredentials.pull-secret.email"="nope@nah.com" \
  --set "secrets.imageCredentials.pull-secret.registry"="ghcr.io" \
  -f "audit-api/values.yaml" \
  audit-api audit-api
