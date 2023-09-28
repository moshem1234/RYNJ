$Message = Get-Content \\PC1380\Results\PrinterStatus.txt | Out-String

If ($Message.Length -le 255){
	msg.exe * "$Message"
}

Else {
	msg.exe * "$Message".Substring(0,255)
	msg.exe * "$Message".Substring(255,$Message.Length-256)
}