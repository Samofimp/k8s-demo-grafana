#!/usr/bin/env bash

# Add needed repos
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ckotzbauer https://ckotzbauer.github.io/helm-charts
helm repo update

# Install nginx ingress controller
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx

# Install kube-prometheus-stack
kubectl create ns monitoring
helm upgrade \
    --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    -n monitoring \
    -f charts/kube-prometheus-stack-values.yaml

# Install cAdvisor
helm upgrade --install cadvisor ckotzbauer/cadvisor -n monitoring \
    -f charts/cadvisor-values.yaml

# Install ArgoCD
kubectl create ns argocd
helm upgrade --install argocd argo/argo-cd -n argocd \
    -f charts/argocd-values.yaml

# Get argocd admin password: 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d'

# Create busybox replicas
helm upgrade --install busybox0 charts/busybox --set replicaCount=2
kubectl create ns test1
helm upgrade --install busybox1 charts/busybox --set replicaCount=2 -n test1
kubectl create ns test2
helm upgrade --install busybox2 charts/busybox --set replicaCount=1 -n test2
kubectl create ns test3
helm upgrade --install busybox3 charts/busybox --set replicaCount=3 -n test3
