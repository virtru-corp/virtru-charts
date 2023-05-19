{{- define "shp.auth.issuer" -}}
{{ printf "%s/realms/%s" ( include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "shp.authinternal.issuer" -}}
{{ printf "http://keycloak-http.%s.cluster.local/auth/realms/%s" ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "shp.auth.jwksUri" -}}
{{ printf "%s/protocol/openid-connect/certs" (include "shp.auth.issuer" . ) }}
{{- end -}}


{{- define "shp.authinternal.jwksUri" -}}
{{ printf "http://keycloak-http.%s.svc.cluster.local/auth/realms/%s/protocol/openid-connect/certs" .Release.Namespace ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

