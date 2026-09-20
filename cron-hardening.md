# Cron Hardening

## Objective

Harden the Cron scheduling service by restricting user access to `crontab` while maintaining required administrative access for `root` and `devops`.

## Current State

* `crond` is installed, enabled, and running.
* Only the default system Cron jobs were present.
* No personal crontab was configured for `root` or `devops`.
* `/etc/cron.allow` and `/etc/cron.deny` were not initially present.
* PAM access control for `crond` is enabled through `pam_access.so`.
* No additional access rules were defined in `/etc/security/access.conf`.

## Configuration

A VMware snapshot was taken before applying the Cron access restriction.

The file:

`/etc/cron.allow`

was created with the following users:

```text
root
devops
```

This restricts access to the `crontab` command to the explicitly listed users.

The file is owned by `root:root` with permissions:

```text
-rw-r--r--
```

No changes were made to the `crond` service configuration or PAM configuration.

## Verification

The Cron service was verified using:

```bash
systemctl status crond --no-pager
```

The configured users were verified using:

```bash
cat /etc/cron.allow
```

Access for `root` and `devops` was verified successfully.

Access restriction was tested using the `sync` system account:

```bash
runuser -u sync -- crontab -l
```

The attempt was correctly rejected.

After reboot, the following were verified:

* `crond` remained active and enabled.
* `/etc/cron.allow` persisted.
* `root` and `devops` remained authorized.
* `sync` remained denied access to `crontab`.

## Before / After

| Setting                  | Before                         | After              |
| ------------------------ | ------------------------------ | ------------------ |
| `crond`                  | Active and enabled             | Active and enabled |
| `/etc/cron.allow`        | Not present                    | `root`, `devops`   |
| `root` crontab           | None                           | None               |
| `devops` crontab         | None                           | None               |
| `sync` crontab access    | Not restricted by `cron.allow` | Denied             |
| Persistence after reboot | Not applicable                 | Verified           |

## Result

Cron access is now restricted to the required administrative users, `root` and `devops`.

The configuration was tested successfully before and after reboot without modifying the existing Cron service or PAM configuration.

