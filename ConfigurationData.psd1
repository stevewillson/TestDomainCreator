@{
	AllNodes = @(
		@{
			NodeName = '*'
			PsDscAllowDomainUser = $true
            PsDscAllowPlainTextPassword = $true
		},
		@{
			NodeName = '10.0.0.10'
            Purpose = 'Domain Controller'
            WindowsFeatures = 'AD-Domain-Services'
        }
    )
    # future add functionality to import users from a csv file
    NonNodeData = @{
        DomainName = 'test.local'
        AdGroups = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        OrganizationalUnits = 'Accounting','Information Systems','Executive Office','Janitorial Services'
        AdUsers = @(
            @{
                FirstName = 'Katie'
                LastName = 'Green'
                Department = 'Accounting'
                Title = 'Manager of Accounting'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Blow'
                Department = 'Information Systems'
                Title = 'System Administrator'
            }
            @{
                FirstName = 'Joe'
                LastName = 'Schmoe'
                Department = 'Information Systems'
                Title = 'Software Developer'
            }
            @{
                FirstName = 'Barack'
                LastName = 'Obama'
                Department = 'Executive Office'
                Title = 'CEO'
            }
            @{
                FirstName = 'Donald'
                LastName = 'Trump'
                Department = 'Janitorial Services'
                Title = 'Custodian'
            }
        )
    }
}
