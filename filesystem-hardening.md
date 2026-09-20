# Filesystem Hardening

## Objective

Review filesystem configuration, mount options, permissions, and special file permissions to identify unnecessary security risks without introducing changes that could affect current or future DevOps workloads.

## Current State

* The system uses XFS on LVM for the root filesystem.
* `/boot` is mounted on a separate partition.
* `/tmp` is part of the root filesystem and is not separately mounted.
* The system uses restrictive mount options such as `nosuid`, `nodev`, and `noexec` on relevant virtual filesystems.
* No unnecessary filesystem partitioning changes were identified.

## Configuration

No filesystem configuration changes were required.

The existing mount configuration was reviewed using:

```bash
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS
```

The following security-related conditions were verified:

* `/proc` and `/sys` use restrictive mount options including `nosuid`, `nodev`, and `noexec`.
* `/dev/shm` uses `nosuid` and `nodev`.
* `/` remains writable and executable as required by the operating system and future DevOps workloads.
* `/tmp` was not separated into an additional filesystem because no operational requirement was identified.

Filesystem permissions were reviewed for:

```bash
find /etc -xdev -type d -perm -0002 -ls
find / -xdev -type f -perm -0002 -ls
```

No world-writable directories under `/etc` or world-writable regular files on the root filesystem were found.

SUID/SGID files were reviewed using:

```bash
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -ls
```

The detected SUID/SGID files were standard system utilities and no unnecessary or unexpected entries were identified.

Files without a valid user or group owner were checked using:

```bash
find / -xdev \( -nouser -o -nogroup \) -ls
```

No unowned or ungrouped files were found.

## Verification

The following checks completed successfully:

* No world-writable directories were found under `/etc`.
* No world-writable regular files were found on the root filesystem.
* No unowned or ungrouped files were found.
* Existing SUID/SGID files were reviewed and appeared consistent with the installed operating system.
* Existing mount options provide appropriate restrictions for virtual filesystems.
* No filesystem or partitioning changes were required.

## Before / After

| Area                              | Before                       | After           |
| --------------------------------- | ---------------------------- | --------------- |
| Root filesystem                   | XFS on LVM                   | Unchanged       |
| `/boot`                           | Separate partition           | Unchanged       |
| `/tmp`                            | Part of `/`                  | Unchanged       |
| World-writable files              | None identified              | None identified |
| World-writable `/etc` directories | None identified              | None identified |
| Unowned/ungrouped files           | None identified              | None identified |
| SUID/SGID files                   | Standard system entries      | Unchanged       |
| Mount options                     | Existing restrictive options | Unchanged       |

## Result

Filesystem security was reviewed without introducing unnecessary changes.

The current XFS/LVM layout and existing mount options are considered appropriate for the server's current role and planned DevOps workloads. No additional partitioning or filesystem permission changes were required.

