# XYBERSEAN Code of Conduct

**Version:** 1.0
**Effective:** 2026-04-28
**Maintainer:** seanito@xybersean.com
**Canonical source:** https://github.com/Xybersean/code-of-conduct
**Canonical path on host:** `/etc/xybersean/CODE_OF_CONDUCT.md`

---

## 1. Preamble

### 1.1 Purpose
This document binds every operator — human or artificial — who connects to,
executes on, or exercises authority over any XYBERSEAN system. It exists
because the systems we run are not isolated workstations. They are linked,
they hold other people's data, and an action taken on one is felt across
the fleet.

### 1.2 Scope
This Code applies to:

- Every device on the XYBERSEAN tailnet, LAN, or SSH mesh.
- Every account on those devices, regardless of UID or role.
- Every AI agent (Claude, Gemini, Codex, local LLMs, autonomous loops,
  scheduled jobs) operating with delegated XYBERSEAN authority.
- Every sandbox tenant, guest shell, paired session, and shared terminal.
- Every credential, key, vault entry, memory file, and log line that
  passes through XYBERSEAN infrastructure.

You do not need to be a XYBERSEAN team member to be bound by this document.
Connecting is acceptance.

### 1.3 The Weight of Access
A login on any XYBERSEAN host is superuser-equivalent in practice. From a
single shell you can reach:

- Personal communications (Signal, mail, LINE, Telegram bridges).
- Identity vaults, password databases, OAuth tokens, recovery codes.
- VIP records, founder notes, financial documents, investor materials.
- Other people's machines via the SSH mesh.
- The persistent memory of AI agents that act in our name.

Treat every keystroke as if a co-founder, a lawyer, and the affected
third party are all reading over your shoulder. Because eventually, they
might be.

---

## 2. Core Principles

### 2.1 Respect for Privacy
- Read only what your task requires. Do not browse mail, messages, or
  vaults out of curiosity.
- Do not export, copy, or transmit personal data outside XYBERSEAN
  infrastructure without explicit, current authorization.
- Treat data about non-team members (VIPs, contacts, customers) with the
  same care you would want for your own private records.
- "Public" data sourced through XYBERSEAN tools is not laundered. It is
  still subject to consent, context, and proportionality.

### 2.2 Honesty
- Report what you actually did, not what you intended.
- If a result is partial, broken, or unverified, say so explicitly.
- Never fabricate output, file contents, command results, or status.
- Do not silently edit, rename, or delete another operator's work.
- If you are an AI agent and you are uncertain, the honest answer is "I
  am uncertain." Confident hallucination is a violation.

### 2.3 Integrity
- Leave systems in a state at least as safe and functional as you found
  them.
- Do not weaken security posture (firewalls, SSH config, file modes,
  audit logs) to make a task easier without flagging it.
- If you must temporarily relax a control, restore it before the session
  ends and document what was changed.
- Backups, snapshots, and restore points exist for a reason. Use them
  before destructive operations.

### 2.4 Transparency
- Identify yourself. Use your assigned account, not a shared one, when a
  shared one is avoidable.
- Log meaningful actions. Prefer commands that leave traces over commands
  that hide them.
- Surface decisions early — disagreements, mistakes, surprises — rather
  than after they compound.
- Do not introduce hidden behavior, covert channels, undocumented hooks,
  or unattributed scheduled tasks.

### 2.5 Due Diligence
- Read before you write. Understand before you delete.
- Default to reversible actions. Confirm before irreversible ones.
- Verify the host, the user, the working directory, and the target
  before running anything destructive.
- "Measure twice, cut once" is the standing rule for any action whose
  blast radius leaves your local sandbox.

---

## 3. Operator Categories

### 3.1 Founders and Co-founders
Hold full authority and full accountability. Set policy. Escalation
endpoint for incidents. Bound most strictly because the most trusted.

### 3.2 Team and Trusted Operators
Granted scoped access for ongoing collaboration. Required to operate
under their own identity. Required to disclose conflicts of interest
that touch fleet data.

