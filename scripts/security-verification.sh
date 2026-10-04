#!/usr/bin/env bash

set -u

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "======================================"
echo " AlmaLinux Security Verification"
echo "======================================"
echo
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must be run as root."
    exit 1
fi

echo "SSH Hardening"
echo "-------------"

SSH_CONFIG=$(sshd -T)

[[ "$SSH_CONFIG" == *"permitrootlogin no"* ]] \
    && pass "PermitRootLogin disabled" \
    || fail "PermitRootLogin is not disabled"

[[ "$SSH_CONFIG" == *"passwordauthentication no"* ]] \
    && pass "PasswordAuthentication disabled" \
    || fail "PasswordAuthentication is not disabled"

[[ "$SSH_CONFIG" == *"kbdinteractiveauthentication no"* ]] \
    && pass "Keyboard-interactive authentication disabled" \
    || fail "Keyboard-interactive authentication is enabled"

[[ "$SSH_CONFIG" == *"maxauthtries 3"* ]] \
    && pass "MaxAuthTries set to 3" \
    || fail "MaxAuthTries is not set to 3"

[[ "$SSH_CONFIG" == *"logingracetime 30"* ]] \
    && pass "LoginGraceTime set to 30 seconds" \
    || fail "LoginGraceTime is not set to 30 seconds"

[[ "$SSH_CONFIG" == *"x11forwarding no"* ]] \
    && pass "X11Forwarding disabled" \
    || fail "X11Forwarding is not disabled"

echo

echo "Firewalld"
echo "---------"

if [[ "$(systemctl is-active firewalld)" == "active" ]]; then
    pass "Firewalld is active"
else
    fail "Firewalld is not active"
fi

ACTIVE_ZONE=$(firewall-cmd --get-active-zones | awk 'NR==1 {print $1}')

if [[ "$ACTIVE_ZONE" == "public" ]]; then
    pass "Public zone is active"
else
    fail "Public zone is not active"
fi

SERVICES=$(firewall-cmd --zone=public --list-services)

if [[ "$SERVICES" == "ssh" ]]; then
    pass "Only SSH service is allowed"
else
    fail "Unexpected firewall services: $SERVICES"
fi

echo

echo "SELinux"
echo "-------"

SELINUX_STATUS=$(getenforce)

if [[ "$SELINUX_STATUS" == "Enforcing" ]]; then
    pass "SELinux is enforcing"
else
    fail "SELinux is not enforcing"
fi

echo

echo "Auditd"
echo "------"

if [[ "$(systemctl is-active auditd)" == "active" ]]; then
    pass "Auditd is active"
else
    fail "Auditd is not active"
fi

echo

echo "Sysctl"
echo "------"

check_sysctl() {
    local parameter="$1"
    local expected="$2"
    local actual

    actual=$(sysctl -n "$parameter" 2>/dev/null)

    if [[ "$actual" == "$expected" ]]; then
        pass "$parameter = $expected"
    else
        fail "$parameter = $actual (expected $expected)"
    fi
}

check_sysctl "net.ipv4.conf.all.accept_redirects" "0"
check_sysctl "net.ipv4.conf.default.accept_redirects" "0"
check_sysctl "net.ipv4.conf.all.send_redirects" "0"
check_sysctl "net.ipv4.conf.default.send_redirects" "0"

echo

echo "Journald"
echo "--------"

if systemctl is-active --quiet systemd-journald; then
    pass "systemd-journald is active"
else
    fail "systemd-journald is not active"
fi

if compgen -G "/var/log/journal/*/system.journal" > /dev/null; then
    pass "Persistent journal storage is available"
else
    fail "Persistent journal storage is not available"
fi

if journalctl --verify >/dev/null 2>&1; then
    pass "Journal integrity verified"
else
    fail "Journal integrity verification failed"
fi

echo

echo "Summary"
echo "-------"

echo "PASS: $PASS_COUNT"
echo "FAIL: $FAIL_COUNT"
echo

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo "Overall status: PASS"
    exit 0
else
    echo "Overall status: FAIL"
    exit 1
fi
