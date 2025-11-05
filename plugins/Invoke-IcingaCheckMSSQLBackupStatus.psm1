<#
.SYNOPSIS
    MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
    last backup log age, last backup execution time, database status of a given database
.DESCRIPTION
    MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
    last backup execution time, database status of a given database
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    MSSQL plugin which checks for total backupsize, average backupsize, last backup age,
    last backup execution time, database status of a given database
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLBackupStatus -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com' -Verbosity 3;
    [OK] MSSQL Backup (MSSQLSERVER) (All must be [OK])
        \_ [OK] master (All must be [OK])
        \_ [OK] Age: 951.34d
        \_ [OK] Average Size: 5.39MiB
        \_ [OK] Execution Time: 0us
        \_ [OK] Log age: 0us
        \_ [OK] Size: 16.17MiB
        \_ [OK] Status: Online
    | master::ifw_mssqlbackupstatus::age=82196160s;;;; master::ifw_mssqlbackupstatus::averagesize=5651114B;;;; master::ifw_mssqlbackupstatus::executiontime=0s;;;; master::ifw_mssqlbackupstatus::logage=0s;;;; master::ifw_mssqlbackupstatus::size=16953340B;;;; master::ifw_mssqlbackupstatus::state=0;6;5;;
.EXAMPLE
    PS>Invoke-IcingaCheckMSSQLBackupStatus -IntegratedSecurity -SqlHost 'example.com' -IncludeDatabase 'msdb' -Verbosity 3;
    [OK] MSSQL Backup (MSSQLSERVER) (All must be [OK])
    \_ [OK] msdb (All must be [OK])
        \_ [OK] Age: 951.34d
        \_ [OK] Average Size: 16.34MiB
        \_ [OK] Execution Time: 0us
        \_ [OK] Log age: 0us
        \_ [OK] Size: 49.03MiB
        \_ [OK] Status: Online
    | msdb::ifw_mssqlbackupstatus::age=82196160s;;;; msdb::ifw_mssqlbackupstatus::averagesize=17138350B;;;; msdb::ifw_mssqlbackupstatus::executiontime=0s;;;; msdb::ifw_mssqlbackupstatus::logage=0s;;;; msdb::ifw_mssqlbackupstatus::size=51415040B;;;; msdb::ifw_mssqlbackupstatus::state=0;6;5;;
.PARAMETER TotalBackupSizeWarning
    Warning threshold for the total backupsize which represent a count of all backups
.PARAMETER TotalBackupSizeCritical
    Critical threshold for the total backupsize which represent a count of all backups
.PARAMETER AvgBackupSizeWarning
    Warning threshold for the average backupsize which represent an average backupsize of all backups
.PARAMETER AvgBackupSizeCritical
    Critical threshold for the average backupsize which represent an average backupsize of all backups
.PARAMETER LastBackupLogAgeWarning
    Warning threshold for the last log backup age, which returns the elapsed time since a database was last backupped
.PARAMETER LastBackupAgeWarning
    Warning threshold for the last log backup age, which returns the elapsed time since a database was last backupped
.PARAMETER LastBackupAgeCritical
    Critical threshold for the last backup age, which returns the elapsed time since a database was last backupped
.PARAMETER ExecutionTimeWarning
    Warning threshold for the execution time, which returns the elapsed time how long the backup process took
.PARAMETER ExecutionTimeCritical
    Critical threshold for the execution time, which returns the elapsed time how long the backup process took
.PARAMETER DatabaseStatusWarning
    Warning threshold for the database status:
        Online
        Restoring
        Recovering
        Recovering_Pending
        Suspect
        Emergency
        Offline
        Copying
        Offline_Secondary
.PARAMETER DatabaseStatusCritical
    Critical threshold for the database status:
        Online
        Restoring
        Recovering
        Recovering_Pending
        Suspect
        Emergency
        Offline
        Copying
        Offline_Secondary
.PARAMETER IncludeDatabase
    Specifies the database or databases which will be checked. Leave empty to fetch metrics from
    all databases on the given system
.PARAMETER SqlUsername
    The username for connecting to the MSSQL database
.PARAMETER SqlPassword
    The password for connecting to the MSSQL database as secure string
.PARAMETER SqlHost
    The IP address or FQDN to the MSSQL server to connect to
.PARAMETER SqlPort
    The port of the MSSQL server/instance to connect to with the provided credentials
.PARAMETER IntegratedSecurity
    Allows this plugin to use the credentials of the current PowerShell session inherited by
    the user the PowerShell is running with. If this is set and the user the PowerShell is
    running with can access to the MSSQL database you will not require to provide username
    and password
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER IncludeDays
    Specifies the number of days to read the backup history from MSSQL. Over time, the history table can get quite
    large and if there is no maintenance task in place to shrink it, this script could time out. By default the entire
    history is evaluated.
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

