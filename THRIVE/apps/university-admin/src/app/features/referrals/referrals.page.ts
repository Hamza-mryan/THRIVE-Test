import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { LanguageService } from '../../core/i18n/language.service';
import { AdminApi } from '../../core/api/admin-api';
import { nextReferralStatuses, Referral, ReferralStatus } from '../../core/api/models';
import { RequestState } from '../../shared/request-state/request-state';
import { RequestFeedback } from '../../shared/request-state/request-feedback';
import { ThriveIcon } from '../../shared/icon/thrive-icon';
@Component({
  selector: 'app-referrals-page',
  imports: [DatePipe, RequestFeedback, ThriveIcon],
  templateUrl: './referrals.page.html',
  styleUrl: './referrals.page.scss',
})
export class ReferralsPage implements OnInit {
  protected readonly language = inject(LanguageService);
  private readonly api = inject(AdminApi);
  protected readonly state = new RequestState();
  protected readonly referrals = signal<Referral[]>([]);
  protected readonly saved = signal(false);
  protected readonly transitions = nextReferralStatuses;
  ngOnInit(): void {
    this.load();
  }
  protected load(): void {
    void this.state.run(async () => this.referrals.set(await this.api.referrals()));
  }
  protected update(referral: Referral, event: Event): void {
    const select = event.target as HTMLSelectElement;
    const next = nextReferralStatuses(referral.status).find((status) => status === select.value);
    select.value = '';
    if (!next) return;
    this.saved.set(false);
    void this.state.run(async () => {
      await this.api.updateReferral(referral.id, next as ReferralStatus);
      this.referrals.set(await this.api.referrals());
      this.saved.set(true);
    });
  }
}
