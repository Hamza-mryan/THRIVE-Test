# THRIVE Test — Design System V2

2026-11-07. Current contract for the complete existing Flutter student and Angular administration presentation. Phase1 baseline is preserved in PHASE1_BASELINE.md. Functional and clinical boundaries in GLOSSARY.md remain authoritative.

## Direction: Campus Sanctuary

A university support experience should feel like a quiet, clear place to return to. Keep the recognisable evergreen identity, shift the canvas toward mineral white, remove repeated decorative hero panels and heavy shadows, and give reading, choices and unfinished journeys a clear hierarchy. The distinctive growth illustration belongs to onboarding and the existing wide Home hero; it is not repeated across every resource. Calm is carried by typography and spacing, not softened low-contrast text.

Three locally researched RTL-compatible directions were evaluated:

| Direction | Actual search result | Assessment |
|---|---|---|
| Campus Sanctuary | organic-biophilic, active, full RTL | Selected: familiar growth identity and emotional comfort; restrain decorative organic shapes and use native accessible controls |
| Editorial Campus | swiss-modernism-2-0, supplemental, full RTL | Excellent hierarchy and administrative clarity, but a wholesale cobalt/monochrome switch would feel colder to students; adopt layout discipline without changing the product into a corporate portal |
| Soft Focus | soft-ui-evolution, active, full RTL | Mature soft surfaces can work, but depth/pastels risk competing with actual state and reproducing a generic component kit; no neumorphic controls or blended boundaries |

The generic design-system query returned a marketing Hero/Features/CTA conversion pattern, Lora display type and blue/orange palette. It was not adopted as a functional-app system. All four raw searches are recorded under .local/thrive-test/phase2-2026-11-07. No unverified generator output overwrote this document.

Canva produced an editable four-page comparison from generic public-facing design descriptions only: https://canva.link/oftphx34mgfwgmj (DAHaO6VINHA). No code, project documents, screenshots, credentials or private data were uploaded. It is concept exploration, not proof of a running UI; no Canva image is substituted for functional screens.

## Tokens and type

| Role | Value | Use |
|---|---|---|
| Anchor/ink | #183F42 | Headings, primary reading, selected web navigation |
| Action | #096B5D | Native actions, links, focus and selected state; 6.42 on white and 5.47 on mint |
| Canvas | #F4F7F5 | Mineral-white workspace, light theme |
| Surface | #FFFFFF | Reading and editing surfaces |
| Quiet surface | #EDF4F0 | Contextual information and gentle separation |
| Supporting ink | #506B66 | Supporting copy; 5.35 on canvas |
| Decorative line | #D5E2DC | Separation, never the sole essential control boundary |
| Control line | #718A7F | Input boundaries; 3.72 on white |
| Urgent/error ink | #AE3E39 | Named urgent help/error only; no clinical risk grading |
| Error surface | #FFEEEC | Named error/urgent help context |
| Path inks | #255F91 / #206E57 / #785622 / #665089 | Check/Guide/Connect/Plus and readable topic labels, paired with established sky/mint/apricot/lavender tints |

Color values are implemented in each frontend's existing token file, with no palette dependency. Verify composed controls and actual hover/focus/error states; these measured pairs are not whole-product accessibility certification. Light is the only supported product theme; do not claim an unimplemented dark theme.

Use existing locally bundled Noto Sans Arabic400/700 in both scripts. No remote font/CDN or new font file. Native reading16/1.8, supporting15/1.8, secondary13/1.8, feature title30/1.45, section20/1.6. Web body16, controls/labels about15, headings responsive. Do not shrink meaningful copy or clamp user text scaling. Long reading remains bounded (native680, welcome1040; web content1320 with bounded forms).

## Layout and components

Use 4/8/12/16/20/24/32/40 spacing; small-screen gutters20, feature/card radius20, controls14, feedback12. White surfaces do not all need shadows. A decorative glyph accompanies a meaningful title; it does not replace the title or repeat as oversized background artwork.

- FeatureIntro is the existing native feature introduction, refined rather than duplicated. Title/body/icon and optional trailing refresh keep hierarchy adaptive, directional and semantic.
- SurfaceCard/PageContent/InlineNotice/StatusPill retain their focused interfaces and own real shared presentation. Feature workflow and API logic stay in their feature/repositories.
- Mobile keeps the five native destinations. At width1000 with ordinary text scale, scrollable native NavigationRail provides the same destinations; larger text falls back to the established NavigationBar, never truncated rail labels. A stable keyed content branch preserves feature state across the breakpoint; a1200×260 rail remains scrollable.
- Home pathways preserve identifiers and callbacks. Only the activity subtree is invalidated after returning from a pushed feature; the entire Home scroll is not intentionally remounted.
- History groups actual in-progress journeys before completed ones. It keeps every session and the same server-backed resume/result behavior. No fabricated progress or clinical score chart.
- Guide has compact category artwork in lists and a calmer reading hierarchy in detail. Search, category, saved-only, source/review metadata and offline public downloads remain functional.
- Questionnaire uses native selected rows and the same explicit save/progress/previous/next/pause behavior. Technical demo totals remain labeled as non-clinical.
- Service directories/details separate introduction, verification status, access information and explicit sharing/request. Never infer verification from publication, demo status or appearance.
- Native account, consent, policies and safety use the same reading hierarchy. Service/research/referral-sharing decisions remain distinct; help stays available before and after sign-in.
- Administration service/resource editors group real fields with native fieldset/legend, explicit language/direction and visible required markers. Two desktop columns keep language pairs together; at≤600px there is one shrinking/wrapping column. Opening focuses the editor heading; cancel restores its initiating button. Pending requests disable competing edit/add actions.
- Referral operations remain a native table with scoped headers and a named keyboard-focusable horizontal scroll region on narrow screens. Do not trade semantics or server transitions for a fake mobile mockup.

## States, interaction and verification

Retain loading, empty, offline, error/retry, saved and session-expired states. Unknown/failed data must not masquerade as an empty success. Sensitive null stays suppressed; numeric zero stays numeric. Confirm successful writes only after the server. Do not log sensitive data or create security/clinical claims through UI copy.

Use genuine native buttons/links, visible keyboard focus, 48dp native and comfortable48px web targets, wrapping controls and RTL-aware layout. Do not rely on color alone. No new autoplay, parallax or decorative entry animations. Preserve the optional user-started breathing animation and its reduced-motion/lifecycle behavior.

Verification is recorded per screen in docs/phase2/SCREEN_COVERAGE.md. Widget/DOM tests, actual browser/native rendering and real assistive technology are different evidence. Report them separately. A shared theme update alone is not evidence that every state was visually inspected.

