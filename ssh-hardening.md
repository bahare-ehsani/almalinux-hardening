# SSH Hardening

## Objective

Harden SSH access on AlmaLinux 9 by restricting authentication methods, preventing direct root login, limiting authentication attempts, and allowing SSH access only for the designated administrative user.

## Configuration

Hardening configuration is stored in:

```text
/etc/ssh/sshd_config.d/99-hardening.conf
```

```text
PasswordAuthentication no

LoginGraceTime 30
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding yes
PermitEmptyPasswords no
AllowUsers devops
```

## Security Settings

| Setting                  |    Value | Purpose                                            |
| ------------------------ | -------: | -------------------------------------------------- |
| `PasswordAuthentication` |     `no` | Disable password-based SSH authentication          |
| `PermitRootLogin`        |     `no` | Prevent direct SSH login as root                   |
| `AllowUsers`             | `devops` | Restrict SSH access to the `devops` user           |
| `LoginGraceTime`         |     `30` | Limit the time allowed for authentication          |
| `MaxAuthTries`           |      `3` | Limit failed authentication attempts               |
| `ClientAliveInterval`    |    `300` | Send keepalive messages every 5 minutes            |
| `ClientAliveCountMax`    |      `2` | Disconnect after two unanswered keepalive messages |
| `X11Forwarding`          |    `yes` | X11 forwarding remains enabled as required         |
| `PermitEmptyPasswords`   |     `no` | Prevent authentication using empty passwords       |

## Administrative Access Model

Direct root SSH access is disabled.

The `devops` user is allowed to connect through SSH and has administrative privileges through `sudo`.

```text
SSH
 ├── root   → DENIED
 │
 └── devops → ALLOWED
              │
              └── sudo → root
```

The `devops` account belongs to the `wheel` group and has full sudo privileges:

```text
User devops may run the following commands on localhost:
    (ALL) ALL
```

## Verification

### Validate SSH configuration

```bash
sshd -t
```

Result:

```text
No output / no errors
```

### Verify effective SSH configuration

```bash
sshd -T | grep -E '^(passwordauthentication|permitrootlogin|allowusers|allowgroups|logingracetime|maxauthtries|clientaliveinterval|clientalivecountmax|x11forwarding|permitemptypasswords)'
```

Expected result:

```text
logingracetime 30
maxauthtries 3
clientaliveinterval 300
clientalivecountmax 2
permitrootlogin no
passwordauthentication no
x11forwarding yes
permitemptypasswords no
allowusers devops
```

### Verify SSH service

```bash
systemctl is-active sshd
systemctl is-enabled sshd
```

Result:

```text
active
enabled
```

### Verify administrative privileges

```bash
sudo -l -U devops
```

Result confirms:

```text
User devops may run the following commands on localhost:
    (ALL) ALL
```

### Verify user membership

```bash
id devops
```

Result:

```text
uid=1000(devops) gid=1000(devops) groups=1000(devops),10(wheel)
```

### SSH Login Test

Remote login using the `devops` account was successfully tested.

```bash
ssh devops@<server-ip>
```

After login:

```bash
whoami
```

returns:

```text
devops
```

Administrative access was also verified using:

```bash
sudo -i
```

and:

```bash
whoami
```

returns:

```text
root
```

## Final Status

SSH hardening verification completed successfully.

* [x] Password authentication disabled
* [x] Direct root SSH login disabled
* [x] SSH access restricted to `devops`
* [x] Authentication attempts limited
* [x] SSH connection timeout configured
* [x] Empty passwords disabled
* [x] SSH configuration validated
* [x] SSH service active and enabled
* [x] `devops` SSH access verified
* [x] `devops` sudo access verified
* [x] Root administrative access through sudo verified

**Status: PASS**

