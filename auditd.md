# Auditd Hardening

## Objective

Harden the Linux auditing service to ensure important security-related changes are logged.

## Configuration

`auditd` was verified to be enabled and running.

A dedicated rules file was created:

```text
/etc/audit/rules.d/99-hardening.rules
```

The following security-sensitive resources are monitored:

```text
/etc/passwd
/etc/shadow
/etc/group
/etc/sudoers
/etc/sudoers.d/
/etc/ssh/sshd_config
/usr/bin/sudo
```

The rules monitor relevant file changes and `sudo` execution using audit keys such as `identity`, `sudo`, and `ssh`.

## Verification

Rules were loaded using:

```bash
augenrules --load
```

Active rules were verified with:

```bash
auditctl -l
```

Audit service status was verified with:

```bash
auditctl -s
```

Final verification confirmed:

* Auditd is enabled and running.
* Security audit rules are loaded.
* `lost = 0`.
* Audit configuration is persistent under `/etc/audit/rules.d/`.

## Result

Auditd is enabled with a focused set of rules for monitoring critical identity, privilege, and SSH configuration changes.

