import { ComponentFixture, TestBed } from '@angular/core/testing';
import { vi } from 'vitest';
import { provideRouter } from '@angular/router';
import { DashboardPage } from './dashboard.page';
import { AdminApi, ApiFailure } from '../../core/api/admin-api';
import { AggregateReport } from '../../core/api/models';
import { LanguageService } from '../../core/i18n/language.service';

const report: AggregateReport = {
  screeningsCount: null,
  referralsCount: 5,
  completedReferralsCount: null,
  minCellSize: 5,
  availableResourcesCount: 0,
  availableServicesCount: 2,
};

async function waitForIdle(fixture: ComponentFixture<DashboardPage>): Promise<void> {
  await vi.waitFor(() => {
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('[data-testid="dashboard-refresh"]').disabled).toBe(
      false,
    );
  });
}

async function render(load: () => Promise<AggregateReport>) {
  await TestBed.configureTestingModule({
    imports: [DashboardPage],
    providers: [provideRouter([]), { provide: AdminApi, useValue: { report: load } }],
  }).compileComponents();
  const fixture = TestBed.createComponent(DashboardPage);
  fixture.detectChanges();
  await waitForIdle(fixture);
  return { fixture, element: fixture.nativeElement as HTMLElement };
}

describe('Dashboard presentation and refresh', () => {
  afterEach(() => TestBed.resetTestingModule());

  it('separates operational links from sensitive aggregates without changing null or zero', async () => {
    const { element } = await render(async () => ({ ...report, referralsCount: 0 }));
    expect(element.querySelectorAll('[data-testid="privacy-metrics"] .suppressed').length).toBe(2);
    const sensitiveZero = element.querySelectorAll(
      '[data-testid="privacy-metrics"] .metric strong',
    )[1];
    expect(sensitiveZero.textContent?.trim()).toBe('0');
    expect(sensitiveZero.classList.contains('suppressed')).toBe(false);
    expect(element.querySelector('[data-testid="resource-count"]')?.textContent?.trim()).toBe('0');
    expect(element.querySelector('[data-testid="service-count"]')?.textContent?.trim()).toBe('2');
    expect(
      element
        .querySelector<HTMLAnchorElement>('[data-testid="resources-action"]')
        ?.getAttribute('href'),
    ).toBe('/resources');
    expect(
      element
        .querySelector<HTMLAnchorElement>('[data-testid="services-action"]')
        ?.getAttribute('href'),
    ).toBe('/services');
    expect(element.textContent).toContain('الحد الأدنى للمجموعة');
  });

  it('prevents overlapping refresh and retains a visible retry when a request fails', async () => {
    let calls = 0;
    let rejectRefresh: (error: unknown) => void = () => undefined;
    const { fixture, element } = await render(() => {
      calls++;
      if (calls === 1) return Promise.resolve(report);
      if (calls === 2)
        return new Promise((_, reject) => {
          rejectRefresh = reject;
        });
      return Promise.resolve({ ...report, availableServicesCount: 3 });
    });
    const refresh = element.querySelector<HTMLButtonElement>('[data-testid="dashboard-refresh"]')!;
    expect(refresh).not.toBeNull();
    expect(calls).toBe(1);
    expect(refresh.disabled).toBe(false);
    refresh.click();
    expect(calls).toBe(2);
    fixture.detectChanges();
    expect(refresh.disabled).toBe(true);
    expect(element.querySelector('[role="status"]')).not.toBeNull();
    refresh.click();
    expect(calls).toBe(2);
    rejectRefresh(new ApiFailure('unavailable'));
    await waitForIdle(fixture);
    expect(refresh.disabled).toBe(false);
    const retry = element.querySelector<HTMLButtonElement>('[role="alert"] button')!;
    expect(retry).not.toBeNull();
    retry.click();
    await waitForIdle(fixture);
    expect(calls).toBe(3);
    expect(element.querySelector('[data-testid="service-count"]')?.textContent?.trim()).toBe('3');
    expect(element.querySelector('[role="alert"]')).toBeNull();
  });

  it('localizes action labels while leaving brand names and privacy meaning intact', async () => {
    const { fixture, element } = await render(async () => report);
    TestBed.inject(LanguageService).toggle();
    fixture.detectChanges();
    expect(element.querySelector('[data-testid="dashboard-refresh"]')?.textContent).toContain(
      'Refresh',
    );
    expect(element.textContent).toContain('Suppressed for privacy');
    expect(element.querySelector('[data-testid="resources-action"]')?.textContent).toContain(
      'resources',
    );
  });
});
