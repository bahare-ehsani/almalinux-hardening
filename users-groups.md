# Users & Groups Audit

## Objective

Audit local users, privileged accounts, login shells, and sudo access on AlmaLinux 9.8.

## Initial Audit

### UID 0 Accounts

```bash
awk -F: '$3 == 0 {print $1}' /etc/passwd
```

Result:

```text
root
```

Only `root` has UID 0.

### Login Shells

Most system accounts use:

```text
/sbin/nologin
```

or:

```text
/usr/sbin/nologin
```

Interactive shells identified:

```text
root       /bin/bash
sync       /bin/sync
shutdown   /sbin/shutdown
halt       /sbin/halt
```

Standard system accounts were not modified.

## Sudo Audit

Current sudo configuration:

```text
root       ALL=(ALL) ALL
%wheel     ALL=(ALL) ALL
```

Initial `wheel` group:

```text
wheel:x:10:
```

No users were initially members of `wheel`.

## Administrative User

A dedicated administrative user was created:

```bash
useradd -m -s /bin/bash devops
usermod -aG wheel devops
```

### Verification

```bash
id devops
```

Result:

```text
uid=1000(devops) gid=1000(devops) groups=1000(devops),10(wheel)
```

The user was also verified with:

```bash
getent passwd devops
```

Result:

```text
devops:x:1000:1000::/home/devops:/bin/bash
```

## Sudo Verification

```bash
sudo -l -U devops
```

Result:

```text
User devops may run the following commands on localhost:
    (ALL) ALL
```

Sudo access was successfully verified.

## Security Assessment

| Check | Result |
|---|---|
| UID 0 accounts | `root` only |
| Service account shells | `nologin` configured |
| Initial wheel members | None |
| Administrative user | `devops` |
| `devops` UID | 1000 |
| `devops` wheel membership | Enabled |
| `devops` sudo access | Verified |

## Result

- Audited local users and privileged accounts.
- Confirmed that only `root` has UID 0.
- Verified service accounts use non-interactive shells.
- Created a dedicated administrative user.
- Configured `wheel` membership for `devops`.
- Verified administrative access through `sudo`.
