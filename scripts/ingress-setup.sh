#!/bin/bash
set -euax pipefail

mkdir -p /home/ubuntu/k8s
cd /home/ubuntu/k8s

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
sleep 5

sudo chmod 700 get_helm.sh
./get_helm.sh

# add helm repo , so when we install controller using helm , it should be part of helm repo on linux
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm search repo traefik/traefik

cd /home/ubuntu/k8s
helm upgrade --install traefik traefik/traefik \
--namespace klks \
--values traefik-values.yaml