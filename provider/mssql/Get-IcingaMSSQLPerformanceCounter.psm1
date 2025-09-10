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
    PS>Get-IcingaMSSQLPerformanceCounter -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
    [OK] Check package "MSSQL Performance Counter"
    | 'sqlserverbuffer_manager'=22;; 'sqlserverlatches'=384199;;
.EXAMPLE
    PS>Get-IcingaMSSQLPerformanceCounter -IntegratedSecurity -SqlHost 'example.com' -PerformanceCounter '\SQLServer:Buffer Manager\Buffer cache hit ratio', '\SQLServer:Latches\Average Latch Wait Time (ms)';
    [OK] Check package "MSSQL Performance Counter"
    | 'sqlserverbuffer_manager'=24;; 'sqlserverlatches'=387257;;
.PARAMETER SqlConnection
    Use an already existing and established SQL object for query handling. Otherwise leave it empty and use the
    authentication by username/password or integrate security
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
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Get-IcingaMSSQLPerformanceCounter
{
    param (
        $SqlConnection              = $null,
        [array]$PerformanceCounters = @(),
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost            = "localhost",
        [int]$SqlPort               = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity = $FALSE
    );

    if ($PerformanceCounters.Count -eq 0) {
        Exit-IcingaThrowException `
            -ExceptionType 'Configuration' `
            -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing `
            -CustomMessage 'Missing argument "-PerformanceCounters"' `
            -Force;
    }

    [bool]$NewSqlConnection = $FALSE;

    if ($null -eq $SqlConnection) {
        $SqlConnection = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort;
        $NewSqlConnection = $TRUE;
    }

    $PerformanceCounterQuery = "SELECT
                                    RTRIM(object_name) as object_name,
                                    RTRIM(counter_name) as counter_name,
                                    RTRIM(instance_name) as instance_name,
                                    RTRIM(cntr_value) as cntr_value,
                                    RTRIM(cntr_type) as cntr_type
                                FROM sys.dm_os_performance_counters
                                WHERE ";

    foreach ($Counter in $PerformanceCounters) {
        $Category      = $null;
        $CounterObject = $null;
        $ArrayCounter  = $Counter.Split('\');
        $Category      = $ArrayCounter[1];
        $InstanceName  = '';
        $CounterObject = $ArrayCounter[2];

        if ($Category.Contains('(')) {
            [array]$InstanceArray = $Category.Split('(');
            $Category             = $InstanceArray[0];
            [string]$InstanceName = $InstanceArray[1];
            $InstanceName         = $InstanceName.Substring(0, $InstanceName.Length - 1);
            if ($InstanceName -eq '*') {
                $InstanceName = '';
            }
        }

        if ([string]::IsNullOrEmpty($InstanceName)) {
            $PerformanceCounterQuery = (
                [string]::Format(
                    "{0}(object_name LIKE '{1}' AND counter_name = '{2}') OR ",
                    $PerformanceCounterQuery,
                    $Category,
                    $CounterObject
                )
            );
        } else {
            $PerformanceCounterQuery = (
                [string]::Format(
                    "{0}(object_name LIKE '{1}' AND counter_name = '{2}' AND instance_name = '{3}') OR ",
                    $PerformanceCounterQuery,
                    $Category,
                    $CounterObject,
                    $InstanceName
                )
            );
        }
    }

    $PerformanceCounterQuery = $PerformanceCounterQuery.SubString(0, $PerformanceCounterQuery.Length - 4);
    $PerformanceCounterQuery += ';';
    $SqlCommand              = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $PerformanceCounterQuery;
    $Data                    = Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;

    if ($NewSqlConnection -eq $TRUE) {
        Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;
    }

    [array]$CounterResult = @();

    foreach ($counter in $Data) {
        [decimal]$CounterValue = 0;
        if ((Test-Numeric $counter.cntr_value)) {
            $CounterValue = ([math]::round([decimal]$counter.cntr_value, 6));
        }

        $CounterResult += @{
            'instance_name' = $counter.instance_name;
            'object_name'   = $counter.object_name;
            'counter_name'  = $counter.counter_name;
            'cntr_value'    = $CounterValue;
        }
    }

    return $CounterResult;
}
