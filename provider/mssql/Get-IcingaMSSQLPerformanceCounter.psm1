function Get-IcingaMSSQLPerformanceCounterValue {
    param (
        # OptionalParameter
        $SqlConnection                              = $null,
        [bool]$NewSqlConnection                     = $FALSE,
        [string]$NewSqlConnectionUsername,
        [securestring]$NewSqlConnectionPassword,
        [string]$NewSqlConnectionAddress            = "localhost",
        [switch]$NewSqlConnectionIntegratedSecurity = $FALSE,
        [array]$PerformanceCounters                 = @()
    );

    if ($NewSqlConnection -eq $TRUE) {
        if ($NewSqlConnectionIntegratedSecurity -eq $TRUE) {
            $SqlConnection            = Open-IcingaMSSQLConnection -IntegratedSecurity;
        } else {
            $SqlConnection            = Open-IcingaMSSQLConnection -Username $Username -Password $Password -Address $Address;
        }
    }

    #TODO: has to be implemented https://www.sentryone.com/blog/allenwhite/sql-server-performance-counters-to-monitor
    if ($null -eq $PerformanceCounters) {
        $PerformanceCounters         += "\SQLServer:Buffer Manager\page life expectancy";
        $PerformanceCounters         += "\SQLServer:Buffer Manager\Buffer cache hit ratio";
        $PerformanceCounters         += "\SQLServer:Latches\Average Latch Wait Time (ms)";
    }

    $PerformanceCounterQuery          = "SELECT * FROM sys.dm_os_performance_counters WHERE ";

    foreach ($Counter in $PerformanceCounters) {
        $Category                     = $null;
        $CounterObject                = $null;
        $Category                     = $Counter.Split('\')[1];
        $CounterObject                = $Counter.Split('\')[2];
        $PerformanceCounterQuery     += "(object_name = '$Category' AND counter_name = '$CounterObject') ";

        if ($PerformanceCounters.Count -gt 1 -and $Counter -ne $PerformanceCounters[-1]) {
            $PerformanceCounterQuery +=  " OR ";
        }
    }

    $SqlCommand                       = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $PerformanceCounterQuery;
    $Data                             = Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;

    if ($NewSqlConnection -eq $TRUE) {
        Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;
    }

    return $Data;
}