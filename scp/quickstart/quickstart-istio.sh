echo "Install istio"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod \
  --set global.proxy.resources.requests.cpu="50m" \
  --set global.proxy.resources.requests.memory="128Mi" \
   -n istio-system --wait

echo "Install istio ingress"
kubectl create namespace istio-ingress
kubectl label namespace istio-ingress istio-injection=enabled
helm install istio-ingress istio/gateway -n istio-ingress --wait

