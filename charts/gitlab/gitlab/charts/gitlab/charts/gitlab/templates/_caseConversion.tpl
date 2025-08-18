{{- define "gitlab.keysToSnakeCase" -}}
{{- $ctx := . }}
{{- if kindIs "slice" $ctx -}}
{{-   range $item := $ctx -}}
{{-     include "gitlab.keysToSnakeCase" $item -}}
{{-   end -}}
{{- end -}}
{{- if kindIs "map" $ctx -}}
{{/*  use deepCopy to prevent reference linking */}}
{{-   $copy := deepCopy $ctx -}}
{{-   $keys := keys $ctx -}}
{{-   range $key := $keys -}}
{{/*    order matters, unset first */}}
{{-     $_ := unset $ctx $key -}}
{{/*    recurse if the value of the current key is another map or slice */}}
{{-     if (kindIs "map" (index $copy $key)) -}}
{{-       include "gitlab.keysToSnakeCase" (index $copy $key) -}}
{{-     else -}}
{{/*      we need to iterate over the slice and recurse on each value if it's a map */}}
{{-       if (kindIs "slice" (index $copy $key)) -}}
{{-         range $el := (index $copy $key) -}}
{{-           include "gitlab.keysToSnakeCase" $el -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{/*    do not overwrite an existing key */}}
{{-     if not (hasKey $ctx (snakecase $key) ) -}}
{{-       $_ := set $ctx (snakecase $key) (get $copy $key) -}}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.keysToCamelCase" -}}
{{- $ctx := . }}
{{- if kindIs "slice" $ctx -}}
{{-   range $item := $ctx -}}
{{-     include "gitlab.keysToCamelCase" $item -}}
{{-   end -}}
{{- end -}}
{{- if kindIs "map" $ctx -}}
{{/*  use deepCopy to prevent reference linking */}}
{{-   $copy := deepCopy $ctx -}}
{{-   $keys := keys $ctx -}}
{{-   range $key := $keys -}}
{{/*    order matters, unset first */}}
{{-     $_ := unset $ctx $key -}}
{{/*    recurse if the value of the current key is another map or slice */}}
{{-     if (kindIs "map" (index $copy $key)) -}}
{{-       include "gitlab.keysToCamelCase" (index $copy $key) -}}
{{-     else -}}
{{/*      we need to iterate over the slice and recurse on each value if it's a map */}}
{{-       if (kindIs "slice" (index $copy $key)) -}}
{{-         range $el := (index $copy $key) -}}
{{-           include "gitlab.keysToCamelCase" $el -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{/*    do not overwrite an existing key */}}
{{-     if not (hasKey $ctx (camelcase $key) ) -}}
{{-       $_ := set $ctx (camelcase $key) (get $copy $key) -}}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
