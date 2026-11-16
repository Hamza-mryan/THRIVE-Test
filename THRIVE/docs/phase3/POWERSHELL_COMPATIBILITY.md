# Windows PowerShell startup compatibility

Date: 2026-11-16 (Asia/Amman). This is a focused startup correction during the unfinished Phase 3 verification, not a full Phase 3 completion report.

## Observed failure and cause

The user ran the local startup scripts in Windows PowerShell 5.1 and encountered `THRIVE Test owner record belongs to another workspace`. The actual owner record matched the workspace when read in PowerShell 7. Reading the same BOM-less UTF-8 JSON without an explicit encoding in Windows PowerShell 5.1 corrupted the Arabic path and made the ownership comparison fail. Microsoft documents the different defaults in [about_Character_Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-5.1).

The new regression script reproduced this exact failure before the correction (exit 1). No repair or rotation of actual owner records or database credentials was performed.

## Changes

- `scripts/lib/LocalEnvironment.ps1`: explicitly read the environment, workspace owner, workspace drive and cluster owner as UTF-8. All identity/path/role/port predicates are unchanged.
- `scripts/lib/GeneratedWorkspace.ps1`: explicitly read generated owner records and Flutter output manifests as UTF-8.
- `scripts/start-database.ps1`, `scripts/start-project.ps1`, `scripts/stop-project.ps1`: explicitly decode the existing cluster/process records as UTF-8.
- `scripts/verify-generated-isolation.ps1`: make fixture text writes and sentinel reads explicit UTF-8. The first PowerShell 5.1 run exposed a separate fixture-writer encoding problem; that failed log was retained before correcting the fixture.
- `scripts/verify-local-encoding.ps1`: exercise a BOM-less UTF-8 owner/lifecycle record under the actual Unicode workspace path, and require rejection of foreign path, instance and application values. Only disposable files beneath the owned Test audit directory are written.
- `docs/RUN_LOCAL.ar.md`: describe manual startup without migrations, temporary process-scope script execution, foreground logs and Ctrl+C, and the separate Application Control blocker.

## Actual checks

Evidence is under `.local/thrive-test/phase3-2026-11-07/` (ignored local files).

| Check | Actual result | Evidence |
|---|---|---|
| New regression before fix, Windows PowerShell 5.1 | Failed with the reported ownership error, exit 1 | `powershell51-encoding-red.log` |
| Encoding/ownership regression after fix, Windows PowerShell 5.1 | 5/5 passed, exit 0 | `powershell51-encoding-green.log` |
| Same regression, PowerShell 7 | 5/5 passed | `powershell7-encoding-green.log` |
| Actual existing Test database startup, Windows PowerShell 5.1 | Exit 0; postgres/thrive_test identity verified on port 55432 | `powershell51-database-green.log` |
| Real lifecycle/generated owner records, Flutter output guards, seven-script syntax check on Windows PowerShell 5.1 | Passed, exit 0 | `powershell51-encoding-records.log` |
| Generated-output isolation fixtures, Windows PowerShell 5.1 | Both checks passed, exit 0 | `powershell51-generated-green.log` |
| Same generated-output checks, PowerShell 7 | Both passed after the production read correction | `powershell7-generated-green.log` |
| Static isolation checks | 7/7 passed | `isolation-after-encoding.log` |
| Actual Backend startup after encoding fix, Windows PowerShell 5.1 | Passed Test ownership/database verification, then failed loading `Thrive.Infrastructure.dll` with Application Control 0x800711C7; process exit -532462766 | `powershell51-backend-after-encoding.log` |

No migration or database reset was run. The already initialized Test cluster was present and verified before testing the database startup. The actual `owner.json` and `.env.local` hashes are unchanged. The normal database guard rewrote its already verified workspace-drive record using the host's UTF-8 writer; the Test mapping remains owned. All 281 protected-original files still match their recorded hashes. See `powershell-encoding-safety.json`.

## Scope and remaining blocker

Renaming or moving the workspace is unnecessary for this correction and would require re-verifying path-bound ownership records and the workspace-drive mapping. The original ownership safeguards remain active.

The successful database command does not establish a running Backend. Windows Application Control still blocks the local Backend assembly, and no Windows protection settings were changed. This correction must not be described as complete environment/runtime readiness or a resolution of that separate OS restriction.

Follow-up diagnosis confirmed `VerifiedAndReputablePolicyState=1`, Code Integrity event 3077 with policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`, and an unsigned `Thrive.Infrastructure.dll`. That policy is Smart App Control. Microsoft's current [FAQ](https://support.microsoft.com/en-us/windows/security/threat-malware-protection/smart-app-control-frequently-asked-questions) states there is no individual-app exception and describes trusted signing and the global off setting. Turning it off affects protection outside this Test workspace, so no such change was made. WSL is not installed, Docker was not found, and no Windows Sandbox executable was present during the read-only availability check. A user choice between preparing an isolated development environment and receiving manual instructions for the global setting was requested before any OS changes.

An independent read-only reviewer compared the scoped immutable baseline/head snapshots and verified all seven script hashes. Final verdict: ready for the encoding fix, with no outstanding critical, important or minor findings. The review identified a manual-start log/stop documentation inconsistency; it was corrected and rechecked. The reviewer did not execute tests or databases and explicitly excluded the OS policy block and broader Phase 3 readiness from this verdict. Source hashes still matched the reviewed snapshot after final checks.
