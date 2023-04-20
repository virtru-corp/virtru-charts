{{- define "sql.keycloak.script" -}}
-- Keycloak DB
CREATE ROLE keycloak_manager WITH LOGIN PASSWORD '{{ .Values.secrets.postgres.dbPassword }}';
CREATE DATABASE keycloak_database WITH OWNER keycloak_manager;
{{- end -}}