<# Connect with uipath orshestrator and schedule a process #>

param(
    $OrchestratorUrl="",
    $TenantName="",
    $ConfigFile = "",
    $OrcUserName = "",
    $OrcPassword = ""
   )


Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Queue Configuration"
Write-Output $ConfigFile

$authtoken = Get-UiPathAuthToken -Session -URL $OrchestratorUrl -TenantName $TenantName -Username $OrcUsername -Password $OrcPassword
$objExcel = New-Object -ComObject Excel.Application  
$Config = $objExcel.Workbooks.Open($ConfigFile) 
#Write-Output $Config.FullName 
# Loop through all items in the excel  
$QueueConfig = $Config.worksheets.Item("QueueConfiguration")
#Write-Output $QueueConfig.Name
    $QueuRange = $QueueConfig.UsedRange
    $totalNoOfRecords = $QueuRange.Rows.Count
    #Write-Output $totalNoOfRecords
    $totalNoOfQueues = $totalNoOfRecords - 1  
    if ($totalNoOfRecords -gt 1) 
    {  
        #Loop to get values from excel file  
        for ($i= 2; $i -le $totalNoOfRecords; $i++) 
        {  
            $QueueName = $QueueConfig.Cells.Item($i,1).text  
            $QueueDescription = $QueueConfig.Cells.Item($i, 2).text
            [bool]$EnforceUniqueRef = [bool]$QueueConfig.Cells.Item($i, 3).text
            [bool]$AutoRetry = [bool]$QueueConfig.Cells.Item($i, 4).text
            $MaxRetry = [int32]$QueueConfig.Cells.Item($i, 5).text
            $TimeOut = [int32]$QueueConfig.Cells.Item($i, 6).text
            $FolderName = $QueueConfig.Cells.Item($i, 7).text
            #Write-Output  $QueueName $QueueDescription, $EnforceUniqueRef, $AutoRetry
            
            Set-UiPathCurrentFolder -FolderPath $FolderName -AuthToken $authtoken

           if ($AutoRetry -and $EnforceUniqueRef)
            {
                Add-UiPathQueueDefinition -Name $QueueName -AcceptAutomaticallyRetry -AuthToken $authtoken -Description $QueueDescription  -EnforceUniqueReference -MaxNumberOfRetries $MaxRetry -RequestTimeout $TimeOut
            }
            elseif ( -not $AutoRetry -and -not $EnforceUniqueRef)
            {
                Add-UiPathQueueDefinition -Name $QueueName -AuthToken $authtoken -Description $QueueDescription -MaxNumberOfRetries $MaxRetry -RequestTimeout $TimeOut
            }
            elseif ( -not $AutoRetry -and  $EnforceUniqueRef)
            {
                Add-UiPathQueueDefinition -Name $QueueName -AuthToken $authtoken -Description $QueueDescription  -EnforceUniqueReference -MaxNumberOfRetries $MaxRetry -RequestTimeout $TimeOut
            }
            else
            {
                Add-UiPathQueueDefinition -Name $QueueName -AcceptAutomaticallyRetry -AuthToken $authtoken -Description $QueueDescription  -MaxNumberOfRetries $MaxRetry -RequestTimeout $TimeOut
            }

        }  
    } 
    else
    {
    Write-Output "No Queues to Configure"
    } 
#}

$Config.Close()
$objExcel.Quit()
 

Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Queue Configuration"


