#!/bin/bash

set -euo pipefail

cd "${1:?Usage: custom.sh CHART_DIRECTORY}"

child_chart=charts/llm-d-infra
configmap="$child_chart/templates/gateway-infrastructure/configmap.yaml"
replicas_value='.Values.gateway.gatewayParameters.replicas'

# The Istio branch applies this strategic merge patch to the generated Deployment.
if ! grep -Fq "replicas: {{ $replicas_value | int64 }}" "$configmap"; then
  updated_configmap=$(awk -v value="$replicas_value" '
    /^  deployment: \|$/ {
      deployment = 1
    }
    deployment && /^    spec:$/ {
      print
      print "      {{- if ne " value " nil }}"
      print "      replicas: {{ " value " | int64 }}"
      print "      {{- end }}"
      deployment = 0
      patched++
      next
    }
    { print }
    END { if (patched != 1) exit 1 }
  ' "$configmap")
  printf '%s\n' "$updated_configmap" > "$configmap"
fi

for values_file in values.yaml "$child_chart/values.yaml"; do
  if [[ $(yq eval '(."llm-d-infra" // .).gateway.gatewayParameters | has("replicas")' "$values_file") == true ]]; then
    continue
  fi
  updated_values=$(awk '
    /^[[:space:]]+gatewayParameters:[[:space:]]*$/ {
      indent = substr($0, 1, index($0, "gatewayParameters") - 1) "  "
    }
    { print }
    indent != "" && $0 == (indent "enabled: true") {
      print ""
      print indent "# -- Desired number of replicas for the Istio gateway Deployment. Null uses the Istio default."
      print indent "replicas: null"
      indent = ""
      patched++
    }
    END { if (patched != 1) exit 1 }
  ' "$values_file")
  printf '%s\n' "$updated_values" > "$values_file"
done

for schema_file in values.schema.json "$child_chart/values.schema.json" "$child_chart/values.schema.tmpl.json"; do
  schema_prefix='[]'
  indent=2
  case "$schema_file" in
    values.schema.json)
      schema_prefix='["properties","llm-d-infra"]'
      ;;
    "$child_chart/values.schema.json")
      indent=4
      ;;
  esac
  updated_schema=$(jq --indent "$indent" --argjson prefix "$schema_prefix" '
    ($prefix + ["properties","gateway","properties","gatewayParameters","properties"]) as $path |
    if (getpath($path) | type) != "object" then error("missing gatewayParameters schema") else
      setpath($path + ["replicas"]; {
        description: "Desired number of replicas for the Istio gateway Deployment.",
        type: ["integer", "null"],
        minimum: 0,
        maximum: 2147483647
      }) |
      setpath($path; getpath($path) | to_entries | sort_by(.key) | from_entries)
    end
  ' "$schema_file")
  printf '%s\n' "$updated_schema" > "$schema_file"
done
