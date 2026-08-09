# SSH Hardening

- Disable root login
- Use key-based authentication
- Change default port

Example commands:
```bash
vi /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
Port 2222
systemctl restart sshd