function Invoke-IcingaCheckMSSQLBackupStatus
{
    param (
        $TotalBackupSizeWarning     = $null,
        $TotalBackupSizeCritical    = $null,
        $AvgBackupSizeWarning       = $null,
        $AvgBackupSizeCritical      = $null,
        $LastBackupLogAgeWarning    = $null,
        $LastBackupLogAgeCritical   = $null,
        $LastBackupAgeWarning       = $null,
        $LastBackupAgeCritical      = $null,
        $ExecutionTimeWarning       = $null,
        $ExecutionTimeCritical      = $null,
        [ValidateSet('Online', 'Restoring', 'Recovering', 'Recovering_Pending', 'Suspect', 'Emergency', 'Offline', 'Copying', 'Offline_Secondary')]
        $DatabaseStatusWarning      = 'Offline',
        [ValidateSet('Online', 'Restoring', 'Recovering', 'Recovering_Pending', 'Suspect', 'Emergency', 'Offline', 'Copying', 'Offline_Secondary')]
        $DatabaseStatusCritical     = 'Emergency',
        [array]$IncludeDatabase     = @(),
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost            = "localhost",
        [int]$SqlPort               = 1433,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$NoPerfData         = $FALSE,
        $IncludeDays                = $null,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                  = 0
    )

    $SqlConnection         = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort;
    $BackupSet             = Get-IcingaMSSQLBackupOverallStatus -SqlConnection $SqlConnection -IncludeDatabase $IncludeDatabase -IncludeDays $IncludeDays;
    $InstanceName          = Get-IcingaMSSQLInstanceName -SqlConnection $SqlConnection;
    $CheckPackage          = New-IcingaCheckPackage -Name ([string]::Format('MSSQL Backup ({0})', $InstanceName)) -OperatorAnd -Verbose $Verbosity -IgnoreEmptyPackage;

    Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;

    foreach ($Backup in $BackupSet.Keys) {
        $BackupObject = $BackupSet[$Backup].backup;

        $DBPackage = New-IcingaCheckPackage -Name $Backup -OperatorAnd -Verbose $Verbosity;

        $DBPackage.AddCheck(
            (New-IcingaCheck -Name 'Size' -Unit 'b' -Value $BackupObject.TotalBackupSize -MetricIndex $Backup -MetricName 'size').WarnOutOfRange($TotalBackupSizeWarning).CritOutOfRange($TotalBackupSizeCritical)
        );
        $DBPackage.AddCheck(
            (New-IcingaCheck -Name 'Average Size' -Unit 'b' -Value $BackupObject.AvgBackupSize -MetricIndex $Backup -MetricName 'averagesize').WarnOutOfRange($AvgBackupSizeWarning).CritOutOfRange($AvgBackupSizeCritical)
        );
        $DBPackage.AddCheck(
            (New-IcingaCheck -Name 'Log age' -Unit 's' -Value $BackupObject.LastBackupLogAge -MetricIndex $Backup -MetricName 'logage').WarnOutOfRange($LastBackupLogAgeWarning).CritOutOfRange($LastBackupLogAgeCritical)
        );
        $DBPackage.AddCheck(
            (New-IcingaCheck -Name 'Age' -Unit 's' -Value $BackupObject.LastBackupAge -MetricIndex $Backup -MetricName 'age').WarnOutOfRange($LastBackupAgeWarning).CritOutOfRange($LastBackupAgeCritical)
        );
        $DBPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name 'Execution Time' `
                    -Unit 's' `
                    -Value $BackupObject.ExecutionTime `
                    -MetricIndex $Backup `
                    -MetricName 'executiontime'
            ).WarnOutOfRange($ExecutionTimeWarning).CritOutOfRange($ExecutionTimeCritical)
        );
        $DBPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name 'Status' `
                    -Value $BackupObject.Status `
                    -Translation $MSSQLProviderEnums.MSSQLDatabaseState `
                    -ObjectExists $BackupObject.Status `
                    -MetricIndex $Backup `
                    -MetricName 'state'
            ).WarnIfMatch($MSSQLProviderEnums.MSSQLDatabaseStateName[$DatabaseStatusWarning]).CritIfMatch($MSSQLProviderEnums.MSSQLDatabaseStateName[$DatabaseStatusCritical])
        );

        $CheckPackage.AddCheck($DBPackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -Compile -NoPerfData $NoPerfData);
}
