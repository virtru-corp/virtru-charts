{{- define "platform.auth.issuer" -}}
{{- printf "%s/realms/%s" ( include "platform.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "platform.auth.jwksUri" -}}
{{- if .Values.istioAuth.internalJWTURL -}}
{{ printf "http://keycloak-http.%s.svc.cluster.local/auth/realms/%s/protocol/openid-connect/certs" .Release.Namespace ( .Values.keycloak.realm | default "tdf" ) }}
{{- else -}}
{{ printf "%s/protocol/openid-connect/certs" (include "platform.auth.issuer" . ) }}
{{- end -}}
{{- end -}}


