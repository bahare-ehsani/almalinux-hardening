# Firewalld Hardening

## Objective

Harden Firewalld on the AlmaLinux server by reducing unnecessary network exposure, applying least-privilege access controls, restricting SSH access to the trusted management subnet, enabling denied-traffic logging, and verifying persistence after reboot.

---

## 1. Initial Firewall Baseline

Firewalld was running with the `public` zone active on interface `ens33`.

Initial configuration:

```text
Zone: public
Interface: ens33
Services:
  cockpit
  dhcpv6-client
  ssh
Ports: none
```

The initial configuration was reviewed with:

```bash
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --get-default-zone
firewall-cmd --list-all
firewall-cmd --permanent --list-all
```

---

## 2. Network Configuration

The server uses the following IPv4 configuration:

```text
Server:  192.168.75.128/24
Network: 192.168.75.0/24
Gateway: 192.168.75.2
Interface: ens33
```

The management workstation uses:

```text
192.168.75.1
```

The `ens33` connection is managed by NetworkManager.

NetworkManager does not explicitly assign a zone to the connection:

```text
connection.zone: --
```

The Firewalld default zone is `public`, therefore `ens33` is active in the `public` zone.

No additional NetworkManager zone configuration was introduced because it was not required for the security objective.

---

## 3. Remove Unnecessary Services

### 3.1 Cockpit

Cockpit was present as an allowed Firewalld service:

```text
cockpit → TCP/9090
```

However, Cockpit was not installed or active:

```bash
systemctl status cockpit.socket
```

Result:

```text
Unit cockpit.socket could not be found.
```

No process was listening on TCP/9090.

Therefore, the unnecessary Firewalld service was removed:

```bash
firewall-cmd --permanent --zone=public --remove-service=cockpit
```

---

### 3.2 DHCPv6 Client

The `dhcpv6-client` service was also allowed by the initial Firewalld configuration.

Its definition allows:

```text
UDP/546
Destination: ipv6:fe80::/64
```

The server does not use DHCPv6 and the network configuration only contains a link-local IPv6 address.

Therefore, the unnecessary Firewalld service was removed:

```bash
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client
```

---

## 4. Firewall Service Exposure After Cleanup

After removing unnecessary services, the public zone was reduced to only the access required for SSH administration.

Additional TCP/UDP ports were not opened through Firewalld.

The effective configuration was verified with:

```bash
firewall-cmd --list-all
```

Final service exposure:

```text
services: none
ports: none
```

SSH was subsequently moved from a globally allowed service to a source-restricted Rich Rule.

---

## 5. SSH Network Restriction

SSH is required for remote administration.

The server listens on:

```text
TCP/22
```

Instead of allowing SSH from all sources, access was restricted to the trusted management subnet:

```text
192.168.75.0/24
```

The following Rich Rule was added:

```bash
firewall-cmd --permanent --zone=public \
  --add-rich-rule='rule family="ipv4" source address="192.168.75.0/24" service name="ssh" accept'
```

The configuration was reloaded:

```bash
firewall-cmd --reload
```

The rule was verified:

```bash
firewall-cmd --zone=public --list-rich-rules
```

Result:

```text
rule family="ipv4" source address="192.168.75.0/24" service name="ssh" accept
```

The original globally allowed SSH service was then removed:

```bash
firewall-cmd --permanent --zone=public --remove-service=ssh
```

After reload:

```bash
firewall-cmd --reload
```

The final zone contained no globally allowed services.

---

## 6. Final Access Model

The resulting SSH access model is:

```text
192.168.75.0/24
        |
        | TCP/22
        v
     ALLOW
        |
        v
     sshd

Other IPv4 sources
        |
        | TCP/22
        v
     REJECT
```

This implements network-level least privilege for administrative access.

The management workstation at:

```text
192.168.75.1
```

was successfully verified against the SSH port.

---

## 7. Denied Traffic Logging

Denied traffic logging was initially disabled:

```text
off
```

Logging for denied unicast traffic was enabled:

```bash
firewall-cmd --set-log-denied=unicast
```

The configuration was persisted:

```bash
firewall-cmd --runtime-to-permanent
```

