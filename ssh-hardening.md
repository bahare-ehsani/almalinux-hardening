# SSH Hardening

## Objective

Harden the OpenSSH service to reduce unauthorized access risks while maintaining a reliable administrative access path through SSH key authentication.

The server is treated as a production environment; therefore, SSH changes were applied incrementally with configuration validation, backups, rollback points, and independent access verification.

## Current State

Before hardening:

* OpenSSH was active and listening on TCP port `22`.
* Direct SSH access for `root` was enabled.
* Password-based SSH authentication was enabled.
* `MaxAuthTries` was set to `6`.
* `LoginGraceTime` was set to `120` seconds.
* `X11Forwarding` was enabled.
* `GSSAPIAuthentication` was enabled.
* The `devops` administrative account was available and belonged to the `wheel` group.
* SSH key authentication for `devops` was configured and tested.

## Configuration

SSH hardening was applied through:

`/etc/ssh/sshd_config.d/01-permitrootlogin.conf`

Final configuration:

```text
PermitRootLogin no
PasswordAuthentication no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
```

Additional authentication state:

```text
KbdInteractiveAuthentication no
GSSAPIAuthentication yes
```

`KbdInteractiveAuthentication` was already disabled by the existing configuration.

`GSSAPIAuthentication` was intentionally left enabled because no requirement was established to disable it in the current environment.

### Administrative Access

A dedicated administrative account was used instead of direct root SSH access:

```text
User: devops
Group: wheel
Authentication: SSH public key
Privilege escalation: sudo
```

The SSH public key was configured in:

`/home/devops/.ssh/authorized_keys`

with restricted ownership and permissions.

### Change Control

Before sensitive SSH changes:

* A VMware snapshot was created as a rollback point.
* Configuration backups were created before modifying the SSH configuration.
* SSH syntax was validated using `sshd -t`.
* Changes were applied using `systemctl reload sshd` rather than restarting the service.
* The existing administrative session was kept open until a new SSH session was independently verified.

## Verification

### Configuration Validation

After each configuration change:

```bash
sshd -t
```

was used to validate the SSH configuration syntax.

Effective configuration was then verified using:

```bash
sshd -T
```

Final effective values:

```text
permitrootlogin no
passwordauthentication no
kbdinteractiveauthentication no
maxauthtries 3
logingracetime 30
x11forwarding no
gssapiauthentication yes
```

### SSH Key Authentication

A new SSH session was established successfully using the `devops` account and its SSH private key.

```text
ssh devops@192.168.75.129
```

The session was verified with:

```bash
whoami
```

Result:

```text
devops
```

### Sudo Verification

Administrative privilege escalation was verified using:

```bash
sudo -l
```

The `devops` account was confirmed to have:

```text
(ALL) ALL
```

### Password Authentication Test

Password-only SSH authentication was explicitly tested by disabling public-key authentication from the client:

```text
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no devops@192.168.75.129
```

The connection was rejected with:

```text
Permission denied
```

This confirmed that password-based SSH authentication was effectively disabled.

### Root SSH Access

Direct SSH access for `root` was disabled through:

```text
PermitRootLogin no
```

Administrative access is performed through `devops` followed by `sudo`.

## Before / After

| Setting                        | Before | After |
| ------------------------------ | -----: | ----: |
| `PermitRootLogin`              |    yes |    no |
| `PasswordAuthentication`       |    yes |    no |
| `KbdInteractiveAuthentication` |     no |    no |
| `MaxAuthTries`                 |      6 |     3 |
| `LoginGraceTime`               |    120 |    30 |
| `X11Forwarding`                |    yes |    no |
| `GSSAPIAuthentication`         |    yes |   yes |

## Result

SSH access has been hardened successfully.

The final configuration:

* Prevents direct root SSH access.
* Prevents password-based SSH authentication.
* Uses SSH key authentication for the `devops` administrative account.
* Limits authentication attempts to `3`.
* Reduces the SSH login grace period to `30` seconds.
* Disables X11 forwarding.
* Preserves GSSAPI authentication because no requirement to disable it was identified.
* Maintains administrative access through `sudo`.

All changes were syntax-validated, applied using SSH reload, and verified through independent SSH connections.

SSH Hardening is considered **completed and operationally verified**.

