# Final Security Verification

## Objective

Perform a final security verification of the AlmaLinux server after completing the hardening activities and confirm that the security configuration remains functional and persistent after a system reboot.

## Current State

* All planned security hardening areas were completed.
* A VMware snapshot named `Before-Final-Security-Verification` was created before the final reboot.
* The server was rebooted successfully.
* Administrative access was restored using the dedicated `devops` account and SSH key authentication.
* `devops` successfully obtained administrative privileges through `sudo`.

## Configuration

The final verification covered the following security areas:

* SSH hardening
* Firewalld
* SELinux
* Auditd
* Sysctl network hardening
* Persistent journald logging
* Administrative access through `devops`

No configuration changes were made during the final verification phase.

## Verification

### SSH

Effective SSH configuration was verified after reboot using:

```bash
sshd -T
```

Verified settings:

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
```

The `devops` account successfully connected after reboot using SSH key authentication and successfully obtained administrative privileges through `sudo`.

### Firewalld

The active zone and allowed services were verified after reboot.

The `public` zone was active on the server interface, with only the SSH service exposed:

```text
ssh
```

### SELinux

SELinux enforcement was verified after reboot:

```bash
getenforce
```

Result:

```text
Enforcing
```

### Auditd

Auditd service status was verified after reboot:

```bash
systemctl is-active auditd
```

Result:

```text
active
```

### Sysctl

The hardened network redirect settings were verified after reboot:

```text
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
```

The settings persisted successfully across the reboot.

### Journald

Persistent journal storage was verified after reboot.

The journal file remained available under:

```text
/var/log/journal/<machine-id>/system.journal
```

The journal directory and file retained the expected systemd ownership and permissions:

```text
root:systemd-journal
0640
```

Current journal disk usage was verified:

```bash
journalctl --disk-usage
```

The journal remained operational after reboot and contained entries from the current boot:

```bash
journalctl -b -n 5 --no-pager
```

Journal integrity had previously been verified successfully using:

```bash
journalctl --verify
```

Result:

```text
PASS
```

## Before / After

| Security Area                | Before Reboot | After Reboot |
| ---------------------------- | ------------- | ------------ |
| SSH hardening                | Verified      | Verified     |
| `devops` SSH access          | Verified      | Verified     |
| `sudo` administrative access | Verified      | Verified     |
| Firewalld                    | Verified      | Verified     |
| SELinux                      | Enforcing     | Enforcing    |
| Auditd                       | Active        | Active       |
| Sysctl hardening             | Verified      | Verified     |
| Persistent journald          | Verified      | Verified     |
| Journal integrity            | PASS          | Operational  |

## Result

The final security verification completed successfully.

The AlmaLinux server rebooted normally and the implemented security controls remained active and persistent after reboot. Administrative access through the `devops` account was confirmed, while SSH hardening, firewall configuration, SELinux enforcement, auditd, sysctl settings, and persistent journald storage remained operational.

The security hardening phase is complete and the server is ready for the next stage of the project.

