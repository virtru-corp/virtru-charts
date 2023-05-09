{{- define "shp.configsvc.auth.issuer" -}}
{{ printf "%s/realms/%s" ( include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "shp.configsvc.auth.jwksUri" -}}
{{ printf "%s/protocol/openid-connect/certs" (include "shp.configsvc.auth.issuer" . ) }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "shp.configsvc.auth.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.configuration.fullnameOverride }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
