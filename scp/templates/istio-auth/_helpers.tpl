{{- define "shp.auth.issuer" -}}
{{ printf "%s/realms/%s" ( include "shp.oidc.externalUrl" . ) ( .Values.keycloak.realm | default "tdf" ) }}
{{- end -}}

{{- define "shp.auth.jwksUri" -}}
{{ printf "%s/protocol/openid-connect/certs" (include "shp.auth.issuer" . ) }}
{{- end -}}


