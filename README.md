# ADPerUserDiskUsage
Get the disk usage for each Active Directory user including the home directory and all profiles versions

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
