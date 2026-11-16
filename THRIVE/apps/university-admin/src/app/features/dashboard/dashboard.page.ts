import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { LanguageService } from '../../core/i18n/language.service';
import { AdminApi } from '../../core/api/admin-api';
import { AggregateReport } from '../../core/api/models';
import { RequestState } from '../../shared/request-state/request-state';
import { RequestFeedback } from '../../shared/request-state/request-feedback';
import { ThriveIcon } from '../../shared/icon/thrive-icon';
@Component({
  selector: 'app-dashboard-page',
  imports: [RouterLink, RequestFeedback, ThriveIcon],
  templateUrl: './dashboard.page.html',
  styleUrl: './dashboard.page.scss',
})
export class DashboardPage implements OnInit {
  protected readonly language = inject(LanguageService);
  private readonly api = inject(AdminApi);
  protected readonly state = new RequestState();
  protected readonly report = signal<AggregateReport | null>(null);
  ngOnInit(): void {
    this.load();
  }
  protected load(): void {
    void this.state.run(async () => this.report.set(await this.api.report()));
  }
  protected sensitiveMetrics(data: AggregateReport) {
    const c = this.language.copy().dashboard;
    return [
      { label: c.screenings, value: data.screeningsCount },
      { label: c.referrals, value: data.referralsCount },
      { label: c.completed, value: data.completedReferralsCount },
    ];
  }
}
