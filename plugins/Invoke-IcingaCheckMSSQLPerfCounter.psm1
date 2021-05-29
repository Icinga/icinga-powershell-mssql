<#
.SYNOPSIS
    Checks specified Performance Counter inside the MSSQL database by fetching
    counters by a given name and compares them to input thresholds
.DESCRIPTION
    Checks specified Performance Counter inside the MSSQL database by fetching
    counters by a given name and compares them to input thresholds
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    Checks specified Performance Counter inside the MSSQL database by fetching
    counters by a given name and compares them to input thresholds
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLHealth -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
    [OK] Check package "MSSQL Performance Counter"
    | 'sqlserverbuffer_manager'=22;; 'sqlserverlatches'=384199;;
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLHealth -IntegratedSecurity -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
    [OK] Check package "MSSQL Performance Counter"
    | 'sqlserverbuffer_manager'=24;; 'sqlserverlatches'=387257;;
.PARAMETER Warning
    The warning threshold of the Performance Counter return values
.PARAMETER Critical
    The critical threshold of the Performance Counter return values
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
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Invoke-IcingaCheckMSSQLPerfCounter()
{
    param (
        $Warning,
        $Critical,
        [array]$PerformanceCounter  = @(),
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost            = "localhost",
        [int]$SqlPort               = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2, 3)]
        [int]$Verbosity             = 0
    );

    [hashtable]$CheckPackages = @{};

    $SqlConnection = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort;

    $PerfCounters = Get-IcingaMSSQLPerformanceCounter `
        -SqlConnection $SqlConnection `
        -PerformanceCounters $PerformanceCounter;

    $InstanceName = Get-IcingaMSSQLInstanceName -SqlConnection $SqlConnection;

    # Close the connection as we no longer require it
    Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;

    $CheckPackage = New-IcingaCheckPackage `
        -Name ([string]::Format('MSSQL Performance Counter ({0})', $InstanceName)) `
        -OperatorAnd `
        -Verbose $Verbosity;

    foreach ($Entry in $PerfCounters) {
        $FullName = Get-IcingaMSSQLPerfCounterPathFromDBObject -DBObject $Entry;

        Add-IcingaHashtableItem `
            -Hashtable $CheckPackages `
            -Key ($Entry.object_name) `
            -Value (New-IcingaCheckPackage -Name $Entry.object_name -OperatorAnd -Verbose $Verbosity) | Out-Null;

        <# https://docs.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-buffer-manager-object?view=sql-server-ver15 #>
        $Check = (New-IcingaCheck -Name (Get-IcingaMSSQLPerfCounterNameFromDBObject -DBObject $Entry) -Value $Entry.cntr_value).WarnOutOfRange($Warning).CritOutOfRange($Critical);

        if ($null -ne $Check) {
            # The check package for our counter category
            (Get-IcingaHashtableItem -Hashtable $CheckPackages -Key ($Entry.object_name)).AddCheck($Check) | Out-Null;
        }
    }

    # Add each counter category check package to our main check package
    foreach ($package in $CheckPackages.Values) {
        $CheckPackage.AddCheck($package);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
