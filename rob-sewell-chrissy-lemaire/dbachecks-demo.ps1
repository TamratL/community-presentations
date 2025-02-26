﻿break

# To get started
Install-Module Pester -SkipPublisherCheck
Update-Module Pester -Force
Import-Module Pester -Force



# Perform a basic check
Invoke-DbcCheck -SqlInstance localhost\sql2017 -Checks SuspectPage, LastBackup

# How do we know which checks exist and if we should specify SqlInstance or ComputerName?
Get-DbcCheck | Out-GridView
Get-DbcCheck *disk*
Invoke-DbcCheck -SqlInstance localhost\sql2017 -Checks ValidDatabaseOwner

# Make a server list
$servers = "localhost\sql2017","localhost\sql2016"
$servers = Get-DbaCmsRegServer -SqlInstance localhost\sql2017
$servers = Get-Content C:\scripts\servers.txt
$servers = Get-ADComputer -Filter "name -like '*sql*'"

# Run statically - set once
Set-DbcConfig -Name app.sqlinstance -Value $servers
Set-DbcConfig -Name app.computername -Value localhost
Invoke-DbcCheck -Checks SuspectPage, LastBackup
Invoke-DbcCheck -Checks DiskCapacity

# Or Dynamically
Invoke-DbcCheck -SqlInstance $sqlservers -Checks SuspectPage, LastBackup
Invoke-DbcCheck -ComputerName $computers -Checks DiskCapacity

# How do we know which configs exist?
Get-DbcConfig | Out-GridView

# A little more advanced which runs all Database Checks except backups - also passes an alternative credential
Invoke-DbcCheck -Check Database -ExcludeCheck Backup -SqlInstance localhost\sql2016 -SqlCredential (Get-Credential sqladmin)

# Run checks and export its JSON
Invoke-DbcCheck -SqlInstance localhost\sql2017 -Checks SuspectPage, LastBackup -Show Summary -PassThru | 
Update-DbcPowerBiDataSource

# You can also split it up by environment
Invoke-DbcCheck -SqlInstance $prod -Checks LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Production
Invoke-DbcCheck -SqlInstance $dev -Checks LastBackup -Show Summary -PassThru  | Update-DbcPowerBiDataSource -Environment Development
Invoke-DbcCheck -SqlInstance $test -Checks LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Test

# Launch Power BI then hit refresh
Start-DbcPowerBi

# Prefer email? Also easy:
Invoke-DbcCheck -SqlInstance localhost\sql2017 -Checks SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru |
Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer localhost

# Have specific requirements and want to add your own checks? Add your own repo! *
Set-DbcConfig -Name app.checkrepos -Value C:\temp\checks -Append

# What does our repo look like?
Invoke-Item "$(Split-Path (Get-Module dbachecks).Path)\checks"
Start-Process https://dbachecks.io/wiki

# Set a global, persistent credential
Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential sqladmin)

# Questions!
