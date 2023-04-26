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

{{/*
SCP Ingress gateway name
*/}}
{{- define "scp.ingress.tlsCredName" -}}
{{- if .Values.ingress.tls }}
{{- if .Values.ingress.existingSecret }}
{{- printf "%s" .Values.ingress.existingSecret }}
{{- else }}
{{- printf "%s-gateway-tls" ( include "common.lib.name" . ) }}
{{- end }}
{{- else }}
{{ print "" }}
{{- end }}
{{- end -}}


{{/*
Generate certificates for gateway tls
Note tls.key is indented on purpose
*/}}
{{- define "scp.ingress.gen-certs" -}}
{{- $altNames := list ( printf "%s" .Values.global.opentdf.common.ingress.hostname ) -}}
{{- $ca := genCA "registry-ca" 365 -}}
{{- $cert := genSignedCert ( include "common.lib.chart" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
  tls.key: {{ $cert.Key | b64enc }}
{{- end -}}