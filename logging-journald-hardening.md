# Logging / Journald Hardening

## Objective

Configure persistent system logging through `systemd-journald`, control journal disk usage and retention, and verify that logging remains operational alongside `rsyslog`.

## Current State

* `systemd-journald` was active and initially stored journals only under `/run/log/journal`.
* Persistent journal storage under `/var/log/journal` was not enabled.
* `rsyslog` was active and configured to read journal messages through `imjournal`.
* No local `journald.conf.d` drop-in configuration existed before hardening.
* Initial journal disk usage was approximately `11.3M`.

A VMware snapshot named `Before-Logging-Hardening` was created before applying the configuration changes.

## Configuration

Persistent journald configuration was added through:

`/etc/systemd/journald.conf.d/99-hardening.conf`

Final configuration:

```text
[Journal]
Storage=persistent
Compress=yes
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=100M
MaxRetentionSec=30day
```

The configuration provides:

* Persistent journal storage under `/var/log/journal`
* Journal compression
* Maximum journal disk usage of `500M`
* At least `1G` free space reserved on the filesystem
* Maximum individual journal file size of `100M`
* Maximum journal retention period of `30 days`

The persistent journal directory was created and initialized:

```text
/var/log/journal
```

The journal was then flushed from runtime storage to persistent storage using:

```bash
journalctl --flush
```

Standard systemd tmpfiles policy was applied to restore the expected ownership, permissions, and ACLs:

```bash
systemd-tmpfiles --create --prefix=/var/log/journal
```

Final journal directory ownership and permissions follow the systemd policy:

```text
root:systemd-journal
2755
```

The `+` shown by `ls -l` indicates the presence of extended ACLs. These ACLs are part of the standard systemd journal file policy.

No `ForwardToSyslog` change was made because `rsyslog` was already configured to read journal messages through `imjournal`.

## Verification

The effective journald configuration was verified using:

```bash
systemd-analyze cat-config systemd/journald.conf
```

The expected hardening settings were present.

`systemd-journald` status was verified:

```bash
systemctl is-active systemd-journald
```

Result:

```text
active
```

`rsyslog` status was verified:

```bash
systemctl is-active rsyslog
```

Result:

```text
active
```

Journal integrity was verified using:

```bash
journalctl --verify
```

Result:

```text
PASS: /var/log/journal/.../system.journal
```

Persistent journal usage was verified:

```bash
journalctl --disk-usage
```

Current usage:

```text
Archived and active journals take up 8M in the file system.
```

Operational logging was tested by generating a test message:

```bash
logger "Journald hardening verification test"
```

The message was successfully retrieved using:

```bash
journalctl -n 5 --no-pager
```

The test message was present in the journal, confirming that new log entries are being recorded and can be retrieved successfully.

## Before / After

| Setting             | Before             | After              |
| ------------------- | ------------------ | ------------------ |
| `Storage`           | runtime            | persistent         |
| Journal location    | `/run/log/journal` | `/var/log/journal` |
| `Compress`          | default            | yes                |
| `SystemMaxUse`      | default            | `500M`             |
| `SystemKeepFree`    | default            | `1G`               |
| `SystemMaxFileSize` | default            | `100M`             |
| `MaxRetentionSec`   | default            | `30day`            |
| `rsyslog`           | active             | active             |
| Journal integrity   | not verified       | PASS               |

## Result

Persistent journald storage is now enabled with controlled disk usage and retention.

Journal files are stored under `/var/log/journal` using the standard systemd ownership, permissions, and ACL policy. Journal integrity and operational logging were verified successfully, and `rsyslog` remains active and continues to consume journal messages through `imjournal`.

No unnecessary changes were made to the existing `rsyslog` integration or other journald settings.

