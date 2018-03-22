##############################################################################
##
## Encapsulating methods for managing IIS
## 封装管理iis的相关方法
## by Scott Wong (https://github.com/scottshare/powershell)
## The details of IIS operation can be accessed by the address:https://docs.microsoft.com/zh-cn/iis/manage/powershell/writing-powershell-commandlets-for-iis
##############################################################################

<#
.SYNOPSIS
Stop the specified application pool 停止指定的应用程序池
.PARAMETER PoolName
Application pool Name 应用程序池名
#>
function Stop-IISAppPool ($PoolName) {
    $appPool = get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsApplicationPool" | where-object {$_.Name -eq "W3SVC/AppPools/$PoolName"}
    $appPool.Stop()
}

<#
.SYNOPSIS
Start the specified application pool 启动指定的应用程序池
.PARAMETER PoolName
Application pool Name 应用程序池名
#>
function Start-IISAppPool($PoolName){
    $appPool = get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsApplicationPool" | where-object {$_.Name -eq "W3SVC/AppPools/$PoolName"}
    $appPool.Start()
}

<#
.SYNOPSIS
Printing application pool Information 打印应用程序池信息
.PARAMETER PoolName
Application pool Name 应用程序池名
#>
function Print-IISAppPool($PoolName){
    get-wmiobject -namespace "root\MicrosoftIISv2" -class "IIsApplicationPool" | where-object {$_.Name -eq "W3SVC/AppPools/$PoolName"}
}
