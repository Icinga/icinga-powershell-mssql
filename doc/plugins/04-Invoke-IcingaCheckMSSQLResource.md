
# Invoke-IcingaCheckMSSQLResource

## Description

MSSQL plugin which checks for page life expectancy, buffer cache hit ratio',
average latch wait time (ms) Performance Counters

MSSQL plugin which checks for page life expectancy, buffer cache hit ratio',
average latch wait time (ms) Performance Counters
More Information on https://github.com/Icinga/icinga-powershell-mssql

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| PageLifeExpectancyCritical | Object | false |  | Critical threshold for the page life expectancy which indicates the number of seconds a page will stay in the buffer pool without references. |
| PageLifeExpectancyWarning | Object | false |  | Warning threshold for the page life expectancy which indicates the number of seconds a page will stay in the buffer pool without references. |
| AverageLatchWaitTimeCritical | Object | false |  | Critical threshold for the Average Latch Wait Time (ms) for latch requests that had to wait. |
| AverageLatchWaitTimeWarning | Object | false |  | Warning threshold for the Average Latch Wait Time (ms) for latch requests that had to wait. |
| BufferCacheHitRatioCritical | Object | false |  | Warning threshold for the Buffer cache hit ratio which Indicates the percentage of pages found in the buffer cache without having to read from disk. The ratio is the total number of cache hits divided by the total number of cache lookups over the last few thousand page accesses. After a long period of time, the ratio moves very little. Because reading from the cache is much less expensive than reading from disk, you want this ratio to be high. Generally, you can increase the buffer cache hit ratio by increasing the amount of memory available to SQL Server or by using the buffer pool extension feature. |
| BufferCacheHitRatioWarning | Object | false |  | Warning threshold for the Buffer cache hit ratio which Indicates the percentage of pages found in the buffer cache without having to read from disk. The ratio is the total number of cache hits divided by the total number of cache lookups over the last few thousand page accesses. After a long period of time, the ratio moves very little. Because reading from the cache is much less expensive than reading from disk, you want this ratio to be high. Generally, you can increase the buffer cache hit ratio by increasing the amount of memory available to SQL Server or by using the buffer pool extension feature. |
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
Invoke-IcingaCheckMSSQLResource -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com';
```

### Example Output 1

```powershell
[OK] Check package "MSSQL Performance"| 'buffer_cache_hit_ratio'=62;; 'page_life_expectancy'=300;; 'average_latch_wait_time_ms'=389839;;
```

### Example Command 2

```powershell
Invoke-IcingaCheckMSSQLResource -IntegratedSecurity -SqlHost 'example.com';
```

### Example Output 2

```powershell
[OK] Check package "MSSQL Performance"| 'buffer_cache_hit_ratio'=2;; 'page_life_expectancy'=300;; 'average_latch_wait_time_ms'=389839;;
```