echo "#1 Deploy postgresql - from shp-embedded-postgresql directory"
helm upgrade --install -n $ns --create-namespace \
    -f shp-embedded-postgresql/values.yaml -f $overrideValues \
     shp-postgresql shp-embedded-postgresql

echo "#2 Wait for postgresql"
kubectl rollout status --watch --timeout=120s statefulset/postgresql -n $ns

echo "#3 Install Keycloak"
helm upgrade --install -n $ns --create-namespace \
    -f shp-embedded-keycloak/values.yaml -f $overrideValues \
     shp-keycloak shp-embedded-keycloak

echo "#4 Wait for keycloak"
kubectl rollout status --watch --timeout=360s statefulset/keycloak -n $ns

echo "#5 Bootstrap keycloak users"
helm upgrade --install -n $ns --create-namespace \
    -f shp-keycloak-bootstrapper/values.yaml -f $overrideValues \
     shp-keycloak-boostrapper shp-keycloak-bootstrapper

echo "#5 Wait for bootstrap job"
kubectl wait --for=condition=complete job/shp-keycloak-boostrapper-job --timeout=120s -n $ns

echo "#6 Install Self hosted platform"
helm upgrade --install -n scp --create-namespace \
    -f scp/values.yaml -f $overrideValues scp $ns
