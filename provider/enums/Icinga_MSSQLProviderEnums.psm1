[hashtable]$MSSQLBackupType = @{
    'D' = 'Database';
    'L' = 'Log';
    'I' = 'Differential database';
    'F' = 'File or filegroup';
    'G' = 'Differential file';
    'P' = 'Partial';
    'Q' = 'Differential partial';
};

[hashtable]$MSSQLDeviceType = @{
    2   = 'Disk';
    5   = 'Tape';
    7   = 'Virtual device';
    9   = 'Azure Storage';
    105 = 'A permanent backup device';
};

[hashtable]$MSSQLDatabaseState = @{
    0  = 'Online';
    1  = 'Restoring';
    2  = 'Recovering';
    3  = 'Recovering_Pending';
    4  = 'Suspect';
    5  = 'Emergency';
    6  = 'Offline';
    7  = 'Copying';
    10 = 'Offline_Secondary';
};

[hashtable]$MSSQLDatabaseStateName = @{
    'Online'             = 0;
    'Restoring'          = 1;
    'Recovering'         = 2;
    'Recovering_Pending' = 3;
    'Suspect'            = 4;
    'Emergency'          = 5;
    'Offline'            = 6;
    'Copying'            = 7;
    'Offline_Secondary'  = 10;
};

[hashtable]$MSSQLRecoveryModel = @{
    1 = 'Full';
	2 = 'Bulk_Logged';
	3 = 'Simple';
};

[hashtable]$MSSQLProviderEnums = @{
    'MSSQLBackupType'        = $MSSQLBackupType;
    'MSSQLDeviceType'        = $MSSQLDeviceType;
    'MSSQLDatabaseState'     = $MSSQLDatabaseState;
    'MSSQLDatabaseStateName' = $MSSQLDatabaseStateName;
    'MSSQLRecoveryModel'     = $MSSQLRecoveryModel;
}

Export-ModuleMember -Variable @('MSSQLProviderEnums');
