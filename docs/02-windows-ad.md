# 2. Windows Server 2022: Active Directory

## Create the VM
- 2 vCPU, 4 GB RAM, 60 GB disk
- Network: **Internal Network** → `LAB-LAN`
- ISO: Windows Server 2022, the 180-day evaluation from the [Microsoft Evaluation Center](https://www.microsoft.com/evalcenter)
- During installation, pick **Standard (Desktop Experience)** to get a graphical interface.

## Base configuration (PowerShell as administrator)
```powershell
# Check the network adapter name (usually "Ethernet")
Get-NetAdapter

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.10.10 -PrefixLength 24 -DefaultGateway 10.0.10.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.10.1
Rename-Computer -NewName DC01 -Restart
```

## Promote it to a domain controller
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName "lab.internal" -DomainNetbiosName "LAB" -InstallDns `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password") -Force
```
The server restarts on its own, and its DNS setting changes to point at itself (`127.0.0.1`).

After the restart, log in as `LAB\Administrator` and forward external DNS lookups to pfSense:
```powershell
Add-DnsServerForwarder -IPAddress 10.0.10.1
Resolve-DnsName google.com   # must return an answer
```

## Users, groups and OUs
Copy [`scripts/create-users.ps1`](../scripts/create-users.ps1) to the domain controller and run:
```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\create-users.ps1
```
The script creates:
- the OUs `Users`, `Computers`, `Servers` and `Groups`;
- one group per department;
- 4 users, including the service account `svc_backup`.

You can run it again without creating duplicates.

Check the result in **Active Directory Users and Computers** (`dsa.msc`).

## 📸 Screenshots to take
- `dsa.msc` showing the OUs and users
- Server Manager showing the AD DS and DNS roles

## For "Lessons learned"
- What a domain, forest, OU and GPO are
- Why AD depends on DNS: clients find the domain controller through SRV records
- Kerberos, and why the clocks have to be in sync
