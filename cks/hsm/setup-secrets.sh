#!/bin/bash
# ==============================================================================
# CKS + CloudHSM — Kubernetes Secrets Setup Script
# ==============================================================================
# Run this script from the hsm/ directory before running helm install.
# All files in this directory must be populated with your actual values
# before running this script.
#
# Usage:
#   chmod +x setup-secrets.sh
#   ./setup-secrets.sh
#
# Optional: Pass a custom namespace (default: virtru)
#   ./setup-secrets.sh my-namespace
# ==============================================================================

set -e

NAMESPACE=${1:-virtru}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo " CKS + CloudHSM — Kubernetes Secrets Setup"
echo " Namespace: $NAMESPACE"
echo " Directory: $SCRIPT_DIR"
echo "=================================================="

# -- Validate required files exist
REQUIRED_FILES=(
  "customerCA.crt"
  "client.crt"
  "client.key"
  "rsa001.pub"
  "cloudhsm-pkcs11.cfg"
  "cloudhsm_client.cfg"
)

echo ""
echo "Validating required files..."
for FILE in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$SCRIPT_DIR/$FILE" ]; then
    echo "ERROR: Required file not found: $SCRIPT_DIR/$FILE"
    echo "Please ensure all required files are in the hsm/ directory."
    exit 1
  fi
  echo "  ✓ $FILE"
done

# -- Create namespace if it doesn't exist
echo ""
echo "Ensuring namespace '$NAMESPACE' exists..."
kubectl get namespace "$NAMESPACE" > /dev/null 2>&1 || \
  kubectl create namespace "$NAMESPACE"
echo "  ✓ Namespace ready"

# -- HSM CA Certificate
echo ""
echo "Creating secret: hsm-ca-cert..."
kubectl create secret generic hsm-ca-cert \
  --from-file=customerCA.crt="$SCRIPT_DIR/customerCA.crt" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ hsm-ca-cert"

# -- CloudHSM Client TLS Cert and Key
echo ""
echo "Creating secret: cloudhsm-client-tls..."
kubectl create secret generic cloudhsm-client-tls \
  --from-file=client.crt="$SCRIPT_DIR/client.crt" \
  --from-file=client.key="$SCRIPT_DIR/client.key" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ cloudhsm-client-tls"

# -- CKS Public Key
echo ""
echo "Creating secret: cks-keys..."
kubectl create secret generic cks-keys \
  --from-file=rsa001.pub="$SCRIPT_DIR/rsa001.pub" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ cks-keys"

# -- HSM PIN
echo ""
echo "Creating secret: hsm-pin..."
read -r -s -p "Enter HSM PIN (<crypto_user>:<password>): " HSM_PIN
echo ""
kubectl create secret generic hsm-pin \
  --from-literal=pkcs11Pin="$HSM_PIN" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ hsm-pin"

# -- PKCS#11 Config (ConfigMap)
echo ""
echo "Creating configmap: cloudhsm-pkcs11-cfg..."
kubectl create configmap cloudhsm-pkcs11-cfg \
  --from-file=cloudhsm-pkcs11.cfg="$SCRIPT_DIR/cloudhsm-pkcs11.cfg" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ cloudhsm-pkcs11-cfg"

# -- CloudHSM Client Config (ConfigMap)
echo ""
echo "Creating configmap: cloudhsm-client-cfg..."
kubectl create configmap cloudhsm-client-cfg \
  --from-file=cloudhsm_client.cfg="$SCRIPT_DIR/cloudhsm_client.cfg" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ cloudhsm-client-cfg"

# -- Summary
echo ""
echo "=================================================="
echo " ✅ All secrets and configmaps created successfully"
echo "=================================================="
echo ""
echo "Secrets:"
kubectl get secrets -n "$NAMESPACE" | grep -E "hsm-ca-cert|cloudhsm-client-tls|cks-keys|hsm-pin"
echo ""
echo "ConfigMaps:"
kubectl get configmaps -n "$NAMESPACE" | grep -E "cloudhsm-pkcs11-cfg|cloudhsm-client-cfg"
echo ""
echo "Next step: helm upgrade --install cks ../ -n $NAMESPACE -f ../values.yaml"
