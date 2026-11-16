# THRIVE engineering rules

These rules apply to all implementation under this directory. Start with `docs/START_HERE.ar.md`; use the existing workspace Git repository.

## Implementation

- Organize code by feature inside the established application and backend layers. Add files when they have a real responsibility; do not populate an empty architecture in advance.
- Keep widgets, Angular components, and HTTP endpoints thin. Put workflow state in application code and authoritative business policies in the backend domain/application layers.
- Domain must not depend on EF Core, HTTP, UI frameworks, or Infrastructure. Application must not depend on Infrastructure. Api is the composition root.
- Keep public DTOs separate from persistence entities. Describe the API with OpenAPI; generate client transport models from that contract once generation is established. Do not hand-edit generated files.
- Reuse an existing component or policy when its meaning is the same. Avoid copy/paste business rules. Similar appearance alone is not enough to create a generic abstraction.
- Prefer small explicit functions, composition, descriptive names, and typed contracts. Avoid catch-all services, generic base repositories, untyped payloads, and configuration-heavy universal components without a demonstrated need.
- Use one agreed state-management approach per frontend. Document consequential choices in a short ADR before introducing alternatives.
- Use EF migrations as the authoritative database schema; do not maintain a second independent schema.sql.

## Product and design

- Use the supplied screen reference for product intent and brand. Improve spacing, hierarchy, navigation, accessibility, and responsive behavior when it makes the experience clearer.
- Centralize each frontend's design tokens and genuinely shared components. Support Arabic RTL and English; externalize user-facing strings.
- Cover loading, empty, error, offline, and success states as appropriate. Preserve access to urgent help across navigation, including onboarding.
- Keep demo data separate and clearly identified. Do not present unapproved instruments, fictional contacts, or illustrative providers as operational services.

## Data and verification

- Treat mental-health data as sensitive. Do not include answers, scores, tokens, or identifying health data in logs, analytics, or notifications.
- Backend computes results from validated versioned responses and enforces ownership and university scope. A student client must not authorize clinician overrides or assert its own trusted final score.
- Separate service, research, and referral-sharing consent. Research refusal must not block service use.
- Keep safety policy independent from routine screening scores, according to the approved product protocol. Require approved configuration before enabling clinical behavior.
- Keep secrets outside Git. Never use production data in development or tests.
- Validate behavior with focused rule tests, permission/integration tests, and essential user journeys. Run the build/lint/checks appropriate to touched applications; explain any toolchain blocker accurately.
- Before marking a task complete, check for duplication, dependency direction, user-visible states, localization, and sensitive-data exposure. Report what works and what remains scaffolded.
