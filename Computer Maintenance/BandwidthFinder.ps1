$PCs = ConnectionTest -Online -OutArray
Write-Progress -Activity "Running Bandwidth Finder"
$List = Invoke-Command -ComputerName $PCs -ScriptBlock {Get-NetAdapter -Name Ethernet} | Select-Object @{name='Room'; expression={Get-RoomNumber -PCName $_.PSComputerName}},PSComputerName,LinkSpeed
$List | Where-Object LinkSpeed -EQ '100 Mbps' | Sort-Object -Property Room
Write-Progress -Activity "Running Bandwidth Finder" -Completed