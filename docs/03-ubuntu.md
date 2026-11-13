# 3. Ubuntu Server 24.04: joining the domain

## Create the VM
- 1 vCPU, 2 GB RAM, 25 GB disk
- Network: **Internal Network** → `LAB-LAN`
- ISO: Ubuntu Server 24.04 LTS, from [ubuntu.com](https://ubuntu.com/download/server)
- During installation, enable **OpenSSH server**.

## Static IP
The easiest way is to set the static IP in the installer itself:
- subnet `10.0.10.0/24`
- address `10.0.10.20`
- gateway `10.0.10.1`
- DNS `10.0.10.10`
- search domain `lab.internal`

To change it later, edit the file in `/etc/netplan/`. Use `ip a` to find the adapter name.
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses: [10.0.10.20/24]
      routes:
        - to: default
          via: 10.0.10.1
      nameservers:
        addresses: [10.0.10.10]
        search: [lab.internal]
```
Then apply it:
```bash
sudo netplan apply
```

## Join the domain
```bash
sudo hostnamectl set-hostname ubu01.lab.internal
sudo apt update && sudo apt install -y realmd sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

realm discover lab.internal                     # must show "type: kerberos"
sudo realm join -U Administrator lab.internal
sudo pam-auth-update --enable mkhomedir         # creates a home folder on an AD user's first login
```

## Test
```bash
id asmith@lab.internal          # shows the AD user and their groups
ssh asmith@lab.internal@10.0.10.20
```
On the domain controller, check that `UBU01` appears under **Computers** in `dsa.msc`. If you want, move it to the `Servers` OU.

## 📸 Screenshots to take
- The output of `realm list`
- The `id` output for a domain user

## For "Lessons learned"
- How Linux authenticates against AD through SSSD and Kerberos
- What happens when the clocks are out of sync (`realm join` fails with a Kerberos error)
