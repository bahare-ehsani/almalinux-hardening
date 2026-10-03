# AlmaLinux Server Hardening

## Overview

This project documents the setup, security hardening, and final verification of an AlmaLinux server for production-like DevOps practice.

The project focuses on building a secure Linux foundation before moving to automation, containerization, CI/CD, and other DevOps technologies.

## Skills

* Linux (AlmaLinux)
* User & Group Management
* Patch Management
* SSH Hardening
* Firewall Configuration (firewalld)
* SELinux
* Systemd
* Auditd
* Cron Security
* Filesystem Security
* Password & PAM Configuration
* Sysctl Hardening
* Logging & Journald
* Security Verification

## Structure

* `baseline.md` – Initial server baseline and system state
* `patch-management.md` – System update and patch management
* `users-groups.md` – User and group management
* `ssh-hardening.md` – SSH configuration and authentication hardening
* `firewalld-hardening.md` – Firewall configuration and network access control
* `selinux-hardening.md` – SELinux verification and hardening
* `systemd-hardening.md` – Systemd service review and hardening
* `auditd-hardening.md` – Linux auditing and security event monitoring
* `cron-hardening.md` – Cron service and scheduled job review
* `filesystem-hardening.md` – Filesystem security review
* `password-pam-hardening.md` – Password and PAM security configuration
* `sysctl-hardening.md` – Kernel network parameter hardening
* `logging-journald-hardening.md` – Persistent journald logging and log management
* `final-security-verification.md` – Final security and reboot persistence verification

## Project Status

The Linux security hardening phase is complete.

The server was successfully rebooted after hardening, and the main security controls were verified to remain active and persistent.

The next phase of the project is automation.

## About

AlmaLinux server setup and hardening project for DevOps practice.

