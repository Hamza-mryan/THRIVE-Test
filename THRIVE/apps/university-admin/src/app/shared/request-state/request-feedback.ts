import { Component, inject, input, output } from '@angular/core';
import { LanguageService } from '../../core/i18n/language.service';
import { RequestState } from './request-state';

@Component({
  selector: 'app-request-feedback',
  template: `
    @if (state().busy()) {
      <p class="notice" role="status">{{ language.copy().common.loading }}</p>
    }
    @if (state().error(); as error) {
      <div class="notice error" role="alert">
        <span>{{ language.copy().errors[error] }}</span>
        <button type="button" class="secondary" (click)="retry.emit()">
          {{ language.copy().common.retry }}
        </button>
      </div>
    }
  `,
})
export class RequestFeedback {
  readonly state = input.required<RequestState>();
  readonly retry = output<void>();
  protected readonly language = inject(LanguageService);
}
