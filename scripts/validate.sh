#!/usr/bin/env bash

set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
validation_dir="$(mktemp -d)"
validation_module_dir="$validation_dir/module"
provider_version="${VPC_PROVIDER_VERSION:-latest}"

cleanup() {
  if [[ -n "$validation_dir" && -d "$validation_dir" ]]; then
    rm -rf -- "$validation_dir"
  fi
}
trap cleanup EXIT

terraform -chdir="$module_dir" fmt -check -recursive

mkdir -p "$validation_module_dir"
tar \
  --exclude=".terraform" \
  --exclude=".terraform.lock.hcl" \
  -cf - \
  -C "$module_dir" . |
  tar -xf - -C "$validation_module_dir"

if [[ "$provider_version" != "latest" ]]; then
  PROVIDER_VERSION="$provider_version" perl -0pi -e \
    's#version\s*=\s*">= 0\.0\.60"#version = "=$ENV{PROVIDER_VERSION}"#g' \
    "$validation_module_dir/versions.tf"
fi

echo "Validating Provider version: $provider_version"
terraform -chdir="$validation_module_dir" init -backend=false -input=false >/dev/null
terraform -chdir="$validation_module_dir" validate

provider_env=(
  "VOLCENGINE_ACCESS_KEY=static-validation"
  "VOLCENGINE_SECRET_KEY=static-validation"
  "VOLCENGINE_REGION=cn-beijing"
)

env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=static-validation" \
  -var="cidr_block=10.40.0.0/16" \
  >/dev/null

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-public-cidr" \
  -var="cidr_block=8.8.8.0/24" \
  >/dev/null 2>&1; then
  echo "A public primary CIDR unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-empty-dns" \
  -var="cidr_block=10.40.0.0/16" \
  -var='dns_servers=[]' \
  >/dev/null 2>&1; then
  echo "An empty DNS server set unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-empty-secondary" \
  -var="cidr_block=10.40.0.0/16" \
  -var='secondary_cidr_blocks=[]' \
  >/dev/null 2>&1; then
  echo "An empty secondary CIDR set unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-empty-user-cidr" \
  -var="cidr_block=10.40.0.0/16" \
  -var='user_cidr_blocks=[]' \
  >/dev/null 2>&1; then
  echo "An empty user CIDR set unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-secondary-count" \
  -var="cidr_block=10.40.0.0/16" \
  -var='secondary_cidr_blocks=["10.41.0.0/16","10.42.0.0/16"]' \
  >/dev/null 2>&1; then
  echo "Two secondary CIDRs unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-public-secondary" \
  -var="cidr_block=10.40.0.0/16" \
  -var='secondary_cidr_blocks=["8.8.8.0/24"]' \
  >/dev/null 2>&1; then
  echo "A public secondary CIDR unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-noncanonical-secondary" \
  -var="cidr_block=10.40.0.0/16" \
  -var='secondary_cidr_blocks=["10.41.1.1/16"]' \
  >/dev/null 2>&1; then
  echo "A non-canonical secondary CIDR unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-secondary-range" \
  -var="cidr_block=10.40.0.0/16" \
  -var='secondary_cidr_blocks=["172.20.0.0/16"]' \
  >/dev/null 2>&1; then
  echo "A secondary CIDR from a different private address range unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=invalid-empty-tags" \
  -var="cidr_block=10.40.0.0/16" \
  -var='tags={}' \
  >/dev/null 2>&1; then
  echo "An empty tags map unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="name=http://invalid" \
  -var="cidr_block=10.40.0.0/16" \
  >/dev/null 2>&1; then
  echo "An invalid VPC name unexpectedly passed validation." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  >/dev/null 2>&1; then
  echo "Create mode unexpectedly accepted missing name and cidr_block." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="create_vpc=false" \
  >/dev/null 2>&1; then
  echo "Existing VPC mode unexpectedly accepted a missing existing_vpc_id." >&2
  exit 1
fi

if env "${provider_env[@]}" terraform -chdir="$validation_module_dir" plan \
  -refresh=false \
  -input=false \
  -lock=false \
  -var="create_vpc=false" \
  -var="existing_vpc_id=vpc-static-validation" \
  -var="name=must-be-rejected" \
  >/dev/null 2>&1; then
  echo "A creation input was unexpectedly accepted in existing VPC mode." >&2
  exit 1
fi

examples=(
  "basic"
  "complete"
  "ipv6-dualstack"
  "secondary-cidr-blocks"
  "existing-vpc"
)

for example in "${examples[@]}"; do
  echo "Validating example: $example"
  target_dir="$validation_dir/$example"
  cp -R "$module_dir/examples/$example" "$target_dir"

  MODULE_DIR="$validation_module_dir" perl -0pi -e \
    's#source\s*=\s*"volcengine/vpc/volcenginecc"#source = "$ENV{MODULE_DIR}"#g; s#^\s*version\s*=\s*"~> 1\.0"\s*\n##m' \
    "$target_dir/main.tf"

  if ! grep -Fq "source = \"$validation_module_dir\"" "$target_dir/main.tf"; then
    echo "Failed to rewrite the module source for $example" >&2
    exit 1
  fi

  terraform -chdir="$target_dir" init -backend=false -input=false >/dev/null
  terraform -chdir="$target_dir" validate
done

if grep -R -n -E '(access_key|secret_key)[[:space:]]*=' \
  "$module_dir" \
  --include='*.tf' \
  --exclude-dir='.terraform'; then
  echo "Static credentials must not be committed." >&2
  exit 1
fi

echo "Static validation passed for the root module and all examples."
