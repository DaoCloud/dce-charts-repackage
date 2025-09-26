#!/bin/bash

set -u

CHECK_INTERVAL="${CHECK_INTERVAL:-10}"

shopt -s nullglob

function unseal() {
  local keys=(/srv/openbao/keys/*)

  if [ ${#keys[@]} -gt 0 ]; then
    echo "Found unseal keys."
    for key in "${keys[@]}"; do
      content="$(cat ${key})"
      bao operator unseal --format=json "${content}"
    done
  else
    # Exit to restart container.
    echo "No keys mounted. Run the init script if not done already."
    echo "Exiting with delay."
    sleep "${CHECK_INTERVAL}"
    exit 1
  fi
}

function quit() {
  exit 0
}

trap quit QUIT TERM

while :
do
  bao status >> /dev/null
  case "$?" in
    0)
      echo "Pod was already unsealed"
      ;;
    1)
      echo "Error checking seal status"
      ;;
    2)
      echo "Attempting to unseal Pod"
      unseal
      ;;
    *)
      echo "Unexpected exit code."
  esac
  sleep "${CHECK_INTERVAL}" &
  wait
done

