# Cron Hardening

## Objective

Review the cron service and scheduled jobs for unnecessary or suspicious configuration.

## Configuration Review

`crond` was verified to be enabled and running.

The following cron directories were reviewed:

```text
/etc/cron.d/
/etc/cron.daily/
/etc/cron.hourly/
/etc/cron.weekly/
/etc/cron.monthly/
```

Only the default system jobs were present:

```text
/etc/cron.d/0hourly
/etc/cron.hourly/0anacron
```

The cron access control files were also reviewed. `/etc/cron.deny` was present and empty, while `/etc/cron.allow` was not configured.

## Verification

Cron service status was checked using:

```bash
systemctl status crond --no-pager
```

Scheduled jobs were reviewed using:

```bash
ls -la /etc/cron.d/ /etc/cron.daily/ /etc/cron.hourly/ /etc/cron.weekly/ /etc/cron.monthly/
```

Cron access control was checked using:

```bash
ls -l /etc/cron.allow /etc/cron.deny 2>/dev/null
cat /etc/cron.allow /etc/cron.deny 2>/dev/null
```

## Result

No unnecessary or suspicious cron jobs were identified. No configuration changes were required.

