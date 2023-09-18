Set-Location C:\Results\PrinterStatistics
$Date = Get-Date -Format "MMMM-dd-yyyy"
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$Yesterday = Get-Date $Yesterday -Format "MMMM-dd-yyyy"
New-Item -Name $Date -ItemType Directory | Out-Null
Set-Location C:\Results\PrinterStatistics\$Date

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
		Invoke-WebRequest -OutFile $Name -Uri http://$NewIP/cgi-bin/dynamic/printer/config/reports/devicestatistics.html
		Invoke-WebRequest -OutFile $Name2 -Uri http://$NewIP/cgi-bin/dynamic/printer/config/reports/deviceinfo.html
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

Set-Location C:\Results\PrinterStatistics
attrib +h $Date

ForEach ($File in $Files) {
	If ($File -Like "*Info.html") {
		$Content = Get-Content $Date/$File

		ForEach ($Line in $Content) {
			If ($Line -Like "*Page&nbsp;Count*") {
				$PageCount = $Line
			}
		}

		$PageCount = $PageCount -replace '<TR><td width = 270><p align="left" style="margin-left: 10;">Page&nbsp;Count</p></td><td><p> =  |'; $PageCount = $PageCount -replace ' </p></td>|'

		$PrinterName = $File -replace "-Info.html|"

		Write-Output "$PrinterName-PageCount,$PageCount" | Out-File -FilePath "$Date\Totals.csv" -Append
	}
	ElseIf ($File -Like "*Stat.html") {
		$Content = Get-Content $Date/$File

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

		Write-Output "$PrinterName-JobCount,$JobCount" | Out-File -FilePath "$Date\Totals.csv" -Append
	}
}

$YesterdayData = Import-CSV -Path "C:\Results\PrinterStatistics\$Yesterday\Totals.csv"
$YesterdayMapping = @{}
ForEach ($Entry in $YesterdayData) {
    $YesterdayMapping[$Entry."Name-Type"] = $Entry."Data"
}

Function Get-Count {
    Param (
        [string]$Data
    )
    If ($YesterdayMapping.ContainsKey($Data)) {
        Return $YesterdayMapping[$Data]
    }
	Else {
        Return "Data not found."
    }
}


$TodayData = Import-CSV -Path "C:\Results\PrinterStatistics\$Date\Totals.csv"

$Comparisons = ForEach ($Entry in $TodayData) {
	$TodayCount = $Entry.Data
	$YesterdayCount = Get-Count -Data $Entry."Name-Type"
	$NewCount = $TodayCount - $YesterdayCount
	$NT = $Entry."Name-Type" | Out-String
	$NT = $NT.Trim()
	Write-Output "$NT : $NewCount"
}

Write-Output ============================================== | Out-File -FilePath "$Date.txt"
Write-Output "Page Counts" | Out-File -FilePath "$Date.txt" -Append
Write-Output ============================================== | Out-File -FilePath "$Date.txt" -Append

ForEach ($Thing in $Comparisons){
	If ($Thing -Like "*-JobCount*"){
		$Replacement = $Thing -replace "-JobCount|"
		Write-Output $Replacement | Out-File -FilePath "$Date.txt" -Append
	}
}

Write-Output ============================================== | Out-File -FilePath "$Date.txt" -Append
Write-Output "Job Counts" | Out-File -FilePath "$Date.txt" -Append
Write-Output ============================================== | Out-File -FilePath "$Date.txt" -Append

ForEach ($Thing in $Comparisons){
	If ($Thing -Like "*-PageCount*"){
		$Replacement = $Thing -replace "-PageCount|"
		Write-Output $Replacement | Out-File -FilePath "$Date.txt" -Append
	}
}

Write-Output "" | Out-File -FilePath "All.txt" -Append
Write-Output ---------------------------------------------- | Out-File -FilePath "All.txt" -Append
Write-Output "" | Out-File -FilePath "All.txt" -Append
Write-Output $Date | Out-File -FilePath "All.txt" -Append
Get-Content -Path "$Date.txt" | Out-File -FilePath "All.txt" -Append

