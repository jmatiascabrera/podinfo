# podinfo

[![e2e](https://github.com/jmatiascabrera/podinfo/workflows/e2e/badge.svg)](https://github.com/jmatiascabrera/podinfo/blob/master/.github/workflows/e2e.yml)
[![test](https://github.com/jmatiascabrera/podinfo/workflows/test/badge.svg)](https://github.com/jmatiascabrera/podinfo/blob/master/.github/workflows/test.yml)
[![cve-scan](https://github.com/jmatiascabrera/podinfo/workflows/cve-scan/badge.svg)](https://github.com/jmatiascabrera/podinfo/blob/master/.github/workflows/cve-scan.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/jmatiascabrera/podinfo)](https://goreportcard.com/report/github.com/jmatiascabrera/podinfo)
Podinfo is a tiny web application made with Go that showcases best practices of running microservices in Kubernetes.
Podinfo is used by CNCF projects like [Flagger](https://github.com/fluxcd/flagger)
for end-to-end testing and workshops.

Specifications:

* Health checks (readiness and liveness)
* Graceful shutdown on interrupt signals
* File watcher for secrets and configmaps
* Instrumented with Prometheus and Open Telemetry
* Structured logging with zap 
* 12-factor app with viper
* Fault injection (random errors and latency)
* Swagger docs
* Kustomize installer
* End-to-End testing with Kubernetes Kind
* Multi-arch container image with Docker buildx and GitHub Actions
* Container image signing with Sigstore cosign
* SBOMs and SLSA Provenance embedded in the container image
* CVE scanning with govulncheck

Web API:

* `GET /` prints runtime information
* `GET /version` prints podinfo version and git commit hash 
* `GET /metrics` return HTTP requests duration and Go runtime metrics
* `GET /healthz` used by Kubernetes liveness probe
* `GET /readyz` used by Kubernetes readiness probe
* `POST /readyz/enable` signals the Kubernetes LB that this instance is ready to receive traffic
* `POST /readyz/disable` signals the Kubernetes LB to stop sending requests to this instance
* `GET /status/{code}` returns the status code
* `GET /panic` crashes the process with exit code 255
* `POST /echo` forwards the call to the backend service and echos the posted content 
* `GET /env` returns the environment variables as a JSON array
* `GET /headers` returns a JSON with the request HTTP headers
* `GET /delay/{seconds}` waits for the specified period
* `POST /token` issues a JWT token valid for one minute `JWT=$(curl -sd 'anon' podinfo:9898/token | jq -r .token)`
* `GET /token/validate` validates the JWT token `curl -H "Authorization: Bearer $JWT" podinfo:9898/token/validate`
* `GET /configs` returns a JSON with configmaps and/or secrets mounted in the `config` volume
* `POST/PUT /cache/{key}` saves the posted content to Redis
* `GET /cache/{key}` returns the content from Redis if the key exists
* `DELETE /cache/{key}` deletes the key from Redis if exists
* `POST /store` writes the posted content to disk at /data/hash and returns the SHA1 hash of the content
* `GET /store/{hash}` returns the content of the file /data/hash if exists
* `GET /ws/echo` echos content via websockets `podcli ws ws://localhost:9898/ws/echo`
* `GET /chunked/{seconds}` uses `transfer-encoding` type `chunked` to give a partial response and then waits for the specified period
* `GET /swagger.json` returns the API Swagger docs, used for Linkerd service profiling and Gloo routes discovery

gRPC API:

* `/grpc.health.v1.Health/Check` health checking
* `/grpc.EchoService/Echo` echos the received content
* `/grpc.VersionService/Version` returns podinfo version and Git commit hash
* `/grpc.DelayService/Delay` returns a successful response after the given seconds in the body of gRPC request
* `/grpc.EnvService/Env` returns environment variables as a JSON array
* `/grpc.HeaderService/Header` returns the headers present in the gRPC request. Any custom header can also be given as a part of request and that can be returned using this API
* `/grpc.InfoService/Info` returns the runtime information
* `/grpc.PanicService/Panic` crashes the process with gRPC status code as '1 CANCELLED'
* `/grpc.StatusService/Status` returns the gRPC Status code given in the request body
* `/grpc.TokenService/TokenGenerate` issues a JWT token valid for one minute
* `/grpc.TokenService/TokenValidate` validates the JWT token

Web UI:

![podinfo-ui](https://raw.githubusercontent.com/jmatiascabrera/podinfo/gh-pages/screens/podinfo-ui-v3.png)

To access the Swagger UI open `<podinfo-host>/swagger/index.html` in a browser.

### Guides

* [Getting started with Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/)
* [Progressive Deliver with Flagger and Linkerd](https://docs.flagger.app/tutorials/linkerd-progressive-delivery)
* [Automated canary deployments with Kubernetes Gateway API](https://docs.flagger.app/tutorials/gatewayapi-progressive-delivery)

### Install

To install Podinfo on Kubernetes the minimum required version is **Kubernetes v1.23**.

#### Kustomize

```bash
kubectl apply -k github.com/jmatiascabrera/podinfo//kustomize
```

#### Docker

```bash
docker run -dp 9898:9898 745892955196.dkr.ecr.us-east-1.amazonaws.com/javier/podinfo
```

### Continuous Delivery

In order to install podinfo on a Kubernetes cluster and keep it up to date with the latest
release in an automated manner, you can use [Argo CD](https://argo-cd.readthedocs.io/en/stable/).

Install the Argo CD CLI on MacOS using Homebrew:

```sh
brew install argocd
```

Deploy Argo CD to your cluster and expose the API server (see the [Argo CD getting started guide](https://argo-cd.readthedocs.io/en/stable/getting_started/) for options).
Once the API server is reachable, create an application that tracks the Kustomize manifests in this repository:

```sh
argocd app create podinfo \
  --repo https://github.com/jmatiascabrera/podinfo \
  --path kustomize \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated

argocd app sync podinfo
```

With automated sync enabled, Argo CD will upgrade the deployment whenever the manifests in this repository change. For multi-environment setups, point separate Argo CD Applications at the overlays under `kustomize/overlays/`.
