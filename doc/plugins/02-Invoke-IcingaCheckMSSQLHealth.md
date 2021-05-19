
# Invoke-IcingaCheckMSSQLHealth

## Description

Checks if MSSQL services for a specific instance are running and if the connection
to a database instance can be established

The plugin will return CRITICAL in case MSSQL instance services are not running and
WARNING or CRITICAL if the connection time is not matching your set thresholds
More Information on https://github.com/Icinga/icinga-powershell-plugins

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Warning | Object | false |  | The warning threshold for the connection time to the MSSQL database as time interval (ms, s, h, m) |
| Critical | Object | false |  | The warning threshold for the connection time to the MSSQL database as time interval (ms, s, h, m) |
| Instance | String | false |  | The name of the database instance to check the service state for. Can either the MSSQL$DB1 or simply DB1 for example |
| SqlUsername | String | false |  | The username for connecting to the MSSQL database |
| SqlPassword | SecureString | false |  | The password for connecting to the MSSQL database as secure string |
| SqlHost | String | false | localhost | The IP address or FQDN to the MSSQL server to connect to |
| SqlPort | Int32 | false | 1433 | The port of the MSSQL server/instance to connect to with the provided credentials |
| SqlDatabase | String | false |  | The name of a specific database to connect to. Leave empty to connect "globally" |
| IntegratedSecurity | SwitchParameter | false | False | Allows this plugin to use the credentials of the current PowerShell session inherited by the user the PowerShell is running with. If this is set and the user the PowerShell is running with can access to the MSSQL database you will not require to provide username and password |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Int32 | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMSSQLHealth -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost example.com;
```

### Example Output 1

```powershell
[OK] Check package "MSSQL Health"| 'connection_time'=19ms;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckMSSQLHealth -IntegratedSecurity -SqlHost example.com;
```

### Example Output 2

```powershell
[OK] Check package "MSSQL Health"| 'connection_time'=26ms;;
```
