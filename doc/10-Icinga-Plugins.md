# Icinga Plugins

Below you will find a documentation for every single available plugin provided by this repository. Most of the plugins allow the usage of default Icinga threshold range handling, which is defined as follows:

| Argument | Throws error on | Ok range                     |
| ---      | ---             | ---                          |
| 20       | < 0 or > 20     | 0 .. 20                      |
| 20:      | < 20            | between 20 .. ∞              |
| ~:20     | > 20            | between -∞ .. 20             |
| 30:40    | < 30 or > 40    | between {30 .. 40}           |
| `@30:40  | ≥ 30 and ≤ 40   | outside -∞ .. 29 and 41 .. ∞ |

Please ensure that you will escape the `@` if you are configuring it on the Icinga side. To do so, you will simply have to write an *\`* before the `@` symbol: \``@`

To test thresholds with different input values, you can use the Framework Cmdlet `Get-IcingaHelpThresholds`.

* [Invoke-IcingaCheckMSSQLBackup](plugins/01-Invoke-IcingaCheckMSSQLBackup.md)
* [Invoke-IcingaCheckMSSQLHealth](plugins/02-Invoke-IcingaCheckMSSQLHealth.md)
* [Invoke-IcingaCheckMSSQLPerfCounter](plugins/03-Invoke-IcingaCheckMSSQLPerfCounter.md)
* [Invoke-IcingaCheckMSSQLResource](plugins/04-Invoke-IcingaCheckMSSQLResource.md)
