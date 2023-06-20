{{/*
Platform Ingress gateway name
*/}}
{{- define "platform.ingress.gateway" -}}
{{- if .Values.ingress.existingGateway -}}
{{ .Values.ingress.existingGateway }}
{{- else -}}
{{  printf "%s-gateway" .Values.ingress.name }}
{{- end }}
{{- end }}

{{/*
Platform Ingress gateway name
*/}}
{{- define "platform.ingress.tlsCredName" -}}
{{- if .Values.ingress.tls.enabled }}
{{- if .Values.ingress.tls.existingSecret }}
{{- printf "%s" .Values.ingress.tls.existingSecret }}
{{- else }}
{{- printf "%s-gateway-tls" ( include "common.lib.name" . ) }}
{{- end }}
{{- else }}
{{ print "" }}
{{- end }}
{{- end -}}

{{- define "platform.ingress.tlsNs" -}}
{{- printf "%s" ( .Values.ingress.istioIngressNS | default "istio-ingress" ) }}
{{- end }}

