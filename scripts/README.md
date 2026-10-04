# Security Verification Script

## Objective

Provide a read-only Bash script to verify the main security controls configured on the AlmaLinux server.

The script is designed to provide a repeatable security verification process after configuration changes, system updates, or server reboots.

## Script

`security-verification.sh`

The script does not modify system configuration. It only reads the current system state and reports the verification results.

## Checks

The script verifies the following security controls:

### SSH Hardening

* `PermitRootLogin`
* `PasswordAuthentication`
* `KbdInteractiveAuthentication`
* `MaxAuthTries`
* `LoginGraceTime`
* `X11Forwarding`

### Firewalld

* Firewalld service status
* Active firewall zone
* Allowed firewall services

### SELinux

* SELinux enforcement status

### Auditd

* Auditd service status

### Sysctl

* IPv4 ICMP redirect acceptance
* IPv4 ICMP redirect sending

The following parameters are checked:

```text
net.ipv4.conf.all.accept_redirects
net.ipv4.conf.default.accept_redirects
net.ipv4.conf.all.send_redirects
net.ipv4.conf.default.send_redirects
```

### Journald

* `systemd-journald` service status
* Persistent journal storage
* Journal integrity

## Usage

Run the script as `root`:

```bash
./scripts/security-verification.sh
```

The script displays the result of each check as:

```text
[PASS]
```

or:

```text
[FAIL]
```

## Example Output

```text
======================================
 AlmaLinux Security Verification
======================================

SSH Hardening
-------------
[PASS] PermitRootLogin disabled
[PASS] PasswordAuthentication disabled
...

Summary
-------
PASS: 18
FAIL: 0

Overall status: PASS
```

## Exit Status

The script returns an exit status based on the verification results:

* `0` – All security checks passed
* `1` – One or more security checks failed

The exit status allows the script to be used by other automation tools in the future.

## Verification Result

The current server verification completed successfully with:

```text
PASS: 18
FAIL: 0
Overall status: PASS
```

This confirms that the main security controls verified by the script were active and correctly configured at the time of testing.

## Role in the Project

This script is the first automation step after completing the manual Linux security hardening phase.

It converts previously manual security verification tasks into a repeatable and reusable process.

The script complements the existing manual security documentation by providing automated verification without replacing the detailed configuration and hardening documentation.

