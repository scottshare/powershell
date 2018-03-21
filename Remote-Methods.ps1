##############################################################################
##
## Remote Call Methods
## powershell远程方法调用
## by Scott Wong (https://github.com/scottshare/powershell)
##
##############################################################################

<#
.SYNOPSIS
Create remote session创建远程会话
.PARAMETER UserName
Login name on the remote computer目标服务器的账户名
.PARAMETER Password
Login password on the remote computer目标服务器的密码
.PARAMETER IP
ip address on the remote computer目标服务器ip地址

#>
function Create-Session{
    [CmdletBinding()]
    param
    (
    [string]
    [Parameter(Mandatory = $true)]
    $UserName,
    [string]
    [Parameter(Mandatory = $true)]
    $Password,
    [string]
    [Parameter(Mandatory = $true)]
    $IP
    )
    $pw   = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object Management.Automation.PSCredential ($UserName, $pw)
    $Session = New-PsSession $IP -Credential $cred
    return $Session
}

<#
.SYNOPSIS
Call command on a remote computer在远程服务上执行指令
.PARAMETER Session
Remote session远程会话
.PARAMETER Action
Remote script block远程执行的脚本块
.PARAMETER ArgumentList
Arguments指令中用到的参数
#>
function Send-Command{
    [CmdletBinding()]
    param(
        ## The path on the local computer
        [Parameter(Mandatory = $true)]
        $Session,
    
        ## The target path on the remote computer
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $Action,
        [Object[]]
        $ArgumentList
    )
    Invoke-Command -Session $Session -ScriptBlock $Action -ArgumentList $ArgumentList
}

<#
.SYNOPSIS
Send file to a remote computer发送文件到远程服务器
.PARAMETER Source
The path on the local computer需要发送的本地文件路径
.PARAMETER Destination
The path on the remote computer目标服务器存放文件的全路径
.PARAMETER Session
ip address on the remote computer目标服务器ip地址

#>
function Send-File{
    [CmdletBinding()]
    param(
        ## The path on the local computer
        [Parameter(Mandatory = $true)]
        $Source,
    
        ## The target path on the remote computer
        [Parameter(Mandatory = $true)]
        $Destination,
    
        [Parameter(Mandatory = $true)]
        $Session
    )

    $remoteScript = {
        param($destination, $bytes)
    
        ## Convert the destination path to a full filesystem path (to support
        ## relative paths)
        $Destination = $executionContext.SessionState.`
            Path.GetUnresolvedProviderPathFromPSPath($Destination)
    
        ## Write the content to the new file
        $file = [IO.File]::Open($Destination, "OpenOrCreate")
        $null = $file.Seek(0, "End")
        $null = $file.Write($bytes, 0, $bytes.Length)
        $file.Close()
    }

    ## Get the source file, and then start reading its content
    $sourceFile = Get-Item $Source
    Send-Command -Session $Session -Action {
        if(Test-Path $args[0]) { Remove-Item $args[0] }
    } -ArgumentList $Destination

    ## Now break it into chunks to stream
    Write-Progress -Activity "Sending $Source" -Status "Preparing file"

    $streamSize = 1MB
    $position = 0
    $rawBytes = New-Object byte[] $streamSize
    $file = [IO.File]::OpenRead($sourceFile.FullName)
    
    while(($read = $file.Read($rawBytes, 0, $streamSize)) -gt 0)
    {
        Write-Progress -Activity "Writing $Destination" `
            -Status "Sending file" `
            -PercentComplete ($position / $sourceFile.Length * 100)
    
        ## Ensure that our array is the same size as what we read
        ## from disk
        if($read -ne $rawBytes.Length)
        {
            [Array]::Resize( [ref] $rawBytes, $read)
        }
    
        ## And send that array to the remote system
        Send-Command -Session $Session $remoteScript `
         -ArgumentList $destination,$rawBytes
    
        ## Ensure that our array is the same size as what we read
        ## from disk
        if($rawBytes.Length -ne $streamSize)
        {
            [Array]::Resize( [ref] $rawBytes, $streamSize)
        }
        
        [GC]::Collect()
        $position += $read
    }
    
    $file.Close()

}