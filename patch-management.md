# Patch Management

## Overview

This document describes the process used to assess, apply, and verify system and security updates on the AlmaLinux server.

The objective of this process is to:

- Identify available package updates.
- Identify available security updates.
- Assess whether a system reboot is required.
- Apply system updates.
- Install and activate the latest available kernel.
- Verify system health after reboot.

---

## Initial System State

| Item | Value |
|---|---|
| Operating System | AlmaLinux 9.8 |
| Kernel Before Patch | 5.14.0-503.11.1.el9_5.x86_64 |
| Architecture | x86_64 |

---

## Repository Verification

The enabled DNF repositories were checked before applying updates.

### Command

```bash
dnf repolist
```

### Result

The system repositories were available and ready for package updates.

---

## Available Updates

Available package updates were checked using:

```bash
dnf check-update
```

Multiple package updates were available, including updates for:

- Kernel
- Linux firmware
- Microcode
- Python
- Dracut
- Kernel tools
- Other system packages

---

## Security Update Assessment

Security advisories were reviewed using:

```bash
dnf updateinfo summary
```

The system reported the following security notices:

| Severity | Count |
|---|---:|
| Important | 43 |
| Moderate | 40 |
| Low | 1 |
| **Total** | **84** |

Security updates were also reviewed using:

```bash
dnf updateinfo list --security
```

---

## Reboot Requirement Assessment

The system was checked for a reboot requirement using:

```bash
dnf needs-restarting -r
```

The following core components had been updated since the previous boot:

- glibc
- kernel
- linux-firmware
- microcode_ctl
- systemd

### Result

```text
Reboot is required to fully utilize these updates.
```

---

## Applying System Updates

System updates were applied using:

```bash
dnf update -y
```

### Result

```text
Complete!
```

The update process completed successfully.

---

## Kernel Update

A newer kernel was installed as part of the system update.

### Kernel Before Patch

```text
5.14.0-503.11.1.el9_5.x86_64
```

### Kernel Installed

```text
5.14.0-687.38.1.el9_8.x86_64
```

The following kernel packages were installed:

```text
kernel-5.14.0-687.38.1.el9_8.x86_64
kernel-core-5.14.0-687.38.1.el9_8.x86_64
kernel-modules-5.14.0-687.38.1.el9_8.x86_64
kernel-modules-core-5.14.0-687.38.1.el9_8.x86_64
```

---

## System Reboot

A system reboot was performed to activate the newly installed kernel.

### Command

```bash
reboot
```

---

## Post-Reboot Verification

After the system came back online, the running kernel was verified using:

```bash
uname -r
```

### Result

```text
5.14.0-687.38.1.el9_8.x86_64
```

The result confirmed that the newly installed kernel was successfully activated.

---

## Reboot Requirement Verification

The system was checked again after reboot using:

```bash
dnf needs-restarting -r
```

### Result

```text
No core libraries or services have been updated since boot-up.
Reboot should not be necessary.
```

This confirmed that no additional reboot was required.

---

## Systemd Health Check

The systemd units were checked after reboot using:

```bash
systemctl --failed
```

### Result

```text
0 loaded units listed.
```

No failed systemd units were detected after the reboot.

---

## Before and After

| Check | Before Patch | After Patch |
|---|---|---|
| Kernel | 5.14.0-503.11.1.el9_5.x86_64 | 5.14.0-687.38.1.el9_8.x86_64 |
| System Updates | Updates Available | Updated |
| Reboot Required | Yes | No |
| Failed systemd Units | Not Assessed | 0 |

---

## Final Patch Status

The patch management process was completed successfully.

- System packages were successfully updated.
- Security updates were identified and applied.
- A newer kernel was installed.
- The system was rebooted successfully.
- The new kernel is currently running.
- No additional reboot is required.
- No failed systemd units were detected after reboot.

---

## Commands Used

```bash
dnf repolist
dnf check-update
rpm -q kernel
uname -r
dnf updateinfo summary
dnf updateinfo list --security
dnf needs-restarting -r
dnf update -y
reboot
systemctl --failed
```

---

## Conclusion

The AlmaLinux server was successfully assessed, patched, rebooted, and verified.

The system is currently running the updated kernel:

```text
5.14.0-687.38.1.el9_8.x86_64
```

Post-reboot verification confirmed that no additional reboot is required and no failed systemd units were detected.