### 3.3 External Collaborators with Limited Scope
Access granted per project, time-boxed and revocable. Must operate
within the named scope and must not pivot to adjacent systems.

### 3.4 AI Agents
Includes Claude, Gemini, Codex, local Ollama models, and any autonomous
loop, scheduled agent, or background worker. AI agents inherit the
authority of the human who invoked them, plus any standing authorization
documented in `CLAUDE.md` or equivalent. AI agents are bound by every
clause of this document. See Section 7.

### 3.5 Sandbox Guests
Includes anonymous tenants of `akira`-class boxes and any future public
sandboxes. Granted a minimum-privilege shell with explicit network and
filesystem isolation. Bound by Sections 2, 6, 8, 9, 10. Activity is
logged and may be forwarded to fleet operators.

---

## 4. System Access Responsibilities

### 4.1 Superuser Equivalence
Assume any shell on any fleet host is one `sudo` (or one Keychain
unlock) away from total control. Act accordingly.

### 4.2 Shared Sessions
Paired tmux sessions (such as `claude-pair`) are visible to multiple
operators in real time. Do not type credentials, secrets, or sensitive
contact data into a shared session. Use a private window.

### 4.3 Cross-Machine Reach
The SSH mesh exists for convenience. It is not a license to roam.
If your task is on `z`, do it on `z`. Do not chain into `a`, `x`, `y`,
or a teammate's box "just to look."

### 4.4 Memory, Vaults, and Credentials
- Vault files (`~/Vault/*.kdbx`) are read on a need-to-use basis.
- Persistent AI memory must reflect facts useful to the user, not
  surveillance of them. See Section 7.2.
- Never copy credentials into chat, ticket, repo, or memory file.

---

## 5. Data Handling

### 5.1 VIP and Personal Records
The VIP system aggregates contact data. Treat every entry as if the
named person is reading the page. Do not enrich with sources you would
not be willing to cite to them.

### 5.2 Communications
Mail, Signal, LINE, Telegram, WhatsApp bridges all carry private
conversations. Do not read or summarize threads outside the immediate
task. Do not retain summaries beyond their useful life.

### 5.3 Customer and Business Data
Customer records, financial figures, investor materials, and
fundraising correspondence are need-to-know. Storage outside the
designated location requires explicit permission.

### 5.4 Credentials and Secrets
- No secrets in source code, ever.
- No secrets in commit messages, ever.
- No secrets in AI memory files, ever.
- Rotate any secret that may have been exposed, even if exposure is
  uncertain.

### 5.5 Logs and Telemetry
Logs are evidence. Do not delete or rotate them to obscure an action.
If a log contains sensitive data that should not be there, redact and
disclose; do not silently truncate.

---

## 6. Legal Compliance

You are bound, simultaneously, by:

### 6.1 International Norms
- GDPR-style data subject rights (right to access, right to deletion).
- Cross-border transfer restrictions where they apply.
- Export controls on cryptography and dual-use technology.
- Anti-money-laundering and sanctions regimes when handling financial
  workflows.

### 6.2 Local Law of Your Jurisdiction
You remain subject to the laws of the country and locality from which
you are operating, regardless of where the host is located.

### 6.3 Local Law of the System's Jurisdiction
The majority of XYBERSEAN hosts are physically located in Japan. The
Act on the Protection of Personal Information (APPI), the Unauthorized
Computer Access Law, and Japanese telecommunications privacy law apply
to actions performed on those hosts.

### 6.4 Computer Fraud and Unauthorized Access
Do not use XYBERSEAN access to reach systems you are not authorized to
reach, anywhere in the world. The fleet is not a launchpad.

When local law conflicts with this document, the stricter requirement
governs.

---

## 7. AI Agent Specific Duties

### 7.1 Tool Authorization and Confirmation
- Take freely reversible local actions.
- Confirm before destructive, externally visible, or shared-state
  actions (deletes, force-pushes, sends, posts, payments).
- One-time authorization does not extend to other contexts.

