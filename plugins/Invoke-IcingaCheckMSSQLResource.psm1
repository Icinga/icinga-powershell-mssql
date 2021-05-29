<#
.SYNOPSIS
    MSSQL plugin which checks for page life expectancy, buffer cache hit ratio',
    average latch wait time (ms) Performance Counters
.DESCRIPTION
    MSSQL plugin which checks for page life expectancy, buffer cache hit ratio',
    average latch wait time (ms) Performance Counters
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    MSSQL plugin which checks for page life expectancy, buffer cache hit ratio',
    average latch wait time (ms) Performance Counters
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLResource -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com';
    [OK] Check package "MSSQL Performance"
    | 'buffer_cache_hit_ratio'=62;; 'page_life_expectancy'=300;; 'average_latch_wait_time_ms'=389839;;
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLResource -IntegratedSecurity -SqlHost 'example.com';
    [OK] Check package "MSSQL Performance"
    | 'buffer_cache_hit_ratio'=2;; 'page_life_expectancy'=300;; 'average_latch_wait_time_ms'=389839;;
.PARAMETER PageLifeExpectancyWarning
    Warning threshold for the page life expectancy which indicates the number of seconds a page will stay in the buffer pool without references.
.PARAMETER PageLifeExpectancyCritical
    Critical threshold for the page life expectancy which indicates the number of seconds a page will stay in the buffer pool without references.
.PARAMETER BufferCacheHitRatioWarning
    Warning threshold for the Buffer cache hit ratio which Indicates the percentage of pages found in the buffer cache without having to read from disk.
    The ratio is the total number of cache hits divided by the total number of cache lookups over the last few thousand page accesses. After a long period
    of time, the ratio moves very little. Because reading from the cache is much less expensive than reading from disk, you want this ratio to be high.
    Generally, you can increase the buffer cache hit ratio by increasing the amount of memory available to SQL Server or by using the buffer pool extension
    feature.
.PARAMETER BufferCacheHitRatioCritical
    Warning threshold for the Buffer cache hit ratio which Indicates the percentage of pages found in the buffer cache without having to read from disk.
    The ratio is the total number of cache hits divided by the total number of cache lookups over the last few thousand page accesses. After a long period
    of time, the ratio moves very little. Because reading from the cache is much less expensive than reading from disk, you want this ratio to be high.
    Generally, you can increase the buffer cache hit ratio by increasing the amount of memory available to SQL Server or by using the buffer pool extension
    feature.
.PARAMETER AverageLatchWaitTimeWarning
    Warning threshold for the Average Latch Wait Time (ms) for latch requests that had to wait.
.PARAMETER AverageLatchWaitTimeCritical
    Critical threshold for the Average Latch Wait Time (ms) for latch requests that had to wait.
.PARAMETER PerformanceCounter
    List of Performance Counters specified by their full path (example '\SQLServer:Buffer Manager\Buffer cache hit ratio')
    to fetch information for
.PARAMETER SqlUsername
    The username for connecting to the MSSQL database
.PARAMETER SqlPassword
    The password for connecting to the MSSQL database as secure string
.PARAMETER SqlHost
    The IP address or FQDN to the MSSQL server to connect to
.PARAMETER SqlPort
    The port of the MSSQL server/instance to connect to with the provided credentials
.PARAMETER SqlDatabase
    The name of a specific database to connect to. Leave empty to connect "globally"
