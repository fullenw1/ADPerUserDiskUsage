function Get-ADPerUserDiskUsage
{
    <#
    .SYNOPSIS
        Get the disk usage for each Active Directory user including the home directory and all profiles versions

    .PARAMETER Identity

        Specifies an Active Directory user object by providing one of the following property values. The identifier in parentheses is the LDAP display name for the attribute.

          Distinguished Name
            Example:  CN=SaraDavis,CN=Europe,CN=Users,DC=corp,DC=contoso,DC=com
          GUID (objectGUID)
            Example: 599c3d2e-f72d-4d20-8a88-030d99495f20
          Security Identifier (objectSid)
            Example: S-1-5-21-3165297888-301567370-576410423-1103
          SAM account name  (sAMAccountName)
            Example: saradavis

        The cmdlet searches the default naming context or partition to find the object. If two or more objects are found, the cmdlet returns a non-terminating error.

        This parameter can also get this object through the pipeline or you can set this parameter to an object instance.

        This example shows how to set the parameter to a distinguished name.
          -Identity  "CN=SaraDavis,CN=Europe,CN=Users,DC=corp,DC=contoso,DC=com"

        This example shows how to set this parameter to a user object instance named "userInstance".
          -Identity   $userInstance

    .PARAMETER Filter

        Specifies a query string that retrieves Active Directory objects. This string uses the PowerShell Expression Language syntax. The PowerShell Expression Language syntax provides rich
        type-conversion support for value types received by the Filter parameter. The syntax uses an in-order representation, which means that the operator is placed between the operand and the value. For
        more information about the Filter parameter, see about_ActiveDirectory_Filter.

        Syntax:
        The following syntax uses Backus-Naur form to show how to use the PowerShell Expression Language for this parameter.

        <filter>  ::= "{" <FilterComponentList> "}"

        <FilterComponentList> ::= <FilterComponent> | <FilterComponent> <JoinOperator> <FilterComponent> | <NotOperator>  <FilterComponent>

        <FilterComponent> ::= <attr> <FilterOperator> <value> | "(" <FilterComponent> ")"

        <FilterOperator> ::= "-eq" | "-le" | "-ge" | "-ne" | "-lt" | "-gt"| "-approx" | "-bor" | "-band" | "-recursivematch" | "-like" | "-notlike"

        <JoinOperator> ::= "-and" | "-or"

        <NotOperator> ::= "-not"

        <attr> ::= <PropertyName> | <LDAPDisplayName of the attribute>

        <value>::= <compare this value with an <attr> by using the specified <FilterOperator>>

        For a list of supported types for <value>, see about_ActiveDirectory_ObjectModel.

        Examples:
        The following examples show how to use this syntax with Active Directory cmdlets.

        To get all objects of the type specified by the cmdlet, use the asterisk wildcard:
        All user objects:
        Get-ADUser -Filter *
          -or-
        All computer objects:
        Get-ADComputer -Filter *

        To get all user objects that have an e-mail message attribute, use one of the following commands:
        Get-ADUser -Filter {EmailAddress -like "*"}
        Get-ADUser -Filter {mail -like "*"}
          -or-
        Get-ADObject -Filter {(mail -like "*") -and (ObjectClass -eq "user")}

        Note: PowerShell wildcards other than "*", such as "?" are not supported by the Filter syntax.

        To get all users objects that have surname of Smith and that have an e-mail attribute, use one of the following commands:
        Get-ADUser -filter {(EmailAddress -like "*") -and (Surname  -eq "smith")}
          -or-
        Get-ADUser -filter {(mail -eq "*") -and (sn -eq "Smith")}

        To get all user objects who have not logged on since January 1, 2007, use the following commands:
        $logonDate = New-Object System.DateTime(2007, 1, 1)
        Get-ADUser  -filter { lastLogon -le $logonDate  }

        To get all groups that have a group category of Security and a group scope of Global, use one of the following commands:
        Get-ADGroup  -filter {GroupCategory  -eq "Security"  -and GroupScope -eq "Global"}
          -or-
        Get-ADGroup -filter {GroupType -band 0x80000000}

        Note: To query using LDAP query strings, use the LDAPFilter parameter.

    .PARAMETER Searchbase

        Specifies an Active Directory path to search under.

        When you run a cmdlet from an Active Directory provider drive, the default value of this parameter is the current path of the drive.

        When you run a cmdlet outside of an Active Directory provider drive against an AD DS target, the default value of this parameter is the default naming context of the target domain.

        When you run a cmdlet outside of an Active Directory provider drive against an AD LDS target, the default value is the default naming context of the target LDS instance if one has been specified
        by setting the msDS-defaultNamingContext property of the Active Directory directory service agent (DSA) object (nTDSDSA) for the AD LDS instance.  If no default naming context has been specified
        for the target AD LDS instance, then this parameter has no default value.

        The following example shows how to set this parameter to search under an OU.
          -SearchBase "ou=mfg,dc=noam,dc=corp,dc=contoso,dc=com"

        When the value of the SearchBase parameter is set to an empty string and you are connected to a GC port, all partitions will be searched. If the value of the SearchBase parameter is set to an
        empty string and you are not connected to a GC port, an error will be thrown.
        The following example shows how to set this parameter to an empty string.   -SearchBase ""

    .PARAMETER SearchScope

        Specifies the scope of an Active Directory search. Possible values for this parameter are:
          Base or 0
          OneLevel or 1
          Subtree or 2

        A Base query searches only the current path or object. A OneLevel query searches the immediate children of that path or object. A Subtree query searches the current path or object and all children
        of that path or object.

        The following example shows how to set this parameter to a subtree search.
          -SearchScope Subtree

        The following lists the acceptable values for this parameter:

        Base

        OneLevel

        Subtree

    .PARAMETER ResultPageSize

        Specifies the number of objects to include in one page for an Active Directory Domain Services query.

        The default is 256 objects per page.

        The following example shows how to set this parameter.
          -ResultPageSize 500

    .PARAMETER ResultSetSize

        Specifies the maximum number of objects to return for an Active Directory Domain Services query. If you want to receive all of the objects, set this parameter to $null (null value). You can use
        Ctrl+c to stop the query and return of objects.

        The default is $null.

        The following example shows how to set this parameter so that you receive all of the returned objects.
          -ResultSetSize $null

    .EXAMPLE

        Get-PerUserDiskUsage -ProgressBar

        Description
        -----------
        Get disk usage of all Active Directory users and displays a progress bar

    .EXAMPLE

        Get-PerUserDiskUsage -Identity JonDoe

        Description
        -----------
        Get disk usage of SAMAccount JonDoe

    .EXAMPLE

        Get-PerUserDiskUsage -Filter {Name -like "*Sam*"} -ResultSetSize 4

        Description
        -----------
        Get disk usage of the first four users which name contains "Sam"

    .NOTES

        The cmdlet will leverage the Get-ChildItem2 cmdlet if installed on computers where you store profiles and homes.

        Permissions needed for the account running the script:

            - Enumerate properties of Active Directory users
            - Enumerate SMB shares on the profiles and home directories servers
            - Read files and folders of users' profiles and homes directories
    #>

    [Alias('gpudu')]

    [CmdletBinding(DefaultParameterSetName = 'Filter')]

    [OutputType('System.Array')]

    param(
        [Parameter(ParameterSetName = 'Identity')]
        [string]$Identity,

        [Parameter(ParameterSetName = 'Filter')]
        [string]$Filter = '*',

        [Parameter(ParameterSetName = 'Filter')]
        [string]$SearchBase,

        [Parameter(ParameterSetName = 'Filter')]
        [ValidateSet('Base','OneLevel','Subtree')]$SearchScope = 'Subtree',

        [Parameter(ParameterSetName = 'Filter')]
        [int]$ResultPageSize = $null,

        [Parameter(ParameterSetName = 'Filter')]
        [int]$ResultSetSize = $null,

        [switch]$ProgressBar
    )

    Begin{
        #Requires -Modules ActiveDirectory

        if($PSBoundParameters['Debug']){$DebugPreference = 'Continue'}

        #region Get-User cmdlet parameters
        $Params = @{
            Properties  = 'ProfilePath', 'HomeDirectory'
        }

        switch($PSCmdlet.ParameterSetName)
        {
        'Identity' {$Params.Identity = $Identity}

        'Filter' {
                $Params.Filter  = $Filter

                If($PSBoundParameters['SearchBase'])
                {$Params.SearchBase  = $SearchBase}

                If($PSBoundParameters['SearchScope'])
                {$Params.SearchScope = $SearchScope}

                If($PSBoundParameters['ResultPageSize'])
                {$Params.ResultPageSize  = $ResultPageSize}

                If($PSBoundParameters['ResultSetSize'])
                {$Params.ResultSetSize  = $ResultSetSize}
            }
        }
        #endregion

        If($PSBoundParameters['Debug'])
        {$Params | Out-String | Write-Debug}

        $UserList = Get-ADUser @Params

        $UserDataList = [System.Collections.ArrayList]::new($UserList.Count)
    }

    Process{

        foreach ($User in $UserList) {

            If($PSBoundParameters['Debug'])
            {$User | Write-Debug}

            If($PSBoundParameters['Verbose'])
            {Write-Verbose -Message "User: $($User.Name)"}

            If(($PSBoundParameters['ProgressBar']) -and ($UserList.Count -gt 1))
            {
                $Params = @{
                    Id              = 1
                    Activity        = 'Gathering user info'
                    PercentComplete = ($UserList.IndexOf($User)/$UserList.Count*100)
                    Status          = "$($User.Name) ($(($UserList.IndexOf($User))+1) of $($UserList.Count))"
                }

                Write-Progress @Params
            }

            $UserData = [PSCustomObject]@{
                'User'                               = $User.Name
                'SamAccount'                         = $User.SamAccountName
                'Frozen'                             = $false
                'Profile Path'                       = $User.ProfilePath
                'Win XP profile size in Mb'          = 0
                'Win 7 profile size in Mb'           = 0
                'Win 8 profile size in Mb'           = 0
                'Win 8.1 profile size in Mb'         = 0
                'Win 10 profile size in Mb'          = 0
                'Win 10 (v14393) profile size in Mb' = 0
                'Home Directory path'                = $User.HomeDirectory
                'Home Directory size'                = 0
            }

            If($User.DistinguishedName -match 'frozen')
            {$UserData.Frozen = $true}

            #region Profile space
            If(($PSBoundParameters['ProgressBar']) -and ($UserList.Count -gt 1))
            {
                $Params = @{
                    Id              = 2
                    ParentId        = 1
                    Activity        = 'Computing disk usage'
                    PercentComplete = 0
                    Status          = 'Profile disk usage'
                }

                Write-Progress @Params
            }

            If($PSBoundParameters['Verbose'])
            {Write-Verbose -Message 'Computing Profiles disk usage...'}

            If($User.ProfilePath)
            {
                $ProfileComputerName = ($User.ProfilePath -split '\\')[2]
                $ProfileShareName = ($User.ProfilePath -split '\\')[3]

                If($PSBoundParameters['Debug'])
                {
                    $ProfileComputerName | Write-Debug
                    $ProfileShareName | Write-Debug
                }

                $Filter = 'Name like "%{0}%"' -f $ProfileShareName
                $ProfileLiteralPathList = (Get-CimInstance -ComputerName $ProfileComputerName -ClassName Win32_Share -Filter $Filter).Path

                If($PSBoundParameters['Debug'])
                {$ProfileLiteralPathList | Out-String | Write-Debug}

                If($ProfileLiteralPathList)
                {
                    foreach($ProfileLiteralPath in $ProfileLiteralPathList)
                    {
                        $ProfileSize = Invoke-Command -ComputerName $ProfileComputerName {
                            $Params = @{
                                Path = $Using:ProfileLiteralPath
                                Recurse = $true
                                Force = $true
                                ErrorAction = 'SilentlyContinue'
                            }

                            If(Get-Command -Name Get-ChildItem2 -ErrorAction SilentlyContinue)
                            {
                                (Get-ChildItem2 @Params |
                                    Measure-Object -Property Length -Sum).Sum/1Mb
                            }
                            else {
                                (Get-ChildItem @Params |
                                    Measure-Object -Property Length -Sum).Sum/1Mb
                            }
                        }

                        if ($ProfileSize)
                        {$ProfileSizeMb = [math]::Round($ProfileSize, 0)}
                        else {$ProfileSizeMb = 0}

                        $ProfileVersion = $ProfileLiteralPath -replace '^.*\.V?'

                        switch ($ProfileVersion)
                        {
                            #Windows 7
                            2 {$UserData.'Win 7 profile size in Mb' = $ProfileSizeMb}

                            #Windows 8
                            3 {$UserData.'Win 8 profile size in Mb' = $ProfileSizeMb}

                            #Windows 8.1
                            4 {$UserData.'Win 8.1 profile size in Mb' = $ProfileSizeMb}

                            #Windows 10
                            5 {$UserData.'Win 10 profile size in Mb' = $ProfileSizeMb}

                            #Windows 10 (version 14393)
                            6 {$UserData.'Win 10 (v14393) profile size in Mb' = $ProfileSizeMb}

                            #Windows XP
                            Default {$UserData.'Win XP profile size in Mb' = $ProfileSizeMb}
                        }
                    }
                }
            }
            #endregion

            #region Home space
            If(($PSBoundParameters['ProgressBar']) -and ($UserList.Count -gt 1))
            {
                $Params = @{
                    Id              = 2
                    ParentId        = 1
                    Activity        = 'Computing disk usage'
                    PercentComplete = 50
                    Status          = 'Home directory disk usage'
                }

                Write-Progress @Params
            }

            If($PSBoundParameters['Verbose'])
            {Write-Verbose -Message 'Computing Home Directory disk usage...'}

            If($User.HomeDirectory)
            {
                $HomeComputerName = ($User.HomeDirectory -split '\\')[2]
                $HomeShareName = ($User.HomeDirectory -split '\\')[3]

                If($PSBoundParameters['Debug'])
                {
                    $HomeComputerName | Write-Debug
                    $HomeShareName | Write-Debug
                }

                $Filter = 'Name like "%{0}%"' -f $HomeShareName
                $HomeLiteralPath = (Get-CimInstance -ComputerName $HomeComputerName -ClassName Win32_Share -Filter $Filter).Path

                If($PSBoundParameters['Debug'])
                {$HomeLiteralPath | Out-String | Write-Debug}

                if ($HomeLiteralPath) {
                    $HomeSize = Invoke-Command -ComputerName $HomeComputerName {
                        $Params = @{
                            Path = $Using:HomeLiteralPath
                            Recurse = $true
                            Force = $true
                            ErrorAction = 'SilentlyContinue'
                        }

                        If(Get-Command -Name Get-ChildItem2 -ErrorAction SilentlyContinue)
                                {
                                    (Get-ChildItem2 @Params |
                                        Measure-Object -Property Length -Sum).Sum/1Mb
                                }
                                else {
                                    (Get-ChildItem @Params |
                                        Measure-Object -Property Length -Sum).Sum/1Mb
                                }
                            }

                    If($HomeSize)
                    {$HomeSizeMb = [math]::Round($HomeSize, 0)}
                    else {$HomeSize = 0}
                }

                $UserData.'Home Directory size' = $HomeSizeMb
            }
            #endregion

            $Null = $UserDataList.Add($UserData)
        }
    }

    End{$UserDataList}
}