import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { computed, inject, Injectable, InjectionToken, signal } from '@angular/core';
import { firstValueFrom, timeout, TimeoutError } from 'rxjs';
import { environment } from '../../../environments/environment';
import {
  AdminUser,
  AggregateReport,
  GuideResource,
  Referral,
  ReferralStatus,
  ResourceWrite,
  UniversityService,
  UniversityServiceWrite,
} from './models';

export const DEVELOPMENT_IDENTITY_ENABLED = new InjectionToken<boolean>(
  'developmentIdentityEnabled',
  {
    providedIn: 'root',
    factory: () => environment.enableDevelopmentIdentity,
  },
);
const requestTimeoutMs = 12_000;
export type ApiFailureKind =
  'unauthorized' | 'forbidden' | 'invalid' | 'conflict' | 'unavailable' | 'timeout';
export class ApiFailure extends Error {
  constructor(readonly kind: ApiFailureKind) {
    super(kind);
  }
}

@Injectable({ providedIn: 'root' })
export class AdminApi {
  private readonly http = inject(HttpClient);
  readonly developmentEnabled = inject(DEVELOPMENT_IDENTITY_ENABLED);
  private token: string | null = null;
  private sessionVersion = 0;
  private readonly expiredSession = signal(false);
  readonly sessionExpired = this.expiredSession.asReadonly();
  private readonly authenticatedUser = signal<AdminUser | null>(null);
  readonly user = this.authenticatedUser.asReadonly();
  readonly signedIn = computed(() => this.user() !== null);

  async signInDevelopment(): Promise<void> {
    if (!this.developmentEnabled) throw new ApiFailure('forbidden');
    this.signOut();
    try {
      const destination = await firstValueFrom(
        this.http
          .get<{
            application: string;
            database: string;
            databaseUser: string;
            databasePort: number;
          }>('/health/isolation')
          .pipe(timeout(requestTimeoutMs)),
      );
      if (
        destination?.application !== 'THRIVE Test' ||
        destination.database !== 'thrive_test' ||
        destination.databaseUser !== 'thrive_test_local' ||
        destination.databasePort !== 55432
      )
        throw new ApiFailure('unavailable');
    } catch (error) {
      if (error instanceof TimeoutError) throw new ApiFailure('timeout');
      throw new ApiFailure('unavailable');
    }
    const session = await this.request<{ accessToken: string; expiresAtUtc: string }>(
      'POST',
      '/development/session',
      { persona: 'admin' },
    );
    this.token = session.accessToken;
    try {
      const user = await this.request<AdminUser>('GET', '/me');
      if (user.role !== 'UniversityAdmin') throw new ApiFailure('forbidden');
      this.authenticatedUser.set(user);
    } catch (error) {
      this.signOut();
      throw error;
    }
  }

  signOut(): void {
    this.sessionVersion++;
    this.token = null;
    this.authenticatedUser.set(null);
    this.expiredSession.set(false);
  }

  report(): Promise<AggregateReport> {
    return this.request('GET', '/admin/reports/aggregate');
  }
  services(): Promise<UniversityService[]> {
    return this.request('GET', '/admin/services');
  }
  saveService(id: string | null, value: UniversityServiceWrite): Promise<UniversityService> {
    return this.request(
      id ? 'PUT' : 'POST',
      `/admin/services${id ? '/' + encodeURIComponent(id) : ''}`,
      { ...value, contactUrl: value.contactUrl?.trim() || null },
    );
  }
  resources(): Promise<GuideResource[]> {
    return this.request('GET', '/admin/resources');
  }
  saveResource(id: string | null, value: ResourceWrite): Promise<GuideResource> {
    return this.request(
      id ? 'PUT' : 'POST',
      `/admin/resources${id ? '/' + encodeURIComponent(id) : ''}`,
      value,
    );
  }
  referrals(): Promise<Referral[]> {
    return this.request('GET', '/admin/referrals');
  }
  updateReferral(id: string, status: ReferralStatus): Promise<Referral> {
    return this.request('PUT', `/admin/referrals/${encodeURIComponent(id)}/status`, { status });
  }

  private async request<T>(method: string, path: string, body?: unknown): Promise<T> {
    const requestSessionVersion = this.sessionVersion;
    const wasSignedIn = this.signedIn();
    let headers = new HttpHeaders({ Accept: 'application/json' });
    if (this.token) headers = headers.set('Authorization', `Bearer ${this.token}`);
    try {
      return await firstValueFrom(
        this.http
          .request<T>(method, '/api/v1' + path, { body, headers })
          .pipe(timeout(requestTimeoutMs)),
      );
    } catch (error) {
      if (error instanceof TimeoutError) throw new ApiFailure('timeout');
      if (error instanceof HttpErrorResponse) {
        if (error.status === 401 && requestSessionVersion === this.sessionVersion) {
          this.signOut();
          this.expiredSession.set(wasSignedIn);
        }
        const kind: ApiFailureKind =
          error.status === 401
            ? 'unauthorized'
            : error.status === 403
              ? 'forbidden'
              : error.status === 409
                ? 'conflict'
                : error.status === 400 || error.status === 422
                  ? 'invalid'
                  : 'unavailable';
        throw new ApiFailure(kind);
      }
      throw new ApiFailure('unavailable');
    }
  }
}
