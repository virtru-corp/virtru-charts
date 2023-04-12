# OpenTDF Configuration Chart

A Helm chart fo OpenTDF Configuration, a service for providing configuration to applications and other services.

This chart requires [Istio](https://istio.io) Service Mesh to be installed.

This chart has a Redis HA dependency from here: https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha

## Database

Use an external PostgreSQL database

```sql
CREATE DATABASE tdf_database;
-- use above database
CREATE SCHEMA IF NOT EXISTS scp_configuration;

CREATE TABLE IF NOT EXISTS scp_configuration.configuration
(
    id        VARCHAR PRIMARY KEY,
    bytes     BYTEA NOT NULL,
    modified  VARCHAR NOT NULL
);
-- user
CREATE ROLE scp_configuration_manager WITH LOGIN PASSWORD 'myPostgresPassword';
GRANT USAGE ON SCHEMA scp_configuration TO scp_configuration_manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA scp_configuration TO scp_configuration_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA scp_configuration TO scp_configuration_manager;
```
