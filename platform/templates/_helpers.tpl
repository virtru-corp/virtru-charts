
{{/*
Generate certificates for private docker registry
Note tls.key is indented on purpose
*/}}
{{- define "registry.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "common.lib.chart" . ) .Release.Namespace ) ( printf "%s.%s.svc" (include "common.lib.chart" . ) .Release.Namespace ) -}}
{{- $ca := genCA "registry-ca" 365 -}}
{{- $cert := genSignedCert ( include "common.lib.chart" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
  tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Create OIDC External Url
*/}}
{{- define "platform.oidc.externalUrl" }}
{{- if .Values.global.opentdf.common.oidcUrlPath }}
{{- printf "%s/%s" .Values.global.opentdf.common.oidcExternalBaseUrl .Values.global.opentdf.common.oidcUrlPath }}
{{- else }}
{{- default .Values.global.opentdf.common.oidcExternalBaseUrl }}
{{- end }}
{{- end }}

{{/*
Create OIDC hostname by extracting from the external url base .Values.global.opentdf.common.oidcExternalBaseUrl
*/}}
{{- define "platform.oidc.externalHostname" }}
{{- .Values.global.opentdf.common.oidcExternalBaseUrl | trimPrefix "http://"  | trimPrefix "https://" | trimSuffix "/" }}
{{- end }}


{{/*
Create OIDC Token Url
*/}}
{{- define "platform.oidc.tokenUrl" }}
{{- if .Values.embedded.keycloak }}
{{- printf "http://keycloak-http/auth/realms/%s/protocol/openid-connect/token" .Values.keycloak.realm }}
{{- else }}
{{- printf "%s/realms/%s/protocol/openid-connect/token" ( include "platform.oidc.externalUrl" .subS ) .Values.keycloak.realm }}
{{- end }}
{{- end }}

