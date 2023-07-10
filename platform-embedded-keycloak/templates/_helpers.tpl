{{/*
Create OIDC External Url
*/}}
{{- define "platform.embedded.keycloak.oidc.externalUrl" }}
{{- if .Values.global.opentdf.common.oidcUrlPath }}
{{- printf "%s/%s" .Values.global.opentdf.common.oidcExternalBaseUrl .Values.global.opentdf.common.oidcUrlPath }}
{{- else }}
{{- default .Values.global.opentdf.common.oidcExternalBaseUrl }}
{{- end }}
{{- end }}


{{/*
Create Extra Volumes
*/}}
{{- define "platform.embedded.keycloak.extraVolumes" -}}
- name: custom-entrypoint
  configMap:
    name: {{ .Values.fullnameOverride }}-custom-entrypoint
    defaultMode: 511
{{ if .Values.trustedCertSecret -}}
- name: x509
  secret:
    secretName: {{ .Values.trustedCertSecret }}
{{- end -}}
{{- end }}

{{/*
Create Extra Volumes Mounts
*/}}
{{- define "platform.embedded.keycloak.extraVolumeMounts" -}}
- name: custom-entrypoint
  mountPath: /opt/keycloak/custom_bin/kc_custom_entrypoint.sh
  subPath: kc_custom_entrypoint.sh
{{ if .Values.trustedCertSecret -}}
- name: x509
  mountPath: /etc/x509/https
{{- end -}}
{{- end }}

{{/*
Create Extra Env From
*/}}
{{- define "platform.embedded.keycloak.extraEnvFrom" -}}
- secretRef:
    name: {{ .Values.fullnameOverride }}-extraenv
- configMapRef:
    name: {{ .Values.fullnameOverride }}-cabundles
{{- end }}


{{- define "platform.embedded.keycloak.extraEnv" -}}
- name: CLAIMS_URL
  value: http://entitlement-pdp:3355/entitlements
- name: JAVA_OPTS_APPEND
  value: -Djgroups.dns.query={{ include "keycloak.fullname" . }}-headless
- name: KC_DB
  value: postgres
- name: KC_DB_URL_PORT
  value: "5432"
- name: KC_LOG_LEVEL
  value: INFO
- name: KC_HOSTNAME_STRICT
  value: "false"
- name: KC_HOSTNAME_STRICT_BACKCHANNEL
  value: "false"
- name: KC_HOSTNAME_STRICT_HTTPS
  value: "false"
- name: KC_HOSTNAME_URL
  value: {{ ( include "platform.embedded.keycloak.oidc.externalUrl" . ) | quote }}
- name: KC_HOSTNAME_ADMIN_URL
  value: {{ ( include "platform.embedded.keycloak.oidc.externalUrl" . ) | quote }}
- name: KC_HTTP_ENABLED
  value: "true"
- name: KC_FEATURES
  value: "preview,token-exchange"
{{- end }}