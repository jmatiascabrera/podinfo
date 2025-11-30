#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <environment> <tag> [image_repo]" >&2
  exit 1
fi

env_name="$1"
new_tag="$2"
image_repo="${3:-745892955196.dkr.ecr.us-east-1.amazonaws.com/javier/podinfo}"
version_file="pkg/version/version.go"

case "$env_name" in
  dev|preq|qa)
    overlay_dir="$env_name"
    file_suffix="$env_name"
    ;;
  prod|production)
    overlay_dir="prod"
    file_suffix="prod"
    ;;
  *)
    echo "Unsupported environment: $env_name" >&2
    exit 1
    ;;
esac

target_file="deploy/overlays/${overlay_dir}/.argocd-source-podinfo-${file_suffix}.yaml"

if [[ ! -f "$target_file" ]]; then
  echo "Target file not found: $target_file" >&2
  exit 1
fi

if [[ ! -f "$version_file" ]]; then
  echo "Version file not found: $version_file" >&2
  exit 1
fi

new_image="${image_repo}:${new_tag}"
new_version="${new_tag#v}"

sed -i "s#^[[:space:]]*- .*#  - ${new_image}#" "$target_file"

sed -i "s/^var VERSION = \".*\"/var VERSION = \"${new_version}\"/" "$version_file"

if git diff --quiet -- "$target_file" "$version_file"; then
  echo "No changes required for ${env_name}; files already reference ${new_image} and version ${new_version}."
else
  echo "Updated ${target_file} to ${new_image}."
  echo "Updated ${version_file} to ${new_version}."
fi
