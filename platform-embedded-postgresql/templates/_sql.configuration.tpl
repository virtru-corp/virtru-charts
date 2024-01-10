{{- define "sql.configuration.script" -}}
CREATE DATABASE config_database;
\connect config_database;
CREATE TABLE IF NOT EXISTS configuration
(
    id        VARCHAR PRIMARY KEY,
    bytes     BYTEA NOT NULL,
    modified  VARCHAR NOT NULL,
    contenttype  VARCHAR NOT NULL
);
-- user
CREATE ROLE configuration_manager WITH LOGIN PASSWORD '{{ .Values.secrets.configuration.dbPassword }}';
GRANT SELECT, INSERT, UPDATE, DELETE ON configuration TO configuration_manager;
CREATE ROLE configuration_reader WITH LOGIN PASSWORD '{{ .Values.secrets.configuration.dbPassword }}';
GRANT SELECT ON configuration TO configuration_reader;
{{- end -}}