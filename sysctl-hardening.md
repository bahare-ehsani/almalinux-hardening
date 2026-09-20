# Sysctl / Kernel Hardening

## Objective

Harden Linux kernel and network parameters through `sysctl` to reduce common kernel and network-level security risks while preserving compatibility with current and future DevOps workloads.

## Current State

* Kernel security parameters were reviewed before making changes.
* Address Space Layout Randomization (ASLR) was already enabled.
* Kernel pointer and `dmesg` access restrictions were already enabled.
* IPv4 forwarding was disabled.
* TCP SYN cookies were enabled.
* IPv4 and IPv6 ICMP redirect-related settings were enabled by default.
* `rp_filter` was enabled on the active interface through the existing Red Hat configuration.
* IPv6 was enabled but only link-local addressing was present on the active interface.
* No changes were made to ARP-related parameters, `log_martians`, or `rp_filter` because the existing configuration was considered appropriate for the server environment.

A VMware snapshot named `Before-Sysctl-Hardening` was created before applying the first configuration change.

## Configuration

Sysctl hardening was implemented through:

`/etc/sysctl.d/99-hardening.conf`

Final configuration:

```text
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.ens33.accept_redirects = 0
net.ipv4.conf.ens33.send_redirects = 0
net.ipv4.conf.ens33.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.ens33.accept_redirects = 0
```

The configuration was applied using:

```bash
sudo sysctl --system
```

Existing secure kernel parameters were intentionally left unchanged because they were already correctly configured.

No changes were made to:

* `net.ipv4.conf.*.rp_filter`
* `net.ipv4.conf.*.arp_ignore`
* `net.ipv4.conf.*.arp_filter`
* `net.ipv4.conf.*.accept_local`
* `net.ipv4.conf.*.drop_gratuitous_arp`
* `net.ipv4.conf.*.log_martians`

These parameters were reviewed but did not require modification for the current server role.

## Verification

The following existing kernel security parameters were verified:

```text
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
net.ipv4.ip_forward = 0
net.ipv4.tcp_syncookies = 1
```

IPv4 redirect settings were verified as:

```text
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.ens33.accept_redirects = 0

net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.ens33.send_redirects = 0

net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.ens33.secure_redirects = 0
```

IPv6 redirect settings were verified as:

```text
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.ens33.accept_redirects = 0
```

The configuration was successfully applied with `sysctl --system` without errors.

The final configuration was stored in `/etc/sysctl.d/99-hardening.conf` to provide persistent configuration across reboots.

## Before / After

| Setting                     | Before | After |
| --------------------------- | -----: | ----: |
| `kernel.randomize_va_space` |      2 |     2 |
| `kernel.dmesg_restrict`     |      1 |     1 |
| `kernel.kptr_restrict`      |      1 |     1 |
| `net.ipv4.ip_forward`       |      0 |     0 |
| `net.ipv4.tcp_syncookies`   |      1 |     1 |
| IPv4 `accept_redirects`     |      1 |     0 |
| IPv4 `send_redirects`       |      1 |     0 |
| IPv4 `secure_redirects`     |      1 |     0 |
| IPv6 `accept_redirects`     |      1 |     0 |
| `rp_filter` on `ens33`      |      1 |     1 |

## Result

Sysctl and kernel network hardening was completed with minimal configuration changes.

IPv4 and IPv6 redirect acceptance was disabled, IPv4 router advertisements through redirect mechanisms were disabled, and existing secure kernel parameters were preserved.

The configuration is stored persistently in `/etc/sysctl.d/99-hardening.conf` and was successfully applied and verified. Parameters such as `rp_filter`, ARP behavior, and martian logging were intentionally left unchanged to avoid unnecessary changes to the production-like server environment.

Reboot persistence will be verified during the final security verification phase.

