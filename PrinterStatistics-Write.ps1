Set-Location C:\Results\PrinterStatistics\Folders
$Date = Get-Date -Format "MMMM-dd-yyyy"
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$Yesterday = Get-Date $Yesterday -Format "MMMM-dd-yyyy"
New-Item -Name $Date -ItemType Directory -ErrorAction:Inquire| Out-Null
Set-Location C:\Results\PrinterStatistics\Folders\$Date

$CSVData = Import-CSV -Path \\PC1380\Results\Printers.csv
ForEach ($Entry in $CSVData) {
	Write-Progress -Activity "Collecting Logs" -Status $Entry.Name -PercentComplete (($Count / $CSVData.Count) * 100)
	$Name = $Entry.Name + "-Stat.html"
	$Name2 = $Entry.Name + "-Info.html"
	# $Name3 = $Entry.Name + "-Offline.txt"
	$IP = $Entry.IP | Out-String
	$NewIP = $IP.Trim()
    If (Test-Connection $Entry.IP -Quiet -Count 1 -ErrorAction:SilentlyContinue){
		# Write-Output $Name
		$ProgressPreference = 'SilentlyContinue' 
		Invoke-WebRequest -OutFile $Name -Uri http://$NewIP/cgi-bin/dynamic/printer/config/reports/devicestatistics.html
		Invoke-WebRequest -OutFile $Name2 -Uri http://$NewIP/cgi-bin/dynamic/printer/config/reports/deviceinfo.html
		$ProgressPreference = 'Continue'
	}
	Else {
		# New-Item -Name $Name3 -ItemType File
	}
	$Count ++
}

Clear-Host

$Files = Get-ChildItem
$Files = $Files.Name

Write-Output "Name-Type,Data" | Out-File -FilePath "Totals.csv"

Set-Location C:\Results\PrinterStatistics\Folders
attrib +h $Date

Set-Location C:\Results\PrinterStatistics\Folders\$Date

ForEach ($File in $Files) {
	If ($File -Like "*Info.html") {
		$Content = Get-Content $File

		ForEach ($Line in $Content) {
			If ($Line -Like "*Page&nbsp;Count*") {
				$PageCount = $Line
			}
		}

		$PageCount = $PageCount -replace '<TR><td width = 270><p align="left" style="margin-left: 10;">Page&nbsp;Count</p></td><td><p> =  |'; $PageCount = $PageCount -replace ' </p></td>|'

		$PrinterName = $File -replace "-Info.html|"

		Write-Output "$PrinterName-PageCount,$PageCount" | Out-File -FilePath "Totals.csv" -Append
	}
	ElseIf ($File -Like "*Stat.html") {
		$Content = Get-Content $File

		ForEach ($Line in $Content) {
			If ($Line -Like '<TR><td><p align="left" style="margin-left: 40;">Total</p></td><td><p>*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* </p></td>') {
				$JobCount = $Line
			}
		}
		
		$JobCount = $JobCount -replace '<TR><td><p align="left" style="margin-left: 40;">Total</p></td><td><p>|'; $JobCount = $JobCount -replace ' |'; $JobCount = $JobCount -replace '</p></td>|'

		For ($Count = 0; $Count -lt 10; $Count ++) {
			$JobCount = $JobCount -replace "&nbsp;$Count|"
		}
		$JobCount = $JobCount -replace '&nbsp;|'

		$PrinterName = $File -replace "-Stat.html|"

		Write-Output "$PrinterName-JobCount,$JobCount" | Out-File -FilePath "Totals.csv" -Append
	}
}

Set-Location C:\Results\PrinterStatistics

Remove-Item -Path "All*.txt" -ErrorAction:SilentlyContinue

Get-ChildItem C:\Results\PrinterStatistics\Folders -Directory -Hidden | ForEach-Object {$FolderCount++}

Function Comparison {
	param(
		[switch]$Daily,
		[switch]$All
	)

	If ($Daily){
		$OldDate = (Get-Date) - (New-TimeSpan -Day 1)
		$OldDate = Get-Date $OldDate -Format "MMMM-dd-yyyy"
	}
	If ($All){
		$FolderCount2 = $FolderCount - 1
		$OldDate = (Get-Date) - (New-TimeSpan -Day $FolderCount2)
		$OldDate = Get-Date $OldDate -Format "MMMM-dd-yyyy"
	}

	$OldDateData = Import-CSV -Path "\\PC1380\Results\PrinterStatistics\Folders\$OldDate\Totals.csv"
	$OldDateMapping = @{}
	ForEach ($Entry in $OldDateData) {
		$OldDateMapping[$Entry."Name-Type"] = $Entry."Data"
	}

	Function Get-Count {
		Param (
			[string]$Data
		)
		If ($OldDateMapping.ContainsKey($Data)) {
			Return $OldDateMapping[$Data]
		}
		Else {
			Return "Data not found."
		}
	}

	$TodayData = Import-CSV -Path "C:\Results\PrinterStatistics\Folders\$Date\Totals.csv"

	$Comparisons = ForEach ($Entry in $TodayData) {
		$TodayCount = $Entry.Data
		$OldDateCount = Get-Count -Data $Entry."Name-Type"
		$NewCount = $TodayCount - $OldDateCount
		$NT = $Entry."Name-Type" | Out-String
		$NT = $NT.Trim()
		Write-Output "$NT : $NewCount"
	}

	Write-Output ==============================================
	Write-Output "Job Counts"
	Write-Output ==============================================

	ForEach ($Thing in $Comparisons){
		If ($Thing -Like "*-JobCount*"){
			$Replacement = $Thing -replace "-JobCount|"
			Write-Output $Replacement
		}
	}

	Write-Output ==============================================
	Write-Output "Page Counts"
	Write-Output ==============================================

	ForEach ($Thing in $Comparisons){
		If ($Thing -Like "*-PageCount*"){
			$Replacement = $Thing -replace "-PageCount|"
			Write-Output $Replacement
		}
	}
}

Comparison -Daily | Out-File -FilePath "Folders\$Date\DailyValue.txt"
Comparison -All | Out-File -FilePath "All-($FolderCount Days).txt"