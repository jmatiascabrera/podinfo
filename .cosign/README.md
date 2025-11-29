# Podinfo signed releases

Podinfo release assets (container image and Flux artifact)
are published to GitHub Container Registry and are signed with
[Cosign v2](https://github.com/sigstore/cosign) keyless & GitHub Actions OIDC.

## Verify podinfo with cosign

Install the [cosign](https://github.com/sigstore/cosign) CLI:

```sh
brew install sigstore/tap/cosign
```

### Container image

Verify the podinfo container image hosted on GHCR:

```sh
cosign verify ghcr.io/stefanprodan/podinfo:6.5.0 \
--certificate-identity-regexp="^https://github.com/stefanprodan/podinfo.*$" \
--certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

Verify the podinfo container image hosted on Docker Hub:

```sh
cosign verify docker.io/stefanprodan/podinfo:6.5.0 \
--certificate-identity-regexp="^https://github.com/stefanprodan/podinfo.*$" \
--certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

### Flux artifact

Verify the podinfo [Flux](https://fluxcd.io) artifact hosted on GHCR:

```sh
cosign verify ghcr.io/stefanprodan/manifests/podinfo:6.5.0 \
--certificate-identity-regexp="^https://github.com/stefanprodan/podinfo.*$" \
--certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

