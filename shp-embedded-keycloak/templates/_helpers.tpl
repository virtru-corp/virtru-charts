{{/*
Create OIDC External Url
*/}}
{{- define "shp.embedded.keycloak.oidc.externalUrl" }}
{{- if .Values.global.opentdf.common.oidcUrlPath }}
{{- printf "%s/%s" .Values.global.opentdf.common.oidcExternalBaseUrl .Values.global.opentdf.common.oidcUrlPath }}
{{- else }}
{{- default .Values.global.opentdf.common.oidcExternalBaseUrl }}
{{- end }}
{{- end }}