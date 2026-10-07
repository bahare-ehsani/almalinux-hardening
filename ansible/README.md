# Ansible Security Verification

## Objective

Automate the verification of the security configuration of the AlmaLinux managed server using Ansible.

The playbook is designed as a read-only verification layer after the manual security hardening phase. It checks the main security controls without modifying the managed server.

## Architecture

The project uses a separate Ansible Control Node to manage the AlmaLinux server:

```text
Ansible Control Node
        │
        │ SSH
        ▼
AlmaLinux Server
(Managed Node)
```

The Ansible Control Node runs `ansible-core` and connects to the managed server using SSH key authentication.

Privilege escalation is performed using Ansible `become`.

## Structure

```text
ansible/
├── inventory/
│   └── hosts
├── playbooks/
│   └── security-verification.yml
└── README.md
```

### Inventory

The inventory defines the managed AlmaLinux server:

```ini
[managed]
almalinux ansible_host=192.168.75.129 ansible_user=devops
```

The `devops` account connects through SSH key authentication and uses `sudo` for privileged verification tasks.

## Security Checks

The `security-verification.yml` playbook verifies:

### SSH

* Root SSH login is disabled
* Password authentication is disabled
* Keyboard-interactive authentication is disabled
* Maximum authentication attempts are set to 3
* SSH login grace time is set to 30 seconds
* X11 forwarding is disabled

### Firewalld

* Firewalld is active
* The public zone is active
* Only the SSH service is allowed in the public zone

### SELinux

* SELinux is running in `Enforcing` mode

### Auditd

* The `auditd` service is active

### Sysctl

The following IPv4 redirect settings are verified:

* `net.ipv4.conf.all.accept_redirects`
* `net.ipv4.conf.default.accept_redirects`
* `net.ipv4.conf.all.send_redirects`
* `net.ipv4.conf.default.send_redirects`

All values must be set to `0`.

### Journald

* `systemd-journald` is active
* Persistent journal storage is available
* Journal integrity verification passes

## Running the Playbook

Run the playbook from the Ansible Control Node:

```bash
ansible-playbook -i /root/almalinux-hardening/ansible/inventory/hosts /root/almalinux-hardening/ansible/playbooks/security-verification.yml -K
```

The `-K` option prompts for the `sudo` password required by Ansible `become`.

## Expected Result

A successful run should report:

```text
changed=0
unreachable=0
failed=0
```

For example:

```text
PLAY RECAP
almalinux : ok=24 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

`changed=0` confirms that the playbook performed verification only and did not modify the managed server.

## Design Notes

This playbook intentionally uses simple Ansible modules and a clear `check → register → verify` pattern.

The current implementation does not use Ansible Roles because the project contains a single verification playbook. Roles can be introduced later when multiple playbooks or reusable configuration tasks justify them.

## Result

The Ansible verification layer provides a repeatable way to validate the security state of the hardened AlmaLinux server without manually checking each security control.

