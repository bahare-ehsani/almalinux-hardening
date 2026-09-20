# System Baseline

## Objective

Establish a documented reference state of the AlmaLinux server before applying further security hardening changes.

The baseline captures the current system configuration, resources, network state, running services, exposed ports, and security controls.

> This document represents the observed system state at the time of assessment. Patch installation and update activities are documented separately in `patch-management.md`.

---

## System Overview

| Item             | Value                           |
| ---------------- | ------------------------------- |
| Operating System | AlmaLinux 10.2 (Lavender Lion)  |
| Release Type     | Stable                          |
| Platform         | EL10                            |
| Architecture     | x86_64                          |
| Kernel           | `6.12.0-211.49.1.el10_2.x86_64` |
| Hostname         | `AlmaLinux`                     |
| Virtualization   | VMware                          |
| Support End      | 2035-06-01                      |

---

## Compute & Memory

| Resource     | Configuration |
| ------------ | ------------- |
| vCPU         | 2             |
| Architecture | x86_64        |
| RAM          | 2.6 GiB       |
| Swap         | 3.0 GiB       |
| Swap Usage   | 0 B           |

---

## Storage

| Device / Mount |  Size | Usage |
| -------------- | ----: | ----: |
| `/dev/sda`     | 30 GB |     — |
| `/boot`        |  2 GB |   19% |
| `/`            | 25 GB |    7% |
| Swap           |  3 GB |    0% |

### Disk Layout

```text
/dev/sda (30G)
├── sda1 (1M)
├── sda2 (2G)  → /boot
└── sda3 (28G)
    ├── almalinux-root (25G) → /
    └── almalinux-swap (3G)  → swap
```

---

## Network Configuration

| Item              | Value                         |
| ----------------- | ----------------------------- |
| Primary Interface | `ens33`                       |
| Network           | Lab network                   |
| IPv4              | Configured                    |
| Default Gateway   | Configured                    |
| DNS               | Configured via NetworkManager |
| Search Domain     | `localdomain`                 |

The server is connected through the `ens33` interface and uses NetworkManager for network configuration.

---

## Listening Ports

The following network sockets were observed during the baseline assessment:

| Protocol | Port | Service   | Exposure       |
| -------- | ---: | --------- | -------------- |
| TCP      |   22 | `sshd`    | Network-facing |
| UDP      |  323 | `chronyd` | Localhost only |

`chronyd` is bound to localhost (`127.0.0.1` / `::1`), while SSH is listening on the network interfaces.

---

## Running Services

Security- and operations-relevant services observed as running:

| Service            | Status  | Purpose               |
| ------------------ | ------- | --------------------- |
| `sshd`             | Running | Remote administration |
| `firewalld`        | Running | Host firewall         |
| `auditd`           | Running | Security auditing     |
| `rsyslog`          | Running | System logging        |
| `systemd-journald` | Running | Journal logging       |
| `chronyd`          | Running | Time synchronization  |
| `crond`            | Running | Scheduled tasks       |
| `NetworkManager`   | Running | Network management    |

---

## Security Controls

| Control   | Baseline Status |
| --------- | --------------- |
| SELinux   | `Enforcing`     |
| Firewalld | `Running`       |
| Auditd    | `Active`        |
| SSH       | `Active`        |
| Rsyslog   | `Active`        |

These controls were verified as active during the baseline assessment.

---

## SSH Baseline

The effective SSH configuration was inspected using `sshd -T`.

| Setting                  | Current Value |
| ------------------------ | ------------- |
| `PermitRootLogin`        | `yes`         |
| `PasswordAuthentication` | `yes`         |
| `MaxAuthTries`           | `6`           |
| `LoginGraceTime`         | `120` seconds |

These values represent the **pre-hardening state** and are documented here as a reference for subsequent SSH hardening.

---

## Users & Groups

| Item                        | Current State  |
| --------------------------- | -------------- |
| Root account                | Present        |
| Regular administrative user | Not configured |
| `wheel` group               | Present        |
| `wheel` members             | None           |

System accounts required by installed services are present.

---

## Time Synchronization

`chronyd` was running and `chronyc tracking` was inspected.

| Item               | Observed Value          |
| ------------------ | ----------------------- |
| Stratum            | `3`                     |
| Reference          | NTP reference available |
| System time offset | `+0.000633061 seconds`  |
| Leap status        | `Normal`                |

---

## Package State

The package state was checked using `dnf check-update`.

Updates were available for:

* `dbus-broker`
* `gzip`

Detailed package update and reboot activities are documented separately in `patch-management.md`.

---

## Baseline Summary

The server is running **AlmaLinux 10.2** on a VMware virtual machine with:

* 2 vCPU
* 2.6 GiB RAM
* 30 GB disk
* SELinux in `Enforcing` mode
* Firewalld running
* Auditd active
* SSH enabled
* Only SSH exposed as a network-facing listening service
* Chrony available locally for time synchronization
* No regular administrative user configured at baseline

This baseline provides the reference state for subsequent hardening activities, including:

* Users & Groups Hardening
* SSH Hardening
* Firewalld Hardening
* SELinux Configuration
* Systemd Hardening
* Auditd & Logging
* Sysctl / Kernel Hardening
* Final Security Verification

