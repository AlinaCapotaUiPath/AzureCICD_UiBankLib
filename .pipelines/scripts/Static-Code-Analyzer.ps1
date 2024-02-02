# Run UiPath Studio's Workflow Analyzer via command line and pipe results to file #>

param(
    $ProjectFilePath="",
    $ExecutableFilePath="C:\'Program Files (x86)'\UiPath\Studio\UiPath.Studio.CommandLine.exe",
    $OutputFilePath="$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')-Workflow-Analysis.json",
    $ReportFilePath="",
    $ConfigFile=""
    )


Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Staic Code Analyzer"

$Command = "$ExecutableFilePath analyze -p $ProjectFilePath"
Invoke-Expression $Command | Out-File -FilePath $OutputFilePath
$rp = Get-Content $OutputFilePath | foreach {$_.replace("#json","")}

Set-Content -Path $OutputFilePath -Value $rp
#Write-Output $rp
$JO = Get-Content $OutputFilePath | ConvertFrom-Json

#Write-Output $JO.'056582b5-7ca5-414a-a7fd-2effa9d41931-ErrorSeverity'
$totalErros=0

$excel = New-Object -ComObject excel.application 
$workbook = $excel.Workbooks.Add(1)
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "Error-Report"

$worksheet.Cells.Item(1,1) = "Error Code"
$worksheet.Cells.Item(1,2) = "Error Severity"
$worksheet.Cells.Item(1,3) = "Description"
$worksheet.Cells.Item(1,4) = "Recommendation"
$worksheet.Cells.Item(1,5) = "File Path"

$row=2
foreach ($ky in $JO.PSObject.Properties)
{
if ($ky.Name.EndsWith("ErrorCode"))
{
$worksheet.Cells.Item($row,1) = $ky.Value
}
if ($ky.Name.EndsWith("Description"))
{
$worksheet.Cells.Item($row,3) = $ky.Value
}
if ($ky.Name.EndsWith("FilePath"))
{
$worksheet.Cells.Item($row,5) = $ky.Value
}
if ($ky.Name.EndsWith("Recommendation"))
{
$worksheet.Cells.Item($row,4) = $ky.Value
$row++
}

if ($ky.Name.EndsWith("ErrorSeverity"))
{
$worksheet.Cells.Item($row,2) = $ky.Value
if ($ky.Value.Equals("Error"))
{
$totalErros++
}
}

}

$workbook.SaveAs($ReportFilePath)
$workbook.Close
$excel.Quit()


Write-Output "Total Number of Violations = $totalErros"

#Write-Output to pipeline

Write-Output "##vso[task.setvariable variable=totalviolations]$totalErros"

Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Staic Code Analyzer"

#Get-Content $OutputFilePath | ConvertFrom-Json | ConvertTo-Csv | Out-File $CSVFilePath

$objExcel = New-Object -ComObject Excel.Application  
$Config = $objExcel.Workbooks.Open($ConfigFile) 

$TeamConfig = $Config.worksheets.Item("TeamDetails")


$ToEmail = $TeamConfig.Cells.Item(2,1).text             
$CCEmail = $TeamConfig.Cells.Item(2,2).text 


Write-Output "##vso[task.setvariable variable=toemail]$ToEmail"
Write-Output "##vso[task.setvariable variable=ccemail]$CCEmail"

$Config.Close
$objExcel.Quit()


