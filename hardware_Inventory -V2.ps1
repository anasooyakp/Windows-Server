#Get the server list
$servers = Get-Content -path C:\Users\mcoshdadmin\Downloads\name.txt
Write-Host $servers
#Run the commands for each server in the list
$infoColl = @()
Foreach ($s in $servers)
{
            $PingResult = Test-Connection -ComputerName $s -Count 1 -Quiet
            If($PingResult)
                {
                
                Write-Host  "$s is connected **********************" -ForegroundColor Green
                }
            Else
                {
                Write-Warning "Failed to connect to computer '$s'."
                continue
                }   
       $CPUInfo = Get-WmiObject Win32_Processor -ComputerName $s #Get CPU Information
       $OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information     
       #Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
       $OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
       $OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
       $PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $s | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) } 
    $ComputerIp = Test-Connection -ComputerName $s -Count 1  | Select IPV4Address
    $ComputerIp = $ComputerIp.IPV4Address
    $HWInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $s
    $VMDomain = $HWInfo.Domain
    $ComputerDisks1=""
    $computerfreesize1 = ""
    $ComputerDisks=@()
    $computerfreesize=@()
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ComputerName 
    foreach ($drive  in $drives)
    {
        $dname = $drive.DeviceID
        
        $dsize=  "$([math]::Round($($drive.Size/1GB)))GB"  
        $dfree=  "$([math]::Round($($drive.FreeSpace/1GB)))GB"
        $disk = "$dname = $dsize"
        $dfreesize =  "$dname = $dfree"
        $ComputerDisks  += $disk
        $computerfreesize += $dfreesize
    }
    $ComputerDisks1 = $ComputerDisks -join ','
    $computerfreesize1 = $computerfreesize -join ','    
       Foreach ($CPU in $CPUInfo)
       {
              $infoObject = New-Object PSObject
              #The following add data to the infoObjects.    
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $CPU.SystemName
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "Processor" -value $CPU.Name
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "PhysicalCores" -value $CPU.NumberOfCores
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "LogicalCores" -value $CPU.NumberOfLogicalProcessors
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption
              #Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory
              #Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "IPAddress" -value $ComputerIp
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "Domainname" -value $VMDomain 
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "DataDisks" -value $ComputerDisks1
              Add-Member -inputObject $infoObject -memberType NoteProperty -name "DisksSizeFree" -value $computerfreesize1
                 
              $infoObject #Output to the screen for a visual feedback.
              $infoColl += $infoObject
       }
}
$infoColl | Export-Csv -path C:\Users\mcoshdadmin\Downloads\name.csv
 

