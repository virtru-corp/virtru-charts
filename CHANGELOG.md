## Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.2.4](https://github.com/virtru-corp/virtru-charts/pull/38/files)
- SUPPORT-1291 ([#38](https://github.com/virtru-corp/virtru-charts/commit/0a91595608c582cfe989b233dd77073386ca2862))
  - Update Gateway version number
  - Remove duplicate labels
## [1.2.3](https://github.com/virtru-corp/virtru-charts/compare/1.2.2...1.2.3)
- CD-897 ([#37](https://github.com/virtru-corp/virtru-charts/pull/37)): _patch_
  - Update workloads to be type `StatefulSet` instead of `Deployment` to accommodate horizontal scaling
  - Add volumeClaimTemplates to `standard StorageClass`

## [1.2.2](https://github.com/virtru-corp/virtru-charts/compare/1.2.1...1.2.2)
- CD-885 ([#35](https://github.com/virtru-corp/virtru-charts/pull/35))([#36](https://github.com/virtru-corp/virtru-charts/pull/36)): _patch_
  - Enable DKIM signing for Gateway chart
- CD-888 ([#36](https://github.com/virtru-corp/virtru-charts/pull/36)): _patch_
  - Set up configmaps to have a base template for generic values and mode-specific config map templates for mode-specific values

## [1.2.1](https://github.com/virtru-corp/virtru-charts/compare/1.2.0...1.2.1)
- CD-786 ([#33](https://github.com/virtru-corp/virtru-charts/pull/33)): _patch_
  - Secrets in values.yaml
  - Iterate through multiple keys for secret creation in CKS keys
  - Readme updates
- CD-786 ([#34](https://github.com/virtru-corp/virtru-charts/pull/34)): _patch_
  - Update comments in `values.yaml`
## [1.2.0](https://github.com/virtru-corp/virtru-charts/compare/1.1.0...1.2.0)
- CD-786 ([#26](https://github.com/virtru-corp/virtru-charts/pull/26)): _minor_
  - Add Gateway charts, updates for CSE and CKS charts

## [1.1.0](https://github.com/virtru-corp/virtru-charts/compare/1.0.0...1.1.0)
- SRE-2913 ([#27](https://github.com/virtru-corp/virtru-charts/pull/27)): _minor_
  - Fix defaultMode for cse-ssl volume
  - CSE version bump

## [1.0.0](https://github.com/virtru-corp/virtru-charts/compare/1.0.0)
- CORE-3558 ([#13](https://github.com/virtru-corp/virtru-charts/pull/13)): _patch_
  - Fix ingress naming for CSE
  - Add ability to disable connection tests for CSE and CKS
  - Add liveness probe for CSE
  - Add changelog
