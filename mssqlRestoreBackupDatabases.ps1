##########################################################################################################
## Author: Netrunner
## License: GNU General Public License v3.0
## Description: Restore backed up databases granularly on a MSSQL instance.
##########################################################################################################
## Usage: Change the $variables and magically restore backed up databases with prompts in a loop.
##########################################################################################################

$server_name = "serverHostname"
$date_string_yesterday = (Get-Date).AddDays(-1).ToString('yyy-MM-dd')
$date_string = (Get-Date).ToString('yyy-MM-dd')
$server_instance_path = "${server_name}\DEVMSSQLSERVER"
$server_backup_path = "${server_name}_backup"

$database_array = (Get-SqlDatabase -ServerInstance $server_name | select Name).Name

# These are predetermined system databases
$system_databases = @("DWConfiguration","DWDiagnostics","DWQueue","master","model","msdb","tempdb")
$user_databases = New-Object System.Collections.Generic.List[System.Object]

foreach($iterated_database in $database_array) {
    if($system_databases -notcontains $iterated_database) {
        $user_databases.Add($iterated_database)
    }
}

foreach($iterated_database in $user_databases) {
    $result_disk = ""
    $result_log = ""

    # First, prompt if we want to skip this database
    try {
        $result = (Invoke-Sqlcmd -ServerInstance $server_instance_path -ErrorAction 'Stop' -Query "RESTORE FILELISTONLY FROM DISK = N'E:\$server_backup_path\${iterated_database}_$date_string_yesterday.bak' WITH NOUNLOAD" | Select PhysicalName).PhysicalName
        $result_disk = $result[0]
        $result_log = $result[1]
    } catch {
        Write-Host "Skipping ${iterated_database} - No Backup Exists for Yesterday"
        continue
    }

    if($result_disk -ne "" -and $result_log -ne "") {
        $confirm = Read-Host -Prompt "Type 'Y' to reclone ${iterated_database}"
        if($confirm -eq "Y") {
            Invoke-Sqlcmd -ServerInstance "$server_instance_path" -Query "Drop database $iterated_database;"
            Write-Host "Dropped database ${iterated_database}"
            $result_disk = $result_disk -replace "MSSQLSERVER", "DEVMSSQLSERVER"
            $result_log = $result_log -replace "MSSQLSERVER", "DEVMSSQLSERVER"
            $relocate_data = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("${iterated_database}", "${result_disk}")
            $relocate_log = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("${iterated_database}_log", "${result_log}")
            Restore-SqlDatabase -ServerInstance $server_instance_path -Database "${iterated_database}" -BackupFile "E:\$server_backup_path\${iterated_database}_$date_string_yesterday.bak" -RelocateFile @($relocate_data,$relocate_log)
            Write-Host "Restored database ${iterated_database}"
        } else {
            Write-Host "Skipping ${iterated_database} - Did not confirm"
        }
    } else {
        Write-Host "Skipping ${iterated_database} - Problem with mdf/ldf files"
        continue
    }
}
