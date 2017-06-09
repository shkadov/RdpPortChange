<# 
#
# Changing RDP port on remote server
# for Windows 2008, Windows 2012, Windows 2012 R2, Windows 2016
# by Denys Shkadov
# 
#>

$password = ConvertTo-SecureString "password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("username", $password)
$OS = Invoke-Command -Credential $cred -ComputerName $ip -ScriptBlock {Get-WmiObject -Class Win32_OperatingSystem }
$sel=$OS.Caption
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"


param (

[Parameter (Mandatory=$true)]
[IPADDRESS]$ip,

[Parameter (Mandatory=$true)]
[ValidateRange(3390,65536)]
[int]$port
)



if($sel -like '*Windows 2008*'){
   
    Invoke-Command -Credential $cred -ComputerName $ip -ScriptBlock {
    
    Set-ItemProperty -Path $registryPath -Name PortNumber -Value $port
    
    cmd /c 'netsh advfirewall firewall add rule name = "New RDP Port" protocol=tcp localport=$port action="allow" dir=in profile=domain,private,public '

    $service = Get-Process TermService
    $service, ($service).dependentServices | Restart-Service -Force
    

} 

if($sel -like '*Windows 2012*'){
    
    Invoke-Command -Credential $cred -ComputerName $ip -ScriptBlock {
    
    Set-ItemProperty -Path $registryPath -Name PortNumber -Value $port
    New-NetFirewallRule -Name NewRDP -DisplayName "New RDP Port" -Enabled True -Profile Any -Action Allow -LocalPort $port -Protocol tcp
    
    $service = Get-Process TermService
    $service, ($service).dependentServices | Restart-Service -Force
    
    }

} 


