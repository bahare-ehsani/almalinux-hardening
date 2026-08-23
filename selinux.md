 SELinux Hardening

## 1. Objective

This document records the SELinux security verification performed on the
AlmaLinux hardening lab server.

The goal was to verify that SELinux is enabled and enforcing, that the
targeted policy is active, that important SSH file and process contexts
are correct, and that there are no recent SELinux AVC denials requiring
remediation.

The approach was verification-first: no SELinux setting was changed
unless a concrete security or operational requirement was identified.

------------------------------------------------------------------------

## 2. SELinux Current State

### Commands

``` bash
getenforce
sestatus
cat /etc/selinux/config
```

### Result

SELinux is enabled and running in **Enforcing** mode.

Key configuration:

``` text
SELinux status:              enabled
Current mode:                enforcing
Mode from config file:       enforcing
Loaded policy name:          targeted
SELINUX=enforcing
SELINUXTYPE=targeted
```

### Security Assessment

-   SELinux is enabled.
-   SELinux is enforcing the security policy.
-   The configuration is persistent across reboot.
-   The `targeted` policy is active.

**Status: PASS**

------------------------------------------------------------------------

## 3. SELinux AVC Denial Review

### Command

``` bash
ausearch -m AVC -ts recent
```

### Result

``` text
<no matches>
```

No recent SELinux AVC denial was found during the verification period.

### Security Assessment

There was no evidence of SELinux policy denials requiring remediation.

**Status: PASS**

------------------------------------------------------------------------

## 4. SELinux Process Context Verification

### Command

``` bash
ps -eZ | head -20
```

System processes were observed running under appropriate SELinux
contexts such as:

``` text
system_u:system_r:init_t:s0
system_u:system_r:kernel_t:s0
```

### SSH Process Verification

``` bash
ps -eZ | grep sshd
```

The SSH daemon was running under:

``` text
system_u:system_r:sshd_t:s0-s0:c0.c1023
```

The `sshd_t` domain is the expected SELinux domain for the SSH daemon.

**Status: PASS**

------------------------------------------------------------------------

## 5. SSH File Context Verification

### SSH Configuration

Command:

``` bash
ls -Zd /etc/ssh /etc/ssh/sshd_config
```

Result:

``` text
system_u:object_r:etc_t:s0 /etc/ssh
system_u:object_r:etc_t:s0 /etc/ssh/sshd_config
```

The SSH configuration files have the expected `etc_t` SELinux type.

### SSH Authorized Keys

Command:

``` bash
ls -Zd /home/devops /home/devops/.ssh /home/devops/.ssh/authorized_keys
```

Result for the SSH directory and authorized keys:

``` text
unconfined_u:object_r:ssh_home_t:s0 /home/devops/.ssh
unconfined_u:object_r:ssh_home_t:s0 /home/devops/.ssh/authorized_keys
```

The important SELinux type is:

``` text
ssh_home_t
```

This is the expected type for SSH files such as `authorized_keys` in a
user's home directory.

### Expected Context Verification

Command:

``` bash
matchpathcon /etc/ssh/sshd_config /home/devops/.ssh/authorized_keys
```

The expected contexts matched the observed contexts.

**Status: PASS**

------------------------------------------------------------------------

## 6. SSH Executable Context Verification

### Commands

``` bash
ls -Zd /usr/sbin/sshd
matchpathcon /usr/sbin/sshd
```

Observed and expected context:

``` text
system_u:object_r:sshd_exec_t:s0
```

The SSH executable has the expected `sshd_exec_t` SELinux type.

**Status: PASS**

------------------------------------------------------------------------

## 7. SELinux Boolean Review

### Command

``` bash
getsebool -a | grep -- ' --> on'
```

A number of SELinux Booleans were enabled.

During the review, several enabled Booleans were found to relate to
services or capabilities that are not currently used by this server,
including PostgreSQL, HTTP services, NFS, and other optional services.

The installed package review confirmed that the following service
families were not installed:

``` bash
rpm -qa | grep -Ei 'httpd|nginx|postgres|mariadb|mysql|samba|vsftpd|nfs|bind'
```

No matching packages were returned.

PostgreSQL was also explicitly verified:

``` bash
rpm -q postgresql-server
```

Result:

``` text
package postgresql-server is not installed
```

### Hardening Decision

No SELinux Boolean was disabled solely because its name appeared
unnecessary.

This avoids introducing unnecessary configuration changes or breaking
functionality that may be required by future services.

**Status: REVIEWED --- NO CHANGE REQUIRED**

------------------------------------------------------------------------

## 8. Running Services and Network Exposure

The currently running services were reviewed:

``` bash
systemctl list-units --type=service --state=running
```

The active services include:

-   auditd
-   chronyd
-   crond
-   firewalld
-   NetworkManager
-   rsyslog
-   sshd
-   systemd-journald
-   systemd-logind

Network listeners were also reviewed:

``` bash
ss -lntup
```

The only externally listening TCP service identified was:

``` text
0.0.0.0:22
[::]:22
```

This corresponds to SSH.

No unnecessary web, database, FTP, Samba, NFS, or DNS service was found
listening.

------------------------------------------------------------------------

## 9. Security Assessment

The SELinux configuration meets the current hardening requirements for
this lab server.

  Check                                   Result
  --------------------------------------- --------
  SELinux enabled                         PASS
  Enforcing mode                          PASS
  Persistent enforcing configuration      PASS
  Targeted policy                         PASS
  Recent AVC denials                      PASS
  SSH daemon domain (`sshd_t`)            PASS
  SSH executable type (`sshd_exec_t`)     PASS
  `authorized_keys` type (`ssh_home_t`)   PASS
  SSH configuration type (`etc_t`)        PASS
  Unnecessary service packages            PASS
  Additional Boolean changes required     NO

------------------------------------------------------------------------

## 10. Hardening Decision

No additional SELinux configuration changes were required.

The existing SELinux configuration was retained because:

1.  SELinux is already enabled and enforcing.
2.  The `targeted` policy is active.
3.  No recent AVC denials were detected.
4.  SSH is running under the expected SELinux domain.
5.  SSH-related file contexts are correct.
6.  No unnecessary network-facing services are installed or running.
7.  Disabling unrelated SELinux Booleans without an actual requirement
    would create unnecessary configuration changes.

This is an intentional **verification-based hardening result** rather
than a change-for-the-sake-of-change approach.

------------------------------------------------------------------------

## 11. Verification Commands

The following commands were used during this hardening step:

``` bash
getenforce
sestatus
cat /etc/selinux/config

ausearch -m AVC -ts recent

ps -eZ | head -20
ps -eZ | grep sshd

ls -Zd /etc/ssh /etc/ssh/sshd_config /var/log /var/log/audit
ls -Zd /home/devops /home/devops/.ssh /home/devops/.ssh/authorized_keys

matchpathcon /etc/ssh/sshd_config /home/devops/.ssh/authorized_keys

ls -Zd /usr/sbin/sshd
matchpathcon /usr/sbin/sshd

getsebool -a | grep -- ' --> on'

systemctl list-units --type=service --state=running
ss -lntup

rpm -q postgresql-server
systemctl list-unit-files | grep -i postgres

rpm -qa | grep -Ei 'httpd|nginx|postgres|mariadb|mysql|samba|vsftpd|nfs|bind'
```

------------------------------------------------------------------------

## 12. Final Status

**SELinux Hardening: COMPLETED**

No SELinux policy or configuration changes were necessary after
verification.

The server retains:

``` text
SELinux = Enforcing
Policy   = targeted
```

with correct SSH SELinux contexts and no recent AVC denials.

