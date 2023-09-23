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
Create OIDC External Url
*/}}
{{- define "platform.oidc.externalUrl" }}
{{- if .Values.istioAuth.oidc.oidcUrlPath }}
{{- printf "%s/%s" .Values.istioAuth.oidc.oidcExternalBaseUrl .Values.istioAuth.oidc.oidcUrlPath }}
{{- else }}
{{- default .Values.istioAuth.oidc.oidcExternalBaseUrl }}
{{- end }}
{{- end }}

{{- define "platform.auth.issuer" -}}
{{- printf "%s/realms/%s" ( include "platform.oidc.externalUrl" . ) ( .Values.istioAuth.oidc.keycloakRealm | default "tdf" ) }}
{{- end -}}

{{- define "platform.auth.jwksUri" -}}
{{- if .Values.istioAuth.internalJWTURL -}}
{{ printf "http://keycloak-http.%s.svc.cluster.local/auth/realms/%s/protocol/openid-connect/certs" .Release.Namespace ( .Values.istioAuth.oidc.keycloakRealm | default "tdf" ) }}
{{- else -}}
{{ printf "%s/protocol/openid-connect/certs" (include "platform.auth.issuer" . ) }}
{{- end -}}
{{- end -}}