# Embedded Install - Not For Production Use
1. Export values:
    - location of values override
     ```
     export overrideValues="demo/demo.values.yaml"
     ```
   - namespace for installation of all charts
    ```
    export ns=scp
    ```
1. Install Embedded Postgresql, Embedded Keycloak + SHP
   Run from base directory:
    ```
    ./scp/embedded-install.sh -u <ghcr username> -p <ghcr pat> -h <ingress host>
    ```
   
## Uninstall everything
```shell
helm ls -n $ns --short | xargs -L1 helm uninstall -n $ns

kubectl delete pvc --all -n $ns
```