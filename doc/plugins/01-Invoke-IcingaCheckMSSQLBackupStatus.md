# Invoke-IcingaCheckMSSQLBackupStatus

## Description

MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
last backup log age, last backup execution time, database status of a given database

MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
last backup execution time, database status of a given database
More Information on https://github.com/Icinga/icinga-powershell-mssql

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| TotalBackupSizeWarning | Object | false |  | Warning threshold for the total backupsize which represent a count of all backups |
| TotalBackupSizeCritical | Object | false |  | Critical threshold for the total backupsize which represent a count of all backups |
| AvgBackupSizeWarning | Object | false |  | Warning threshold for the average backupsize which represent an average backupsize of all backups |
| AvgBackupSizeCritical | Object | false |  | Critical threshold for the average backupsize which represent an average backupsize of all backups |
| LastBackupLogAgeWarning | Object | false |  | Warning threshold for the last log backup age, which returns the elapsed time since a database was last backupped |
| LastBackupLogAgeCritical | Object | false |  |  |
| LastBackupAgeWarning | Object | false |  | Warning threshold for the last log backup age, which returns the elapsed time since a database was last backupped |
| LastBackupAgeCritical | Object | false |  | Critical threshold for the last backup age, which returns the elapsed time since a database was last backupped |
| ExecutionTimeWarning | Object | false |  | Warning threshold for the execution time, which returns the elapsed time how long the backup process took |
| ExecutionTimeCritical | Object | false |  | Critical threshold for the execution time, which returns the elapsed time how long the backup process took |
| DatabaseStatusWarning | Object | false | Offline | Warning threshold for the database status:<br />     Online<br />     Restoring<br />     Recovering<br />     Recovering_Pending<br />     Suspect<br />     Emergency<br />     Offline<br />     Copying<br />     Offline_Secondary |
| DatabaseStatusCritical | Object | false | Emergency | Critical threshold for the database status:<br />     Online<br />     Restoring<br />     Recovering<br />     Recovering_Pending<br />     Suspect<br />     Emergency<br />     Offline<br />     Copying<br />     Offline_Secondary |
| IncludeDatabase | Array | false | @() | Specifies the database or databases which will be checked. Leave empty to fetch metrics from<br /> all databases on the given system |
| SqlUsername | String | false |  | The username for connecting to the MSSQL database |
| SqlPassword | SecureString | false |  | The password for connecting to the MSSQL database as secure string |
| SqlHost | String | false | localhost | The IP address or FQDN to the MSSQL server to connect to |
| SqlPort | Int32 | false | 1433 | The port of the MSSQL server/instance to connect to with the provided credentials |
| IntegratedSecurity | SwitchParameter | false | False | Allows this plugin to use the credentials of the current PowerShell session inherited by<br /> the user the PowerShell is running with. If this is set and the user the PowerShell is<br /> running with can access to the MSSQL database you will not require to provide username<br /> and password |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| IncludeDays | Object | false |  | Specifies the number of days to read the backup history from MSSQL. Over time, the history table can get quite<br /> large and if there is no maintenance task in place to shrink it, this script could time out. By default the entire<br /> history is evaluated. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckMSSQLBackupStatus -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -Verbosity 3;
```

### Example Output 1

```powershell
[OK] MSSQL Backup (MSSQLSERVER) (All must be [OK])
    \_ [OK] master (All must be [OK])
    \_ [OK] Age: 951.34d
    \_ [OK] Average Size: 5.39MiB
    \_ [OK] Execution Time: 0us
    \_ [OK] Log age: 0us
    \_ [OK] Size: 16.17MiB
    \_ [OK] Status: Online
| master::ifw_mssqlbackupstatus::age=82196160s;;;; master::ifw_mssqlbackupstatus::averagesize=5651114B;;;; master::ifw_mssqlbackupstatus::executiontime=0s;;;; master::ifw_mssqlbackupstatus::logage=0s;;;; master::ifw_mssqlbackupstatus::size=16953340B;;;; master::ifw_mssqlbackupstatus::state=0;6;5;;    
```

### Example Command 2

```powershell
Invoke-IcingaCheckMSSQLBackupStatus -IntegratedSecurity -SqlHost 'example.com' -IncludeDatabase 'msdb' -Verbosity 3;
```

### Example Output 2

```powershell
[OK] MSSQL Backup (MSSQLSERVER) (All must be [OK])
\_ [OK] msdb (All must be [OK])
    \_ [OK] Age: 951.34d
    \_ [OK] Average Size: 16.34MiB
    \_ [OK] Execution Time: 0us
    \_ [OK] Log age: 0us
    \_ [OK] Size: 49.03MiB
    \_ [OK] Status: Online
| msdb::ifw_mssqlbackupstatus::age=82196160s;;;; msdb::ifw_mssqlbackupstatus::averagesize=17138350B;;;; msdb::ifw_mssqlbackupstatus::executiontime=0s;;;; msdb::ifw_mssqlbackupstatus::logage=0s;;;; msdb::ifw_mssqlbackupstatus::size=51415040B;;;; msdb::ifw_mssqlbackupstatus::state=0;6;5;;    
```


