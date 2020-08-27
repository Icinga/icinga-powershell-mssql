
# Invoke-IcingaCheckMSSQLPerfCounter

## Description

Checks specified Performance Counter inside the MSSQL database by fetching
counters by a given name and compares them to input thresholds

Checks specified Performance Counter inside the MSSQL database by fetching
counters by a given name and compares them to input thresholds
More Information on https://github.com/Icinga/icinga-powershell-mssql

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | The warning threshold of the Performance Counter return values |
| Critical | Object | false |  | The critical threshold of the Performance Counter return values |
| PerformanceCounter | Array | false | @() | List of Performance Counters specified by their full path (example '\SQLServer:Buffer Manager\Buffer cache hit ratio') to fetch information for |
| SqlUsername | String | false |  | The username for connecting to the MSSQL database |
| SqlPassword | SecureString | false |  | The password for connecting to the MSSQL database as secure string |
| SqlHost | String | false | localhost | The IP address or FQDN to the MSSQL server to connect to |
| SqlPort | Int32 | false | 1433 | The port of the MSSQL server/instance to connect to with the provided credentials |
| SqlDatabase | String | false |  | The name of a specific database to connect to. Leave empty to connect "globally" |
| IntegratedSecurity | SwitchParameter | false | False | Allows this plugin to use the credentials of the current PowerShell session inherited by the user the PowerShell is running with. If this is set and the user the PowerShell is running with can access to the MSSQL database you will not require to provide username and password |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMSSQLHealth -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
```

### Example Output 1

```powershell
[OK] Check package "MSSQL Performance Counter"| 'sqlserverbuffer_manager'=22;; 'sqlserverlatches'=384199;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckMSSQLHealth -IntegratedSecurity -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
```

### Example Output 2

```powershell
[OK] Check package "MSSQL Performance Counter"| 'sqlserverbuffer_manager'=24;; 'sqlserverlatches'=387257;;
```
