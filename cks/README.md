# CKS Deployment via Helm

## Overview

This Helm chart deploys Virtru's Customer Key Server (CKS) on Kubernetes. It supports two key provider modes:

- **Default (File-based):** RSA keys are stored as Kubernetes secrets and mounted into the container
- **HSM Mode:** RSA keys are stored in AWS CloudHSM and never leave the hardware — all crypto operations are delegated to the HSM via PKCS#11

You can read this documentation on Virtru's support site here:

* [Kubernetes Prerequisites](https://support.virtru.com/hc/en-us/articles/5747166730903-CKS-Kubernetes-cluster)
* [CKS Helm Deployment](https://support.virtru.com/hc/en-us/articles/5746713557015-CKS-Install-Kubernetes-)

---

### v1.2.0 Upgrade Notes

**Relevant to users leveraging `.Values.externalAppSecrets`**

Upgrading from `< v1.2.0` to `>= v1.2.0` chart version while using the `.Values.externalAppSecrets` requires your in-cluster external-secrets operator to be on v0.16.0+. In chart version v1.2.0+, upgrades to the `ExternalSecrets` object to use `external-secrets.io/v1` apiVersion have been made. Previously the external secret created used `external-secrets.io/v1beta1`.

This upgrade is in line with external-secrets operator no longer serving v1beta1 APIs in v0.17.0+. v1 APIs were promoted in v0.16.0, and will be the default in Virtru provided charts moving forward.

---

### Assumptions

* The namespace for the deployment is `virtru`
* The secrets directory is created in the same working directory as the Helm chart

---

## Repository Structure

```
cks/
├── Chart.yaml
├── values.yaml             # Helm chart values (default + HSM commented out)
├── templates/              # Helm templates
├── README.md
└── hsm/                    # HSM operator inputs — excluded from helm package via .helmignore
    ├── setup-secrets.sh        # Run this first to create all Kubernetes secrets
    ├── cloudhsm-pkcs11.cfg     # PKCS#11 config — update with your HSM ENI IPs
    ├── customerCA.crt.example  # Rename to .crt and replace with your CloudHSM CA cert
    ├── client.crt.example      # Rename to .crt and replace with your client cert
    ├── client.key.example      # Rename to .key and replace with your client private key
    └── rsa001.pub.example      # Rename to .pub and replace with your HSM-exported public key
```

> **Note:** The `hsm/` directory is excluded from Helm package artifacts via `.helmignore`. The `.example` files are safe instructional placeholders. Never commit real certs, keys, or public key files to source control — the `.gitignore` in this directory excludes `*.crt`, `*.key`, and `*.pub` for this reason.

---

## Prerequisites

### Common Prerequisites (All Modes)

* Virtru provisioned organization with licenses for your email users
* Kubernetes cluster provisioned in the environment of your choosing:
  * [AWS cluster creation](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
  * [GCP cluster creation](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster)
  * [Azure cluster creation](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal)
* [Helm is installed](https://helm.sh/docs/intro/install/) on your terminal
* Your terminal is connected to your Kubernetes cluster and ready to use `kubectl`
* You have a CA signed certificate provisioned for your CKS FQDN
* You have generated an RSA keypair and CKS Auth token on your local machine

### Additional Prerequisites for HSM Mode

> **Critical:** You cannot configure CKS + CloudHSM directly from a Helm chart without first validating the integration on a Linux server. The Linux setup must succeed before proceeding to Kubernetes.

* **Minimum CKS image version:** The container image must include the CloudHSM SDK v5 tooling (specifically `/opt/cloudhsm/bin/configure-pkcs11`). Confirm with your Virtru representative which image tag supports HSM mode before deploying.
* AWS CloudHSM cluster provisioned with **at least 2 active HSM nodes** (required for key availability quorum)
* Linux server with CKS + CloudHSM fully configured and validated (`list-keys` must succeed)
* The following files collected and placed in the `hsm/` directory (rename `.example` files after populating):

| File | Source |
|---|---|
| `customerCA.crt` | AWS CloudHSM console → Clusters → Certificates |
| `client.crt` | Generated during CloudHSM cluster initialization |
| `client.key` | Generated during CloudHSM cluster initialization |
| `rsa001.pub` | Exported from HSM by key reference (see HSM Installation section) |
| `cloudhsm-pkcs11.cfg` | Template provided — update with your HSM ENI IPs |

* Security group rule: EKS cluster SG → CloudHSM cluster SG inbound **port 2223 TCP**

---

## Installation — Default Mode (File-based Keys)

### Create Secrets

There are a number of ways that Kubernetes secrets can be managed. If you do not have an existing external secret manager for your Kubernetes clusters, you can create secrets by using the `appSecrets` section of the `values.yaml` file.

**Please note we strongly advise you consider using an external secrets manager. Creating secrets via the `values.yaml` is a default option to help get your CKS up and running more quickly.**

### Updating `values.yaml`

#### `ingress`

To serve traffic appropriately, you must have an ingress controller for your CKS service. This is enabled by default, but you will need to update the host under `ingress.hosts.host` to match the FQDN of your CKS.

Depending on your environment, you will need to add annotations to:

* Apply your CA signed certificate
* Designate load balancer configurations
* Expose your load balancer to the internet

#### `appSecrets`

Update your secrets to match the values from your local CKS config as mapped below.

| Filename | Value from CKS setup script |
|---|---|
| `hmac-auth` | `env/cks.env => AUTH_TOKEN_STORAGE_IN_MEMORY_TOKEN_JSON` |
| `rsa001.pub` | `keys/rsa001.pub` |
| `rsa001.pem` | `keys/rsa001.pem` |

You can have multiple RSA keypairs on your CKS as long as they follow the naming convention `rsa###.pub` and `rsa###.pem` for all public/private keypairs.

**Note: Indentation matters for a multiline string — ensure proper indentation for your CKS key secrets.**

### Installing the CKS

Use a standard [helm install](https://helm.sh/docs/helm/helm_install/) command to deploy your CKS:

```bash
helm install -n virtru -f ./values.yaml cks ./ --create-namespace
```

---

## Installation — HSM Mode (AWS CloudHSM)

### Step 1 — Validate Linux Server First

Before deploying to Kubernetes, confirm your Linux CKS + CloudHSM integration is working. The `list-keys` output must show your RSA key pair before continuing. The minimum CKS image version that supports HSM mode must also be confirmed before proceeding (see Prerequisites).

### Step 2 — Export the Correct Public Key from the HSM

The `rsa001.pub` file must be exported directly from the HSM using the key **reference** (not the label). Multiple keys may share the same label — using the wrong one will cause `NoKeyError` at rewrap time.

```bash
# List all keys to find the correct reference
CLOUDHSM_PIN=<cu_user>:<password> CLOUDHSM_ROLE=crypto-user \
  /opt/cloudhsm/bin/cloudhsm-cli key list --filter attr.label=rsa001

# Export public key by reference
CLOUDHSM_PIN=<cu_user>:<password> CLOUDHSM_ROLE=crypto-user \
  /opt/cloudhsm/bin/cloudhsm-cli key generate-file \
  --filter key-reference=<0xKEY_REFERENCE> \
  --encoding pem \
  --path hsm/rsa001.pub

# Verify fingerprint — must match what is registered in the Virtru admin console

# Linux (GNU coreutils 8.31+):
openssl rsa -pubin -in hsm/rsa001.pub -outform DER | \
  openssl dgst -sha256 -binary | basenc --base64url | tr -d '='

# macOS (no basenc — use openssl instead):
openssl rsa -pubin -in hsm/rsa001.pub -outform DER | \
  openssl dgst -sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '='
```

### Step 3 — Populate the `hsm/` Directory

Rename each `.example` file and replace its contents with the real value. Update the config files with your HSM ENI IPs:

```
cks/hsm/
├── setup-secrets.sh          ✓ included
├── cloudhsm-pkcs11.cfg       → update <HSM_ENI_IP_1> and <HSM_ENI_IP_2>
├── customerCA.crt            → renamed from .example — paste CloudHSM CA cert
├── client.crt                → renamed from .example — paste client cert
├── client.key                → renamed from .example — paste client private key
└── rsa001.pub                → renamed from .example — exported from HSM in Step 2
```

> **Warning:** Never commit real cert, key, or public key files to source control. The `.gitignore` in the `hsm/` directory excludes `*.crt`, `*.key`, and `*.pub`.

### Step 4 — Create Kubernetes Secrets

Run the provided setup script from the `hsm/` directory. The script validates all required files, prompts for the HSM PIN securely, and creates all secrets and configmaps in one step:

```bash
cd cks/hsm
./setup-secrets.sh
# or with a custom namespace:
./setup-secrets.sh my-namespace
```

> **Important:** In HSM mode, `setup-secrets.sh` owns the `cks-keys` secret. The Helm chart's `templates/cks-keys-secret.yaml` is gated off when `appConfig.keyProviderType: hsm` is set — if you run `helm upgrade --install` before setting that value, the chart will overwrite `cks-keys` with the placeholder from `values.yaml`. Always ensure HSM mode is set in `values.yaml` before installing or upgrading.

The script creates the following resources:

| Resource | Type | Contents |
|---|---|---|
| `hsm-ca-cert` | Secret | `customerCA.crt` |
| `cloudhsm-client-tls` | Secret | `client.crt`, `client.key` |
| `cks-keys` | Secret | `rsa001.pub` |
| `hsm-pin` | Secret | `pkcs11Pin` (prompted securely) |
| `cloudhsm-pkcs11-cfg` | ConfigMap | `cloudhsm-pkcs11.cfg` |

Verify all resources were created:

```bash
kubectl get secrets -n virtru
kubectl get configmaps -n virtru
```

### Step 5 — Update `values.yaml` for HSM Mode

Uncomment the HSM configuration sections in `values.yaml`:

```yaml
appConfig:
  keyProviderType: hsm
  cryptoOperationsType: hsm
  noKeysRule: hsm
  privateKeyPath: ""
  hsmIp: "<HSM_ENI_IP_1>"
  hsmIp2: "<HSM_ENI_IP_2>"
  pkcs11Vendor: "custom"
  pkcs11LibName: "CloudHSM"
  pkcs11LibPath: "/opt/cloudhsm/lib/libcloudhsm_pkcs11.so"
  pkcs11SlotLbl: "hsm1"
  pkcs11KeyLbl: "rsa001"
  publicKeyPath: /app/keys/rsa001.pub
```

Also uncomment the `appSecrets.hsmPin` section.

### Step 6 — Install

```bash
cd cks/
helm upgrade --install cks . \
  -n virtru \
  -f values.yaml \
  --create-namespace
```

### Step 7 — Validate

```bash
# Check pods are running (init container completes first)
kubectl get pods -n virtru -w

# Check init container logs
kubectl logs <pod-name> -n virtru -c configure-pkcs11

# Validate CKS status (version reflects your deployed image tag)
curl https://<your-cks-domain>/status
# Expected: {"version":"<cks-version>","hsmStatus":"ok"}

# Verify public key fingerprint matches Virtru admin console
kubectl exec -it -n virtru deployment/cks -- node -e "
const crypto = require('crypto');
const fs = require('fs');
const pub = fs.readFileSync('/app/keys/rsa001.pub');
const der = crypto.createPublicKey(pub).export({type:'spki',format:'der'});
const fp = crypto.createHash('sha256').update(der).digest('base64url');
console.log('Fingerprint:', fp);
"
```

---

## Key Rotation (HSM Mode)

> **Important:** Key rotation for HSM-backed CKS deployments requires access to your Linux server where CKS + CloudHSM was originally configured. New keys must be generated and validated on the Linux server before being promoted to Kubernetes. The updated public key must then be applied to the cluster to keep the Kubernetes deployment in sync with the HSM.

### Rotation Steps

**1. Generate the new RSA key pair on the Linux server**

Use the CloudHSM CLI on your Linux server to create a new RSA key pair in the HSM under a new or updated label.

**2. Validate the new key on Linux**

Run `list-keys` on the Linux CKS to confirm the new key is visible and the fingerprint is correct before touching Kubernetes.

**3. Export the new public key from the HSM by key reference**

```bash
# List all keys — note the reference for the new key
CLOUDHSM_PIN=<cu_user>:<password> CLOUDHSM_ROLE=crypto-user \
  /opt/cloudhsm/bin/cloudhsm-cli key list --filter attr.label=<new_key_label>

# Export public key by reference (not label — multiple keys may share a label)
CLOUDHSM_PIN=<cu_user>:<password> CLOUDHSM_ROLE=crypto-user \
  /opt/cloudhsm/bin/cloudhsm-cli key generate-file \
  --filter key-reference=<0xNEW_KEY_REFERENCE> \
  --encoding pem \
  --path hsm/rsa002.pub

# Verify the fingerprint before registering it anywhere
# Linux:
openssl rsa -pubin -in hsm/rsa002.pub -outform DER | \
  openssl dgst -sha256 -binary | basenc --base64url | tr -d '='
# macOS:
openssl rsa -pubin -in hsm/rsa002.pub -outform DER | \
  openssl dgst -sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '='
```

**4. Register the new fingerprint in the Virtru admin console**

Update the admin console with the new public key fingerprint before applying changes to Kubernetes. This ensures no gap in rewrap availability.

**5. Update the `cks-keys` secret in Kubernetes**

Replace the public key in the cluster with the newly exported file:

```bash
kubectl create secret generic cks-keys \
  --from-file=rsa001.pub=hsm/rsa002.pub \
  -n virtru \
  --dry-run=client -o yaml | kubectl apply -f -
```

**6. Update `values.yaml` if the key label changed**

If you used a new key label in the HSM, update `appConfig.pkcs11KeyLbl` in `values.yaml` and redeploy:

```bash
helm upgrade cks . -n virtru -f values.yaml
```

**7. Validate the new fingerprint is active in the cluster**

```bash
kubectl exec -it -n virtru deployment/cks -- node -e "
const crypto = require('crypto');
const fs = require('fs');
const pub = fs.readFileSync('/app/keys/rsa001.pub');
const der = crypto.createPublicKey(pub).export({type:'spki',format:'der'});
const fp = crypto.createHash('sha256').update(der).digest('base64url');
console.log('Fingerprint:', fp);
"
```
### v2.0.0 Upgrade Notes

**Relevant to users who explicitly set `logStdoutEnabled` in `appConfig`**

The `logStdoutEnabled` key has been renamed to `logConsoleEnabled` to match
the `LOG_CONSOLE_ENABLED` environment variable it controls. If you previously
set `logStdoutEnabled: false`, update your values to `logConsoleEnabled: false`
or console logging will silently revert to enabled.

Confirm the printed fingerprint matches what was registered in the Virtru admin console.

---

## Common HSM Errors

| Error | Root Cause | Fix |
|---|---|---|
| `CKR_GENERAL_ERROR` at `C_Initialize` | Port 2223 blocked | Add SG rule: EKS cluster SG → CloudHSM SG port 2223 |
| `getSlot() returns null` | Wrong env var `PKCS11_SLOT_LABEL` | Must be `PKCS11_SLOT_LBL` in configmap.yaml |
| `NoKeyError` | Public key doesn't match HSM key | Export public key from HSM by key reference, not label |
| `CKR_PIN_INCORRECT` | `PKCS11_PIN` env var missing | Ensure `hsm-pin` secret exists and is injected |
| Key availability quorum error | Only 1 HSM node active | Add second HSM node to cluster |
| `Unable to write config file` | `cloudhsm-pkcs11.cfg` read-only | Init container + emptyDir pattern handles this automatically |
| `Unknown issuer` on rewrap | JWT issuer mismatch | Match `jwtAuthIssuer` to the environment sending tokens |
| `500` from platform on rewrap | CKS not registered | Register CKS URL and public key fingerprint in Virtru admin console |

---

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Optional: Controls scheduling rules to optimize workload distribution. |
| appConfig | object | See `values.yaml` | Application Configuration |
| appConfig.virtruOrgId | string | `"<your org id>"` | The orgId will be provided to you by your Virtru representative. |
| appConfig.keyProviderType | string | `"file"` | Key provider. `file` = PEM files (default). `hsm` = AWS CloudHSM via PKCS#11. |
| appConfig.cryptoOperationsType | string | `""` | HSM only: Set to `hsm` to delegate all crypto to CloudHSM. |
| appConfig.noKeysRule | string | `"importPEM"` | Boot behavior. `importPEM` = import from files. `hsm` = keys live in HSM. |
| appConfig.privateKeyPath | string | `"/run/secrets/rsa001.pem"` | Path to RSA private key. Set to `""` in HSM mode. |
| appConfig.publicKeyPath | string | `"/run/secrets/rsa001.pub"` | Path to RSA public key. |
| appConfig.hsmIp | string | `""` | HSM only: Primary CloudHSM ENI IP address. |
| appConfig.hsmIp2 | string | `""` | HSM only: Secondary CloudHSM ENI IP (required for 2-node quorum). |
| appConfig.pkcs11Vendor | string | `""` | HSM only: PKCS#11 vendor. Use `custom` for AWS CloudHSM SDK v5. |
| appConfig.pkcs11LibName | string | `""` | HSM only: PKCS#11 library name. Use `CloudHSM`. |
| appConfig.pkcs11LibPath | string | `""` | HSM only: Full path to PKCS#11 `.so` library inside the container. |
| appConfig.pkcs11SlotLbl | string | `""` | HSM only: PKCS#11 slot label. Always `hsm1` for AWS CloudHSM SDK v5. |
| appConfig.pkcs11KeyLbl | string | `""` | HSM only: RSA key label in the HSM. Must match the label used at key creation. |
| appConfig.hmacAuthEnabled | bool | `true` | Whether HMAC API token authentication is enabled. |
| appConfig.jwtAuthEnabled | bool | `true` | Whether JWT Bearer token authentication is enabled. |
| appConfig.jwtAuthIssuer | string | `"https://api.virtru.com"` | JWT issuer URL. Must match the `iss` claim in platform tokens. |
| appConfig.jwtAuthJwksPath | string | `"/acm/api/jwks"` | Path to JWKS endpoint for JWT public key verification. |
| appSecrets | object | See `values.yaml` | Secrets Management |
| appSecrets.virtruAuth.data.authTokenJson | string | `"<base64-encoded-JSON-from-your-CKS>"` | Base64-encoded HMAC auth token. See [setup guide](https://support.virtru.com/hc/en-us/articles/17797745877655). |
| appSecrets.virtruKeys.data."rsa001.pub" | string | `"<rsa001 public key>"` | RSA public key. HSM: export from HSM by key reference. See [setup guide](https://support.virtru.com/hc/en-us/articles/17797745877655). |
| appSecrets.virtruKeys.data."rsa001.pem" | string | `"<rsa001 private key>"` | RSA private key. Default mode only — leave blank in HSM mode. |
| appSecrets.hsmPin | object | `{}` | HSM only: Reference to the `hsm-pin` secret created by `setup-secrets.sh`. |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling is disabled by default. |
| autoscaling.maxReplicas | int | `100` | Maximum number of pods. |
| autoscaling.minReplicas | int | `1` | Minimum number of pods. |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU threshold for scaling. Default is 80%. |
| deployment | object | `{"port":9000}` | Internal application port used for the deployment. |
| deployment.port | int | `9000` | The CKS will use the default internal port 9000. |
| fullnameOverride | string | `""` | Optional override for the full resource name. |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"containers.virtru.com/cks","tag":""}` | Container image config. For versions see [release notes](https://support.virtru.com/hc/en-us/articles/360034039233). HSM: confirm image tag supports CloudHSM SDK v5. |
| ingress | object | See `values.yaml` | Ingress Configuration. Enabled by default. |
| ingress.hosts[0].host | string | `"fqdn.yourdomain.com"` | Change to match the FQDN of your CKS. |
| nameOverride | string | `""` | Optional name override for the CKS release. |
| nodeSelector | object | `{}` | Optional: Specifies node labels for pod placement. HSM: pin to HSM-ready nodes. |
| podAnnotations | object | `{}` | Optional annotations for pods, useful for monitoring or automation. |
| podSecurityContext | object | `{}` | Pod-level security context. HSM: do not set `readOnlyRootFilesystem: true`. |
| replicaCount | int | `3` | Number of CKS pod replicas. Default is 3 for HA. |
| resources | object | `{}` | CPU/memory limits and requests. HSM workloads benefit from defined limits. |
| revisionHistoryLimit | int | `10` | Number of old deployments retained for rollback purposes. |
| securityContext | object | `{}` | Container-level security context. HSM: do not set `readOnlyRootFilesystem: true`. |
| service | object | `{"annotations":{},"port":443,"protocol":"TCP","type":"ClusterIP"}` | Service Configuration. |
| service.type | string | `"ClusterIP"` | Service type. Use `LoadBalancer` for AWS NLB in HSM/public deployments. |
| serviceAccount.annotations | object | `{}` | Metadata annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | Service account name. Auto-generated if not set and create is true. |
| testerPod | object | `{"annotations":{"helm.sh/hook":"test"},"enabled":true}` | Test pod is created by default. |
| tolerations | list | `[]` | Optional: Defines tolerations to allow pods to be scheduled on tainted nodes. |
