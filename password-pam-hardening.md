# Password & PAM Hardening

## Objective

Harden password authentication and PAM policies to reduce the risk of brute-force attacks and password reuse while maintaining reliable administrative access.

## Current State

* `authselect` profile: `local`
* `pam_pwquality` was already active through the existing PAM configuration.
* No custom password-quality settings were configured.
* `pam_faillock` was not previously enabled.
* Password history was not previously enabled.
* Password expiration was set to `never` and was not changed because no mandatory password-rotation requirement was established.
* Administrative access is provided through the `devops` account with SSH key authentication and `sudo`.

A VMware snapshot named `Before-PAM-Hardening` was created before PAM changes.

## Configuration

### Account Lockout

`pam_faillock` was enabled through `authselect`:

```bash
authselect enable-feature with-faillock --backup=before-faillock
```

The following policy was configured in `/etc/security/faillock.conf`:

```text
deny=5
fail_interval=900
unlock_time=900
```

Configured behavior:

* Lockout threshold: 5 failed authentication attempts
* Failure interval: 15 minutes
* Unlock time: 15 minutes
* `even_deny_root` was not enabled.

### Password History

Password history was enabled through `authselect`:

```bash
authselect enable-feature with-pwhistory --backup=before-pwhistory
```

`pam_pwhistory.so` was verified as active in both:

```text
/etc/pam.d/system-auth
/etc/pam.d/password-auth
```

No custom settings were added to `/etc/security/pwhistory.conf`. The system default of remembering the last 10 passwords is therefore used.

### Password Quality

`pam_pwquality.so` was already active in the PAM configuration.

No additional password-complexity policy was added because the existing configuration was already enforcing password-quality checks.

During testing with a temporary account, weak passwords were rejected by the existing password-quality controls.

### Password Expiration

No changes were made to password-aging settings.

The existing `PASS_MAX_DAYS 99999` policy was retained because no mandatory password-rotation requirement was established for this environment.

## Verification

The active `authselect` configuration was verified:

```bash
authselect current
```

Result:

```text
Profile ID: local
Enabled features:
- with-faillock
- with-pwhistory
```

Configuration validity was verified:

```bash
authselect check
```

Result:

```text
Current configuration is valid.
```

`pam_faillock` was functionally tested using a temporary account. Two failed authentication attempts were successfully recorded by `faillock`.

The test records were then cleared:

```bash
faillock --user faillock-test --reset
```

The temporary test account was subsequently removed.

The lockout threshold of five failures was configured but was not intentionally triggered during testing to avoid unnecessary account lockout.

## Before / After

| Setting             | Before         | After                 |
| ------------------- | -------------- | --------------------- |
| `pam_pwquality`     | Active         | Active                |
| `pam_faillock`      | Not enabled    | Enabled               |
| Lockout policy      | Not configured | 5 failures / 15 min   |
| Unlock time         | —              | 15 minutes            |
| `pam_pwhistory`     | Not enabled    | Enabled               |
| Password history    | —              | 10 previous passwords |
| Password expiration | Never          | Never                 |
| `even_deny_root`    | Not enabled    | Not enabled           |

## Result

Password and PAM authentication controls were hardened using `authselect`.

`pam_faillock` now provides a configured failed-authentication lockout policy, while `pam_pwhistory` prevents reuse according to the system default history of 10 passwords. Existing `pam_pwquality` controls remain active.

The configuration was validated successfully with `authselect check`, and failed authentication recording was functionally verified without disrupting the administrative `devops` account.

