import { signal } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { provideRouter, Router } from '@angular/router';
import { App } from './app';
import { routes } from './app.routes';
import { AdminApi } from './core/api/admin-api';
import { nextReferralStatuses } from './core/api/models';
import { NgModel } from '@angular/forms';
import { By } from '@angular/platform-browser';

function fakeApi(signedIn = true) {
  const authenticated = signal(signedIn);
  return {
    signedIn: authenticated,
    sessionExpired: signal(false),
    user: signal(signedIn ? { isDevelopmentIdentity: true } : null),
    developmentEnabled: false,
    report: async () => ({
      screeningsCount: null,
      referralsCount: null,
      completedReferralsCount: null,
      minCellSize: 5,
      availableResourcesCount: 2,
      availableServicesCount: 1,
    }),
    services: async () => [],
    resources: async () => [],
    referrals: async () => [],
    signOut: () => authenticated.set(false),
  };
}
async function render(path: string, signedIn = true) {
  await TestBed.configureTestingModule({
    imports: [App],
    providers: [provideRouter(routes), { provide: AdminApi, useValue: fakeApi(signedIn) }],
  }).compileComponents();
  const fixture = TestBed.createComponent(App);
  await TestBed.inject(Router).navigateByUrl(path);
  await fixture.whenStable();
  return { fixture, element: fixture.nativeElement as HTMLElement };
}
describe('University workspace', () => {
  it('hides operations and disables unconfigured development sign-in', async () => {
    const { element } = await render('/services', false);
    expect(element.querySelector<HTMLButtonElement>('[data-testid="dev-login"]')?.disabled).toBe(
      true,
    );
    expect(element.querySelector('app-services-page')).toBeNull();
    expect(element.textContent).toContain('تفعيلًا صريحًا');
  });
  it('shows suppressed metrics as privacy labels rather than zero', async () => {
    const { element } = await render('/dashboard');
    expect(element.querySelector('.workspace')?.getAttribute('dir')).toBe('rtl');
    expect(element.querySelectorAll('.metric strong.suppressed').length).toBe(3);
    expect(element.querySelector('.metric strong.suppressed')?.textContent).toContain('محجوب');
    expect(element.querySelectorAll('nav a[aria-current="page"]').length).toBe(1);
  });
  it('switches the resources page into English LTR', async () => {
    const { element, fixture } = await render('/resources');
    element.querySelector<HTMLButtonElement>('.language-button')?.click();
    await fixture.whenStable();
    expect(element.querySelector('.workspace')?.getAttribute('dir')).toBe('ltr');
    expect(element.querySelector('h1')?.textContent).toBe('Resources & guidance');
  });
  it('prevents submitting a new service until required fields are supplied', async () => {
    const { element, fixture } = await render('/services');
    element.querySelector<HTMLButtonElement>('[data-testid="service-add"]')?.click();
    await fixture.whenStable();
    expect(element.querySelector<HTMLButtonElement>('[data-testid="service-save"]')?.disabled).toBe(
      true,
    );
    expect(element.querySelector<HTMLInputElement>('[name="verified"]')?.disabled).toBe(true);
  });
  it('offers only nonterminal transitions and never completes a newly requested referral', () => {
    expect(nextReferralStatuses('Requested')).toEqual(['Received', 'Declined']);
    expect(nextReferralStatuses('Scheduled')).toContain('Completed');
    for (const status of ['Completed', 'Declined', 'Cancelled'] as const)
      expect(nextReferralStatuses(status)).toEqual([]);
  });
  it('moves skip-link focus to the current page without changing routes', async () => {
    const { element, fixture } = await render('/resources');
    const content = element.querySelector<HTMLElement>('#main-content')!;
    element.querySelector<HTMLAnchorElement>('.skip-link')!.click();
    await fixture.whenStable();
    expect(document.activeElement).toBe(content);
    expect(TestBed.inject(Router).url).toBe('/resources');
  });
  it('matches the backend resource slug limit at 100 characters', async () => {
    const { element, fixture } = await render('/resources');
    element.querySelector<HTMLButtonElement>('[data-testid="resource-add"]')!.click();
    await fixture.whenStable();
    const input = element.querySelector<HTMLInputElement>('input[name="slug"]')!;
    const model = fixture.debugElement.query(By.css('input[name="slug"]')).injector.get(NgModel);
    input.value = 'a'.repeat(101);
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('blur'));
    await fixture.whenStable();
    fixture.detectChanges();
    expect(model.hasError('maxlength')).toBe(true);
    expect(element.querySelector('#resources-slug-error')?.textContent).toContain(
      'استخدم 100 حرفًا أو أقل.',
    );
    input.value = 'a'.repeat(100);
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await fixture.whenStable();
    expect(model.hasError('maxlength')).toBe(false);
  });
});
