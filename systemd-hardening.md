# Systemd Hardening

## Objective

Review systemd services and security exposure, identify unnecessary services, and apply only justified changes while maintaining compatibility with current and future DevOps workloads.

## Current State

* Systemd is running normally.
* 15 services are currently running.
* 23 service unit files are enabled.
* No failed systemd units were detected.
* No clearly unnecessary active services were identified.
* `systemd-pstore.service` was enabled but did not run because its start condition was not met.
* Services required for networking, remote administration, security, logging, and future DevOps workloads were retained.

## Configuration

Systemd services were reviewed using:

```bash
systemctl list-units --type=service --state=running
systemctl list-unit-files --type=service --state=enabled
```

Systemd security exposure was reviewed using:

```bash
systemd-analyze security
```

The security score was used as an assessment indicator only. Services were not disabled solely because they received a high exposure score.

Unnecessary or potentially unnecessary services were reviewed with consideration for current system requirements and future workloads such as Docker, Kubernetes, Ansible, CI/CD, and monitoring.

`systemd-pstore.service` was identified as unnecessary for the current environment. It was not running because:

```text
ConditionDirectoryNotEmpty=/sys/fs/pstore was not met
```

A VMware snapshot was created before the change.

The service was then disabled:

```bash
systemctl disable systemd-pstore.service
```

No changes were made to essential services such as:

* `sshd`
* `NetworkManager`
* `firewalld`
* `auditd`
* `chronyd`
* `crond`
* `rsyslog`
* `dbus-broker`
* `sssd`
* `kdump`

## Verification

The following checks were performed:

* Reviewed currently running systemd services.
* Reviewed enabled systemd service units.
* Reviewed systemd security exposure.
* Checked for unnecessary services such as Cockpit, NIS, RPC, Avahi, Bluetooth, CUPS, Samba, and NFS.
* Confirmed that `nis-domainname.service` was already disabled.
* Reviewed `kdump.service` and confirmed it was active and functioning correctly.
* Reviewed `systemd-pstore.service` and confirmed that it was not required in the current environment.
* Verified that `systemd-pstore.service` is now disabled.
* Verified that no systemd units are in a failed state.

Final verification:

```text
systemd-pstore.service → disabled
Failed units → 0
```

## Before / After

| Setting                   | Before   | After    |
| ------------------------- | -------- | -------- |
| `systemd-pstore.service`  | enabled  | disabled |
| Failed systemd units      | 0        | 0        |
| `nis-domainname.service`  | disabled | disabled |
| Essential system services | Enabled  | Enabled  |

## Result

Systemd services were reviewed using a least-privilege approach without applying unnecessary restrictions.

Only `systemd-pstore.service` was disabled because it was not required in the current environment and was not actively providing functionality.

Essential system services were retained to maintain system stability and compatibility with future DevOps workloads, including Docker, Kubernetes, Ansible, CI/CD, and monitoring.

