{{- define "sql.configuration.script" -}}
\connect tdf_database;
CREATE SCHEMA IF NOT EXISTS scp_configuration;

CREATE TABLE IF NOT EXISTS scp_configuration.configuration
(
    id        VARCHAR PRIMARY KEY,
    bytes     BYTEA NOT NULL,
    modified  VARCHAR NOT NULL
);
-- user
CREATE ROLE scp_configuration_manager WITH LOGIN PASSWORD '{{ .Values.secrets.postgres.dbPassword }}';
GRANT USAGE ON SCHEMA scp_configuration TO scp_configuration_manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA scp_configuration TO scp_configuration_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA scp_configuration TO scp_configuration_manager;
{{- end -}}