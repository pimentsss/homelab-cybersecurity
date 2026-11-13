# 1. pfSense: firewall and network segmentation

## VirtualBox networks
You don't need to create anything separately. An "Internal Network" is created as soon as you type its name in a VM's network adapter settings.

## Create the VM
- Type: **BSD / FreeBSD (64-bit)**, 1 vCPU, 1 GB RAM, 16 GB disk
- Network adapters:
  - Adapter 1: **NAT** (WAN)
  - Adapter 2: **Internal Network** → `LAB-LAN`
  - Adapter 3: **Internal Network** → `LAB-ATTACK`
- ISO: pfSense CE, from [pfsense.org](https://www.pfsense.org/download/)

## Installation and console
1. Install with the default options (ZFS or UFS, either is fine).
2. When asked to assign interfaces, set **WAN = em0**, **LAN = em1**, **OPT1 = em2**. Don't set up any VLANs.
3. From the console menu, choose **2) Set interface(s) IP address**:
   - LAN: `10.0.10.1/24`, enable DHCP with the range `10.0.10.100`–`10.0.10.199`
   - OPT1: `10.0.20.1/24`, enable DHCP with the range `10.0.20.100`–`10.0.20.199`

## Web interface
The web interface can only be reached from the LAN. The first time, temporarily connect Kali to `LAB-LAN` and open `https://10.0.10.1`. The default login is `admin` / `pfsense`.

1. In the setup wizard, set the hostname to `pfsense`, the domain to `lab.internal` and your time zone. **Change the admin password.**
2. Under **Interfaces → OPT1**, rename the interface to `ATTACK` and save.
3. Under **Services → DHCP Server**, set the DNS server to `10.0.10.10` (the domain controller) on both the **LAN** and **ATTACK** tabs. This lets every machine resolve domain names.

## Firewall rules (Firewall → Rules → ATTACK)
A new OPT interface starts with **no rules**, so it blocks all traffic. Add these rules in this order:

| # | Action | Source | Destination | Why |
|---|---|---|---|---|
| 1 | Block | ATTACK net | This Firewall | The attacker can't reach the firewall's management interface |
| 2 | Pass | ATTACK net | any | The attacker can reach the lab and the internet |

Rules are checked **top to bottom**, and the first match wins. If you swap the order, the block rule never takes effect.

When you're done, move Kali back to `LAB-ATTACK`.

## 📸 Screenshots to take
- The dashboard showing all 3 interfaces
- The ATTACK interface rules

## For "Lessons learned"
- Stateful vs stateless rules: reply traffic is allowed automatically
- Why rule order matters
- Network segmentation: an attacker on a separate network only reaches what the firewall allows
