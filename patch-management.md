# Patch Management

## Objective

Keep the AlmaLinux server up to date with the latest security and system packages while maintaining service availability and providing a controlled rollback point before system changes.

## Environment

| Item            | Value            |
| --------------- | ---------------- |
| OS              | AlmaLinux 10.2   |
| Package Manager | DNF              |
| Primary Service | OpenSSH (`sshd`) |
| Rollback Point  | VMware Snapshot  |

## Before / After

| Component     | Before                         | After                           |
| ------------- | ------------------------------ | ------------------------------- |
| Kernel        | `6.12.0-211.7.3.el10_2.x86_64` | `6.12.0-211.49.1.el10_2.x86_64` |
| Package State | Updates available              | Packages updated                |
| Reboot Status | Not required                   | Required and completed          |
| SSH Service   | Active                         | Active                          |

## Pre-Change Assessment

Available updates were reviewed before making any changes:

```bash
dnf check-update
```

Updates were available for several core system components, including:

* Kernel
* OpenSSH
* PAM
* systemd
* firewalld
* SELinux policy
* NetworkManager
* glibc

A VMware snapshot was created before the update to provide a controlled rollback point.

## Patch Installation

The proposed transaction was reviewed before confirmation.

| Change             |  Result |
| ------------------ | ------: |
| Packages upgraded  |      85 |
| Packages installed |       4 |
| Download size      | ~317 MB |

The update was then applied using:

```bash
dnf upgrade
```

During the transaction, the official AlmaLinux GPG signing key was imported and verified by DNF.

## Reboot Assessment

After the update, the system was checked for components requiring a restart:

```bash
dnf needs-restarting -r
```

A reboot was required because core components including the kernel, glibc, systemd, firmware, and microcode had been updated.

The server was then rebooted.

## Post-Change Verification

### Kernel

```bash
uname -r
```

```text
6.12.0-211.49.1.el10_2.x86_64
```

### SSH Service

```bash
systemctl is-active sshd
```

```text
active
```

## Result

Patch Management was completed successfully.

* System packages updated successfully
* New kernel loaded successfully after reboot
* SSH service remained operational
* No service availability issues were observed

## Operational Notes

For production environments, OS patching should follow a controlled change process:

1. Pre-change assessment
2. Backup or snapshot
3. Package transaction review
4. Controlled update
5. Reboot planning
6. Post-change verification
7. Rollback readiness

This approach reduces the risk of service disruption during operating system maintenance.

