# THRIVE Test — Design system

Date: 2026-11-07. Applies to the existing Arabic-first student and university workspaces. This is a curated implementation contract, not unreviewed output from a generator.

## Product and direction

THRIVE supports student check-ins, public guidance and consent-based referral. This test build provides labeled synthetic workflows, not diagnosis or emergency response. The visual direction is calm botanical utility: a recognisable deep green anchor, readable Arabic, quiet surfaces and direct choices. Existing growth/leaf artwork carries the distinctive visual moment; surrounding UI stays practical.

No testimonials, invented providers, clinical score colors, ornamental gradients, autoplay or new dark-mode feature. The existing app has a light theme only. Never communicate urgency or privacy suppression by color alone.

## Research provenance and judgment

Actual local ui-ux-pro-max searches:

- `university student wellbeing calm --design-system`: rejected; returned Portfolio Grid / academic typography inappropriate for a functional student app.
- Narrow retry `mental health wellness app --design-system`: rejected as a whole; testimonial/marketing composition and high-risk neumorphism do not fit the real product or accessibility needs. These systems were not persisted as recommendations.
- `wellbeing calm natural --domain style --rtl=full`: Organic Biophilic, style ID organic-biophilic, verified as a product/RTL fit; adopt restraint and low rendering cost, not every decorative suggestion.
- `Noto Arabic multilingual --domain typography`: Arabic Elegant supports Noto Sans Arabic body text. Retain the already bundled Noto Sans Arabic for both scripts rather than add a second font or a CDN.
- `touch target size --domain ux`: distinguish Android48dp/iOS44pt from web24CSSpx WCAG minimum; choose comfortable 44–48px web controls here.
- Flutter stack search confirmed TextScaler and Semantics guidance; project APIs are checked against the actual 3.47.9 SDK, not assumed from the dataset's older version note.
- Angular focus search had no verified focused match on retry. Keyboard/focus recommendations therefore come from the skill's general UX checklist and primary WCAG guidance; no Angular-specific search result is invented. Retain Angular22 built-in control flow and existing signals.

Frontend-design critique: avoid four decorative feature-card clones, repeated slogan headings and arbitrary arrow glyphs. Make the student pathway names/action hierarchy legible; make university operational actions and sensitive aggregates meaningfully different.

## Color tokens

| Semantic role | Hex | Usage |
|---|---|---|
| Ink / anchor | #183F42 | Headings, high-emphasis hero, primary reading and selected web navigation/notice/tag text |
| Brand / action | #087F76 | Primary buttons and links on white; decorative icons on soft surfaces |
| Canvas | #F7F8F2 | Main background, retained THRIVE identity |
| Surface | #FFFFFF | Quiet cards, controls and reading panels |
| Supporting text | #506B66 | Normal text with measured contrast above 4.5 on canvas |
| Outline | #D5E2DC | Decorative separation; never the sole state indicator |
| Check | #255F91 on #E8F1FC | Path identity, not a health result |
| Guide | #206E57 on #E0F1E8 | Path identity |
| Connect | #785622 on #FFF0DD | Path identity |
| Plus | #665089 on #EFEBFA | Path identity |
| Urgent help | #AE3E39 on white | Existing urgent-help affordance only |

Existing measured path-text ratios were 4.17 / 3.75 / 3.68 / 4.31; revised pairs are approximately 5.90 / 5.22 / 5.95 / 5.83. Supporting text improves from 4.33 to 5.41 on canvas. Verify underlying token pairs without rounding a failing value into a pass.

The implemented home titles sit on white, where their measured ratios are 6.72 / 6.12 / 6.66 / 6.83. Web selected-navigation/notice/tag text uses the dark anchor on mint (9.80); brand teal on mint is only 4.16 and is not used for normal text there. White primary-button text on brand teal is 4.88.

Normal-text target 4.5:1 follows [W3C Contrast Minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html). This token check is not a claim of whole-product WCAG certification.

## Type, spacing and layout

- Locally bundled Noto Sans Arabic Regular400/Bold700 for Arabic and English. Preserve OFL attribution. No external font request. Web uses font-display: swap and a system fallback.
- Page title 28–32; section title20–22; action title16–18; body15–16 with generous 1.65–1.8 line-height; secondary labels13–14. Do not shrink core text to fit a card.
- Spacing scale: 4,8,12,16,24,32,48,64. Phone gutters20, wider gutters24–32. Reading content max900–1120; long text remains bounded.
- Hero radius24–28, action rows16, controls12, subtle flat dividers. Avoid applying the same rounded/shadow treatment to every hierarchy level.
- Student pathways become one readable column on compact screens and two columns when width/text scale allow. No fixed card height that truncates enlarged Arabic.
- Dashboard uses two operational actions and a separate privacy group, with single-column reflow on narrow screens. Tables elsewhere may scroll inside their own bounded container.
- Compact web navigation uses auto-fit tracks sized from available width and font size, with shrinkable wrapping labels. Small-screen main/card/error gutters retain readable space when text grows; error controls wrap to a new row instead of squeezing offscreen.

## Interaction and accessibility

- Native buttons/links/InkWell actions, visible focus, labels and disabled/busy states. Decorative SVG/art is excluded from semantics.
- Preserve logical RTL reading/tab order. Mirror directional navigation arrows; keep brand names in their correct text direction.
- Urgent help stays available across screens, before sign-in and after consent. Keep fixed bars outside scroll content so content remains reachable.
- Support TextScaler and 200% text without clamping it; test 320/375px and landscape. Web reflow criteria derive from [W3C Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html).
- No new automatic animation; honor existing reduced-motion preferences. Refresh is an explicit GET action, guarded against overlap and announced via the existing status/alert feedback.
- A suppressed health count remains a privacy label. Never display a fake zero, fabricated trend, invented clinical interpretation or individual health detail.
- Use existing error/retry, empty, loading, saved and offline behavior. Styling must not replace a working feature with a placeholder.

## Implementation scope

First slice: student home and administration overview plus the shared presentation necessary for them. Other screens retain their workflows and receive regression inspection; they are not claimed as redesigned. Page details live in pages/student-home.md and pages/admin-dashboard.md.