Verification:

```bash
firewall-cmd --get-log-denied
```

Result:

```text
unicast
```

This allows rejected unicast traffic to be observed in the kernel journal.

---

## 8. Firewall Rejection Verification

TCP/22 was tested from the management workstation:

```powershell
Test-NetConnection 192.168.75.128 -Port 22
```

Result:

```text
TcpTestSucceeded : True
```

TCP/9090 was also tested:

```powershell
Test-NetConnection 192.168.75.128 -Port 9090
```

Result:

```text
TcpTestSucceeded : False
```

This confirmed that SSH remained reachable while the unused Cockpit port was blocked.

The blocked connection to TCP/9090 was also observed in the kernel journal:

```text
filter_IN_public_REJECT
SRC=192.168.75.1
DST=192.168.75.128
PROTO=TCP
DPT=9090
```

Therefore, Firewalld rejection and denied-traffic logging were both verified.

---

## 9. Forwarding Review

The Firewalld zone reports:

```text
forward: yes
```

However, kernel IP forwarding is disabled:

```bash
sysctl net.ipv4.ip_forward
```

Result:

```text
net.ipv4.ip_forward = 0
```

IPv6 forwarding is also disabled:

```bash
sysctl net.ipv6.conf.all.forwarding
```

Result:

```text
net.ipv6.conf.all.forwarding = 0
```

The server is therefore not operating as an IP router.

No additional forwarding configuration was introduced because it was not required.

---

## 10. IPv6 Review

The SSH daemon listens on both IPv4 and IPv6 sockets:

```text
0.0.0.0:22
[::]:22
```

The `ens33` interface has only a link-local IPv6 address:

```text
fe80::/64
```

The SSH Firewalld Rich Rule is explicitly IPv4:

```text
family="ipv4"
```

No IPv6 SSH allow rule was added.

IPv6 was not disabled because there was no demonstrated security requirement to disable it.

---

## 11. Persistence Verification

Before reboot, the effective configuration was verified:

```bash
firewall-cmd --list-all
firewall-cmd --get-log-denied
firewall-cmd --permanent --zone=public --list-rich-rules
```

The server was then rebooted:

```bash
sudo reboot
```

After reboot, Firewalld was verified:

```bash
firewall-cmd --state
```

Result:

```text
running
```

The active configuration remained:

```text
public (active)
  interfaces: ens33
  services:
  ports:
  rich rules:
    rule family="ipv4" source address="192.168.75.0/24" service name="ssh" accept
```

Denied logging also remained enabled:

```text
unicast
```

This confirmed persistence of the Firewalld hardening configuration across reboot.

---

## 12. Final Verification

### SSH

```powershell
Test-NetConnection 192.168.75.128 -Port 22
```

Result:

```text
TcpTestSucceeded : True
```

### Unused Cockpit Port

```powershell
Test-NetConnection 192.168.75.128 -Port 9090
```

Result:

```text
TcpTestSucceeded : False
```

### Final Firewalld State

```text
Zone: public
Interface: ens33

Services: none
Ports: none

Rich Rules:
192.168.75.0/24 → SSH → ACCEPT

Denied logging:
unicast
```

---

## 13. Hardening Summary

The following hardening actions were completed:

* [x] Firewalld enabled and running
* [x] Active zone reviewed
* [x] Unnecessary `cockpit` service removed
* [x] Unnecessary `dhcpv6-client` service removed
* [x] No unnecessary ports exposed
* [x] Global SSH service removed from the zone
* [x] SSH restricted to `192.168.75.0/24`
* [x] Denied unicast traffic logging enabled
* [x] Blocked TCP/9090 verified
* [x] Allowed TCP/22 verified
* [x] Firewall rejection observed in kernel logs
* [x] IPv4 forwarding verified as disabled
* [x] IPv6 forwarding verified as disabled
* [x] Firewalld persistence verified after reboot

---

## Result

Firewalld has been hardened according to the principles of least privilege and reduced network exposure.

The final configuration exposes no unnecessary Firewalld services or ports and restricts SSH administrative access to the trusted management subnet.

The configuration was verified both before and after reboot to confirm that the intended security posture persists.

