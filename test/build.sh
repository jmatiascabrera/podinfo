
#! /usr/bin/env sh

set -e

# build the docker file
GIT_COMMIT=$(git rev-list -1 HEAD) && \
docker buildx build --secret id=corp_ca,src="$HOME"/work/certs/ca_bundle.pem --tag test/podinfo --build-arg "REVISION=${GIT_COMMIT}" .
