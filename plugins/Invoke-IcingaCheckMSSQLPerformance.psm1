  <#
.SYNOPSIS
   Checks MSSQL for various performance metrics.
.DESCRIPTION
   Invoke-IcingaCheckMSSQLPerforamance returns either OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g A MSSQL instance has an extremely low Page Life Expectancy returns 'CRITIAL'.
   More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
   This module is intended to be used to check different performance metrics of a MSSQL instance.
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   FOOBAR 1
.EXAMPLE
   FOOBAR 2
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Invoke-IcingaCheckMSSQLPerformancedata()
{
   param(
      $PageLifeExpectancyCritical       = $null,
      $PageLifeExpectancyWarning        = $null,
      $AverageLatchWaitTimeCritical     = $null,
      $AverageLatchWaitTimeWarning      = $null,
      $BufferCacheHitRatioCritical      = $null,
      $BufferCacheHitRatioWarning       = $null,
      $BufferCacheHitRatioBaseCritical  = $null,
      $BufferCacheHitRatioBaseWarning   = $null,
      [array]$MSSQLPerformanceCounters  = @(),
      [switch]$NoPerfData,
      [int]$Verbosity                   = 0
   );

   $CheckPackage = New-IcingaCheckPackage -Name 'MSSQL Performance Package' `
                                          -OperatorAnd `
                                          -Verbose $Verbosity;

   <# $AllCounters =  New-IcingaPerformanceCounterArray -CounterArray ([string]::Format('\SQLServer:Buffer Manager\page life expectancy'), `
                                                                    [string]::Format('\SQLServer:Buffer Manager\Buffer cache hit ratio'), `

                                                                    [string]::Format('\SQLServer:Latches\Average Latch Wait Time (ms)'), `
                                                                    [string]::Format('\SQLServer:Latches\Average Latch Wait Time Base'));
 #>

   if ($null -ne $MSSQLPerformanceCounters) {

      foreach ($Counter in $MSSQLPerformanceCounters) {
         $Category = $null
         $CounterObject = $null

         $Category = $Counter.Split('\')[1]
         $CounterObject = $Counter.Split('\')[2]

         $PerformanceCounterQuery += "object_name = '$Category' AND counter_name = '$CounterObject'"
         Write-Host $PerformanceCounterQuery

         if ($PerformanceCounters.Count -gt 1) {
            $PerformanceCounterQuery += "OR "
        }
      }
   } else {
      Write-Host "HAS TO BE AT LEAST ONE PARAMETER"
   }


   <# Aööe perfcounter aus der datenbank holen die ich haben möächt mit einer Query holen.
   in pweorshell weiterberechnen    #>

   #TODO make generic function

    <# foreach ($Entry in $AllCounters.Keys) {
      $Value = $AllCounters[$Entry].value;
      <# Write-Host $Entry; #>
      <# Write-Host ($CounterObjects | Out-String); #>

      <# https://docs.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-buffer-manager-object?view=sql-server-ver15 #>
      <# switch ($Entry.counter_name) {
        '\SQLServer:Buffer Manager\page life expectancy' {
           $Check = (New-IcingaCheck -Name 'SQL: page life expectancy' -Value $Value).WarnOutOfRange($PageLifeExpectancyWarning).CritOutOfRange($PageLifeExpectancyCritical);
           break;
        };
        '\SQLServer:Buffer Manager\Buffer cache hit ratio' {
            $Check = (New-IcingaCheck -Name 'SQL: Buffer cache hit ratio' -Value $Value).WarnOutOfRange($BufferCacheHitRatioWarning).CritOutOfRange($BufferCacheHitRatioCritical);
            break;
        };
        '\SQLServer:Latches\Average Latch Wait Time (ms)' {
            $Check = (New-IcingaCheck -Name 'SQL: Average Latch Wait Time (ms)' -Value $Value).WarnOutOfRange($AverageLatchWaitTimeWarning).CritOutOfRange($AverageLatchWaitTimeCritical);
            break;
        }
      }


      if ($null -ne $Check) {
         $CheckPackage.AddCheck($Check);
      }
   }

   return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile) #> #>
}
