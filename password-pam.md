# Password & PAM Hardening

## Objective

Review password aging and PAM password policies to identify unnecessary or insecure configurations.

## Configuration Review

Password aging settings in `/etc/login.defs` were reviewed:

```text
PASS_MAX_DAYS = 99999
PASS_MIN_DAYS = 0
PASS_WARN_AGE = 7
```

Existing users were also checked with `chage`.

The `pam_pwquality` module was found to be enabled in both:

```text
/etc/pam.d/system-auth
/etc/pam.d/password-auth
```

No `pam_faillock` configuration was found.

## Decision

No configuration changes were applied.

Password-based SSH authentication is already disabled, reducing the exposure to password-based brute-force attacks.

PAM configuration was left unchanged to avoid unnecessary modifications to the AlmaLinux `authselect`-managed configuration.

## Verification

Current password policies were verified using:

```bash
grep -E '^(PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE)' /etc/login.defs
```

Existing user policies were checked with:

```bash
chage -l devops
chage -l root
```

PAM modules were reviewed with:

```bash
grep -E 'pam_faillock|pam_pwquality|pam_pwhistory' \
/etc/pam.d/system-auth /etc/pam.d/password-auth
```

## Result

Password and PAM configurations were reviewed and no additional changes were considered necessary for this hardening baseline.

