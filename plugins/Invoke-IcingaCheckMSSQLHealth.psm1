function Invoke-IcingaCheckMSSQLHealth {
    param (
        $SqlConnection              = $null,
        [string]$Username           = $null,
        [securestring]$Password,
        [string]$Address            = "localhost",
        [switch]$IntegratedSecurity = $FALSE
    )

    $SqlConnection = Open-IcingaMSSQLConnection -IntegratedSecurity:$NewSqlConnectionIntegratedSecurity;
}