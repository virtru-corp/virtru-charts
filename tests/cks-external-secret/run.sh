#!/usr/bin/env bash
set -euo pipefail

chart_repo=$(cd "$(dirname "$0")/../.." && pwd)
eso_commit=0755b0af7de7f05a104b0df29ba84f43513fee8b # v2.5.0, deployed in mgmt-prod
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

git clone --quiet --depth 1 --branch v2.5.0 --filter=blob:none --sparse \
  https://github.com/external-secrets/external-secrets.git "$scratch/eso"
test "$(git -C "$scratch/eso" rev-parse HEAD)" = "$eso_commit"
git -C "$scratch/eso" sparse-checkout set runtime apis
cp "$chart_repo/tests/cks-external-secret/cks_external_secret_test.go" \
  "$scratch/eso/runtime/template/v2/cks_external_secret_test.go"
cd "$scratch/eso/runtime"
GOWORK=off CKS_CHART_DIR="$chart_repo/cks" go test ./template/v2 -run '^TestCKSExternalSecret' -count=1 -v
