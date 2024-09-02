{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use common.images.renderPullSecrets instead)
{{ include "common.images.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "common.images.pullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return the proper image name for the `image.registry/repository/tag` style values
eg. trace, eventProxy
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name for the `Image/ImageTag` style values
eg. Master, Agent, Agent.Builder.Base
{{ include "jenkins.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global "root" .Values.image ) }}
*/}}
{{- define "jenkins.images.image" -}}
{{- $registryName := .root.registry -}}
{{- $repositoryName := .imageRoot.Image -}}
{{- $tag := .imageRoot.ImageTag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Shortcut to return image for builders
{{ include "builder.image" ( dict "builder" .Values.Agent.Builder.Base "root" .) }}
*/}}
{{- define "builder.image" }}
  {{- $image := include "jenkins.images.image" (dict "imageRoot" .builder "global" .root.Values.global "root" .root.Values.image) -}}
  {{- $osSuffix := "" -}}
  {{- if .os -}}
    {{- $osSuffix = printf "-%s" .os -}}
  {{- end -}}
  {{- $variant := include "jenkins.agent.variant" .root -}}
  {{- printf "%s%s%s" $image $osSuffix $variant -}}
{{- end -}}
