##############################################################################
##
## Compress/Uncompress Methods by 7z(seven zip)
## powershell封装7zip压缩和解压缩方法
## by Scott Wong (https://github.com/scottshare/powershell)
##
##############################################################################

## 7z exe file path
$SevenZipExePath ="$PSScriptRoot\thirdparty\7z1701-extra\7za.exe"

<#
.SYNOPSIS
Compress file by 7z 使用7zip压缩指定文件
.PARAMETER Source
File path 需要压缩的文件目录路径
.PARAMETER Destination
The full path of zip 生成的压缩包全路径
.PARAMETER FilterConfig
Regular list for ignore files 目录中需要忽略的文件规则列表
#>
function Compress-7Z{
    [CmdletBinding()]
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $Source,
        [string]
        [Parameter(Mandatory = $true)]
        $Destination,
        [string]
        $FilterConfig
    )
    if($FilterConfig)
    {
        if(Test-Path $FilterConfig){
            iex -Command "& $SevenZipExePath a $Destination $Source\* -x@$FilterConfig" 
        }
        return
    }
    iex -Command "& $SevenZipExePath a $Destination $Source\*" 
}

<#
.SYNOPSIS
Uncompress file by 7z 使用7zip解压
.PARAMETER Source
Zip file path 需要解压的文件全路径
.PARAMETER Destination
Directory path for uncompress 解压后存放路径

#>
function Expand-7Z{
    [CmdletBinding()]
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $Source,
        [string]
        [Parameter(Mandatory = $true)]
        $Destination
    )
    iex -Command "& $SevenZipExePath x $Source -o$Destination -aoa"
}