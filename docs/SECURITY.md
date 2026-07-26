# Security Policy

## Defaults

- No anonymous telemetry.
- No enabled SSH, web, file-sharing, or remote-desktop server.
- Root login is disabled; administrative access uses sudo and polkit.
- The firewall starts with an inbound-deny workstation policy.
- AppArmor is enabled in enforcing mode for project-provided profiles.
- Packages and repository databases require trusted signatures.
- Flatpaks are installed only from explicitly configured remotes.

## Security Tools

The default image contains diagnostics and traffic-analysis tools. It does not
grant them unrestricted root access. Wireshark capture access is an explicit
installer/user setting; graphical applications never run as root.

Network, Web, Wireless, Forensics, and Password Audit packs are separate,
signed metapackages. Their descriptions must state that they are for authorized
systems and lab environments.

Sable will not include anticheat bypasses, credential theft automation,
silent persistence, or defaults that weaken host security.

## Release Keys

Development keys may sign local artifacts but never stable releases. Stable
package and repository signing uses an offline primary key and a constrained
online signing subkey. Keys, tokens, and recovery material never enter Git.

## Reporting

Until a dedicated security address exists, report vulnerabilities privately to
the project owner. Do not open public issues containing active exploit details
or private machine data.
