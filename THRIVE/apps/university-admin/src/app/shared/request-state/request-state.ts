import { signal } from '@angular/core';
import { ApiFailure, ApiFailureKind } from '../../core/api/admin-api';

/** Request lifecycle shared by pages, without retaining server payloads in errors. */
export class RequestState {
  readonly busy = signal(false);
  readonly error = signal<ApiFailureKind | null>(null);
  async run(action: () => Promise<void>): Promise<boolean> {
    if (this.busy()) return false;
    this.busy.set(true);
    this.error.set(null);
    try {
      await action();
      return true;
    } catch (error) {
      this.error.set(error instanceof ApiFailure ? error.kind : 'unavailable');
      return false;
    } finally {
      this.busy.set(false);
    }
  }
}
