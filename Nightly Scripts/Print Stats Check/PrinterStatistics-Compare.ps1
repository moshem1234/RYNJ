param (
	[Int32]$Days,
	[switch]$Max
)

$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$Yesterday = Get-Date $Yesterday -Format "MMMM-dd-yyyy"

If ($Days) {
	$OldDate = (Get-Date) - (New-TimeSpan -Day $Days)
	$OldDate = Get-Date $OldDate -Format "MMMM-dd-yyyy"
}
ElseIf ($Max) {
	Get-ChildItem C:\Results\PrinterStatistics\Folders -Directory -Hidden | ForEach-Object {$FolderCount++}
	$OldDate = (Get-Date) - (New-TimeSpan -Day $FolderCount)
	$OldDate = Get-Date $OldDate -Format "MMMM-dd-yyyy"
}
Else {
	$OldDate = (Get-Date) - (New-TimeSpan -Day 2)
	$OldDate = Get-Date $OldDate -Format "MMMM-dd-yyyy"
}

$Test = Get-ChildItem -Path "\\PC1380\Results\PrinterStatistics\Folders\$OldDate" -ErrorAction:SilentlyContinue

If ($Test) {
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


	$YesterdayData = Import-CSV -Path "\\PC1380\Results\PrinterStatistics\Folders\$Yesterday\Totals.csv"

	$Comparisons = ForEach ($Entry in $YesterdayData) {
		$YesterdayCount = $Entry.Data
		$OldDateCount = Get-Count -Data $Entry."Name-Type"
		$NewCount = $YesterdayCount - $OldDateCount
		$NT = $Entry."Name-Type" | Out-String
		$NT = $NT.Trim()
		Write-Output "$NT : $NewCount"
	}

	Write-Output ==============================================
	Write-Output "Page Counts"
	Write-Output ==============================================

	ForEach ($Thing in $Comparisons){
		If ($Thing -Like "*-PageCount*"){
			$Replacement = $Thing -replace "-PageCount|"
			# $Replacement = $Replacement -replace ' : ',','
			Write-Output $Replacement
		}
	}

	Write-Output ""
	Write-Output ==============================================
	Write-Output "Job Counts"
	Write-Output ==============================================

	ForEach ($Thing in $Comparisons){
		If ($Thing -Like "*-JobCount*"){
			$Replacement = $Thing -replace "-JobCount|"
			Write-Output $Replacement
		}
	}
}
Else {
	Write-Output "Data Not Available"
}
