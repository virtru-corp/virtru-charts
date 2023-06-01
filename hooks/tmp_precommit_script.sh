#!/usr/bin/env bash

set -e

charts=(
"common-lib"
"platform"
"platform-embedded-keycloak"
"platform-embedded-postgresql"
"platform-keycloak-bootstrapper"
)
cwd_abspath="$(realpath "$PWD")"
for i in "${charts[@]}";
do
  echo "updating dependencies for $i"
  helm dependency update $i
  helm lint $i
  if [ "$i" != "common-lib" ]; then
    helm template $i -f $i/values.yaml
    npx @bitnami/readme-generator-for-helm -v $i/values.yaml -r $i/README.md
  fi
  helm package $i
done

helm repo index .
