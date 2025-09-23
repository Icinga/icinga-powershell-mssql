# Invoke-IcingaCheckMSSQLPerfCounter

## Description

Checks specified Performance Counter inside the MSSQL database by fetching
counters by a given name and compares them to input thresholds

Checks specified Performance Counter inside the MSSQL database by fetching
counters by a given name and compares them to input thresholds
More Information on https://github.com/Icinga/icinga-powershell-mssql

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | The warning threshold of the Performance Counter return values |
| Critical | Object | false |  | The critical threshold of the Performance Counter return values |
| PerformanceCounter | Array | false | @() | List of Performance Counters specified by their full path (example '\SQLServer:Buffer Manager\Buffer cache hit ratio')<br /> to fetch information for |
| SqlUsername | String | false |  | The username for connecting to the MSSQL database |
| SqlPassword | SecureString | false |  | The password for connecting to the MSSQL database as secure string |
| SqlHost | String | false | localhost | The IP address or FQDN to the MSSQL server to connect to |
| SqlPort | Int32 | false | 1433 | The port of the MSSQL server/instance to connect to with the provided credentials |
| SqlDatabase | String | false |  | The name of a specific database to connect to. Leave empty to connect "globally" |
| IntegratedSecurity | SwitchParameter | false | False | Allows this plugin to use the credentials of the current PowerShell session inherited by<br /> the user the PowerShell is running with. If this is set and the user the PowerShell is<br /> running with can access to the MSSQL database you will not require to provide username<br /> and password |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMSSQLPerfCounter -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -PerformanceCounter '\%:Buffer Manager%\Buffer cache hit ratio', '\%:Latches%\Average Latch Wait Time (ms)' -Verbosity 3;
```

### Example Output 1

```powershell
[OK] MSSQL Performance Counter (MSSQLSERVER) (All must be [OK])
\_ [OK] SQLServer:Buffer Manager (All must be [OK])
    \_ [OK] SQLServer:Buffer Manager: 62
\_ [OK] SQLServer:Latches (All must be [OK])
    \_ [OK] SQLServer:Latches: 597
| sqlserverbuffermanager::ifw_mssqlperfcounter::buffercachehitratio=62;;;; sqlserverlatches::ifw_mssqlperfcounter::averagelatchwaittimems=597;;;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckMSSQLPerfCounter -IntegratedSecurity -SqlHost 'example.com' -PerformanceCounter '\%:Buffer Manager%\Buffer cache hit ratio', '\%:Latches%\Average Latch Wait Time (ms)' -Verbosity 3;
```

### Example Output 2

```powershell
[OK] MSSQL Performance Counter (MSSQLSERVER) (All must be [OK])
\_ [OK] SQLServer:Buffer Manager (All must be [OK])
    \_ [OK] SQLServer:Buffer Manager: 62
\_ [OK] SQLServer:Latches (All must be [OK])
    \_ [OK] SQLServer:Latches: 597
| sqlserverbuffermanager::ifw_mssqlperfcounter::buffercachehitratio=62;;;; sqlserverlatches::ifw_mssqlperfcounter::averagelatchwaittimems=597;;;;    
```


