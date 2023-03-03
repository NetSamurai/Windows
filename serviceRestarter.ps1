##########################################################################################################
## Author: Netrunner
## License: GNU General Public License v3.0
## Description: Toggle AutoHDR within Windows using parameters
##########################################################################################################
## Usage: Change the $servers and $validServices to match what you want to be able to restart.
## Tip: Use the smart card helper bat file if you want to use a YubiKey.
##########################################################################################################

# Define the list of servers to choose from
$servers = @("someserver1", "server2", "server4")
# Must be a RegEx compatible string [use escapes]
$validServices = @("ColdFusion", "W3SVC", "Oracle", "MSSQLSERVER", "MSSQLSRVR")

# Define the menu options for the server selection
$serverMenuOptions = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt $servers.Count; $i++) {
    $serverMenuOptions.Add($servers[$i])
}

# Define the function to select a server
function Select-Server {
    # Display the server selection menu and get user input
    $serverSelection = ""
    while ($serverSelection -eq "") {
        Clear-Host
        Write-Host "Select a server:" -ForegroundColor Green

        for ($i=1; $i -le $servers.Count; $i++){ 
            Write-Host $i")" $servers[$i-1]
        }
        $serverSelection = Read-Host "Enter option or 'X' to exit"
        if ($serverSelection -le 0 -or $serverSelection -gt $serverMenuOptions.Count ) {
            if($serverSelection -eq "X") {
                exit
            }
            Write-Host "Invalid selection, please try again." -ForegroundColor Red
            $serverSelection = ""
            Start-Sleep 2
        }
    }
    return $serverMenuOptions[$serverSelection-1]
}

# Define the function to select a service and restart it remotely
function Select-Service {
    param (
        [Parameter(Mandatory=$true)]
        [string]$serverName
    )
    # Get the list of services to choose from
    $services = Get-Service -ComputerName $serverName | Select-Object -ExpandProperty Name

    # Define the menu options for the service selection
    $serviceMenuOptions = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $services.Count; $i++) {
        for ($z = 0; $z -lt $validServices.Count; $z++) {
            if( $services[$i] -match ($validServices[$z]) ) {
                $serviceMenuOptions.Add($services[$i])
                break
            }
        }
    }

    # Display the service selection menu and get user input
    $serviceSelection = ""
    while ($serviceSelection -eq "") {
        Clear-Host
        Write-Host "Select a service to restart on $($serverName):" -ForegroundColor Green

        for ($i=1; $i -le $serviceMenuOptions.Count; $i++){ 
            Write-Host $i")" $serviceMenuOptions[$i-1]
        }     

        $serviceSelection = Read-Host "Enter option or 'X' to exit"
        if ($serviceSelection -le 0 -or $serviceSelection -gt $serviceMenuOptions.Count ) {
            if($serviceSelection -eq "X") {
                exit
            }
            Write-Host "Invalid selection, please try again." -ForegroundColor Red
            $serviceSelection = ""
            Start-Sleep 2
        }
    }

    # Restart the selected service
    $serviceName = $serviceMenuOptions[$serviceSelection-1]
    Write-Host "Restarting $($serviceName) on $($serverName)..." -ForegroundColor Green
    Get-Service $serviceName -ComputerName $serverName | Restart-Service -Force
    Write-Host "Service restarted successfully." -ForegroundColor Green
}

# Main loop
$selection = ""
while ($selection -ne "X") {
    $serverName = Select-Server
    Select-Service -serverName $serverName

    # Check if user wants to exit
    $exitSelection = Read-Host "Enter 'X' to exit or any key to restart this prompt.."
    if ($exitSelection -eq "X") {
        $selection = "X"
    }
}
