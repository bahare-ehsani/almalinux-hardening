# User & Group Management

- Add users and groups
- Limit root usage
- Use wheel group for sudo access

Example commands:
```bash
groupadd devops
useradd -m -G devops bahar
passwd bahar
usermod -aG wheel bahar
