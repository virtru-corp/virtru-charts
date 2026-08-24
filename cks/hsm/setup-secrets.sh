#!/bin/bash
# ==============================================================================
# CKS + CloudHSM — Kubernetes Secrets Setup Script
# ==============================================================================
# Run this script from the hsm/ directory before running helm install.
# All files in this directory must be populated with your actual values
# before running this script.
#
# Usage:
#   ./setup-secrets.sh
#
# Optional: Pass a custom namespace (default: virtru)
#   ./setup-secrets.sh my-namespace
#
# Note: if you use a custom namespace here, pass the same value to helm:
#   helm upgrade --install cks ../ -n <namespace> -f ../values.yaml
# ==============================================================================

set -eo pipefail

NAMESPACE=${1:-virtru}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo " CKS + CloudHSM — Kubernetes Secrets Setup"
echo " Namespace: $NAMESPACE"
echo " Directory: $SCRIPT_DIR"
echo "=================================================="

# ------------------------------------------------------------------------------
# Validate required files exist AND have been populated with real values.
# Files are shipped as .example placeholders — if a user forgets to rename and
# fill them in, the raw placeholder text passes an existence check but produces
# a garbage secret that will fail at runtime with a cryptic error.
# ------------------------------------------------------------------------------
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
  FILEPATH="$SCRIPT_DIR/$FILE"

  if [ ! -f "$FILEPATH" ]; then
    echo "ERROR: Required file not found: $FILEPATH"
    echo "       Rename the corresponding .example file and populate it with your actual values."
    exit 1
  fi

  # Reject files that still contain placeholder tokens
  if grep -q '<YOUR_' "$FILEPATH" 2>/dev/null; then
    echo "ERROR: $FILE still contains placeholder text (<YOUR_...)."
    echo "       Replace all placeholder values before running this script."
    exit 1
  fi

  echo "  ✓ $FILE"
done

# Validate cert files are parseable (catches truncated or mis-pasted PEM blocks)
echo ""
echo "Validating certificate files..."
if ! openssl x509 -noout -in "$SCRIPT_DIR/customerCA.crt" 2>/dev/null; then
  echo "ERROR: customerCA.crt is not a valid X.509 certificate."
  echo "       Download it from the AWS CloudHSM console under Clusters > Certificates."
  exit 1
fi
echo "  ✓ customerCA.crt is a valid X.509 certificate"

if ! openssl x509 -noout -in "$SCRIPT_DIR/client.crt" 2>/dev/null; then
  echo "ERROR: client.crt is not a valid X.509 certificate."
  exit 1
fi
echo "  ✓ client.crt is a valid X.509 certificate"

if ! openssl rsa -noout -in "$SCRIPT_DIR/client.key" 2>/dev/null; then
  echo "ERROR: client.key is not a valid RSA private key."
  exit 1
fi
echo "  ✓ client.key is a valid RSA private key"

if ! openssl rsa -pubin -noout -in "$SCRIPT_DIR/rsa001.pub" 2>/dev/null; then
  echo "ERROR: rsa001.pub is not a valid RSA public key."
  echo "       Export it from the HSM by key reference using cloudhsm-cli key generate-file."
  exit 1
fi
echo "  ✓ rsa001.pub is a valid RSA public key"

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
# Read the PIN via stdin and pipe directly to kubectl --from-file=pkcs11Pin=/dev/stdin.
# This avoids passing the PIN as a command-line argument, which would expose it
# in the process list (visible via `ps aux` to other users on the host).
echo ""
echo "Creating secret: hsm-pin..."
read -r -s -p "Enter HSM PIN (<crypto_user>:<password>): " HSM_PIN
echo ""
echo -n "$HSM_PIN" | kubectl create secret generic hsm-pin \
  --from-file=pkcs11Pin=/dev/stdin \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -
unset HSM_PIN
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
kubectl get secrets -n "$NAMESPACE" | grep -E "hsm-ca-cert|cloudhsm-client-tls|cks-keys|hsm-pin" || true
echo ""
echo "ConfigMaps:"
kubectl get configmaps -n "$NAMESPACE" | grep -E "cloudhsm-pkcs11-cfg|cloudhsm-client-cfg" || true
echo ""
echo "Next step: helm upgrade --install cks ../ -n $NAMESPACE -f ../values.yaml"
