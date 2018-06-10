# route53

# tell what domain name you want, include the root dot (example: ibuildirun.com.)
$zoneName = "ibuildirun.com."
$zoneId = Get-R53HostedZoneList |  Where-Object {$_.Name -eq $zoneName}
$zoneId | get-member
$strZoneId = $zoneId.Id.ToString().Replace('/hostedzone/', '')
$strZoneId



$rRecords = Get-R53ResourceRecordSet -HostedZoneId $strZoneId
$rRecord = $rRecords.ResourceRecordSets | Where-Object { $_.Name -eq 'web2-west-origin.ibuildirun.com.' }
$rRecord.SetIdentifier

# test with the alias object
$alias = New-Object Amazon.Route53.Model.AliasTarget
$alias | get-member

# Manage-R53RecordSet parameters splat
# HostdZoneId, Type Value, Mandatory
# full splat
$parms = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = '52.52.56.150';
  'Name' = 'web2-west-origin';       # just the subdomain/hostname
  'AliasRecord' = '';
  'Weight' = '';
  'HealthCheckId' = '';
  'Failover' = '';
  'TrafficPolicyInstanceId' = '';
  'SetIdentifier' = '';
  'GeoLocation' = '';
  'Ttl' = '';
  'EvaluateTargetHealth' = '';
  'Action' = '';                     # "CREATE","DELETE","UPSERT"
  'Comment' = '';                    # change comment
  'Timeout' = '';
  'Force' = ''
}

# origin record splat
$originSplat = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = '52.52.56.150';
  'Name' = 'web2-west-origin';
  'Ttl' = 30;
  'Comment' = '';
  'Force' = $true
}

# alias record splat
$aliasSplat = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = 'web1-west-origin.ibuildirun.com.';
  'Name' = 'onemoretest';
  'AliasRecord' = $true;
  'EvaluateTargetHealth' = $false;
  'Comment' = '';
  'Force' = $true
}


.\Manage-R53RecordSet.ps1 @parms -Verbose

# let's do some loops
$originRecords = @{}
$originRecords['web1-west-origin'] = '54.177.181.82'
$originRecords['web2-west-origin'] = '52.52.56.150'
$originRecords['web1-east-origin'] = '34.236.99.158'
$originRecords['web2-east-origin'] = '35.170.193.70'
$originRecords

foreach ($i in $originRecords.GetEnumerator()) {
  Write-Host
  Write-Host $i.Key $i.Value
  Write-Host $('=' * 50 )
  $originSplat['Value'] = $i.Value
  $originSplat['Name'] = $i.Key
  $originSplat
  .\Manage-R53RecordSet.ps1 @originSplat -Verbose
}

# needed a special ordered hashtable
$aliasRecords = New-Object System.Collections.Specialized.OrderedDictionary
$aliasRecords.add('Primary','web1-west-origin.ibuildirun.com.')
$aliasRecords.add('Secondary','web2-west-origin.ibuildirun.com.')
$aliasRecords.add('tertiary','web1-east-origin.ibuildirun.com.')
$aliasRecords.add('www','Primary.ibuildirun.com.')

foreach ($i in $aliasRecords.GetEnumerator()) {
  Write-Host
  Write-Host $i.Key $i.Value
  Write-Host $('=' * 50 )
  $aliasSplat['Value'] = $i.Value
  $aliasSplat['Name'] = $i.Key
  $aliasSplat
  .\Manage-R53RecordSet.ps1 @aliasSplat -Verbose  
}

# manually route traffic to a fail over server
$aliasSplat['Value'] = 'Secondary'
$aliasSplat['Name'] = 'www'
$aliasSplat
.\Manage-R53RecordSet.ps1 @aliasSplat -Verbose  


