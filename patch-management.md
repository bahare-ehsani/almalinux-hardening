# Patch Management

## Objective

Keep the AlmaLinux server up to date with the latest available security and system packages while maintaining service availability and providing a controlled rollback point before system changes.

## Environment

* **OS:** AlmaLinux 10.2
* **Kernel (before update):** `6.12.0-211.7.3.el10_2.x86_64`
* **Kernel (after update):** `6.12.0-211.49.1.el10_2.x86_64`
* **Package Manager:** DNF
* **Primary Service Verified:** OpenSSH (`sshd`)

## Pre-Change Assessment

Before applying updates, available package updates were reviewed using:

```bash
dnf check-update
```

The system had updates available for several core components, including:

* Kernel
* OpenSSH
* PAM
* systemd
* firewalld
* SELinux policy
* NetworkManager
* glibc

Because the server is treated as a production-like environment, a VMware snapshot was created before applying the package updates.

## Patch Installation

The pending transaction was reviewed before confirmation.

The update included:

* **85 packages upgraded**
* **4 packages installed**
* Approximately **317 MB** of packages downloaded

The transaction was then approved and completed using:

```bash
dnf upgrade
```

During the transaction, the official AlmaLinux GPG signing key was imported and verified by DNF.

## Reboot Requirement

After the update, the system was checked for processes and components requiring a restart:

```bash
dnf needs-restarting -r
```

The command reported that a reboot was required because core components including the kernel, glibc, systemd, firmware, and microcode had been updated.

The server was then rebooted.

## Post-Change Verification

After reboot, the running kernel was verified:

```bash
uname -r
```

Result:

```text
6.12.0-211.49.1.el10_2.x86_64
```

The SSH service was also verified:

```bash
systemctl is-active sshd
```

Result:

```text
active
```

## Result

Patch Management was completed successfully.

* System packages updated successfully
* New kernel successfully loaded after reboot
* SSH service remained operational
* No service availability issue was observed after the update

## Operational Notes

For production environments, system updates should be performed through a controlled change process that includes:

1. Pre-change assessment
2. Backup or snapshot
3. Review of the proposed package transaction
4. Controlled update
5. Reboot planning when required
6. Post-change service verification
7. Rollback readiness

This approach reduces the risk of service disruption during operating system maintenance.

