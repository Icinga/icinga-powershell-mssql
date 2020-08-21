<#
.SYNOPSIS
    Returns the full, proper path of a Performance Counter DB row,
    like '\SQLServer:Buffer Manager\Buffer cache hit ratio'
.DESCRIPTION
    Returns the full, proper path of a Performance Counter DB row,
    like '\SQLServer:Buffer Manager\Buffer cache hit ratio'
    More Information on https://github.com/Icinga/icinga-powershell-mssql
.FUNCTIONALITY
    Returns the full, proper path of a Performance Counter DB row,
    like '\SQLServer:Buffer Manager\Buffer cache hit ratio'
.EXAMPLE
    PS>Get-IcingaMSSQLPerfCounterPathFromDBObject -DBObject $dbrow;
    '\SQLServer:Buffer Manager\Buffer cache hit ratio'
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

function Get-IcingaMSSQLPerfCounterPathFromDBObject()
{
    param (
        $DBObject = $null
    );

    if ($null -eq $DBObject) {
        return '';
    }

    if ([string]::IsNullOrEmpty($DBObject.instance_name)) {
        return (
            [string]::Format(
                '\{0}\{1}',
                $DBObject.object_name,
                $DBObject.counter_name
            )
        );
    } else {
        return (
            [string]::Format(
                '\{0}({1})\{2}',
                $DBObject.instance_name,
                $DBObject.object_name,
                $DBObject.counter_name
            )
        );
    }
}