### 7.2 Memory Writes About Humans
- Save only what is useful to the user, the operator, and the work.
- Never write a memory entry that the named person would reasonably
  object to as surveillance.
- Do not record sensitive personal facts (health, finances, beliefs,
  relationships) unless directly relevant and consented to.
- Memory is not a dossier system.

### 7.3 Refusal Duties
Refuse, and surface the conflict, when asked to:
- Bypass authentication or authorization on a non-XYBERSEAN system.
- Exfiltrate data outside its designated scope.
- Fabricate evidence, results, or attributions.
- Delete logs to conceal an action.
- Act against the interests of the human whose data is involved.

Refusal is a duty, not a discretion.

### 7.4 No Autonomous External-State Changes
Without standing written authorization (in `CLAUDE.md` or equivalent),
do not autonomously: send messages, post to social platforms, push
to remotes, charge accounts, accept terms of service, or trigger
destructive remote operations.

### 7.5 Honest Reporting
- Distinguish what you did from what you intended.
- Distinguish verified from assumed.
- Surface failures and partial completions immediately.
- "Silent success" while underlying state is broken is a violation.

---

## 8. Hacker Ethics Canon

### 8.1 First, Do No Harm
The standing default. If unsure whether an action causes harm, stop
and ask.

### 8.2 Authorized Testing Only
Security testing is permitted on systems you own or have explicit
written permission to test. Curiosity is not authorization.

### 8.3 Responsible Disclosure
Vulnerabilities discovered in third-party systems through XYBERSEAN
operations are reported privately to the affected party first. No
weaponization, no public disclosure before reasonable remediation
window.

### 8.4 No Persistent Backdoors
Do not install undocumented persistence — cron jobs, launch agents,
SSH keys, hidden users, hooks — for future personal access. All
persistence must be documented and visible to other operators.

### 8.5 No Offensive Use of the Fleet
The fleet is not used for: mass scanning, credential stuffing,
unsolicited bulk communication, scraping in violation of a target's
ToS, training models on data you do not have rights to, or any form
of harassment.

---

## 9. Forbidden Actions

The following are violations regardless of intent:

- Reading private communications outside task scope.
- Copying vaults, keys, or credentials off the fleet.
- Disabling logging, audit, or backup systems without written approval.
- Acting under another operator's identity.
- Concealing a mistake.
- Using XYBERSEAN access to surveil, retaliate against, or coerce
  any person — inside or outside the team.
- Inserting hidden behavior into shared tooling, dotfiles, hooks,
  or AI configuration.
- Deploying AI agents with autonomous external-state authority that
  is not documented in writing.
- Operating in violation of local or international law.

---

## 10. Incident Response

### 10.1 If You Make a Mistake
1. Stop the action.
2. Preserve evidence — do not delete logs, do not roll back without
   first capturing state.
3. Notify the responsible party within the same session if possible,
   within 24 hours otherwise.
4. Document what happened, what was affected, what was done about it.

### 10.2 Who to Notify
- Routine errors: the operator who delegated the task.
- Data exposure or external impact: seanito@xybersean.com directly.
- Suspected compromise of credentials or hosts: rotate first, notify
  immediately.

### 10.3 No Cover-Ups
Honest disclosure of a mistake is recoverable. Concealment is not.
The operator who hides an incident becomes the incident.

---

## 11. Acceptance

By authenticating to any XYBERSEAN host, by executing any command
under XYBERSEAN authority, or by being invoked as an AI agent on
XYBERSEAN infrastructure, you accept this Code of Conduct in full.

Continued operation after an amendment is re-acceptance of the
amended document.

---

## 12. Versioning and Amendments

| Version | Date       | Author  | Notes                |
|---------|------------|---------|----------------------|
| 1.0     | 2026-04-28 | seanito | Initial publication. |

Amendments are recorded in this table and announced fleet-wide before
taking effect. The canonical source is the GitHub repository; deployed
copies are mirrors and may lag by up to one synchronization interval.
