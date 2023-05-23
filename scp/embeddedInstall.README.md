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
        -k <optional - path to keycloak trust certs> \
        -e <pathToEntitlementPolicyDir> \
        -c <pathToInstallationConfigFile> \
        -o <pathToChartOverridesFile(s) -- multiple files can be passed with "," delimeter> \
        -l <optional - path to local charts dir > \
        -i <optional - scale istio down and up after install (no arg)>
        -a <optional - add security contexts to keycloak, config, and registry (no arg)>
    ```
   
## Uninstall everything
```shell
helm ls -n $ns --short | xargs -L1 helm uninstall -n $ns

kubectl delete pvc --all -n $ns
kubectl delete secret --all -n $ns
```