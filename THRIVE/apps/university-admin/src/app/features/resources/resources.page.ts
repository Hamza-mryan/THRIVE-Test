import {
  afterNextRender,
  Component,
  ElementRef,
  inject,
  Injector,
  OnInit,
  signal,
  viewChild,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LanguageService } from '../../core/i18n/language.service';
import { AdminApi } from '../../core/api/admin-api';
import { GuideResource, ResourceWrite } from '../../core/api/models';
import { RequestState } from '../../shared/request-state/request-state';
import { RequestFeedback } from '../../shared/request-state/request-feedback';
import { ThriveIcon } from '../../shared/icon/thrive-icon';
import { FieldFeedback } from '../../shared/form-feedback/field-feedback';
function newResource(): ResourceWrite {
  return {
    slug: '',
    titleAr: '',
    titleEn: '',
    summaryAr: '',
    summaryEn: '',
    bodyAr: '',
    bodyEn: '',
    category: '',
    source: '',
    version: '1',
    published: false,
  };
}
@Component({
  selector: 'app-resources-page',
  imports: [FormsModule, RequestFeedback, ThriveIcon, FieldFeedback],
  templateUrl: './resources.page.html',
})
export class ResourcesPage implements OnInit {
  protected readonly language = inject(LanguageService);
  private readonly api = inject(AdminApi);
  protected readonly state = new RequestState();
  protected readonly resources = signal<GuideResource[]>([]);
  protected readonly editing = signal(false);
  protected readonly saved = signal(false);
  protected draft = newResource();
  private selectedId: string | null = null;
  private readonly injector = inject(Injector);
  private readonly editorHeading = viewChild<ElementRef<HTMLElement>>('editorHeading');
  private returnFocus: HTMLElement | null = null;
  protected cancel(): void {
    this.editing.set(false);
    if (this.returnFocus?.isConnected) this.returnFocus.focus();
  }
  ngOnInit(): void {
    this.load();
  }
  protected load(): void {
    void this.state.run(async () => this.resources.set(await this.api.resources()));
  }
  protected edit(resource?: GuideResource, event?: Event): void {
    this.returnFocus = (event?.currentTarget as HTMLElement | null) ?? null;
    this.selectedId = resource?.id ?? null;
    if (resource) {
      const { id, isDemo, reviewedAtUtc, ...editable } = resource;
      this.draft = editable;
    } else this.draft = newResource();
    this.saved.set(false);
    this.editing.set(true);
    afterNextRender(() => this.editorHeading()?.nativeElement.focus(), { injector: this.injector });
  }
  protected save(): void {
    void this.state.run(async () => {
      await this.api.saveResource(this.selectedId, this.draft);
      this.editing.set(false);
      this.saved.set(true);
      this.resources.set(await this.api.resources());
    });
  }
}
