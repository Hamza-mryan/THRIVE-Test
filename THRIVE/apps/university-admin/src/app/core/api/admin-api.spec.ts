import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { AdminApi, ApiFailure, DEVELOPMENT_IDENTITY_ENABLED } from './admin-api';

function configure(enabled = true) {
  TestBed.configureTestingModule({
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: DEVELOPMENT_IDENTITY_ENABLED, useValue: enabled },
    ],
  });
  return { api: TestBed.inject(AdminApi), http: TestBed.inject(HttpTestingController) };
}
async function authenticate(api: AdminApi, http: HttpTestingController, role = 'UniversityAdmin') {
  const result = api.signInDevelopment();
  http.expectOne('/health/isolation').flush({
    application: 'THRIVE Test',
    database: 'thrive_test',
    databaseUser: 'thrive_test_local',
    databasePort: 55432,
  });
  await new Promise<void>((resolve) => setTimeout(resolve, 0));
  http
    .expectOne('/api/v1/development/session')
    .flush({ accessToken: 'synthetic-token', expiresAtUtc: '2099-01-01T00:00:00Z' });
  await new Promise<void>((resolve) => setTimeout(resolve, 0));
  const me = http.expectOne('/api/v1/me');
  expect(me.request.headers.get('Authorization')).toBe('Bearer synthetic-token');
  me.flush({
    subjectId: 'demo-admin',
    universityId: 'demo-university',
    displayName: 'Demo',
    isDevelopmentIdentity: true,
    role,
  });
  return result;
}
describe('Admin session and API boundary', () => {
  afterEach(() => {
    try {
      TestBed.inject(HttpTestingController).verify();
    } finally {
      TestBed.resetTestingModule();
    }
  });
  it('keeps development identity disabled unless explicitly enabled', async () => {
    const { api, http } = configure(false);
    await expect(api.signInDevelopment()).rejects.toMatchObject({ kind: 'forbidden' });
    expect(api.signedIn()).toBe(false);
    http.expectNone('/api/v1/development/session');
  });
  it('rejects the original backend before requesting a development session', async () => {
    const { api, http } = configure();
    const result = expect(api.signInDevelopment()).rejects.toMatchObject({ kind: 'unavailable' });
    http.expectOne('/health/isolation').flush({ application: 'THRIVE' });
    await result;
    http.expectNone('/api/v1/development/session');
    expect(api.signedIn()).toBe(false);
  });
  it('confirms admin role and clears the bearer on sign-out', async () => {
    const { api, http } = configure();
    await authenticate(api, http);
    expect(api.signedIn()).toBe(true);
    api.signOut();
    expect(api.user()).toBeNull();
    const request = api.services();
    const services = http.expectOne('/api/v1/admin/services');
    expect(services.request.headers.has('Authorization')).toBe(false);
    services.flush([]);
    await request;
  });
  it('rejects a student token instead of treating a successful sign-in as admin access', async () => {
    const { api, http } = configure();
    await expect(authenticate(api, http, 'Student')).rejects.toMatchObject({ kind: 'forbidden' });
    expect(api.signedIn()).toBe(false);
  });
  it('expires the memory session on401 without exposing a private response body', async () => {
    const { api, http } = configure();
    await authenticate(api, http);
    const report = api.report();
    const result = expect(report).rejects.toEqual(new ApiFailure('unauthorized'));
    http
      .expectOne('/api/v1/admin/reports/aggregate')
      .flush({ detail: 'private server details' }, { status: 401, statusText: 'Unauthorized' });
    await result;
    expect(api.signedIn()).toBe(false);
  });
  it('maps an invalid transition to a conflict without inventing success', async () => {
    const { api, http } = configure();
    const result = expect(api.updateReferral('r-1', 'Completed')).rejects.toMatchObject({
      kind: 'conflict',
    });
    http
      .expectOne('/api/v1/admin/referrals/r-1/status')
      .flush({}, { status: 409, statusText: 'Conflict' });
    await result;
  });
});
