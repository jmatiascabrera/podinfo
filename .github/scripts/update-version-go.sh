#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <tag> " >&2
  exit 1
fi

new_tag="$1"
version_file="pkg/version/version.go"

if [[ ! -f "$version_file" ]]; then
  echo "Version file not found: $version_file" >&2
  exit 1
fi

new_version="${new_tag#v}"

sed -i "s/^var VERSION = \".*\"/var VERSION = \"${new_version}\"/" "$version_file"

if git diff --quiet -- "$version_file"; then
  echo "No changes required — files already references version ${new_version}."
else
  echo "Updated ${version_file} to ${new_version}."
fi
