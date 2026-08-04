#!/usr/bin/env bash

if ! (return 0 2>/dev/null); then
  echo "This file must be sourced so the Provider environment variables remain available:" >&2
  echo "  source ./load-current-profile.sh" >&2
  exit 1
fi

xtrace_was_enabled=false
case "$-" in
  *x*)
    xtrace_was_enabled=true
    set +x
    ;;
esac

cleanup_loader() {
  unset access_key secret_key region current_profile config_path
}

config_path="${VOLCENGINE_CONFIG_FILE:-${HOME}/.volcengine/config.json}"

if [[ ! -f "$config_path" ]]; then
  echo "Volcengine config file not found: $config_path" >&2
  cleanup_loader
  unset -f cleanup_loader
  [[ "$xtrace_was_enabled" == "true" ]] && set -x
  unset xtrace_was_enabled
  return 1
fi

if ! current_profile="$(jq -er '.current' "$config_path")"; then
  echo "Unable to read the current profile from: $config_path" >&2
  cleanup_loader
  unset -f cleanup_loader
  [[ "$xtrace_was_enabled" == "true" ]] && set -x
  unset xtrace_was_enabled
  return 1
fi

if ! access_key="$(jq -er --arg profile "$current_profile" '.profiles[$profile]["access-key"]' "$config_path")" ||
  ! secret_key="$(jq -er --arg profile "$current_profile" '.profiles[$profile]["secret-key"]' "$config_path")" ||
  ! region="$(jq -er --arg profile "$current_profile" '.profiles[$profile].region' "$config_path")"; then
  echo "Unable to read credentials or region for the current Volcengine profile." >&2
  cleanup_loader
  unset -f cleanup_loader
  [[ "$xtrace_was_enabled" == "true" ]] && set -x
  unset xtrace_was_enabled
  return 1
fi

if [[ -z "$access_key" || -z "$secret_key" || -z "$region" ]]; then
  echo "The current Volcengine profile is missing an access key, secret key, or region." >&2
  cleanup_loader
  unset -f cleanup_loader
  [[ "$xtrace_was_enabled" == "true" ]] && set -x
  unset xtrace_was_enabled
  return 1
fi

export VOLCENGINE_ACCESS_KEY="$access_key"
export VOLCENGINE_SECRET_KEY="$secret_key"
export VOLCENGINE_REGION="$region"

printf 'Loaded Volcengine profile: %s\n' "$current_profile"
printf 'Region: %s\n' "$VOLCENGINE_REGION"

cleanup_loader
unset -f cleanup_loader
[[ "$xtrace_was_enabled" == "true" ]] && set -x
unset xtrace_was_enabled
