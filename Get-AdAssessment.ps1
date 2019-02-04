<#
  .SYNOPSIS
  Reports domain and server configuration data

  .DESCRIPTION
   Used to document failed mailboxs during a migration for verification and troubleshooting purposes
   Saves workbook is same directory as script. This script requires the ImportExcel module for PowerShell.
   https://github.com/dfinke/ImportExcel
   https://www.powershellgallery.com/packages/ImportExcel/4.0.11

  .PARAMETER ClientName
  Client name will be appended to the exported file name

  .EXAMPLE
  .\Get-ServerData 'Company Name'

  .OUTPUTS
  Company Name_MigrationBatchStats.xlsx

  .NOTES
#>

Param 
    (
    [Parameter(Mandatory=$true)]
    [string]$ClientName
    )

Import-Module activedirectory
$domain = Get-ADDomain
$forest = Get-ADForest
$DCs = Get-ADDomainController -Filter *
$servers = Get-ADComputer -LDAPFilter "(&(objectcategory=computer)(OperatingSystem=*server*))"


## functions
function Get-Servers {
    foreach($server in $servers)
        {
       $name = $server.Name
         if(Test-Connection $name -Count 1 -Quiet)
            {                
            Get-ADComputer -Filter {Name -eq $name} -Properties * | select Name,OperatingSystem,@{n="IP Address";`
            e={$_.IPv4Address}} | fl
            $roles = Get-WindowsFeature | ? {$_.Installed -and $_.DisplayName -notlike "*tools*"} |`
             ? {$_.displayName -notlike "*shell*"} | ? {$_.displayName -notlike "*.net*"} | ? {$_.displayName -notlike "*64*"} | ? {$_.displayName -notlike "*support*"}               
            $roles.displayname              
            }
        }
    }