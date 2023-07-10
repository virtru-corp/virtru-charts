{{- define "sql.otdf.platform.script" -}}

-- Attributes and entitlements used in the Trusted Data Format
CREATE DATABASE tdf_database;
\connect tdf_database;

-- performs nocase checks
CREATE COLLATION IF NOT EXISTS NOCASE
(
  provider = 'icu',
  locale = 'und-u-ks-level2'
);

CREATE SCHEMA IF NOT EXISTS tdf_attribute;
CREATE TABLE IF NOT EXISTS tdf_attribute.attribute_namespace
(
  id   SERIAL PRIMARY KEY,
  name VARCHAR COLLATE NOCASE NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tdf_attribute.attribute
(
  id           SERIAL PRIMARY KEY,
  namespace_id INTEGER NOT NULL REFERENCES tdf_attribute.attribute_namespace,
  state        VARCHAR NOT NULL,
  rule         VARCHAR NOT NULL,
  name         VARCHAR NOT NULL, -- ??? COLLATE NOCASE
  description  VARCHAR,
  values_array TEXT[],
  group_by_attr INTEGER REFERENCES tdf_attribute.attribute(id),
  group_by_attrval VARCHAR,
  CONSTRAINT no_attrval_without_attrid CHECK(group_by_attrval is not null or group_by_attr is null),
  CONSTRAINT namespase_id_name_unique UNIQUE (namespace_id, name)
);

CREATE SCHEMA IF NOT EXISTS tdf_entitlement;
CREATE TABLE IF NOT EXISTS tdf_entitlement.entity_attribute
(
  id        SERIAL PRIMARY KEY,
  entity_id VARCHAR NOT NULL,
  namespace VARCHAR NOT NULL,
  name      VARCHAR NOT NULL,
  value     VARCHAR NOT NULL
);
CREATE INDEX entity_id_index ON tdf_entitlement.entity_attribute (entity_id);

-- tdf_attribute
CREATE ROLE tdf_attribute_manager WITH LOGIN PASSWORD '{{ .Values.secrets.attributes.dbPassword }}';
GRANT USAGE ON SCHEMA tdf_attribute TO tdf_attribute_manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA tdf_attribute TO tdf_attribute_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA tdf_attribute TO tdf_attribute_manager;

-- tdf_entitlement
CREATE ROLE tdf_entitlement_manager WITH LOGIN PASSWORD '{{ .Values.secrets.entitlements.dbPassword }}';
GRANT USAGE ON SCHEMA tdf_entitlement TO tdf_entitlement_manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA tdf_entitlement TO tdf_entitlement_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA tdf_entitlement TO tdf_entitlement_manager;

-- entitlement-store
CREATE ROLE tdf_entitlement_reader WITH LOGIN PASSWORD '{{ .Values.secrets.entitlementStore.dbPassword }}';
GRANT USAGE ON SCHEMA tdf_entitlement TO tdf_entitlement_reader;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA tdf_entitlement TO tdf_entitlement_reader;
GRANT SELECT ON tdf_entitlement.entity_attribute TO tdf_entitlement_reader;

{{- end -}}

{{- define "sql.otdf.upgrade1.script" -}}
\connect tdf_database;
-- Add groupby
ALTER TABLE tdf_attribute.attribute ADD COLUMN IF NOT EXISTS group_by_attr INTEGER REFERENCES tdf_attribute.attribute(id);
ALTER TABLE tdf_attribute.attribute ADD COLUMN IF NOT EXISTS group_by_attrval VARCHAR;
ALTER TABLE tdf_attribute.attribute DROP CONSTRAINT IF EXISTS no_attrval_without_attrid;
ALTER TABLE tdf_attribute.attribute ADD CONSTRAINT no_attrval_without_attrid CHECK(group_by_attrval is not null or group_by_attr is null)
{{- end -}}
