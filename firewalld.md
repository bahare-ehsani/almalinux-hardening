# Firewall Configuration (firewalld)

- Allow only necessary ports
- Reload firewall after changes

Commands:
```bash
firewall-cmd --permanent --add-port=2222/tcp
firewall-cmd --reload
firewall-cmd --list-all
