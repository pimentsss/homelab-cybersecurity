# 4. Kali: validation and first tests

## Create the VM
- Download the **prebuilt VirtualBox image** from [kali.org](https://www.kali.org/get-kali/#kali-virtual-machines), so there's nothing to install. The default login is `kali` / `kali`.
- 2 vCPU, 4 GB RAM
- Network: **Internal Network** → `LAB-ATTACK` (gets its IP from DHCP)

## Validation tests

| Test | Command | Expected result |
|---|---|---|
| IP assigned | `ip a` | An address in `10.0.20.1xx` |
| Internet | `ping -c 3 8.8.8.8` | Replies |
| Domain DNS | `nslookup dc01.lab.internal` | `10.0.10.10` |
| Reach the DC | `ping -c 3 10.0.10.10` | Replies ¹ |
| Firewall management blocked | `curl -k -m 5 https://10.0.20.1` | Times out |

¹ Windows Firewall blocks ping (ICMP) by default. If the ping fails, move on to nmap.

## Reconnaissance
```bash
# Which machines are on the LAN?
nmap -sn 10.0.10.0/24

# Which services does the domain controller expose?
nmap -sV -p 53,88,135,389,445,636,3389 10.0.10.10
```
On the domain controller you should see the typical Active Directory ports:

| Port | Service |
|---|---|
| 53 | DNS |
| 88 | Kerberos |
| 389 / 636 | LDAP / LDAPS |
| 445 | SMB |

Save the scan to a file with `-oN scan-dc01.txt` and add it to the repository. It's good proof of your work.

## 📸 Screenshots to take
- The nmap scan of the domain controller
- The failing `curl` to the firewall, which shows that the segmentation works

## For "Lessons learned"
- What each domain controller port reveals to an attacker
- How the block rule protects the firewall's management interface

> ⚠️ Only use these tools **on your own lab**. Scanning networks you don't own is illegal.
