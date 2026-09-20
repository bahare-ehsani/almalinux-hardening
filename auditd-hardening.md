# Auditd Hardening

## Objective

Harden the Linux auditing subsystem to provide targeted monitoring of security-sensitive configuration changes while maintaining low overhead and compatibility with future DevOps workloads.

## Current State

* `auditd` is installed, enabled, and running.
* The `audit-rules` package was installed to provide `auditctl` and audit rule management.
* The initial system had no security-specific audit rules.
* `auditd.conf` was reviewed and required no changes.
* Audit rules are managed through `/etc/audit/rules.d/`.
* Audit event loss is currently `0`.
* Audit rules were verified to persist after reboot.

## Configuration

Audit rules were added in:

`/etc/audit/rules.d/99-hardening.rules`

The following security-sensitive paths are monitored:

```text
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k privilege
-w /etc/sudoers.d/ -p wa -k privilege
-w /etc/ssh/sshd_config -p wa -k ssh
-w /etc/audit/ -p wa -k audit
```

The rules provide monitoring for:

* User and group identity files
* Sudo privilege configuration
* SSH configuration
* Audit configuration

No broad system-call or command-execution rules were added in order to avoid unnecessary audit volume and maintain compatibility with future DevOps workloads.

The existing `auditd.conf` configuration was retained without modification.

A VMware snapshot was taken before applying the audit rule changes.

## Verification

Audit rules were validated using:

```bash
augenrules --check
```

Loaded rules were verified using:

```bash
auditctl -l
```

Audit subsystem health was checked using:

```bash
auditctl -s
```

The privilege monitoring rule was practically tested by creating and deleting a temporary file under `/etc/sudoers.d/` and searching for the corresponding events:

```bash
ausearch -k privilege -ts recent
```

The test successfully recorded both `CREATE` and `DELETE` events.

After reboot, the following were verified:

* `auditd` remained active and running.
* All configured audit rules were loaded.
* `lost 0` was reported by `auditctl -s`.
* Audit rule persistence was confirmed.

## Before / After

| Setting                        | Before          | After                 |
| ------------------------------ | --------------- | --------------------- |
| `auditd`                       | Active          | Active                |
| Security-specific audit rules  | None            | 8 targeted rules      |
| Identity monitoring            | Not configured  | Enabled               |
| Privilege monitoring           | Not configured  | Enabled               |
| SSH configuration monitoring   | Not configured  | Enabled               |
| Audit configuration monitoring | Not configured  | Enabled               |
| Audit event loss               | 0               | 0                     |
| Rule persistence               | Not established | Verified after reboot |
| `audit-rules.service`          | Not available   | Enabled               |

## Result

Auditd hardening is complete with targeted monitoring of identity, privilege, SSH, and audit configuration changes.

The rules were functionally tested, successfully reloaded after reboot, and verified with zero lost audit events. The configuration remains intentionally focused to provide useful security visibility without introducing unnecessary audit overhead for future DevOps workloads.

