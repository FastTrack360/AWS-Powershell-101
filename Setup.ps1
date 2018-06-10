# setup
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html
# download msi and install https://aws.amazon.com/powershell/
# install the module as administrator
Install-Module -Name AWSPowerShell

# enable script execution if you have not
Set-ExecutionPolicy RemoteSigned

# check that you see AWSPowerShell there
Get-Module AWSPowerShell

# Intialize to setup up your access keys
Initialize-AWSDefaultConfiguration

