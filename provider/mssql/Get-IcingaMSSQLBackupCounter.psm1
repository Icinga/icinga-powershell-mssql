function Get-IcingaMSSQLBackupAgeStatus {
    param (
        # OptionalParameter
        $SqlConnection                              = $null,
        [bool]$NewSqlConnection                     = $FALSE,
        [string]$NewSqlConnectionUsername,
        [securestring]$NewSqlConnectionPassword,
        [string]$NewSqlConnectionAddress            = "localhost",
        [switch]$NewSqlConnectionIntegratedSecurity = $FALSE
    );

    if ($null -eq $SqlConnection) {
        $SqlConnection                = Open-IcingaMSSQLConnection -IntegratedSecurity:$NewSqlConnectionIntegratedSecurity;
    } else {
        $SqlConnection                = Open-IcingaMSSQLConnection -Username $Username -Password $Password -Address $Address;
    }

    # TODO: Has to be changed a bit
    $OverallDatabaseInformationQuery = "SELECT d.name AS database_name, d.recovery_model, bs1.last_backup, bs1.last_duration, d.state, d.state_desc `
                                        FROM sys.databases d `
                                        LEFT JOIN (`
                                            SELECT bs.database_name, DATEDIFF(HH, MAX(bs.backup_finish_date), GETDATE()) AS last_backup, DATEDIFF(MI, MAX(bs.backup_start_date), MAX(bs.backup_finish_date)) AS last_duration `
                                            FROM msdb.dbo.backupset bs WITH (NOLOCK) `
                                            WHERE bs.type IN ('D', 'I') `
                                            GROUP BY bs.database_name) bs1 `
                                        ON d.name = bs1.database_name `
                                        WHERE d.source_database_id IS NULL"

    $SqlCommand                       = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $OverallDatabaseInformationQuery;
    $Data                             = Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;

    if ($null -ne $SqlConnection) {
        Close-IcingaMSSQLConnection;
    }

    return $Data;
}