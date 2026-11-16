# ADR 0001 Application boundaries and first implementation slice

Status: accepted for the initial development foundation.

## Decisions

- Keep one workspace Git repository. Flutter student UI and Angular university UI use a single ASP.NET Core API; neither accesses PostgreSQL directly.
- Backend dependencies point inward: Domain is independent; Application uses Domain; Infrastructure implements Application ports; Api composes them. Contracts hold public transport types. Add abstractions only at useful boundaries.
- PostgreSQL with EF migrations is the production-shaped persistence path. Relational in-memory test databases may substitute only in tests; their limitations must be stated.
- Start Flutter with SDK ChangeNotifier for the small onboarding/session workflow, dependency-injected repositories, and official localization resources. Do not add a second state framework until an ADR explains a concrete need.
- Backend is the authoritative source of consent and screening outcomes. Public API contracts are typed; generated transport clients will be introduced when the initial contract stabilizes. Keep hand-written mapping at the initial boundary small and centralized.
- No institution identity provider is supplied. Production identity uses configured trusted JWT/OIDC validation. Unconfigured identity must fail closed. Local synthetic identities require explicit enablement in Development and a separately labeled UI entry point; this does not complete real university sign-in.
- Do not persist browser bearer tokens in localStorage. The initial session may be memory-only; document that limitation rather than implying automatic persistent sign-in.
- Brand follows the screen reference's navy/teal palette and supportive tone. Improve hierarchy, whitespace, responsiveness, localization, and state design; avoid fictional operational metrics and clinical content.

## First slice and limits

Implement buildable foundations and a testable onboarding consent flow. Complete production SSO, clinical instruments, referrals, and administration workflows in subsequent slices. Do not mark them complete because UI shells exist.

The consent policy text included for development is sample copy with a development version. Publishing operational policy text requires the institution's approved content. No real student data should be collected during this foundation phase.
