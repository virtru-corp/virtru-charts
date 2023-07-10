{{- define "sql.audit.script" -}}
-- audit DB
CREATE ROLE audit_manager WITH LOGIN PASSWORD '{{ .Values.secrets.audit.dbPassword }}';
CREATE DATABASE audit_database WITH OWNER audit_manager;
{{- end -}}