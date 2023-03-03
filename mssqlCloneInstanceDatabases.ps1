##########################################################################################################
## Author: Netrunner
## License: GNU General Public License v3.0
## Description: Clonea instances across MSSQL instances.
##########################################################################################################
## Usage: Change the $variables and magically clone databases from one instance to another with prompts in a loop.
##########################################################################################################

$server_name = "serverHostname"
$date_string = (Get-Date).ToString('yyy-MM-dd')
$server_instance_path = "${server_name}\DEVMSSQLSERVER"
$server_backup_path = "${server_name}_backup"

$database_array = (Get-SqlDatabase -ServerInstance $server_name | select Name).Name
$dev_sql_server = New-Object Microsoft.SqlServer.Management.Smo.Server $server_instance_path

# These are predetermined system databases
$system_databases = @("DWConfiguration","DWDiagnostics","DWQueue","master","model","msdb","tempdb")
$user_databases = New-Object System.Collections.Generic.List[System.Object]
$databases_cloned = New-Object System.Collections.Generic.List[System.Object]

foreach($iterated_database in $database_array) {
    if($system_databases -notcontains $iterated_database) {
        $user_databases.Add($iterated_database)
    }
}

foreach($iterated_database in $user_databases) {
    $server_backup_file = "E:\${server_backup_path}\${iterated_database}_clone.bak"
    $server_backup_file_noquotes = $server_backup_file.Replace('"','')

    # Create the backup
    try {
        Backup-SqlDatabase -ServerInstance $server_name -Database "${iterated_database}" -BackupFile $server_backup_file
    } catch {
        Write-Host "Skipping ${iterated_databased} - Unable to create backup"
    }

    $result_disk = ""
    $result_log = ""

    # First, prompt if we want to skip this database
    try {
        $result = (Invoke-Sqlcmd -ServerInstance $server_name -ErrorAction 'Stop' -Query "RESTORE FILELISTONLY FROM DISK = N'$server_backup_file' WITH NOUNLOAD" | Select PhysicalName).PhysicalName
        $result_disk = $result[0]
        $result_log = $result[1]
    } catch {
        Write-Host "Skipping ${iterated_database} - No Backup Exists"
        continue
    }

    if($result_disk -ne "" -and $result_log -ne "") {
        $confirm = Read-Host -Prompt "Type 'Y' to reclone ${iterated_database}"
        if($confirm -eq "Y") {
            Write-Host "Killing connections for ${server_instance_path}"
            $dev_sql_server.KillAllprocesses("${iterated_database}")
            Invoke-Sqlcmd -ServerInstance "$server_instance_path" -Query "Drop database $iterated_database;"
            Write-Host "Dropped database ${iterated_database}"
            $result_disk = $result_disk -replace "MSSQLSERVER", "DEVMSSQLSERVER"
            $result_log = $result_log -replace "MSSQLSERVER", "DEVMSSQLSERVER"
            $relocate_data = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("${iterated_database}", "${result_disk}")
            $relocate_log = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("${iterated_database}_log", "${result_log}")
            Restore-SqlDatabase -ServerInstance $server_instance_path -Database "${iterated_database}" -BackupFile $server_backup_file -RelocateFile @($relocate_data,$relocate_log)
            Write-Host "Restored database ${iterated_database}"
            Remove-Item -Path $server_backup_file_noquotes -Force
            Write-Host "Deleted backup file for ${iterated_database}"
            $databases_cloned.Add($iterated_database)
            continue
        } else {
            Write-Host "Skipping ${iterated_database} - Did not confirm"
            Remove-Item -Path $server_backup_file_noquotes -Force
            Write-Host "Deleted backup file for ${iterated_database}"
            continue
        }
    } else {
        Write-Host "Skipping ${iterated_database} - Problem with mdf/ldf files"
        Remove-Item -Path $server_backup_file_noquotes -Force
        Write-Host "Deleted backup file for ${iterated_database}"
        continue
    }
}

if($databases_cloned -gt 0) {
    $databases_cloned_length = $databases_cloned.Count
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Write-Host "Successfully cloned $databases_cloned_length Databases.."
    Write-Host "~~~~~Manually fix User Permissions for~~~~"
    foreach($iterated_database in $databases_cloned) {
        Write-Host($iterated_database)
    }
    Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    Write-Host "Reminder: Go into Security > Logins > User > Properties > User Mapping > Select the database and dbo.."
    Write-Host "Then go to Database > Properties > Permissions and assign rights there."

} else {
    Write-Host "Clone script complete - no databases cloned."
}
