# CKS external-secret regression tests

Run `./tests/cks-external-secret/run.sh` from the repository root. Requires Git, Helm, and Go with toolchain downloads enabled.

The runner uses the exact External Secrets v2.5.0 source deployed in mgmt-prod. It executes the Helm-rendered literal with ESO's `Execute` function and `KeysAndValues` scope, using synthetic data only. Tests reproduce the original `map[string]string`/Sprig `omit` failure and cover present, empty, absent, and multiple excluded keys; preservation of multiline and string-like values; and unchanged behavior without exclusions.
