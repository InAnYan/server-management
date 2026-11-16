# Incident Report: [Brief Title of Incident]

- Date Detected: [YYYY-MM-DD HH:MM UTC]
- Date Resolved: [YYYY-MM-DD HH:MM UTC]
- Incident ID: [INC-YYYY-XXXX]
- Severity: [Critical | High | Medium | Low]
- Status: [Identified | Contained | Resolved | Closed]
- Lead Investigator: [Operator Name / Team]

## Summary

[High-level executive summary of the incident in 2-3 sentences. What occurred, what was the primary impact, and current status.]

## History Log of Events

Chronological sequence of key events, attacker activity, and operational responses:

| Timestamp (UTC) | Location / Node | Actor (Who) | Action / Observation (What) |
| :--- | :--- | :--- | :--- |
| [YYYY-MM-DD HH:MM] | [e.g. core-coord-gitea, host, external WAN] | [Attacker IP / Account / System] | [Initial breach attempt detected, unauthorized SSH login] |
| [YYYY-MM-DD HH:MM] | [e.g. dev-data-postgres] | [Attacker] | [Attempted privilege escalation or query execution] |
| [YYYY-MM-DD HH:MM] | [e.g. host vmbr0] | [Operator / Defender] | [Revoked API token, isolated node, blocked source IP] |
| [YYYY-MM-DD HH:MM] | [e.g. cluster-wide] | [Operator] | [Rotated credentials, deployed patched container] |

## Root Cause Analysis (Why It Happened)

Detailed explanation of the vulnerability, operational vector, or failure mechanism that allowed the incident to occur:

- **Vector Type**: [Leaked secret | Unpatched CVE | Misconfigured firewall | Weak credential | Phishing | Other]
- **Detailed Mechanism**: [Explain exactly how the perimeter or control was bypassed. E.g., commit containing a plaintext token pushed to public repository, or unauthenticated container port exposed on host.]
- **Compromised Artifacts**: [List any leaked API keys, tokens, SSH keys, or passwords.]

## Threat Actor Intentions (Approximative)

Assessment of the attacker's motivation, capabilities, and objectives:

- **Estimated Profile**: [Opportunistic automated scanner | Targeted attacker | Cryptominer | Ransomware operator | Script kiddie]
- **Primary Objective**: [e.g., Cryptojacking, intellectual property theft, database extortion, infrastructure abuse for botnets]
- **Observed Tooling / Indicators**: [Known exploit frameworks, custom scripts, external C2 servers, download staging URLs]

## Impact Analysis

Evaluation of damage across confidentiality, integrity, availability, and infrastructure scope:

- **Affected Systems**: [List specific VMs, containers, networks, or host components accessed]
- **Data Exposure (Confidentiality)**: [Were database contents, repository code, or secrets accessed or downloaded? Detail specific tables or files.]
- **Data Modification (Integrity)**: [Were files, database records, container images, or binaries modified or injected?]
- **Service Availability**: [Was there downtime, service interruption, or resource starvation?]
- **Lateral Movement**: [Did the attacker pivot across SDN subnets (e.g. from app to data tier) or access Proxmox host?]

## Taken Measures & Remediation

Concrete actions executed to contain, eradicate, and prevent recurrence:

### Immediate Containment & Eradication

- [e.g. Revoked compromised API tokens and rotated all affected database passwords]
- [e.g. Stopped compromised VM and purged infected Docker volume]
- [e.g. Blocked attacker IP ranges at network perimeter]

### Corrective & Preventive Measures

- [e.g. Added git pre-commit secret detection hooks to prevent future token leaks]
- [e.g. Hardened SDN firewall rules to eliminate unnecessary inter-subnet access]
- [e.g. Audited all Infisical and Proxmox access control logs]

## Lessons Learned

- What worked well during incident detection and response?
- What was missing or delayed (e.g. alert logging, secret rotation automation)?
- Action items and tracking tickets for long-term improvements.
