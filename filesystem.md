# Filesystem Hardening

## Objective

Review filesystem and mount configurations for basic security protections.

## Configuration Review

The following mount points and security options were reviewed:

* `/proc`
* `/sys`
* `/dev`
* `/dev/shm`
* `/run`
* `/dev/pts`
* `/dev/mqueue`

Existing protections such as `nosuid`, `nodev`, and `noexec` were verified where applicable.

`/dev/shm` was verified to use:

```text
rw,nosuid,nodev
```

`/tmp` and `/var/tmp` were not configured as separate filesystems, so no changes were made.

## Verification

Current mount options were reviewed using:

```bash
findmnt -o TARGET,FSTYPE,OPTIONS
```

Filesystem usage and mount points were reviewed using:

```bash
df -hT
```

`/dev/shm` configuration was additionally verified with:

```bash
mount | grep '/dev/shm'
findmnt /dev/shm
```

## Result

The existing filesystem configuration provides appropriate baseline protections for the reviewed virtual filesystems.

No additional filesystem changes were applied to avoid unnecessary configuration complexity or compatibility risks.

