# Creates the lab's test OUs, groups and users. Safe to run more than once.
Import-Module ActiveDirectory

$domain   = Get-ADDomain
$base     = $domain.DistinguishedName
$password = Read-Host -AsSecureString "Initial password for the users"

# "Users" and "Computers" already exist as default containers (CN=), but these OUs are separate objects
foreach ($ou in "Users", "Computers", "Servers", "Groups") {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'")) {
        New-ADOrganizationalUnit -Name $ou -Path $base
    }
}

$users = @(
    @{ First = "Anna";  Last = "Smith";  Login = "asmith";     Dept = "HR" }
    @{ First = "Bruce"; Last = "Taylor"; Login = "btaylor";    Dept = "IT" }
    @{ First = "Clara"; Last = "Jones";  Login = "cjones";     Dept = "Finance" }
    @{ First = "Svc";   Last = "Backup"; Login = "svc_backup"; Dept = "IT" }
)

foreach ($u in $users) {
    $group = "GRP_$($u.Dept)"
    if (-not (Get-ADGroup -Filter "Name -eq '$group'")) {
        New-ADGroup -Name $group -GroupScope Global -Path "OU=Groups,$base"
    }
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.Login)'")) {
        New-ADUser -Name "$($u.First) $($u.Last)" -GivenName $u.First -Surname $u.Last `
            -SamAccountName $u.Login -UserPrincipalName "$($u.Login)@$($domain.DNSRoot)" `
            -Department $u.Dept -Path "OU=Users,$base" `
            -AccountPassword $password -Enabled $true `
            -ChangePasswordAtLogon ($u.Login -notlike "svc_*")  # service accounts don't log in interactively
    }
    Add-ADGroupMember -Identity $group -Members $u.Login
}

Get-ADUser -Filter * -SearchBase "OU=Users,$base" -Properties Department |
    Format-Table Name, SamAccountName, Department
