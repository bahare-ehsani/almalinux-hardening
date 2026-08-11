# AlmaLinux Server Baseline

## System Information

| Item | Value |
|---|---|
| Operating System | AlmaLinux 9.8 |
| Kernel | 5.14.0-503.11.1.el9_5.x86_64 |
| Architecture | x86_64 |
| Virtualization | VMware |
| CPU | 2 vCPU |
| Memory | 2.7 GiB |
| Disk | 30 GB |
| Root Filesystem | 26 GB |
| IP Address | 192.168.75.128/24 |
| Hostname | localhost |

## Security Baseline

| Component | Status |
|---|---|
| SELinux | Enforcing |
| firewalld | Running |
| auditd | Running |
| SSH | Running |
| rsyslog | Running |

## Listening Ports

| Protocol | Address | Port | Service |
|---|---|---:|---|
| TCP | 0.0.0.0 | 22 | SSH |
| TCP | [::] | 22 | SSH |
| UDP | 127.0.0.1 | 323 | chronyd |
| UDP | [::1] | 323 | chronyd |

## Running Services

The following services were active during the initial assessment:

- auditd
- chronyd
- crond
- dbus-broker
- firewalld
- irqbalance
- NetworkManager
- rsyslog
- sshd
- systemd-journald
- systemd-logind
- systemd-udevd

## Initial Assessment

The server currently has:

- SELinux enabled in Enforcing mode.
- firewalld enabled and running.
- SSH exposed on TCP port 22.
- chronyd listening only on localhost.
- auditd and rsyslog enabled.
- No unnecessary network listening services identified during the initial assessment.

This baseline will be used to compare the system before and after hardening.
