#1 /usr/bin/env sh

set -e

# wait for podinfo
kubectl rollout status deployment/podinfo --timeout=3m

# smoke test the service endpoint using the in-cluster DNS name
kubectl run podinfo-smoke --rm -i --restart=Never --image=curlimages/curl -- \
  sh -c 'curl -sf podinfo:9898/readyz'
