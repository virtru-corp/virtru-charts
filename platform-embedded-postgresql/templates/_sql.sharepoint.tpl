{{- define "sql.sharepoint.script" -}}
-- sharepoint DB
CREATE ROLE sharepoint_manager WITH LOGIN PASSWORD '{{ .Values.secrets.sharepoint.dbPassword }}';
CREATE DATABASE tdf_sharepoint WITH OWNER sharepoint_manager;
{{- end -}}