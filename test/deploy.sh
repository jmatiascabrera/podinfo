#! /usr/bin/env sh

set -e

# deploy the locally built image with kustomize
kubectl apply -k ./kustomize/overlays/test
