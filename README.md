# Powershell封装方法介绍

## 发送文件到远程电脑
> Send-File
``` powershell
## 引用脚本库
. "$PSScriptRoot\Remote-Methods.ps1"
## 创建远程会话
$session = Create-Session -UserName "Remote computer login Name" -Password "Remote computer login Password" -IP "IP address of the remote computer"
## 发送文件
Send-File -Source "E:\demo\test.zip" -Destination "E:\demo\test.zip" -Session $session
```

## 调用远程命令
> Send-Command
``` powershell
## 引用脚本库
. "$PSScriptRoot\Remote-Methods.ps1"
## 创建远程会话
$session = Create-Session -UserName "Remote computer login Name" -Password "Remote computer login Password" -IP "IP address of the remote computer"
## 调用指令
Send-Command -Session $session {
    param([string]$FilePath)
    Remove-Item $FilePath -Force
    } -ArgumentList "E:\demo\test.zip"
```

## 压缩文件
> Compress-7Z
``` powershell
. "$PSScriptRoot\Compress-Methods.ps1"
Compress-7Z -Source "E:\demo\hel" -Destination "E:\hel.7z"
## 压缩文件有时候需要忽略目录中某些文件，参考如下方法
###1. 创建一个记事本文件比如exclude.txt,名字可以任意取
###2. 在该文件中写入需要忽略的内容，参考如下
###   Files
###   Log
###   TempFiles
###   Temp
###   MakePriceLog
###   ParamValueFiles
###   ProcessFiles
###   *.rar
###   *.zip
###   *.7z
###   bin\*.rar
###   bin\*.zip
###   bin\*.7z
###3. 调用压缩方法
Compress-7Z -Source "E:\demo\hel" -Destination "E:\hel.7z" -FilterConfig "E:\exclude.txt"
```

## 解压文件
> Expand-7Z
``` powershell
. "$PSScriptRoot\Compress-Methods.ps1"
Expand-7Z -Source "E:\hel.7z" -Destination "E:\demo\hel"
```
