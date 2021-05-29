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

Each plugin ships with a constant Framework argument `-ThresholdInterval`. This can be used to modify the value your thresholds are compared against from the current, fetched value to one collected over time by the Icinga for Windows daemon. In case you [registered service checks](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/) for specific time intervals, you can for example set the argument to `15m` to get the average value of 15m as base for your monitoring values. Please note that in this example, you will require to have collected the `15m` average for `Invoke-IcingaCheckCPU`.

```powershell
icinga> icinga { Invoke-IcingaCheckCPU -Warning 20 -Critical 40 -Core _Total -ThresholdInterval 15m }

[WARNING] CPU Load: [WARNING] Core Total (29,14817700%)
\_ [WARNING] Core Total: 29,14817700% is greater than threshold 20% (15m avg.)
| 'core_total_1'=31.545677%;;;0;100 'core_total_15'=29.148177%;20;40;0;100 'core_total_5'=28.827410%;;;0;100 'core_total_20'=30.032942%;;;0;100 'core_total_3'=27.731669%;;;0;100 'core_total'=33.87817%;;;0;100
```
* [Invoke-IcingaCheckMSSQLBackupStatus](plugins/01-Invoke-IcingaCheckMSSQLBackupStatus.md)
* [Invoke-IcingaCheckMSSQLHealth](plugins/02-Invoke-IcingaCheckMSSQLHealth.md)
* [Invoke-IcingaCheckMSSQLPerfCounter](plugins/03-Invoke-IcingaCheckMSSQLPerfCounter.md)
* [Invoke-IcingaCheckMSSQLResource](plugins/04-Invoke-IcingaCheckMSSQLResource.md)
