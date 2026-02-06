{{/*
Concatenate the full image address
Receives an image object containing registry, repository, and tag fields
Returns format: <registry>/<repository>:<tag>
*/}}
{{- define "llm-d-modelservice.imageAddress" -}}
{{- $registry := .registry | default "docker.io" -}}
{{- $repository := .repository | required "image.repository is required" -}}
{{- $tag := .tag | default "latest" -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end }}