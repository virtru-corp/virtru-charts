# Sample EKS SCP deployment
Requires: AWS CLI + [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
1. Create cluster
Uses the eksctl tool + [eks config file](./sample-eks-config.yaml) to create an eks cluster.  Modify the config cluster/nodegroup names as needed.
```shell
eksctl create cluster -f sample-eks-config.yaml
```
2. Add EKS cluster to kubectl config
- Get cluster info from eksctl: `eksctl get clusters`
```shell
aws eks update-kubeconfig --region us-west-2 --name scpsandbox
```
3. Install Istio: [See istio instructions](./../istio.md)
  
    - ingress gateway with eks config: 
      ```
      helm install istio-ingress istio/gateway -n istio-ingress -f sample-ingress-gateway.yaml
      ```
4. Deploy SCP
```shell
kubectl config set-context --current --namespace=scp
```


# Delete cluster
```shell
eksctl delete cluster -f sample-eks-config.yaml
```

If error on delete: "pods are unevictable from node"

[See pod distruption delete](https://veducate.co.uk/delete-eks-fails-cannot-evict-pod/)
```
kubectl get poddisruptionbudget -A
kubectl delete poddisruptionbudget {name} -n {namespace}
```

