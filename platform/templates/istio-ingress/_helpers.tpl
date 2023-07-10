{{/*
Platform Ingress hostname
for now taken from global otdf value.
*/}}
{{- define "platform.ingressHostname" -}}
{{- .Values.global.opentdf.common.ingress.hostname | trunc 63 | trimSuffix "-" }}
{{- end }}

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

{{/*
Generate certificates for gateway tls
Note tls.key is indented on purpose
*/}}
{{- define "platform.ingress.gen-certs" -}}
{{- $altNames := list ( printf "%s" .Values.global.opentdf.common.ingress.hostname ) -}}
{{- $ca := genCA "platform-ca" 365 -}}
{{- $cert := genSignedCert .Values.global.opentdf.common.ingress.hostname nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
  tls.key: {{ $cert.Key | b64enc }}
{{- end -}}