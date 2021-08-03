#!/bin/bash -l

# echo "Hello $1"
# time=$(date)
# echo "::set-output name=time::$time"

#! todo clean up this file

aws eks update-kubeconfig --region us-west-2 --name k8s-mgmt

argo submit -n argo-events ./.argo/workflow.yaml -p gitRepoName=virtru-charts -p chartDirectory=cse --wait --log

argo submit -n argo-events ./.argo/workflow.yaml -p gitRepoName=virtru-charts -p chartDirectory=cks --wait --log
