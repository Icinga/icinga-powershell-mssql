@{
    ModuleVersion     = '1.6.0'
    GUID              = '8441b44a-e105-42b7-82c9-8ecf69c13b8b'
    # ModuleToProcess   = 'icinga-powershell-mssql.psm1'
    Author            = 'Lord Hepipud, pdorschner'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2021 Icinga GmbH | GPLv2'
    Description       = 'A collection of Icinga PowerShell MSSQL plugins for the Icinga PowerShell Framework'
    PowerShellVersion = '4.0'
    RequiredModules   = @(
        @{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.10.0' },
        @{ModuleName = 'icinga-powershell-plugins'; ModuleVersion = '1.10.0' }
    )
    NestedModules     = @(
        '.\compiled\icinga-powershell-mssql.ifw_compilation.psm1'
    )
    FunctionsToExport     = @(
        'Import-IcingaPowerShellComponentMSSQL',
        'Invoke-IcingaCheckMSSQLBackupStatus',
        'Invoke-IcingaCheckMSSQLResource',
        'Invoke-IcingaCheckMSSQLPerfCounter',
        'Invoke-IcingaCheckMSSQLHealth'
    )
    CmdletsToExport     = @(
    )
    VariablesToExport     = @(
        'MSSQLProviderEnums'
    )
    PrivateData       = @{
        PSData  = @{
            Tags         = @( 'icinga', 'icinga2', 'mssqlplugins', 'icingamssql', 'icinga2mssql', 'icingawindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-mssql/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-mssql'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-mssql/releases'
        };
        Version  = 'v1.6.0';
        Name     = 'Windows MSSQL';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-mssql'
}

