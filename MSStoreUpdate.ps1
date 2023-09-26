$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$wmiObj.UpdateScanMethod()
Write-Output "Sleeping to give apps time to update"
Start-Sleep -Seconds 150