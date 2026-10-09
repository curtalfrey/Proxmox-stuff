# Next steps

## 2026-10-09 audit: helper script and playbook fixes (branch `audit/round3-script-fixes`)

Nothing in this repo runs by itself. These steps apply only where you copied a script
or playbook onto a host earlier.

- [ ] Re-copy any changed script you use from a host's crontab or `.bashrc`
  (`anti-virus/2_clam-rk-update-scan.sh`, `helpful_commands/scripts/*.sh`, `helpful_commands/ban_ips`).
- [ ] rkhunter: the scan scripts no longer run `rkhunter --propupd` before every check.
  On each host that used them, run `sudo rkhunter --propupd` **once**, after confirming
  the last `apt` upgrade was yours, so the next `--check` has a clean baseline.
- [ ] `restore_from_backup.sh` now takes the backup file as its first argument; update
  any cron line or note that called it with no arguments.
- [ ] `ansible/playbooks/github-repo-update`: give each repository a `url` (and optional `branch`).
- [ ] Open decision: `backup.sh` excludes `/log/*`, which matches nothing on a normal
  system. If `/var/log/*` was meant, change it (left as-is in this PR).
- [ ] Open decision: `helpful_commands/scripts/clam-rk-update-scan.sh` still uses
  `clamscan --remove` (deletes infected files). Switch to `--move=<dir>` if you prefer to review first.
