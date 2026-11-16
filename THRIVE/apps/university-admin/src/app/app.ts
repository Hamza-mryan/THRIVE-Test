import { Component, ElementRef, inject, viewChild } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { LanguageService } from './core/i18n/language.service';
import { AdminApi } from './core/api/admin-api';
import { RequestState } from './shared/request-state/request-state';
import { RequestFeedback } from './shared/request-state/request-feedback';
import { ThriveIcon } from './shared/icon/thrive-icon';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, RequestFeedback, ThriveIcon],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected readonly language = inject(LanguageService);
  protected readonly api = inject(AdminApi);
  protected readonly login = new RequestState();
  private readonly mainContent = viewChild.required<ElementRef<HTMLElement>>('mainContent');
  protected readonly navigation = [
    { path: '/dashboard', label: 'dashboard', icon: 'overview' },
    { path: '/services', label: 'services', icon: 'services' },
    { path: '/resources', label: 'resources', icon: 'resources' },
    { path: '/referrals', label: 'referrals', icon: 'referrals' },
  ] as const;
  protected focusContent(event: Event): void {
    event.preventDefault();
    this.mainContent().nativeElement.focus();
  }
  protected signIn(): void {
    void this.login.run(() => this.api.signInDevelopment());
  }
}
