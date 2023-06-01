# Sample EKS Platform deployment
Requires: AWS CLI + [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
1. Create cluster
Uses the eksctl tool + [eks config file](./sample-eks-config.yaml) to create an eks cluster.  Modify the config cluster/nodegroup names as needed.
```shell
eksctl create cluster -f sample-eks-config.yaml
```
2. Add EKS cluster to kubectl config
- Get cluster info from eksctl: `eksctl get clusters`
```shell
aws eks update-kubeconfig --region us-west-2 --name shpsandbox
```
3. Install Istio: [See istio instructions](./../istio.md)
  
    - ingress gateway with eks config: 
      ```
      helm install istio-ingress istio/gateway -n istio-ingress -f sample-ingress-gateway.yaml
      ```
4. Deploy the Platform
```shell
kubectl config set-context --current --namespace=shp
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

# AWS Load Balancer Controller Instructions:

Needed if strict http2 support is required or to use a more modern AWS LoadBalancer other than the default Classic Load Balancer

Prerequisite: 
- AWS Load Balancer Controller:
  - [Installation](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
  - [Annotation Reference]([https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html])

Example:
- Set Variables
  ```shell
  export accountId=replaceme
  export clustername=replaceme
  ```
1. If IAM policy doesn't exist:
   ```shell
   curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
   ```
   ```shell
   aws iam create-policy \
       --policy-name AWSLoadBalancerControllerIAMPolicy \
       --policy-document file://iam_policy.json
   ```
1. Create Service Account
  - Create service account
     ```
     eksctl create iamserviceaccount \
     --cluster=$clustername \
     --namespace=kube-system \
     --name=aws-load-balancer-controller \
     --role-name AmazonEKSLoadBalancerControllerRole$clustername \
     --attach-policy-arn=arn:aws:iam::$accountId:policy/AWSLoadBalancerControllerIAMPolicy \
     --approve
     ```
1. Install the controller
   ```shell
   helm repo add eks https://aws.github.io/eks-charts
   helm repo update
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     -n kube-system \
     --set clusterName=$clustername \
     --set serviceAccount.create=false \
     --set serviceAccount.name=aws-load-balancer-controller 
   ```
   
   ```shell
   kubectl get deployment -n kube-system aws-load-balancer-controller
   ```

## NLB - Network Load Balancer
- https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html

```shell
helm install istio-ingress istio/gateway -n istio-ingress -f  sample-nlb-ingress-gateway.yaml
```

## ALB - Application Load Balancer
https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

