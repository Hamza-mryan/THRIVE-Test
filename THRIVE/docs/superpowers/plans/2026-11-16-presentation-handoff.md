# THRIVE Test Windows Presentation Handoff Plan

> Execute natively in the authorized Test workspace, task by task. The user needs a university demonstration on another Windows 10 or 11 machine on 2026-11-17. No new implementation agent, OS installation, security-setting change, database migration or original-project write is authorized by this handoff plan. Use a fresh read-only review for the diagnostic and packaging boundary.

**Goal:** Deliver clean transferable source, actionable Windows setup instructions and a clearly labeled historical visual backup, without claiming that an untested second computer is ready.

**Architecture:** Retain the existing guarded launchers and synthetic development identity. Add a read-only prerequisite diagnostic; it does not initialize an environment, stop processes, open the firewall, alter PowerShell policy or disable Smart App Control. Package only explicitly selected Test source and verified historical screenshots, excluding device-bound state, databases, credentials, caches and compiled artifacts.

**Tech Stack:** Existing Windows PowerShell 5.1/7, Flutter, Angular, .NET and PostgreSQL. Local ZIP creation uses the available Python standard library only.

**Spec:** User's 2026-11-16 conversation: another Windows 10/11 computer, doctor must see the project tomorrow; original Test isolation restrictions and unfinished Phase 3 still apply.

## Global constraints

- Writable root: C:/Users/hmztm/OneDrive/Desktop/New folder/الصحة النفسيه/THRIVE. Preserve the Documents original.
- Keep existing Test IDs and API5280/student5400/admin4300/database55432. Do not carry this device's `.local` or `.env.local` to another machine.
- The current Backend is blocked by Smart App Control. Packaging or a successful build is not evidence that it starts elsewhere.
- Describe initial migrations only for a new, independently initialized and verified Test cluster on the second machine; execute none here.
- Screenshots are actual Phase 2 captures from 2026-11-07, not current interactive behavior, final Phase 3 verification or clinical approval.

## Review focus

- A second computer may lack SDKs, package access or compatible binaries: show missing prerequisites rather than promise automatic startup.
- Active Smart App Control may block the same unsigned assemblies: identify it without changing security settings.
- A full folder copy carries path-bound owner records and secrets: refuse those archive entries.
- Existing occupied ports must remain untouched: diagnostics report, never stop or rebind them.
- A visual fallback must remain visibly historical and static, with no simulated claim of a working Backend.

## Task 1 — Diagnostic and setup guide

**Files:** scripts/check-presentation-environment.ps1; docs/PRESENTATION_ON_WINDOWS.ar.md.

**Interfaces:** Diagnostic returns exit 0 only when required tools are found and Smart App Control is not observed in enforcement mode; exit 2 means setup/blockers remain. Neither outcome proves complete runtime readiness. Guide uses existing initialize/start launchers and explicit fresh Test setup.

- [ ] Add a read-only check for OS architecture, PowerShell, tool availability, Smart App Control state and current Test-port listeners.
- [ ] Run it under actual PowerShell 5.1 and 7. Expect this machine's known Smart App Control blocker to prevent an all-clear result.
- [ ] Explain source-only prerequisites, Windows setup, separate consoles, safe initial Test migrations and a real smoke-test journey before the appointment.

## Task 2 — Transfer artifact and review

**Files:** local packaging code/evidence under .local/thrive-test/phase3-2026-11-07; output/presentation/THRIVE-Test-Windows-Handoff-2026-11-16.zip; output/presentation/THRIVE-Test-Windows-Handoff-2026-11-16.sha256.txt.

**Interfaces:** Git-selected nonignored Test files are the source boundary. Archive inspection must find no .local/output/dependency/build/env/private-key/database entries or known local password. Screenshot copies must match the existing Phase 2 manifest hashes. Static HTML has local-only image links and an explicit historical notice.

- [ ] Inspect selected actual screenshots and prepare a local HTML visual backup.
- [ ] Package fresh source plus guide/backup, with per-entry hashes; verify ZIP CRC and exclusion rules.
- [ ] Obtain read-only review, address concrete findings, recheck source hashes and the protected original.
- [ ] Deliver the ZIP and report tested versus untested limits. Require an actual second-machine launch before calling it demonstration-ready.