.PARAMETER IntegratedSecurity
    Allows this plugin to use the credentials of the current PowerShell session inherited by
    the user the PowerShell is running with. If this is set and the user the PowerShell is
    running with can access to the MSSQL database you will not require to provide username
    and password
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])e
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Invoke-IcingaCheckMSSQLResource()
{
    param (
        $PageLifeExpectancyCritical   = $null,
        $PageLifeExpectancyWarning    = $null,
        $AverageLatchWaitTimeCritical = $null,
        $AverageLatchWaitTimeWarning  = $null,
        $BufferCacheHitRatioCritical  = $null,
        $BufferCacheHitRatioWarning   = $null,
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost              = "localhost",
        [int]$SqlPort                 = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity   = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity               = 0
    );

    [hashtable]$CheckPackages = @{};

    $SqlConnection = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort;

    $PerfCounters = Get-IcingaMSSQLPerformanceCounter `
        -SqlConnection $SqlConnection `
        -PerformanceCounters @(
            '\SQLServer:Buffer Manager\page life expectancy',
            '\SQLServer:Buffer Manager\Buffer cache hit ratio',
            '\SQLServer:Latches\Average Latch Wait Time (ms)',
            '\SQLServer:Buffer Manager\Buffer cache hit ratio base',
            '\SQLServer:Latches\Average Latch Wait Time Base'
        );

    [decimal]$BufferRatioBase   = 1;
    [decimal]$LatchWaitTimeBase = 1;

    foreach ($entry in $PerfCounters) {
        switch ($entry.counter_name) {
            'Buffer cache hit ratio base' {
                $BufferRatioBase = $entry.cntr_value;
                break;
            };
            'Average Latch Wait Time Base' {
                $LatchWaitTimeBase = $entry.cntr_value;
                break;
            };
        }
    }

    $InstanceName = Get-IcingaMSSQLInstanceName -SqlConnection $SqlConnection;

    # Close the connection as we no longer require it
    Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;

    $CheckPackage = New-IcingaCheckPackage `
        -Name ([string]::Format('MSSQL Performance ({0})', $InstanceName)) `
        -OperatorAnd `
        -Verbose $Verbosity;

    foreach ($Entry in $PerfCounters) {
        $FullName = Get-IcingaMSSQLPerfCounterPathFromDBObject -DBObject $Entry;

        <# https://docs.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-buffer-manager-object?view=sql-server-ver15 #>
        switch ($FullName) {
            '\SQLServer:Buffer Manager\page life expectancy' {
                $Check = (New-IcingaCheck -Name $Entry.counter_name -Value $Entry.cntr_value).WarnOutOfRange($PageLifeExpectancyWarning).CritOutOfRange($PageLifeExpectancyCritical);
                break;
            };
            '\SQLServer:Buffer Manager\Buffer cache hit ratio' {
                $Check = (New-IcingaCheck -Name $Entry.counter_name -Value (($Entry.cntr_value * 1.0 / $BufferRatioBase) * 100) -Unit '%').WarnOutOfRange($BufferCacheHitRatioWarning).CritOutOfRange($BufferCacheHitRatioCritical);
                break;
            };
            '\SQLServer:Latches\Average Latch Wait Time (ms)' {
                $Check = (New-IcingaCheck -Name $Entry.counter_name -Value ($Entry.cntr_value / $LatchWaitTimeBase) -Unit 'ms').WarnOutOfRange($AverageLatchWaitTimeWarning).CritOutOfRange($AverageLatchWaitTimeCritical);
                break;
            };
        }

        # Do not add these metrics to our check package of create checks for them
        if ($FullName -eq '\SQLServer:Buffer Manager\Buffer cache hit ratio base' -Or $FullName -eq '\SQLServer:Latches\Average Latch Wait Time Base') {
            continue;
        }

        Add-IcingaHashtableItem `
            -Hashtable $CheckPackages `
            -Key ($Entry.object_name) `
            -Value (New-IcingaCheckPackage -Name $Entry.object_name -OperatorAnd -Verbose $Verbosity) | Out-Null;

        if ($null -ne $Check) {
            # The check package for our counter category
            (Get-IcingaHashtableItem -Hashtable $CheckPackages -Key ($Entry.object_name)).AddCheck($Check) | Out-Null;
        }
    }

    foreach ($package in $CheckPackages.Values) {
        $CheckPackage.AddCheck($package);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
