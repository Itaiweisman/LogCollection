$date=get-date
$ts=$date.ToString('MMddyyyyhhmm')
$collection="\infini_collection_"
$date=get-date
$ts=$date.ToString('MMddyyyyhhmm')
$collection="\infini_collection_"
$collection+=$ts
$directory=$env:temp
if (Test-Path $directory) {
    $directory+=$collection 
    $directory+=$ts
    $out=new-item $directory -itemtype directory
    if (-Not $out ) {
        Exit-PSSession
    }
}
else {
    Exit-PSSession
}

$commands =  $trees = @("Get-InitiatorPort","Get-InitiatorId","Get-Partition","Get-maskingset","Get-OffloadDataTransferSetting","Get-volume","Get-Iscsiconnection","Get-Iscsisession", "get-iscsitarget", "get-service", "get-netroute", "get-netadapter", "get-netipaddress")
foreach ($command in $commands) {
    $outfile=$directory+"\"+$command+".out"
    Write-Host "writing to" + $outfile
    Invoke-Expression $command | Out-File -Filepath $outfile 2>&1
}
$cutoff=-4
$date_cut=(get-date).adddays($cutoff)
$outfile=$directory+"\system_event_log"
Write-Host "Getting System Event Log"
get-eventlog -log system -after $date_cut | format-list | out-file  $outfile
$outfile=$directory+"\application_event_log"
Write-Host "Getting Application Event Log"
get-eventlog -log application -after $date_cut | format-list | out-file  $outfile
$outfile=$directory+"\system_info"
 Get-WMIObject win32_operatingsystem | out-file $outfile
$zip=$directory+".zip"
compress-archive -path $directory -DestinationPath $zip
write-host "Collection Done, Collection in"+$zip

start  $env:temp