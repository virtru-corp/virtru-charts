#!/bin/bash -l

# echo "Hello $1"
# time=$(date)
# echo "::set-output name=time::$time"

#! todo clean up this file

aws eks update-kubeconfig --region us-west-2 --name k8s-mgmt

argo submit -n argo-events ./.argo/workflow.yaml -p gitRepoName=virtru-charts -p chartDirectory=cse -p buildImage=833190184321.dkr.ecr.us-west-2.amazonaws.com/virtru-builder:1.0.16 --wait --log

argo submit -n argo-events ./.argo/workflow.yaml -p gitRepoName=virtru-charts -p chartDirectory=cks -p buildImage=833190184321.dkr.ecr.us-west-2.amazonaws.com/virtru-builder:1.0.16 --wait --log
