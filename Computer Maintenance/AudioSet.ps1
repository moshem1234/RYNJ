Param (
	[String]$PCName
	# [Switch]$Newline,
	# [Switch]$PC
)

If ($PCName) {
	Invoke-Command -ComputerName $PCName -ScriptBlock {
		Install-Module -Name AudioDeviceCmdlets
		# If ($Newline) {
			Get-AudioDevice -List | Where-Object {$_.Name -Like 'Newline*'} | Set-AudioDevice
		# }
		# ElseIf ($PC) {

		# }
		# Else {

		# }
	}
}
Else {
	Write-Error "No PCName Specified. Please try again"
}