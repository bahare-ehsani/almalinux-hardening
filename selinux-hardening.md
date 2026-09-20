# SELinux Hardening

## Objective

Verify and maintain SELinux in a secure enforcing state, validate the active policy, review recent access denials, and verify SELinux contexts for critical services and system files.

## Current State

* SELinux is enabled and running in `Enforcing` mode.
* Policy type: `targeted`
* SELinux configuration is set to `Enforcing`.
* No recent AVC denials were detected.
* Core system services are running within dedicated SELinux domains.
* No unnecessary SELinux-related service packages were identified during the assessment.

## Configuration

No additional SELinux policy changes were required.

The existing configuration was retained:

```text
SELINUX=enforcing
SELINUXTYPE=targeted
```

SELinux Boolean settings were reviewed. No specific Boolean was changed because no unnecessary or service-related configuration requiring modification was identified.

## Verification

The following checks were performed:

* Verified SELinux status and enforcing mode using `sestatus`.
* Checked recent SELinux AVC denials using `ausearch`.
* Reviewed active SELinux Boolean settings.
* Verified enabled system services and compared them with SELinux-related Boolean capabilities.
* Confirmed that packages related to unused services such as HTTPD, PostgreSQL, NFS, Gluster, Squid, Samba, and XGuest were not installed.
* Verified SELinux process contexts for critical services:

  * `auditd` → `auditd_t`
  * `chronyd` → `chronyd_t`
  * `sshd` → `sshd_t`
  * `rsyslogd` → `syslogd_t`
* Verified SELinux contexts for critical system files:

  * `/etc/passwd` → `passwd_file_t`
  * `/etc/group` → `passwd_file_t`
  * `/etc/shadow` → `shadow_t`
  * `/etc/ssh/sshd_config` → `etc_t`
  * `/etc/sudoers` → `etc_t`

## Before / After

| Setting                | Before        | After         |
| ---------------------- | ------------- | ------------- |
| SELinux                | `enabled`     | `enabled`     |
| Mode                   | `enforcing`   | `enforcing`   |
| Policy                 | `targeted`    | `targeted`    |
| Recent AVC denials     | None detected | None detected |
| SELinux policy changes | None          | None          |
| Critical file contexts | Correct       | Correct       |

## Result

SELinux was verified to be correctly enabled and enforcing with the `targeted` policy. No recent AVC denials or incorrect security contexts were identified, and no additional policy changes were required.

The existing SELinux configuration was retained to minimize unnecessary changes on the Production server.

