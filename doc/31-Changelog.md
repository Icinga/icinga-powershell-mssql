# Icinga PowerShell MSSQL CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](https://icinga.com/docs/windows/latest/mssql/doc/30-Upgrading-Plugins)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-mssql/milestones?state=closed).

## 1.6.0 (tbd)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/8?closed=1)

### Enhancements

## 1.5.1 (tbd)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/9?closed=1)

## Bugfixes

* [#52](https://github.com/Icinga/icinga-powershell-mssql/pull/52) Fixes broken Icinga plain configuration

## 1.5.0 (2023-08-01)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/7?closed=1)

### Enhancements

* [51](https://github.com/Icinga/icinga-powershell-mssql/pull/51) Updates Icinga Director baskets and Icinga plain config for Icinga 2.14

## 1.4.0 (2022-08-30)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/6?closed=1)

### Enhancements

* [42](https://github.com/Icinga/icinga-powershell-mssql/pull/42) Adds option for `IncludeDays` to reduce the amount of backup data generated [ronnybremer]
* [46](https://github.com/Icinga/icinga-powershell-mssql/pull/46) Updates configuration and dependencies for Icinga for Windows v1.10.0
* [47](https://github.com/Icinga/icinga-powershell-mssql/pull/47) Adds new performance data handling for Icinga for Windows v1.10.0 and provides basic Grafana dashboards and Icinga Web integration
* [48](https://github.com/Icinga/icinga-powershell-mssql/pull/48) Improves MSSQL backup plugin by fetching backups more granular by minutes now instead of hours

### Grafana Dashboards

#### New Dashboards

* MSSQL Base
* Windows-MSSQL-Web

#### New Plugin Integrations

* Invoke-IcingaCheckMSSQLBackupStatus
* Invoke-IcingaCheckMSSQLHealth
* Invoke-IcingaCheckMSSQLPerfCounter
* Invoke-IcingaCheckMSSQLResource

## 1.3.0 (2022-05-03)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/5?closed=1)

### Bugfixes

* [34](https://github.com/Icinga/icinga-powershell-mssql/issues/34) Fixes `IncludeDatabase` not being used by `Invoke-IcingaCheckMSSQLBackupStatus`

### Enhancements

* [44](https://github.com/Icinga/icinga-powershell-mssql/pull/44) Adds support for Icinga for Windows v1.9.0 module isolation

## 1.2.0 (2021-06-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/4?closed=1)

### Enhancements

* [31](https://github.com/Icinga/icinga-powershell-mssql/pull/31) Updates plugins and configuration files for Icinga for Windows v1.5.0

### Bugfixes

* [32](https://github.com/Icinga/icinga-powershell-mssql/issues/32) Fixes `MSSQLSERVER` service not being added by default for `Invoke-IcingaCheckMSSQLHealth`

## 1.1.0 (2021-03-02)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/2?closed=1)

### Breaking Changes

MSSQL v1.1.0 ships with new pre-compiled configuration for Icinga for Windows v1.4.0. Please ensure to update your entire environment before updating MSSQL plugins for CheckCommand configuration

### Enhancements

* [#28](https://github.com/Icinga/icinga-powershell-mssql/pull/28) Updates Icinga config and dependency to v1.4.0

## 1.0.1 (2021-02-04)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/3?closed=1)

### Bugfixes

* [27](https://github.com/Icinga/icinga-powershell-mssql/pull/27) Fixes broken Icinga 2 plain conf files

### Enhancements

* [#25](https://github.com/Icinga/icinga-powershell-mssql/pull/25) Adds Icinga 2 and Icinga Director pre-compiled configuration files and updates documentation

## 1.0.0 (2020-10-13)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-mssql/milestone/1?closed=1)

### Notes

* Initial release candidate for the new Icinga PowerShell Plugins
