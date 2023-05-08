# Overview
Postman collections to verify installation

Install newman cli:
- MacOSX: `brew install newman`



## Global: 
- Environment File - Supply environment variables across the various testing collections. [Example](./env.json)


## Collections:
The pattern is to invoke the collection with the environment file and collection specific data file.

e.g.
```shell
newman run <collection.json> -e <env file> -d <data file>
```

Helper for pluggable data/envs:
```shell
export POSTMAN_VAR_DIR=./tests/postman
```
- Verify Access Service
  - [Collection](./access-pep.postman_collection.json)
  - [Data](./access-pep_data.json)
  - Example:
    ```
    newman run tests/postman/access-pep.postman_collection.json -e $POSTMAN_VAR_DIR/env.json -d $POSTMAN_VAR_DIR/access-pep_data.json
    ```
- Attribute Definitions
  - [Collection](./attribute-definitions.postman_collection.json)
  - [Data](./attribute-definitions_data.json)
  - Example:
    ```shell
     newman run tests/postman/attribute-definitions.postman_collection.json -e $POSTMAN_VAR_DIR/env.json -d $POSTMAN_VAR_DIR/attribute-definitions_data.json
    ```
- Configuration Service
  - [Collection](./configuration-svc.postman_collection.json)
  - [Data](./configuration-svc_data.json)
  - Example:
    ```shell
     newman run tests/postman/configuration-svc.postman_collection.json -e $POSTMAN_VAR_DIR/env.json -d $POSTMAN_VAR_DIR/configuration-svc_data.json
    ```
    
For re-use - this folder is archived and under source control for downloading by consumers.

```
tar czf ../postman.tar.gz ../postman  
```