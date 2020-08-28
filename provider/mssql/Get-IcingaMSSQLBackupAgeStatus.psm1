 <#
.SYNOPSIS
    Checks overall Backupstatus metrics inside the MSSQL database by fetching
    metrics and compares them to input thresholds
.DESCRIPTION
    Checks overall Backupstatus metrics inside the MSSQL database by fetching
    metrics and compares them to input thresholds
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    Checks overall Backupstatus metrics inside the MSSQL database by fetching
    metrics and compares them to input thresholds
.EXAMPLE
    PS> Get-IcingaMSSQLBackupOverallStatus -SqlUsername 'username' -SqlPassword (ConvertTo-IcingaSecureString 'password') -SqlHost 'example.com';
    [OK] Check package "MSSQL Backup"
    | 'status'=0;6;5 'size'=10110976b;; 'execution_time'=0s;; 'age'=144000s;; 'average_size'=3370325.333333b;; 'status'=0;6;5 'size'=12664832b;;
    'execution_time'=0s;; 'age'=493200s;; 'average_size'=6332416b;; 'status'=0;6;5 'size'=33445888b;; 'execution_time'=0s;; 'age'=144000s;; 'average_size'=16722944b;;
.EXAMPLE
    PS>Get-IcingaMSSQLBackupOverallStatus -IntegratedSecurity -SqlHost 'example.com' -IncludeDatabase 'ExampleDatabase','AnotherDatabase';
    [OK] Check package "MSSQL Backup"
    | 'status'=0;6;5 'size'=12664832b;; 'execution_time'=0s;; 'age'=493200s;; 'average_size'=6332416b;; 'status'=0;6;5 'size'=10110976b;;
    'execution_time'=0s;; 'age'=144000s;; 'average_size'=3370325.333333b;;
.PARAMETER SqlConnection
    Use an already existing and established SQL object for query handling. Otherwise leave it empty and use the
    authentication by username/password or integrate security
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
.INPUTS
    System.Array
.OUTPUTS
    System.Collections.Hashtable
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

 function Get-IcingaMSSQLBackupOverallStatus
{
   param (
        $SqlConnection              = $null,
        [array]$IncludeDatabase     = @(),
        [string]$SqlUsername,
        [securestring]$SqlPassword,
        [string]$SqlHost            = "localhost",
        [int]$SqlPort               = 1433,
        [switch]$IntegratedSecurity = $FALSE
    );

    [bool]$NewSqlConnection = $FALSE;

    if ($null -eq $SqlConnection) {
        $SqlConnection = Open-IcingaMSSQLConnection -Username $SqlUsername -Password $SqlPassword -Address $SqlHost -IntegratedSecurity:$IntegratedSecurity -Port $SqlPort;
        $NewSqlConnection = $TRUE;
    }

    $Query = "SELECT
                msdb.dbo.backupset.database_name,
                msdb.dbo.backupset.backup_start_date,
                msdb.dbo.backupset.backup_finish_date,
                msdb.dbo.backupset.is_damaged,
                msdb.dbo.backupset.type,
                msdb.dbo.backupset.backup_size,
				msdb.dbo.backupset.backup_set_uuid,
                msdb.dbo.backupmediafamily.physical_device_name,
                msdb.dbo.backupmediafamily.device_type,
                sys.databases.state,
                sys.databases.recovery_model,
                DATEDIFF(HH, msdb.dbo.backupset.backup_finish_date, GETDATE()) AS last_backup_hours,
                DATEDIFF(MI, msdb.dbo.backupset.backup_start_date,  msdb.dbo.backupset.backup_finish_date) AS last_backup_duration_min
            FROM msdb.dbo.backupmediafamily
                INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
                LEFT JOIN sys.databases ON sys.databases.name = msdb.dbo.backupset.database_name WHERE sys.databases.source_database_id IS NULL
            ORDER BY
                msdb.dbo.backupset.database_name,
                msdb.dbo.backupset.backup_finish_date"

    $SqlCommand              = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $Query;
    $Data                    = Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;

    if ($NewSqlConnection -eq $TRUE) {
        Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;
    }

    [hashtable]$Backupdata = @{}

    foreach ($Entry in $Data) {
        if ($IncludeDatabase.Count -ne 0 -And ($IncludeDatabase -Contains $Entry.database_name) -eq $FALSE) {
            continue;
        }

        Add-IcingaHashtableItem `
            -Hashtable $Backupdata `
            -Key $Entry.database_name `
            -Value @{
                'backup'  = @{};
                'history' = @();
            } | Out-Null;

        [hashtable]$LastBackup = Get-IcingaHashtableItem -Hashtable $Backupdata[$Entry.database_name] -Key 'backup' -NullValue @{};
        [array]$BackupHistory  = Get-IcingaHashtableItem -Hashtable $Backupdata[$Entry.database_name] -Key 'history' -NullValue @();
        [string]$BackupDrive   = '';

        if ($Entry.physical_device_name -match '\:' ) {
            $BackupDrive = $Entry.physical_device_name.Substring(0, [Math]::Min($Entry.physical_device_name.Length, 2));
        }

        if ($Entry.type -eq 'L') {
            $LastBackupLogAge = ($Entry.last_backup_hours * 60 * 60)
        } else {
            $LastBackupLogAge = $null
        }

        $TotalBackupSize = (Get-IcingaHashtableItem -Hashtable $LastBackup -Key 'TotalBackupSize' -NullValue 0) + $Entry.backup_size;

        [hashtable]$CurrentBackup = @{
            'TotalBackupSize'  = $TotalBackupSize;
            'AvgBackupSize'    = ($TotalBackupSize / ([Math]::Max($BackupHistory.Count, 1)));
            'UUID'             = $Entry.backup_set_uuid;
            'StartDate'        = $Entry.backup_start_date;
            'FinishDate'       = $Entry.backup_finish_date;
            'IsDamaged'        = $Entry.is_damaged;
            'Type'             = $Entry.type;
            'LastBackupLogAge' = $LastBackupLogAge;
            'LastBackupAge'    = ($Entry.last_backup_hours * 60 * 60);
            'ExecutionTime'    = ($Entry.last_backup_duration_min * 60);
            'Location'         = $Entry.physical_device_name;
            'Drive'            = $BackupDrive;
            'Status'           = $Entry.state;
            'DeviceType'       = $Entry.device_type;
            'TotalBackups'     = $BackupHistory.Count;
        };

        Add-IcingaHashtableItem -Hashtable $Backupdata[$Entry.database_name] -Key 'backup' -Value $CurrentBackup -Override | Out-Null;

        [hashtable]$HistoryEntry = $CurrentBackup.Clone();

        Remove-IcingaHashtableItem -Hashtable $HistoryEntry -Key 'TotalBackupSize';
        Remove-IcingaHashtableItem -Hashtable $HistoryEntry -Key 'AvgBackupSize';
        Remove-IcingaHashtableItem -Hashtable $HistoryEntry -Key 'TotalBackups';

        $BackupHistory += $HistoryEntry;

        Add-IcingaHashtableItem -Hashtable $Backupdata[$Entry.database_name] -Key 'history' -Value $BackupHistory -Override | Out-Null;
    }

    return $Backupdata;
}
