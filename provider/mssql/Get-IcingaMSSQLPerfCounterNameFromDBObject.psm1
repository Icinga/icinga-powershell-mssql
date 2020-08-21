<#
.SYNOPSIS
    Returns the category name of a Performance Counter DB row,
    like 'SQLServer:Buffer Manager'
.DESCRIPTION
    Returns the category name of a Performance Counter DB row,
    like 'SQLServer:Buffer Manager'
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    Returns the category name of a Performance Counter DB row,
    like 'SQLServer:Buffer Manager'
.EXAMPLE
    PS>Get-IcingaMSSQLPerfCounterNameFromDBObject -DBObject $dbrow;
    'SQLServer:Buffer Manager'
.EXAMPLE
    PS>Get-IcingaMSSQLPerfCounterNameFromDBObject -DBObject $dbrow;
    'Processor(*)'
.PARAMETER DBObject
    Specifies the DB row of the query for which we fetched Performance Counters from
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-mssql
.NOTES
#>

function Get-IcingaMSSQLPerfCounterNameFromDBObject()
{
    param (
        $DBObject = $null
    );

    if ($null -eq $DBObject) {
        return '';
    }

    if ([string]::IsNullOrEmpty($DBObject.instance_name)) {
        return $DBObject.object_name;
    } else {
        return (
            [string]::Format(
                '{0} ({1})',
                $DBObject.counter_name,
                $DBObject.instance_name
            )
        );
    }
}
