# route53


# tell what domain name you want, include the root dot (example: ibuildirun.com.)
$zoneName = ".rockportapp.com."
$zoneId = Get-R53HostedZoneList |  Where-Object {$_.Name -eq $zoneName}
$zoneId | get-member
$strZoneId = $zoneId.Id.ToString().Replace('/hostedzone/', '')
$strZoneId


$rRecords = Get-R53ResourceRecordSet -HostedZoneId $strZoneId
$rRecord = $rRecords.ResourceRecordSets | Where-Object { $_.Name -eq '{r53test.rockportapp.com.' }
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
  'Name' = '<hostname>';             # just the subdomain/hostname
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
  'Name' = '<hostname>';
  'Ttl' = 30;
  'Comment' = '';
  'Force' = $true
}

# alias record splat
$aliasSplat = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = '<host.exampleFQDN.com.>';
  'Name' = 'Primary';
  'AliasRecord' = $true;
  'EvaluateTargetHealth' = $false;
  'Comment' = '';
  'Force' = $true
}


.\Manage-R53RecordSet.ps1 @parms -Verbose

# let's do some loops
$originRecords = @{}
$originRecords['r53test-web1'] = '174.143.127.78'
$originRecords['r53test-web2'] = '174.143.127.79'
$originRecords['r53test-web3'] = '148.62.46.183'
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
$aliasRecords.add('r53test-Primary','r53test-web1.rockportapp.com.')
$aliasRecords.add('r53test-Secondary','r53test-web2.rockportapp.com.')
$aliasRecords.add('r53test-tertiary','r53test-web3.rockportapp.com.')
$aliasRecords.add('r53test','r53test-Primary.rockportapp.com.com.')

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
$aliasSplat['Name'] = 'r53test'
$aliasSplat['Value'] = 'r53test-Secondary'
$aliasSplat
.\Manage-R53RecordSet.ps1 @aliasSplat -Verbose  

