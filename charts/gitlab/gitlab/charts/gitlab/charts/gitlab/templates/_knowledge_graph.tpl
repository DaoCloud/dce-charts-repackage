{{/* ######### Knowledge Graph related templates */}}

{{- define "gitlab.appConfig.knowledgeGraph.mountSecrets" -}}
{{- with .Values.global.appConfig.knowledgeGraph -}}
{{- if and .enabled .jwtSecret -}}
# mount secret for knowledge graph
- secret:
    name: {{ .jwtSecret.secret | quote }}
    items:
      - key: {{ default "secret" .jwtSecret.key | quote }}
        path: knowledge_graph/.gitlab_knowledge_graph_secret
{{- end -}}
{{- end -}}
{{- end -}}{{/* "gitlab.appConfig.knowledgeGraph.mountSecrets" */}}

{{- define "gitlab.appConfig.knowledgeGraph" -}}
{{- if .Values.global.appConfig.knowledgeGraph.enabled -}}
knowledge_graph:
  enabled: true
  secret_file: /etc/gitlab/knowledge_graph/.gitlab_knowledge_graph_secret
  grpc_endpoint: {{ .Values.global.appConfig.knowledgeGraph.grpcEndpoint | quote }}
{{- end -}}
{{- end -}}
