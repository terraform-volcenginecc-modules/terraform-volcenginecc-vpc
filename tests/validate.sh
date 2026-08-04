#!/usr/bin/env bash

set -euo pipefail

test_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
module_root="$(cd "$test_root/.." && pwd)"
validation_root="$(mktemp -d)"
validation_module_root="$validation_root/module"

cleanup() {
  if [[ -n "$validation_root" && -d "$validation_root" ]]; then
    rm -rf -- "$validation_root"
  fi
}
trap cleanup EXIT

terraform -chdir="$test_root" fmt -check -recursive

mkdir -p "$validation_module_root"
tar \
  --exclude=".terraform" \
  --exclude=".terraform.lock.hcl" \
  --exclude="*.tfplan" \
  --exclude="*.tfstate" \
  --exclude="*.tfstate.*" \
  -cf - \
  -C "$module_root" . |
  tar -xf - -C "$validation_module_root"

for fixture in lifecycle existing-vpc ip-stack ipv4-gateway; do
  target_dir="$validation_module_root/tests/$fixture"

  terraform -chdir="$target_dir" init -backend=false -input=false >/dev/null
  terraform -chdir="$target_dir" validate

  if [[ "$fixture" == "lifecycle" ]]; then
    for phase in create update; do
      env \
        VOLCENGINE_ACCESS_KEY=static-validation \
        VOLCENGINE_SECRET_KEY=static-validation \
        VOLCENGINE_REGION=cn-beijing \
        terraform -chdir="$target_dir" plan \
        -refresh=false \
        -input=false \
        -lock=false \
        -var="run_id=static-validation" \
        -var="phase=$phase" \
        >/dev/null
      done
  elif [[ "$fixture" == "ip-stack" ]]; then
    for phase in ipv4-only dualstack; do
      env \
        VOLCENGINE_ACCESS_KEY=static-validation \
        VOLCENGINE_SECRET_KEY=static-validation \
        VOLCENGINE_REGION=cn-beijing \
        terraform -chdir="$target_dir" plan \
        -refresh=false \
        -input=false \
        -lock=false \
        -var="run_id=static-validation" \
        -var="phase=$phase" \
        >/dev/null
    done
  elif [[ "$fixture" == "ipv4-gateway" ]]; then
    env \
      VOLCENGINE_ACCESS_KEY=static-validation \
      VOLCENGINE_SECRET_KEY=static-validation \
      VOLCENGINE_REGION=cn-beijing \
      terraform -chdir="$target_dir" plan \
      -refresh=false \
      -input=false \
      -lock=false \
      -var="run_id=static-validation" \
      -var="ipv4_gateway_id=ipv4gw-staticvalidation" \
      >/dev/null
  fi
done

echo "Real-cloud test fixtures passed static validation."
