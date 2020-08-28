<#
.SYNOPSIS
    Checks if MSSQL services for a specific instance are running and if the connection
    to a database instance can be established
.DESCRIPTION
    The plugin will return CRITICAL in case MSSQL instance services are not running and
    WARNING or CRITICAL if the connection time is not matching your set thresholds
    More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
    Checks if MSSQL services for a specific instance are running and if the connection
    to a database instance can be established
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLHealth -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost example.com;
    [OK] Check package "MSSQL Health"
    | 'connection_time'=19ms;;
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLHealth -IntegratedSecurity -SqlHost example.com;
    [OK] Check package "MSSQL Health"
    | 'connection_time'=26ms;;
.PARAMETER Warning
    The warning threshold for the connection time to the MSSQL database as time interval (ms, s, h, m)
.PARAMETER Critical
    The warning threshold for the connection time to the MSSQL database as time interval (ms, s, h, m)
.PARAMETER Instance
   The name of the database instance to check the service state for. Can either the MSSQL$DB1 or simply DB1
   for example
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
.INPUTS
    System.Array
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Invoke-IcingaCheckMSSQLHealth()
{
    param (
        $Warning,
        $Critical,
        [string]$Instance,
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost            = "localhost",
        [int]$SqlPort               = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$NoPerfData,
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity             = 0
    );

    $Warning  = ConvertTo-SecondsFromIcingaThresholds $Warning;
    $Critical = ConvertTo-SecondsFromIcingaThresholds $Critical;

    # Create a unique name for our timer
    [string]$MSSQLTimer = [string]::Format('MSSQL_Timer_{0}', $Instance);
    # Start the timer to store our connection time
    Start-IcingaTimer $MSSQLTimer;
    # Connect to MSSQL
    $SqlConnection     = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort -TestConnection;
    # Stop the timer
    Stop-IcingaTimer $MSSQLTimer;

    $InstanceName      = '';
    $MSSQLConnCheck    = $null;

    if ($null -ne $SqlConnection) {
        $InstanceName      = Get-IcingaMSSQLInstanceName -SqlConnection $SqlConnection;
        # Build a check based on our connection time
        $MSSQLConnCheck = New-IcingaCheck -Name 'Connection Time' -Value (Get-IcingaTimer $MSSQLTimer).ElapsedMilliseconds -Unit 'ms';
        $MSSQLConnCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

        if ([string]::IsNullOrEmpty($Instance)) {
            $Instance = $InstanceName;
        }
    } else {
        # Build a check based on our connection time
        $MSSQLConnCheck = New-IcingaCheck -Name 'DB Connection error' -Value $TRUE;
        $MSSQLConnCheck.SetCritical() | Out-Null;
    }

    # Close the connection as we no longer require it
    Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;

    # Create a check package to store our checks
    $MSSQLCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('MSSQL Health ({0})', $InstanceName)) -OperatorAnd -Verbose $Verbosity;

    # Fetch all services for MSSQL which are mandatory
    $MSSQLServices     = Get-IcingaServices 'MSSQLSERVER', 'MSSQL$*', $InstanceName;

    # Now loop all services we found
    foreach ($service in $MSSQLServices.Keys) {
        # Setup some basic variables for later handling and usage
        $ServiceObject = $MSSQLServices[$service];
        $ServiceName   = Get-IcingaServiceCheckName -ServiceInput $service -Service $ServiceObject;
        $StatusRaw     = $ServiceObject.configuration.Status.raw;

        # Now check if our instance name is either matching the exact service name of the instance name
        if ($service -eq $Instance -Or $service -eq ([string]::Format('MSSQL${0}', $Instance))) {
            $ServiceCheck = New-IcingaCheck -Name $ServiceName -Value $StatusRaw -ObjectExists $service -Translation $ProviderEnums.ServiceStatusName;
            $ServiceCheck.CritIfNotMatch($ProviderEnums.ServiceStatus.Running) | Out-Null;
            $MSSQLCheckPackage.AddCheck($ServiceCheck);
        }
    }

    $MSSQLCheckPackage.AddCheck($MSSQLConnCheck);

    return (New-IcingaCheckResult -Check $MSSQLCheckPackage -Compile -NoPerfData $NoPerfData)
}
