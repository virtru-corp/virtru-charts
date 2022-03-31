# CSE Deployment via Helm

To deploy CSE with Helm, you will first need to create the following secret with your Docker login credentials:

```
kubectl create secret docker-registry regcred --docker-username=<your dockerhub username> --docker-password="<your dockerhub password>" --docker-email=<your dockerhub email>
```

Update the values of the `jwksAuthzIssuers`, `jwksAuthnIssuers`, and `jwtAud` with the names and locations of your issuers json files. `jwksAuthzIssuers` and `jwksAuthnIssuers` should have the format 

```
{ "<name>": "<location of json file containing issuer information>" }
```

For example:

```
{ "virtru-test": "http://jwt.default.svc.cluster.local/jwk.json" }
```

`jwtKaclsUrl` should have the format

```
{"authn":"<authn name>","authz":"<authz name>"}
```

All of these values should be base64-encoded.

The parameter `jwtKaclsUrl` will also need to be updated to use the DNS name assigned to your cluster. This parameter is not base64-encoded.

You will also need to add your Virtru-provided hmac tokens to `values.yaml`, as well as your own SSL certificate and private key.