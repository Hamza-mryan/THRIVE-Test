import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { vi } from 'vitest';
import { App } from '../../app';
import { RequestState } from '../../shared/request-state/request-state';
import { AdminApi, DEVELOPMENT_IDENTITY_ENABLED } from './admin-api';

function configure() {
  TestBed.configureTestingModule({
    imports: [App],
    providers: [
      provideRouter([]),
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: DEVELOPMENT_IDENTITY_ENABLED, useValue: true },
    ],
  });
  return { api: TestBed.inject(AdminApi), http: TestBed.inject(HttpTestingController) };
}

async function completeSignIn(http: HttpTestingController) {
  http.expectOne('/health/isolation').flush({
    application: 'THRIVE Test',
    database: 'thrive_test',
    databaseUser: 'thrive_test_local',
    databasePort: 55432,
  });
  await new Promise<void>((resolve) => setTimeout(resolve, 0));
  http.expectOne('/api/v1/development/session').flush({ accessToken: 'synthetic-token' });
  await new Promise<void>((resolve) => setTimeout(resolve, 0));
  http.expectOne('/api/v1/me').flush({
    displayName: 'Synthetic administrator',
    role: 'UniversityAdmin',
    isDevelopmentIdentity: true,
  });
}

describe('Bounded administration failures and session recovery', () => {
  afterEach(() => {
    vi.useRealTimers();
    try {
      TestBed.inject(HttpTestingController).verify();
    } finally {
      TestBed.resetTestingModule();
    }
  });

  for (const boundary of ['handshake', 'read', 'write'] as const) {
    it(`${boundary} cancels after12 seconds and releases busy without retrying`, async () => {
      const { api, http } = configure();
      vi.useFakeTimers();
      const state = new RequestState();
      const work = state.run(async () => {
        if (boundary === 'handshake') await api.signInDevelopment();
        else if (boundary === 'read') await api.services();
        else await api.updateReferral('synthetic-referral', 'Received');
      });
      const url =
        boundary === 'handshake'
          ? '/health/isolation'
          : boundary === 'read'
            ? '/api/v1/admin/services'
            : '/api/v1/admin/referrals/synthetic-referral/status';
      const request = http.expectOne(url);
      expect(state.busy()).toBe(true);
      await vi.advanceTimersByTimeAsync(12_001);
      const observed = { busy: state.busy(), error: state.error(), cancelled: request.cancelled };
      // Settle the pre-fix reproduction without leaving a hanging test promise.
      if (!request.cancelled)
        request.flush(boundary === 'handshake' ? { application: 'THRIVE' } : []);
      await work;
      expect(observed).toEqual({ busy: false, error: 'timeout', cancelled: true });
      http.expectNone(url);
      http.expectNone('/api/v1/development/session');
    });
  }

  it('explains page-triggered expiry on the login screen and supports signing in again', async () => {
    const { api, http } = configure();
    const fixture = TestBed.createComponent(App);
    const element = fixture.nativeElement as HTMLElement;
    const signIn = api.signInDevelopment();
    await completeSignIn(http);
    await signIn;
    fixture.detectChanges();
    expect(element.querySelector('[data-testid="dev-login"]')).toBeNull();
    const result = expect(api.report()).rejects.toMatchObject({ kind: 'unauthorized' });
    http
      .expectOne('/api/v1/admin/reports/aggregate')
      .flush({ detail: 'SENSITIVE_SERVER_SENTINEL' }, { status: 401, statusText: 'Unauthorized' });
    await result;
    fixture.detectChanges();
    expect(api.signedIn()).toBe(false);
    expect(element.querySelector('[role="alert"]')).not.toBeNull();
    expect(element.querySelector('[role="alert"]')?.textContent).toContain(
      'انتهت الجلسة. سجل الدخول مجددًا.',
    );
    expect(element.textContent).not.toContain('SENSITIVE_SERVER_SENTINEL');
    element.querySelector<HTMLButtonElement>('[data-testid="dev-login"]')!.click();
    await completeSignIn(http);
    await fixture.whenStable();
    fixture.detectChanges();
    expect(api.signedIn()).toBe(true);
    api.signOut();
    fixture.detectChanges();
    expect(element.textContent).not.toContain('انتهت الجلسة. سجل الدخول مجددًا.');
  });

  it('does not let a late401 from an earlier session end a newly authenticated session', async () => {
    const { api, http } = configure();
    const first = api.signInDevelopment();
    await completeSignIn(http);
    await first;
    const oldResult = expect(api.report()).rejects.toMatchObject({ kind: 'unauthorized' });
    const oldRequest = http.expectOne('/api/v1/admin/reports/aggregate');
    api.signOut();
    const next = api.signInDevelopment();
    await completeSignIn(http);
    await next;
    oldRequest.flush({}, { status: 401, statusText: 'Unauthorized' });
    await oldResult;
    expect(api.signedIn()).toBe(true);
  });
});
