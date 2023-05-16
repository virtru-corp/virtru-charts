{{/*
Sharepoint Ingress hostname
for now taken from global otdf value.
*/}}
{{- define "sharepoint.ingressHostname" -}}
{{- (coalesce .Values.ingress.hostname .Values.global.opentdf.common.ingress.hostname ) | default "www.example.org" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Sharepoint Ingress TlS Cred Name
*/}}
{{- define "sharepoint.ingress.tlsCredName" -}}
{{- if .Values.ingress.istio.tls.enabled }}
{{- if .Values.ingress.istio.tls.existingSecret }}
{{- printf "%s" .Values.ingress.istio.tls.existingSecret }}
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
{{- define "sharepoint.ingress.gen-certs" -}}
{{- $altNames := list ( printf "%s" ( include "sharepoint.ingressHostname" . ) ) -}}
{{- $ca := genCA "registry-ca" 365 -}}
{{- $cert := genSignedCert ( include "common.lib.chart" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
  tls.key: {{ $cert.Key | b64enc }}
{{- end -}}