<# Connect with uipath orshestrator and schedule a process #>

param(
    $OrchestratorUrl="https://pepwap18050.corp.pep.pvt/",
    $TenantName="IAI_Internal",
    $ConfigFile = "C:\Users\svcIAIDevOpsCICDPL1\Desktop\Script Test_Ambika\Configuration.xlsx",
    $OrcUserName = "Test1",
    $OrcPassword = "Cicdtest@1"

   )


  
Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Process Scheduler"

$authtoken = Get-UiPathAuthToken -Session -URL $OrchestratorUrl -TenantName $TenantName -Username $OrcUserName -Password $OrcPassword
Write-Output $ConfigFile
$objExcel = New-Object -ComObject Excel.Application  
$Config = $objExcel.Workbooks.Open($ConfigFile) 
Write-Output $ConfigFile
# Loop through all items in the excel  
#$Robots = New-Object Collections.Generic.List[String]
#$Robots.Add("corppvt\spaul123")

$ScheduleConfig = $Config.worksheets.Item("ScheduleConfiguration")
#Write-Output $QueueConfig.Name
    $ScheduleRange = $ScheduleConfig.UsedRange
    $totalNoOfRecords = $ScheduleRange.Rows.Count
    #Write-Output $totalNoOfRecords
    $totalNuoOfSchedules = $totalNoOfRecords - 1  
    if ($totalNoOfRecords -gt 1) 
    {  
        #Loop to get values from excel file  
        for ($i= 2; $i -le $totalNoOfRecords; $i++) 
        {  
            Write-Output "Counter value is $i"
            $ProcessName = $ScheduleConfig.Cells.Item($i,1).text 
            $ScheduleName =  $ScheduleConfig.Cells.Item($i,2).text 
            $ProcessCron = $ScheduleConfig.Cells.Item($i,3).text
            $RobotCount = $ScheduleConfig.Cells.Item($i,4).text
            $TimeZone = $ScheduleConfig.Cells.Item($i, 5).text
            $FolderName = $ScheduleConfig.Cells.Item($i, 6).text

                     
            Set-UiPathCurrentFolder -FolderPath $FolderName -AuthToken $authtoken
            $processID = Get-UiPathProcess -Name $ProcessName

            $ProcessSchedule = Get-UiPathProcessSchedule -AuthToken $authtoken -Name $ScheduleName

            if ($ProcessSchedule -ne $null -and $ProcessSchedule.Name.Equals($ScheduleName) )
            {
            Write-Output "A schedule with same name ($ScheduleName) is already exists"
            }
            else
            {
            Write-Output $ScheduleName,$processID,$RobotCount,$ProcessCron,$TimeZone
            Write-output "Schedule $ScheduleName -Process $processID -RobotCount $RobotCount -StartProcessCron $ProcessCron -TimeZoneId $TimeZone"
            #Add-UiPathProcessSchedule $ScheduleName -Process $processID -RobotCount $RobotCount -StartProcessCron $ProcessCron -TimeZoneId $TimeZone
            Add-UiPathProcessSchedule $ScheduleName -Process $processID -RobotCount $RobotCount -StartProcessCron $ProcessCron 
            Write-Output "A schedule $ScheduleName is configured successfully"
            }
           # Add-UiPathProcessSchedule $ScheduleName -Process $processID -Robots $Robots -StartProcessCron $ProcessCron
        }
    }

    else
    {
    Write-Output "No Schedules to Configure"
    }

$Config.Close()
$objExcel.Quit()
Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Process Scheduler"


