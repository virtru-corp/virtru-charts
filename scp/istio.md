# Istio Installation Guide
1. Install istio - optional if cluster does not have istio
    ```
    helm repo add istio https://istio-release.storage.googleapis.com/charts
    helm repo update  
    kubectl create namespace istio-system
    helm install istio-base istio/base -n istio-system
    helm install istiod istio/istiod -n istio-system --wait
    ```
1. Install istio ingress gateway  - optional; needed only if not using an existing gateway
   ```
      kubectl create namespace istio-ingress
      kubectl label namespace istio-ingress istio-injection=enabled
      helm install istio-ingress istio/gateway -n istio-ingress <optional env override: -f ingress-gateway-values.yaml>
   ```

   Vendor ingress value examples:
    - AWS EKS: Example using an AWS Cert ARN
      ```
      service:
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:replaceme"
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
          service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
          service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"     
      ```