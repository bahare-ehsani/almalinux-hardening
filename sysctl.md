# Sysctl Hardening

## Objective

Harden selected kernel network parameters to reduce unnecessary network exposure.

## Configuration

A dedicated configuration file was created:

```text
/etc/sysctl.d/99-hardening.conf
```

The following parameters were configured:

```text
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv6.conf.all.accept_redirects = 0
```

IP forwarding was already disabled and therefore required no change:

```text
net.ipv4.ip_forward = 0
```

## Verification

The configuration was applied using:

```bash
sysctl --system
```

The final values were verified with:

```bash
sysctl net.ipv4.ip_forward
sysctl net.ipv4.conf.all.accept_redirects
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.all.rp_filter
sysctl net.ipv6.conf.all.accept_redirects
```

## Result

Selected IPv4 and IPv6 network parameters were hardened and verified successfully. The configuration is stored persistently under `/etc/sysctl.d/99-hardening.conf`.

