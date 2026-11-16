import { Component, computed, inject, input } from '@angular/core';
import { ValidationErrors } from '@angular/forms';
import { LanguageService } from '../../core/i18n/language.service';

/** Presents existing form-validator errors; it never validates or changes a value. */
@Component({
  selector: 'app-field-feedback',
  template: `
    @if (message(); as text) {
      <p role="status">{{ text }}</p>
    }
  `,
  styles: `
    :host {
      display: block;
      min-width: 0;
    }
    p {
      margin: 0.35rem 0 0;
      color: var(--error);
      font-size: 0.875rem;
      line-height: 1.6;
    }
  `,
})
export class FieldFeedback {
  readonly errors = input<ValidationErrors | null>(null);
  readonly show = input<boolean | null>(false);
  private readonly language = inject(LanguageService);
  protected readonly message = computed(() => {
    const errors = this.errors();
    if (!this.show() || !errors) return '';
    const copy = this.language.copy().editor;
    if (errors['required']) return copy.fieldRequired;
    if (errors['email']) return copy.fieldEmail;
    if (errors['pattern']) return copy.fieldSlug;
    if (errors['maxlength']) {
      return copy.fieldMaxLength.replace('{max}', String(errors['maxlength'].requiredLength));
    }
    return copy.invalid;
  });
}
