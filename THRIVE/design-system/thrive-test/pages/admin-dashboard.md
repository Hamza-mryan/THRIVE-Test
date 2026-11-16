# University overview

Keep /dashboard, AdminApi.report and AggregateReport unchanged. Separate services/resources actions from sensitive aggregate reporting. Sensitive null values remain explicitly suppressed; zero remains zero. All counts come from the backend.

Add an explicit refresh using RequestState's existing busy/error/retry lifecycle. Disable overlapping requests. Keep stale results clearly associated with an error if a refresh fails; do not pretend a refresh succeeded.

Use feature-scoped template/styles, the local Arabic font and a small decorative SVG icon module shared with real shell callers. Preserve role gating, language toggle, sign-out, skip link and current-page indication. Validate keyboard navigation and compact layout on the existing services/resources/referrals pages as well as the overview.

Verification delivered: overview rendered in both languages at desktop and 320px; focus-to-main and real links checked; service/resource forms and referral table inspected on desktop. Four static snapshots of actual rendered overview DOM (success/error × Arabic/English) were checked at 320px/root32px with no measured internal overflow after corrections. This is presentation evidence, not live browser zoom or complete compact-page/assistive-technology coverage. Broader per-page accessibility remains explicitly partial in the audit.
