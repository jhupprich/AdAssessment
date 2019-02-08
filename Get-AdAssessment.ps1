<#
  .SYNOPSIS
  Reports domain and server configuration data

  .DESCRIPTION
   Used to document Active Directory and Windows server configurations.
   Saves workbook is same directory as script. This script requires the ImportExcel module for PowerShell.
   https://github.com/dfinke/ImportExcel
   https://www.powershellgallery.com/packages/ImportExcel/4.0.11

  .PARAMETER ClientName
  Required parameter.
  Client name will be appended to the exported file name

  .EXAMPLE
  .\Get-ServerData 'Company Name'

  .OUTPUTS
  Company Name_AdAssessment.xlsx

  .NOTES
#>

Param 
    (
    [Parameter(Mandatory=$true)]
    [string]$ClientName
    )

Import-Module activedirectory

## variables
$domain = Get-ADDomain
$forest = Get-ADForest
$DCs = Get-ADDomainController -Filter *
$servers = Get-ADComputer -LDAPFilter "(&(objectcategory=computer)(OperatingSystem=*server*))"
$path = $ClientName + '_AdASsessment.xlsx'
$arr01 = @()


## functions
function Get-Servers {
    foreach($server in $servers)
        {
       $name = $server.Name
         if(Test-Connection $name -Count 1 -Quiet)
            {
                #roles
                Get-ADComputer -Filter {Name -eq $name} -Properties * | Select-Object Name,OperatingSystem,@{n="IP Address";`
                e={$_.IPv4Address}} | fl
                $roles = Get-WindowsFeature | Where-Object {$_.Installed -and $_.DisplayName -notlike "*tools*"} | `
                Where-Object {$_.displayName -notlike "*shell*"} | Where-Object {$_.displayName -notlike "*.net*"} | `
                Where-Object {$_.displayName -notlike "*64*"} | `
                Where-Object {$_.displayName -notlike "*support*"}               
                #$roles.displayname              
            }
        }
    }