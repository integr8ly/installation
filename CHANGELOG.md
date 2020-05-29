# Changelog
All notable changes to this project will be documented in this file.

Some of these changes may include:
- Changes to number of pods running in any given namespace
- New namespaces added or namespaces removed (components added/components removed)
- New monitoring or alerting changes and link to relevant SOP
- Any networking-related changes (e.g. not needing the extra router shard in 1.5)
- Any changes to roles, users, or other permissions.
- Any changes to backups, or to restore procedures.
- Changes in resource requirements (num pods, ram, cpu, containers)

## Unreleased

### Added

### Changed
* [INTLY-3623] - Refactor of inventories and associated group_vars to support POC, OSD and PDS environments
* [INTLY-3847] - Update Alert Manager emails to include cluster URL and timestamps
* [INTLY-5856] - Improve resiliency of sso/user-sso w/ 2nd replica and qos of postgres pods up from BestEffort to Burstable
* [INTLY-2544] - allow customer-admins view 3Scale logs in Kibana
* [INTLY-6525] - Updated heimdall version to release-1.0.1
* [INTLY-6512] - Heimdall installed by default
* [INTLY-7813] - New Alerts for Node CPU & Memory utilisation

### Removed

### Bug Fixes
