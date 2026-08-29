# Systemd Hardening

## Overview

Systemd hardening was performed on the AlmaLinux 9.8 laboratory VM to reduce the attack surface of system services while maintaining normal system functionality.

The approach focused on:

* Identifying unnecessary enabled services
* Disabling services that were not required in the laboratory environment
* Applying systemd security restrictions to `rsyslog`
* Verifying service functionality after each security change
* Avoiding unnecessary restrictions that could affect service stability

---

## Service Review

The system was reviewed using:

```bash
systemctl --failed
systemctl list-unit-files --type=service --state=enabled
systemd-analyze security --no-pager
```

No failed systemd units were present after the hardening changes.

Two unnecessary services were disabled because they were not required by the VM configuration:

```bash
systemctl disable --now systemd-boot-update.service
systemctl disable --now systemd-network-generator.service
```

The network configuration was confirmed to remain functional through NetworkManager.

---

## rsyslog Hardening

`rsyslog` was selected for service-level hardening because it runs with elevated privileges and handles system log files.

A systemd drop-in override was created at:

```text
/etc/systemd/system/rsyslog.service.d/override.conf
```

The following restrictions were applied:

```ini
[Service]
NoNewPrivileges=yes
ProtectControlGroups=yes
ProtectHome=read-only
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictSUIDSGID=yes
SystemCallArchitectures=native
SystemCallFilter=~@clock @debug @module @raw-io @reboot @swap @cpu-emulation @obsolete
LockPersonality=yes
MemoryDenyWriteExecute=yes

PrivateTmp=yes

ProtectSystem=strict
ReadWritePaths=/var/log /var/lib/rsyslog

PrivateDevices=yes
ProtectClock=yes
ProtectKernelLogs=yes
RestrictRealtime=yes

ProtectProc=invisible
ProcSubset=pid
```

### Rationale

The restrictions were selected to limit rsyslog's access to:

* Kernel interfaces and kernel logs
* System devices
* Process information
* Temporary directories
* System files outside its required write locations
* Privileged system calls and namespaces
* Additional privileges and runtime capabilities

Because rsyslog needs to write system logs, `ProtectSystem=strict` was combined with:

```ini
ReadWritePaths=/var/log /var/lib/rsyslog
```

This provides a read-only system filesystem while preserving the directories required by rsyslog.

---

## Verification

After applying the systemd restrictions, the service was reloaded and restarted:

```bash
systemctl daemon-reload
systemctl restart rsyslog.service
```

Service health was verified with:

```bash
systemctl status rsyslog.service --no-pager
```

Log processing was tested using:

```bash
logger "rsyslog-hardening-test"
tail -n 5 /var/log/messages
```

The test message was successfully written to `/var/log/messages`, confirming that the hardening changes did not prevent normal logging functionality.

The resulting security configuration was reviewed with:

```bash
systemd-analyze security rsyslog.service
```

The implemented restrictions were confirmed by `systemd-analyze security`, including:

* `ProtectSystem`
* `PrivateTmp`
* `PrivateDevices`
* `ProtectClock`
* `ProtectKernelLogs`
* `ProtectProc`
* `ProcSubset`
* `RestrictRealtime`
* `NoNewPrivileges`
* `MemoryDenyWriteExecute`
* `SystemCallFilter`
* `RestrictSUIDSGID`

---

## Security Decisions

Not every `systemd-analyze security` finding was changed.

Some recommendations, particularly the remaining `CapabilityBoundingSet` findings, were intentionally left unchanged. The goal was to apply meaningful and low-risk restrictions rather than modify every available security option solely to improve the exposure score.

This approach reduces the risk of breaking a required system service while still providing significant service isolation and privilege reduction.

---

## Result

Systemd hardening was completed for the current laboratory baseline.

The final configuration:

* Removes unnecessary services
* Reduces the privileges and filesystem access of `rsyslog`
* Restricts access to devices, processes, kernel interfaces and system files
* Preserves required logging functionality
* Verifies service health after security changes
* Documents security decisions and intentionally unchanged recommendations

The configuration is intended as a practical security baseline for the AlmaLinux laboratory environment and can be further extended if stricter production requirements are introduced.

