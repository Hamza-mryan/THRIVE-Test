import { Component, input } from '@angular/core';

export type ThriveIconName =
  'overview' | 'services' | 'resources' | 'referrals' | 'arrow' | 'refresh' | 'shield';

/** Decorative vectors accompany visible control labels; they never carry state alone. */
@Component({
  selector: 'app-thrive-icon',
  template: `
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.7"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
      focusable="false"
      [class.directional]="kind() === 'arrow' || kind() === 'referrals'"
    >
      @switch (kind()) {
        @case ('overview') {
          <rect x="3" y="3" width="7" height="7" rx="1.5" />
          <rect x="14" y="3" width="7" height="7" rx="1.5" />
          <rect x="3" y="14" width="7" height="7" rx="1.5" />
          <rect x="14" y="14" width="7" height="7" rx="1.5" />
        }
        @case ('services') {
          <circle cx="9" cy="8" r="3" />
          <path d="M3 21v-3a6 6 0 0 1 12 0v3M16 5a3 3 0 0 1 0 6M18 15a5 5 0 0 1 3 5" />
        }
        @case ('resources') {
          <path d="M12 5c-3-2-6-2-9-1v15c3-1 6-1 9 1 3-2 6-2 9-1V4c-3-1-6-1-9 1Zm0 0v15" />
        }
        @case ('referrals') {
          <circle cx="5" cy="6" r="2" />
          <circle cx="19" cy="18" r="2" />
          <path d="M7 6h7a4 4 0 0 1 0 8h-4a4 4 0 0 0 0 8M17 14l4 4-4 4" />
        }
        @case ('arrow') {
          <path d="M4 12h16m-6-6 6 6-6 6" />
        }
        @case ('refresh') {
          <path d="M20 7v5h-5M4 17v-5h5M6 6a8 8 0 0 1 14 6M4 12a8 8 0 0 0 14 6" />
        }
        @case ('shield') {
          <path d="m12 3 8 3v6c0 5-8 9-8 9s-8-4-8-9V6l8-3Zm-4 9 3 3 5-6" />
        }
      }
    </svg>
  `,
  styles: `
    :host {
      display: inline-flex;
      width: 1.25em;
      height: 1.25em;
      flex: 0 0 auto;
    }
    svg {
      width: 100%;
      height: 100%;
    }
    .directional {
      transform: scaleX(var(--direction-scale, 1));
    }
  `,
})
export class ThriveIcon {
  readonly kind = input.required<ThriveIconName>();
}
