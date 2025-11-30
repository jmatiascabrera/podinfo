#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <environment> <tag> [image_repo]sd" >&2
  exit 1
fi

env_name="$1"
new_tag="$2"
image_repo="${3:-745892955196.dkr.ecr.us-east-1.amazonaws.com/javier/podinfo}"

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

new_image="${image_repo}:${new_tag}"

sed -i "s#^[[:space:]]*- .*#  - ${new_image}#" "$target_file"

if git diff --quiet -- "$target_file"; then
  echo "No changes required for ${env_name}; file already references ${new_image}."
else
  echo "Updated ${target_file} to ${new_image}."
fi
