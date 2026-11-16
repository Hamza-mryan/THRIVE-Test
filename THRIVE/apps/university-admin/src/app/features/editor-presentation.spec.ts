import { Type } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { vi } from 'vitest';
import { AdminApi, ApiFailure } from '../core/api/admin-api';
import { LanguageService } from '../core/i18n/language.service';
import { ServicesPage } from './services/services.page';
import { ResourcesPage } from './resources/resources.page';
import { ReferralsPage } from './referrals/referrals.page';

describe('Administration editor journeys', () => {
  afterEach(() => TestBed.resetTestingModule());

  it('does not claim an empty referral queue after a failed load and recovers through retry', async () => {
    let calls = 0;
    await TestBed.configureTestingModule({
      imports: [ReferralsPage],
      providers: [
        {
          provide: AdminApi,
          useValue: {
            referrals: async () => {
              if (++calls === 1) throw new ApiFailure('unavailable');
              return [];
            },
          },
        },
      ],
    }).compileComponents();
    const fixture = TestBed.createComponent(ReferralsPage);
    const element = fixture.nativeElement as HTMLElement;
    fixture.detectChanges();
    await vi.waitFor(() => {
      fixture.detectChanges();
      expect(element.querySelector('[role="alert"]')).not.toBeNull();
    });
    expect(element.textContent).not.toContain('لا توجد سجلات بعد.');
    element.querySelector<HTMLButtonElement>('[role="alert"] button')!.click();
    await vi.waitFor(() => {
      fixture.detectChanges();
      expect(element.querySelector('[role="alert"]')).toBeNull();
      expect(element.textContent).toContain('لا توجد سجلات بعد.');
    });
    expect(calls).toBe(2);
  });

  for (const [name, component, addId, arabicField, englishField] of [
    ['service', ServicesPage, 'service-add', 'nameAr', 'nameEn'],
    ['resource', ResourcesPage, 'resource-add', 'titleAr', 'titleEn'],
  ] as const) {
    it(`${name} waits for loading, groups real fields, focuses the editor and restores cancel focus`, async () => {
      let completeLoad: (value: never[]) => void = () => undefined;
      const pending = new Promise<never[]>((resolve) => {
        completeLoad = resolve;
      });
      await TestBed.configureTestingModule({
        imports: [component],
        providers: [
          { provide: AdminApi, useValue: { services: () => pending, resources: () => pending } },
        ],
      }).compileComponents();
      const fixture = TestBed.createComponent(component as Type<unknown>);
      const element = fixture.nativeElement as HTMLElement;
      fixture.detectChanges();
      const add = element.querySelector<HTMLButtonElement>(`[data-testid="${addId}"]`)!;
      expect(add.disabled).toBe(true);
      add.click();
      fixture.detectChanges();
      expect(element.querySelector('form')).toBeNull();
      completeLoad([]);
      await vi.waitFor(() => {
        fixture.detectChanges();
        expect(add.disabled).toBe(false);
      });
      add.click();
      await fixture.whenStable();
      fixture.detectChanges();
      const form = element.querySelector<HTMLFormElement>('form')!;
      expect(form.querySelectorAll('legend').length).toBeGreaterThanOrEqual(3);
      expect(document.activeElement).toBe(form.querySelector('h2'));
      const arabic = form.querySelector<HTMLInputElement>(`[name="${arabicField}"]`)!;
      const english = form.querySelector<HTMLInputElement>(`[name="${englishField}"]`)!;
      expect(arabic.dir).toBe('rtl');
      expect(english.dir).toBe('ltr');
      expect(arabic.required).toBe(true);
      expect(english.required).toBe(true);
      expect(form.querySelector<HTMLButtonElement>('button[type="submit"]')!.disabled).toBe(true);
      if (name === 'service')
        expect(form.querySelector<HTMLInputElement>('[name="verified"]')!.disabled).toBe(true);
      if (name === 'resource')
        expect(form.querySelector<HTMLInputElement>('[name="slug"]')!.maxLength).toBe(100);
      TestBed.inject(LanguageService).toggle();
      fixture.detectChanges();
      expect(form.textContent).toContain('Essential details');
      form.querySelector<HTMLButtonElement>('[data-testid="editor-cancel"]')!.click();
      await fixture.whenStable();
      expect(element.querySelector('form')).toBeNull();
      expect(document.activeElement).toBe(add);
    });
  }

  it('keeps referral data in a named keyboard-accessible native table region', async () => {
    await TestBed.configureTestingModule({
      imports: [ReferralsPage],
      providers: [{ provide: AdminApi, useValue: { referrals: async () => [] } }],
    }).compileComponents();
    const fixture = TestBed.createComponent(ReferralsPage);
    fixture.detectChanges();
    await fixture.whenStable();
    const element = fixture.nativeElement as HTMLElement;
    const region = element.querySelector<HTMLElement>('[role="region"]')!;
    expect(region.tabIndex).toBe(0);
    expect(region.getAttribute('aria-label')).toBe('الإحالات');
    expect(region.querySelector('caption')?.textContent).toContain('هوية الطالب');
    expect(region.querySelectorAll('th[scope="col"]').length).toBe(4);
  });
});
