# Firewalld Hardening

## Objective

Harden the host-based firewall by limiting exposed services, removing unnecessary firewall rules, enabling denied-traffic logging, and verifying configuration persistence across reboot.

## Current State

* `firewalld` is active and enabled at boot.
* Active zone: `public`
* Network interface: `ens33`
* Only SSH is required for remote administration.
* No custom firewall ports are configured.
* The server is not used for IP forwarding or NAT.
* Cockpit is not installed or active.
* DHCPv6 is not used in the current network configuration.

## Configuration

The following changes were applied to the `public` zone:

* Removed the unnecessary `cockpit` service.
* Removed the unnecessary `dhcpv6-client` service.
* Retained `ssh` for administrative access.
* No custom ports or rich rules were added.
* Masquerading remains disabled.
* Denied unicast traffic logging was enabled.

Final firewall services:

```text
ssh
```

Denied traffic logging:

```text
LogDenied=unicast
```

## Verification

The following checks were performed:

* Verified `firewalld` service status.
* Verified the active zone and network interface.
* Verified listening network ports using `ss`.
* Confirmed that only SSH is externally listening.
* Verified that IP forwarding is disabled.
* Verified that masquerading is disabled.
* Verified that no custom ports or rich rules are configured.
* Verified that only `ssh` remains as an allowed firewall service.
* Verified `LogDenied=unicast` in both runtime and persistent configuration.
* Rebooted the server and confirmed firewall configuration persisted.
* Verified SSH administrative access remained available after reboot.

## Before / After

| Setting                | Before                            | After     |
| ---------------------- | --------------------------------- | --------- |
| Allowed services       | `cockpit`, `dhcpv6-client`, `ssh` | `ssh`     |
| Custom ports           | None                              | None      |
| Rich rules             | None                              | None      |
| Masquerade             | `no`                              | `no`      |
| IP forwarding          | `0`                               | `0`       |
| Denied traffic logging | `off`                             | `unicast` |

## Result

Firewalld was hardened using a least-privilege approach. Unnecessary services were removed from the active zone, SSH remains available for administration, denied unicast traffic is logged, and the final configuration was verified to persist after reboot.

