# Automatic-Services.ps1 
 
# Varibles used to caluclate number and type of errors if any. 
[int]$intResultWarning = 0 
[int]$intResultError = 0 
[int]$intResultTotal = 0 
 
# List of Services to Ignore. 
$Ignore=@( 
    'Microsoft .NET Framework NGEN v4.0.30319_X64', 
    'Microsoft .NET Framework NGEN v4.0.30319_X86', 
    'Multimedia Class Scheduler', 
    'Performance Logs and Alerts', 
    'SBSD Security Center Service', 
    'Shell Hardware Detection', 
    'Software Protection', 
    'TPM Base Services',
'Remote Registry',
'Openfire_ns',
'Internet Connection Sharing (ICS)',
'HP ProLiant System Shutdown Service',
'HP Insight NIC Agents'
'VMware Physical Disk Helper Service',
'Windows Font Cache Service',
'SQL Server (SQLEXPRESS)',
'SMS Agent Host',
'Windows Search',
'IaasVmProvider',
'Volume Shadow Copy',
'Windows Modules Installer',
'Windows Update',
'Update Services',
'Windows Installer',
'Skype Updater',
'DPMRA',
'NSClientpp (Nagios) 0.3.8.76 2010-05-27 x64',
'OracleMTSRecoveryService',
'McAfee Product Improvement Program',
'HP ProLiant Agentless Management Service',
'Connected Devices Platform Service',
'Windows Biometric Service',
'Downloaded Maps Manager',
'Distributed Link Tracking Client',
'User Access Logging Service',
'Net.Pipe Listener Adapter',
'Net.Tcp Listener Adapter',
'Net.Msmq Listener Adapter',
'Citrix AD Identity Service',
'iQor Package Manager Auto Update',
                'Google Update Service (gupdate)'; 
) 
 
# Get list of services that are not running, not in the ignore list and set to automatic 
$Services=Get-WmiObject Win32_Service -ComputerName '10.3.80.225' -Credential '${CREDENTIAL}' | Where {$_.StartMode -eq 'Auto' -and $Ignore -notcontains $_.DisplayName } 
 
# If any services were found fitting the above description... 
if ($Services) { 
    # Loop through each service in services 
    ForEach ($Service in $Services) { 
<#         # Attempt to restart the service 
        $err = $Service.StartService() 
        # Pause for 1 second 
        Start-Sleep -s 1  #>
        # Re-Get the Service information in order to recheck its status 
        $StoppedService=Get-Service -Displayname $Service.Displayname 
        # If the service failed to restart... 
        If ($StoppedService.Status -ne 'Running') { 
            # Set the error level to 2 (critical) 
            $intResultError = 2 
            # If this is not the first recorded error amend the error text 
            if ($strResultError) { 
                $strResultError=$strResultError + ', ' + $Service.Displayname 
            } 
            # If this is the first or only error set error text 
            ELSE { 
                $strResultError = 'Automatic Services Not Running: ' + $Service.Displayname 
            } 
        } 
        ELSE { 
            # If the service restarted set the warning error level to 1 (warning) 
            $intResultWarning = 1 
            # If this is not the first recorded error amend the error text 
            if ($strResultWarning) { 
            $strResultWarning=$strResultWarning + ', ' + $Service.Displayname 
            } 
            # If this is the first or only error set error text 
            ELSE { 
                $strResultWarning = 'Services restarted: ' + $Service.Displayname 
            } 
        } 
        # Clear the StoppedService varible 
        if ($StoppedService) {Clear-Variable StoppedService} 
    } 
} 
 
# Add the warning error (0 or 1) to the critical error (0 or 2) 
$intResultTotal=$intResultWarning + $intResultError 
 
# Using the sum of the warning errors to the critical errors select the appropriate response 
Switch ($intResultTotal) { 
    # Default/no errors 
    default { 
        write-host 'Message.Services: All automatic started services are running' 
write-host 'Statistic.Services:0'        
exit 0 
    } 
    # Warning error(s) only 
    1 { 
        write-host 'Message.Services:' $strResultWarning;
write-host 'Statistic.Services:1'
        exit 1 
    } 
    # Critical error(s) only 
    2 { 
        write-host 'Message.Services:' $strResultError;
write-host 'Statistic.Services:2'         
exit 2 
    }  
    # Critical and Warning errors 
    3 { 
       write-host 'Message.Services:' $strResultError; 
       write-host 'Message.Services:' $strResultWarning;
write-host 'Statistic.Services:2' 
        exit 2 
    }  
}