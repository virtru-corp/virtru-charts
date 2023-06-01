
{{/*
Create the name of the service account to use
*/}}
{{- define "taggingpdp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.lib.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


