# CKS Deployment via Helm

To deploy CKS with Helm, you will first need to create the following secrets:

Create a `secret.yaml` containing the following:

```
---
apiVersion: v1
kind: Secret
metadata:
  name: virtru-keys
type: Opaque
data:
  rsa001.pem: <your private key> 
  rsa001.pub: <your public key>
```

and apply using the command `kubectl apply -n <your namespace> -f secret.yaml`.

Then run the following command to add your Docker login credentials:

```
kubectl create secret docker-registry regcred --docker-username=<your dockerhub username> --docker-password="<your dockerhub password>" --docker-email=<your dockerhub email>
```

You will also need to add your base64-encoded auth token to the `values.yaml` file under `virtruAuth.authTokenJson`.

The auth token and an initial RSA key pair are provisioned by the [CKS setup wizard](https://github.com/virtru/cks-setup-wizard/).

## Minikube

You can easily install CKS in minikube using the default `values.yaml` settings and running `helm install cks cks` from inside the directory holding the helm chart.

Run the commands specified in the command output to set up port fowarding and test that the service is working by running

```
curl http://127.0.0.1:8080/status
```

## GKE

To deploy CKS in GKE, you will need to modify some of the parameters in `values.yaml` to create an `Ingress` resource and deploy the service behind a load balancer.

In particular, you will need to modify `service.type` to be `LoadBalancer` and set `ingress.enabled` to `true`. You will also need to either update the hostname for the ingress to use your domain or omit the host field to wildcard the domain and use the IP Google assigns when it creates the load balancer. See more ingress configuration options in the [kubernetes docs](https://kubernetes.io/docs/concepts/services-networking/ingress/). You should then be able to run `helm install cks cks` to deploy the service.

To verify that the service is up and running, run 

```
curl http://<your load balancer's public ip>/status
```

For Virtru deployments, to further verify functionality, configure SSL in front of the service (e.g. via an HTTPS frontend), and run the following:

```
docker run --rm virtru/cks-tool:v1.1.0 --hostname <your load balancer's public ip> --port 443 --hmac_id <your hmac token id> --hmac_secret <your hmac token secret> -n 1  --validate_crypto
```
