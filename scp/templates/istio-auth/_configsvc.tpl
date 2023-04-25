{{- define "shp.configsvc.auth.issuer" -}}
{{- if .Values.embedded.keycloak -}}
{{ printf "%s/realms/%s" ( include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- else -}}
{{ printf "%s" ( include "shp.oidc.externalUrl" . ) }}
{{- end -}}
{{- end -}}

{{- define "shp.configsvc.auth.jwksUri" -}}
{{- if .Values.embedded.keycloak -}}
{{ printf "http://keycloak-http.%s.svc.cluster.local/realms/%s/protocol/openid-connect/certs" .Release.Namespace ( .Values.keycloak.realm | default "tdf" ) }}
{{- else -}}
{{ printf "%s" include "shp.oidc.externalUrl" . }}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "shp.configsvc.auth.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.configuration.fullnameOverride }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
