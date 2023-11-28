PowerShell -Command {
	$OldPref = $ErrorActionPreference
	$ErrorActionPreference = 'SilentlyContinue'
	$ManufacturerHash = @{ 
		"AAC" =	"AcerView";
		"ACI" = "ASUS"
		"ACR" = "Acer";
		"AOC" = "AOC";
		"AIC" = "AG Neovo";
		"APP" = "Apple Computer";
		"AST" = "AST Research";
		"AUO" = "Asus";
		"BNQ" = "BenQ";
		"CMO" = "Acer";
		"CPL" = "Compal";
		"CPQ" = "Compaq";
		"CPT" = "Chunghwa Pciture Tubes, Ltd.";
		"CTX" = "CTX";
		"DEC" = "DEC";
		"DEL" = "Dell";
		"DPC" = "Delta";
		"DWE" = "Daewoo";
		"EIZ" = "EIZO";
		"ELS" = "ELSA";
		"ENC" = "EIZO";
		"EPI" = "Envision";
		"FCM" = "Funai";
		"FUJ" = "Fujitsu";
		"FUS" = "Fujitsu-Siemens";
		"GSM" = "LG Electronics";
		"GWY" = "Gateway 2000";
		"HEI" = "Hyundai";
		"HIT" = "Hyundai";
		"HSL" = "Hansol";
		"HTC" = "Hitachi/Nissei";
		"HWP" = "HP";
		"IBM" = "IBM";
		"ICL" = "Fujitsu ICL";
		"IGM" = "V-Seven"
		"IVM" = "Iiyama";
		"KDS" = "Korea Data Systems";
		"LEN" = "Lenovo";
		"LGD" = "Asus";
		"LPL" = "Fujitsu";
		"MAX" = "Belinea"; 
		"MEI" = "Panasonic";
		"MEL" = "Mitsubishi Electronics";
		"MS_" = "Panasonic";
		"NAN" = "Nanao";
		"NEC" = "NEC";
		"NOK" = "Nokia Data";
		"NVD" = "Fujitsu";
		"OPT" = "Optoma";
		"PHL" = "Philips";
		"REL" = "Relisys";
		"SAN" = "Samsung";
		"SAM" = "Samsung";
		"SBI" = "Smarttech";
		"SGI" = "SGI";
		"SNY" = "Sony";
		"SRC" = "Shamrock";
		"SUN" = "Sun Microsystems";
		"SEC" = "Hewlett-Packard";
		"TAT" = "Tatung";
		"TOS" = "Toshiba";
		"TSB" = "Toshiba";
		"VSC" = "ViewSonic";
		"ZCM" = "Zenith";
		"UNK" = "Unknown";
		"_YV" = "Fujitsu";
	}
	# $PCs = Get-Content -Path '\\PC1380\Results\MissingMonitors.txt'
	$PCs = Get-Content -Path '\\PC1380\Scripts\AllPCs.txt'
	$Monitor_Array = @()
	ForEach ($Computer in $PCs) {
		Write-Progress -Activity "Finding Monitors" -Status $Computer -PercentComplete (($count / $PCs.Count) * 100)
		# Write-Output $Computer
		$Room = Get-RoomNumber -PCName $Computer
		If (Test-Connection -ComputerName $Computer -Quiet -Count 1 -ErrorAction SilentlyContinue) {
			$Monitors = Get-WmiObject -Namespace "root\WMI" -Class "WMIMonitorID" -ComputerName $Computer -ErrorAction SilentlyContinue
			ForEach ($Monitor in $Monitors) {
				If ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)) {
					$Mon_Model = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
				}
				Else {
					$Mon_Model = $null
				}
				$Mon_Attached_Computer = ($Monitor.PSComputerName).Replace("$([char]0x0000)","")
				$Mon_Manufacturer = ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")
				If ($Mon_Model -like "*800 AIO*" -or $Mon_Model -like "*8300 AiO*") {Break}
				$Mon_Manufacturer_Friendly = $ManufacturerHash.$Mon_Manufacturer
				If (-not $Mon_Manufacturer_Friendly) {
					$Mon_Manufacturer_Friendly = $Mon_Manufacturer
				}
				$Monitor_Obj = [PSCustomObject]@{
					ComputerName = $Mon_Attached_Computer
					Room = $Room
					Manufacturer     = $Mon_Manufacturer_Friendly
					Model            = $Mon_Model
				}
				$Monitor_Array += $Monitor_Obj
			}
		}
		$Count ++
	}
	$Monitor_Array | Where-Object {$_.Manufacturer -NE 'NWL'} | Sort-Object -Property Room | Format-Table -AutoSize
	$ErrorActionPreference = $OldPref
}