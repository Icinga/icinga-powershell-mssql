<#
.SYNOPSIS
   Checks MSSQL for various metrics.
.DESCRIPTION
   Invoke-IcingaCheckMSSQL returns either OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g A MSSQL instance has an extremely low Page Life Expectancy return xyz.
   More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
   This module is intended to be used to check different metrics of a MSSQL istance.
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
      [integer]$PageLifeExpectancyCritical   = 180,
      [integer]$PageLifeExpectancyWarning    = 300,
      $AverageLatchWaitTimeCritical = 1,
      $AverageLatchWaitTimeWarning  = 5,
      $BufferCacheHitRatioCritical  = $FALSE,
      $BufferCacheHitRatioWarning   = $FALSE,


      $critical,
      $warning,

      [switch]$NoPerfData,
      [int]$Verbosity      = 0
   );

   $CheckPackage = New-IcingaCheckPackage -Name 'MSSQL Data' -OperatorAnd -Verbose $Verbosity;

   $AllCounters =  New-IcingaPerformanceCounterArray -CounterArray ([string]::Format('\SQLServer:Buffer Manager\page life expectancy'), `

                                                                    [string]::Format('\SQLServer:Buffer Manager\Buffer cache hit ratio'), `
                                                                    [string]::Format('\SQLServer:Buffer Manager\Buffer cache hit ratio base'), `

                                                                    [string]::Format('\SQLServer:Latches\Average Latch Wait Time (ms)'), `
                                                                    [string]::Format('\SQLServer:Latches\Average Latch Wait Time Base'));

   foreach ($Entry in $AllCounters.Keys) {
      $CounterObjects = $AllCounters[$Entry];
      Write-Host $CounterObjects
      foreach ($Counter in $CounterObjects.Keys) {
         $CounterObject = $CounterObjects[$Counter];
         $CheckPackage.AddCheck(
            (
               (New-IcingaCheck -Name ([string]::Format('{0} {1}', $Entry, $Counter)) -Value $CounterObject.value).WarnOutOfRange($warning).CritOutOfRange($critical)
            )
         )
      }
   }

   return (New-IcingaCheckResult -Check $CheckPackage -Complie -Verbose $Verbosity)
}
