# Embedded Install - Not For Production Use
1. Export values:
   - namespace for installation of all charts
    ```
    export ns=scp
    ```
1. Install Embedded Postgresql, Embedded Keycloak + SHP
   Run from base directory:
    ```
    ./scp/embedded-install.sh -u <ghcr username> \
        -p <ghcr pat> \
        -h <ingress host> \
        -e <pathToEntitlementPolicyDir> \
        -c <pathToInstallationConfigFile> \
        -o <pathToChartOverridesFile>
    ```
   
## Uninstall everything
```shell
helm ls -n $ns --short | xargs -L1 helm uninstall -n $ns

kubectl delete pvc --all -n $ns
kubectl delete secret --all -n $ns
```