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
$parms = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = '52.52.56.150';
  'Name' = 'web2-west-origin';
  'Ttl' = 30;
  'Comment' = '';
  'Force' = $true
}

# alias record splat
$parms = @{
  'HostedZoneId' = $strZoneId;
  'Type' = 'A';
  'Value' = 'web1-west-origin.ibuildirun.com.';
  'Name' = 'onemoretest';
  'AliasRecord' = $true;
  'EvaluateTargetHealth' = $false;
  'Comment' = '';
  'Force' = $true
}


.\c084fbde81968389d6d1b9e1632e69fd\Manage-R53RecordSet.ps1 @parms -Verbose


