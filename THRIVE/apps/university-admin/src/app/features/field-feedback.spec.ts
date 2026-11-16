import { Type } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { vi } from 'vitest';
import { AdminApi } from '../core/api/admin-api';
import { LanguageService } from '../core/i18n/language.service';
import { ServicesPage } from './services/services.page';
import { ResourcesPage } from './resources/resources.page';

describe('Field-specific editor feedback', () => {
  afterEach(() => TestBed.resetTestingModule());
  for (const scenario of [
    {
      component: ServicesPage,
      add: 'service-add',
      field: 'nameAr',
      invalid: '',
      valid: 'اسم اصطناعي',
      ar: 'هذا الحقل مطلوب.',
      en: 'This field is required.',
    },
    {
      component: ResourcesPage,
      add: 'resource-add',
      field: 'titleAr',
      invalid: '',
      valid: 'عنوان اصطناعي',
      ar: 'هذا الحقل مطلوب.',
      en: 'This field is required.',
    },
    {
      component: ServicesPage,
      add: 'service-add',
      field: 'email',
      invalid: 'not-an-email',
      valid: 'qa@example.invalid',
      ar: 'أدخل بريدًا إلكترونيًا صالحًا.',
      en: 'Enter a valid email address.',
    },
    {
      component: ResourcesPage,
      add: 'resource-add',
      field: 'slug',
      invalid: 'Invalid slug!',
      valid: 'qa-resource',
      ar: 'استخدم أحرفًا إنجليزية صغيرة وأرقامًا، مع شرطة واحدة بين الكلمات ودون مسافات.',
      en: 'Use lowercase letters and numbers, with single hyphens between words and no spaces.',
    },
  ]) {
    it(`${scenario.field} explains the existing validator and associates its bilingual correction`, async () => {
      await TestBed.configureTestingModule({
        imports: [scenario.component],
        providers: [
          { provide: AdminApi, useValue: { services: async () => [], resources: async () => [] } },
        ],
      }).compileComponents();
      const fixture = TestBed.createComponent(scenario.component as Type<unknown>);
      const element = fixture.nativeElement as HTMLElement;
      fixture.detectChanges();
      const add = element.querySelector<HTMLButtonElement>(`[data-testid="${scenario.add}"]`)!;
      await vi.waitFor(() => {
        fixture.detectChanges();
        expect(add.disabled).toBe(false);
      });
      add.click();
      await fixture.whenStable();
      fixture.detectChanges();
      const input = element.querySelector<HTMLInputElement>(`[name="${scenario.field}"]`)!;
      const nativeLabel = input.closest('label')!.textContent!.trim();
      expect(input.getAttribute('aria-invalid')).toBeNull();
      input.value = scenario.invalid;
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('blur'));
      await fixture.whenStable();
      fixture.detectChanges();
      expect(input.getAttribute('aria-invalid')).toBe('true');
      const id = input.getAttribute('aria-describedby');
      expect(id).toBeTruthy();
      const feedback = element.querySelector<HTMLElement>(`[id="${id}"]`)!;
      expect(feedback.textContent).toContain(scenario.ar);
      expect(feedback.querySelector('[role="status"]')).not.toBeNull();
      expect(input.closest('label')!.textContent!.trim()).toBe(nativeLabel);
      TestBed.inject(LanguageService).toggle();
      fixture.detectChanges();
      expect(feedback.textContent).toContain(scenario.en);
      input.focus();
      input.value = scenario.valid;
      input.dispatchEvent(new Event('input', { bubbles: true }));
      await fixture.whenStable();
      fixture.detectChanges();
      expect(document.activeElement).toBe(input);
      expect(input.value).toBe(scenario.valid);
      expect(input.getAttribute('aria-invalid')).toBeNull();
      expect(input.getAttribute('aria-describedby')).toBeNull();
      expect(feedback.textContent?.trim()).toBe('');
      expect(element.querySelector<HTMLButtonElement>('button[type="submit"]')!.disabled).toBe(
        true,
      );
    });
  }
});
