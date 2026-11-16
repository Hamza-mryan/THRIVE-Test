import { computed, Injectable, signal } from '@angular/core';
import { COPY, Locale } from './copy';

@Injectable({ providedIn: 'root' })
export class LanguageService {
  private readonly currentLocale = signal<Locale>('ar');
  readonly locale = this.currentLocale.asReadonly();
  readonly direction = computed(() => (this.locale() === 'ar' ? 'rtl' : 'ltr'));
  readonly copy = computed(() => COPY[this.locale()]);

  toggle(): void {
    this.currentLocale.update((locale) => (locale === 'ar' ? 'en' : 'ar'));
  }
}
