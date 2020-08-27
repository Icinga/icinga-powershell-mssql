
# Invoke-IcingaCheckMSSQLBackupStatus

## Description

MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
last backup log age, last backup execution time, database status of a given database

MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
last backup execution time, database status of a given database
More Information on https://github.com/Icinga/icinga-powershell-mssql

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
| DatabaseStatusWarning | Object | false | Offline | Warning threshold for the database status:     Online     Restoring     Recovering     Recovering_Pending     Suspect     Emergency     Offline     Copying     Offline_Secondary |
| DatabaseStatusCritical | Object | false | Emergency | Critical threshold for the database status:     Online     Restoring     Recovering     Recovering_Pending     Suspect     Emergency     Offline     Copying     Offline_Secondary |
| IncludeDatabase | Array | false | @() | Specifies the database or databases which will be checked. Leave empty to fetch metrics from all databases on the given system |
| SqlConnection | Object | false |  | Use an already existing and established SQL object for query handling. Otherwise leave it empty and use the authentication by username/password or integrate security |
| SqlUsername | String | false |  | The username for connecting to the MSSQL database |
| SqlPassword | SecureString | false |  | The password for connecting to the MSSQL database as secure string |
| SqlHost | String | false | localhost | The IP address or FQDN to the MSSQL server to connect to |
| SqlPort | Int32 | false | 1433 | The port of the MSSQL server/instance to connect to with the provided credentials |
| IntegratedSecurity | SwitchParameter | false | False | Allows this plugin to use the credentials of the current PowerShell session inherited by the user the PowerShell is running with. If this is set and the user the PowerShell is running with can access to the MSSQL database you will not require to provide username and password |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state |

## Examples

### Example Command 1

```powershell
Invoke-IcingaMSSQLBackupOverallStatus -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com';
```

### Example Output 1

```powershell
[OK] Check package "MSSQL Backup"| 'status'=0;6;5 'size'=10110976b;; 'execution_time'=0s;; 'age'=144000s;; 'average_size'=3370325.333333b;; 'status'=0;6;5 'size'=12664832b;;'execution_time'=0s;; 'age'=493200s;; 'average_size'=6332416b;; 'status'=0;6;5 'size'=33445888b;; 'execution_time'=0s;; 'age'=144000s;; 'average_size'=16722944b;;
```

### Example Command 2

```powershell
Get-IcingaMSSQLBackupOverallStatus -IntegratedSecurity -SqlHost 'example.com' -IncludeDatabase 'ExampleDatabase','AnotherDatabase';
```

### Example Output 2

```powershell
[OK] Check package "MSSQL Backup"| 'status'=0;6;5 'size'=12664832b;; 'execution_time'=0s;; 'age'=493200s;; 'average_size'=6332416b;; 'status'=0;6;5 'size'=10110976b;;'execution_time'=0s;; 'age'=144000s;; 'average_size'=3370325.333333b;;
```