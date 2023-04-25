{{- define "shp.configsvc.auth.issuer" -}}
{{ printf "%s/realms/%s" ( include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "shp.configsvc.auth.jwksUri" -}}
{{- if .Values.keycloak.inCluster -}}
{{ printf "http://keycloak-http.%s.svc.cluster.local/realms/%s/protocol/openid-connect/certs" .Release.Namespace ( .Values.keycloak.realm | default "tdf" ) }}
{{- else -}}
{{ printf "%s/realms/%s/protocol/openid-connect/certs" (include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "shp.configsvc.auth.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.configuration.fullnameOverride }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
