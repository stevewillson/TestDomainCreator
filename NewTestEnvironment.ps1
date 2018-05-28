# Steve Willson
# 5/20/18
# Forked from https://github.com/adbertram/TestDomainCreator

configuration NewTestEnvironment
{        
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    $pwd = ConvertTo-SecureString "ReallyStrongPassword123!@#" -AsPlainText -Force

    $defaultAdUserCred = New-Object System.Management.Automation.PSCredential("test\Administrator",$pwd)
    $domainSafeModeCred = New-Object System.Management.Automation.PSCredential('(Password Only)',$pwd)
            
    Node $AllNodes.where({ $_.Purpose -eq 'Domain Controller' }).NodeName
    {

        @($ConfigurationData.NonNodeData.ADGroups).foreach( {
                xADGroup $_
                {
                    Ensure = 'Present'
                    GroupName = $_
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

# Overwrite these areas to receive OUs from another source

        @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach( {
                xADOrganizationalUnit $_
                {
                    Ensure = 'Present'
                    Name = ($_ -replace '-')
                    Path = ('DC={0},DC={1}' -f ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

        @($ConfigurationData.NonNodeData.ADUsers).foreach( {
                xADUser "$($_.FirstName) $($_.LastName)"
                {
                    Ensure = 'Present'
                    DomainName = $ConfigurationData.NonNodeData.DomainName
                    GivenName = $_.FirstName
                    SurName = $_.LastName
                    UserName = ('{0}{1}' -f $_.FirstName.SubString(0, 1), $_.LastName)
                    Department = $_.Department
                    Path = ("OU={0},DC={1},DC={2}" -f $_.Department, ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
                    JobTitle = $_.Title
                    Password = $defaultAdUserCred
                    DependsOn = '[xADDomain]ADDomain'
                }
            })

        ($Node.WindowsFeatures).foreach( {
                WindowsFeature $_
                {
                    Ensure = 'Present'
                    Name = $_
                }
            })        
        
        xADDomain ADDomain          
        {             
            DomainName = $ConfigurationData.NonNodeData.DomainName
            DomainAdministratorCredential = $domainSafeModeCred
            SafemodeAdministratorPassword = $domainSafeModeCred
            DependsOn = '[WindowsFeature]AD-Domain-Services'
        }
    }         
}

# Need to get the content of the ConfigurationData.psd1 file and store in the $ConfigurationData variable
Write-Host 'Getting ConfigData from local file'
$configDataFilePath = ".\ConfigurationData.psd1"
$ConfigurationData = Invoke-Expression (Get-Content -Path $configDataFilePath -Raw)

NewTestEnvironment -ConfigurationData $ConfigurationData

# This will prompt for the 'Administrator' credentials and use those to setup the environment
# need to use the same Admininstrator credentials on all machines

Start-DscConfiguration -path .\NewTestEnvironment -Wait -Force -Credential Administrator
