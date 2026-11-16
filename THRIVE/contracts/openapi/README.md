# THRIVE API contract

`thrive-v1.json` is exported from the ASP.NET Core application's OpenAPI document. It describes health, development identities, consent and withdrawal, screening sessions, guide resources, services, referrals, and university administration. The development behavior is described in `../IMPLEMENTATION_SLICE.md`.

Run the migrated local backend in Development with development identity enabled, then export from the `THRIVE` directory:

```powershell
./scripts/export-openapi.ps1
```

The export omits the environment-specific `servers` address. The development-session endpoint appears only when explicitly enabled in Development; it is not a production sign-in API. Protected operations declare Bearer authentication. An initial consent read may return JSON null; a successful save returns a non-null consent decision.

Update endpoint contracts in the backend and regenerate this document; do not independently maintain payload shapes in the JSON file. Typed client generation will be added after this initial contract settles. The current Flutter transport mapping remains centralized in its onboarding repository.
