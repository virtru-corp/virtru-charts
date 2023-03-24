{{/*
SCP Ingress hostname
for now taken from global otdf value.
*/}}
{{- define "scp.ingressHostname" -}}
{{- .Values.global.opentdf.common.ingress.hostname | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
SCP Ingress gateway name
*/}}
{{- define "scp.ingress.gateway" -}}
{{- if .Values.ingress.existingGateway -}}
{{ .Values.ingress.existingGateway }}
{{- else -}}
{{  printf "%s-gateway" .Values.ingress.name }}
{{- end }}
{{- end }}
