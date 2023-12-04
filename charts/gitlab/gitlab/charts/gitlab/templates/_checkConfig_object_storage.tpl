{{/*
Ensure consolidate and type-specific object store configuration are not mixed.
*/}}
{{- define "gitlab.checkConfig.objectStorage.consolidatedConfig" -}}
{{-   if $.Values.global.appConfig.object_store.enabled -}}
{{-     $problematicTypes := list -}}
{{-     range $objectTypes := list "artifacts" "lfs" "uploads" "packages" "externalDiffs" "terraformState" "dependencyProxy" -}}
{{-       if hasKey $.Values.global.appConfig . -}}
{{-         $objectProps := index $.Values.global.appConfig . -}}
{{-         if (and (index $objectProps "enabled") (or (not (empty (index $objectProps "connection"))) (empty (index $objectProps "bucket")))) -}}
{{-           $problematicTypes = append $problematicTypes . -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $problematicTypes) -}}
When consolidated object storage is enabled, for each item `bucket` must be specified and the `connection` must be empty. Check the following object storage configuration(s): {{ join "," $problematicTypes }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.objectStorage.consolidatedConfig */}}

{{- define "gitlab.checkConfig.objectStorage.typeSpecificConfig" -}}
{{-   if and (not $.Values.global.minio.enabled) (not $.Values.global.appConfig.object_store.enabled) -}}
{{-     $problematicTypes := list -}}
{{-     range $objectTypes := list "artifacts" "lfs" "uploads" "packages" "externalDiffs" "terraformState" "dependencyProxy" -}}
{{-       if hasKey $.Values.global.appConfig . -}}
{{-         $objectProps := index $.Values.global.appConfig . -}}
{{-         if and (index $objectProps "enabled") (empty (index $objectProps "connection")) -}}
{{-           $problematicTypes = append $problematicTypes . -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $problematicTypes) -}}
When type-specific object storage is enabled the `connection` property can not be empty. Check the following object storage configuration(s): {{ join "," $problematicTypes }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.objectStorage.typeSpecificConfig */}}

{{- define "gitlab.checkConfig.objectStorage.ciSecureFiles" -}}
{{-   if and (not $.Values.global.minio.enabled) ($.Values.global.appConfig.ciSecureFiles.enabled)  -}}
{{-     $objectProps := index $.Values.global.appConfig "ciSecureFiles" -}}
{{-     if or (empty (index $objectProps "connection")) (empty (index $objectProps "bucket")) -}}
ciSecureFiles:
  A valid object storage configuration must be set for ciSecureFiles, the
  `bucket` and `connection` properties can not be empty.
  Consolidated object storage configurations is not supported at this time
  for ciSecureFiles.
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.objectStorage.ciSecureFiles */}}
