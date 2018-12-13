# step one
# run the stuff in connect
Get-AWSCredential -ListProfileDetail
Set-AWSCredential -ProfileName default

# tell what domain name you want, include the root dot (example: ibuildirun.com.)
$zoneName = "ibuildirun.com."
$zoneId = Get-R53HostedZoneList |  Where-Object {$_.Name -eq $zoneName}
#$zoneId | get-member
$strZoneId = $zoneId.Id.ToString().Replace('/hostedzone/', '')
$strZoneId

$rRecords = Get-R53ResourceRecordSet -HostedZoneId $strZoneId
$rRecords.ResourceRecordSets[0]

# set the ttl
# can't ge this to work at all
foreach ($i in $rRecords.ResourceRecordSets) {
    Write-Host
    Write-Host $i.TTL $i.name
    $aliasSplat['Name'] = $i.name
    $aliasSplat['Ttl'] = '600'
    $aliasSplat
    .\Manage-R53RecordSet.ps1 @aliasSplat -Verbose  

    #$i.TTL = 600
    #Write-Host $i.TTL $i.name
}

# let see if we can get a single item to update
$parms = @{
    'HostedZoneId' = $strZoneId;
    'Name' = '<hostname>';             # just the subdomain/hostname
    'Ttl' = '';
    'Action' = 'UPSERT';                     # "CREATE","DELETE","UPSERT"
    # 'Comment' = '';                    # change comment
    # 'Timeout' = '';
    # 'Force' = ''
  }

.\Manage-R53RecordSet.ps1 @parms -Verbose





# try this guys stuff now

Set-StrictMode -Version Latest


$HOSTED_ZONE_ID = $strZoneId


$changeRequest01 = New-Object -TypeName Amazon.Route53.Model.Change
$changeRequest01.Action = "UPSERT"
$changeRequest01.ResourceRecordSet = New-Object -TypeName Amazon.Route53.Model.ResourceRecordSet
$changeRequest01.ResourceRecordSet.Name = "test1.ibuildirun.com"
$changeRequest01.ResourceRecordSet.Type = "CNAME"
$changeRequest01.ResourceRecordSet.TTL = 600


Edit-R53ResourceRecordSet -HostedZoneId $HOSTED_ZONE_ID -ChangeBatch_Change @($changeRequest01)