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
import { UniversityService, UniversityServiceWrite } from '../../core/api/models';
import { RequestState } from '../../shared/request-state/request-state';
import { RequestFeedback } from '../../shared/request-state/request-feedback';
import { ThriveIcon } from '../../shared/icon/thrive-icon';
import { FieldFeedback } from '../../shared/form-feedback/field-feedback';

function newService(): UniversityServiceWrite {
  return {
    level: 'Counseling',
    nameAr: '',
    nameEn: '',
    descriptionAr: '',
    descriptionEn: '',
    hoursAr: '',
    hoursEn: '',
    locationAr: '',
    locationEn: '',
    bookingMethod: 'InternalRequest',
    contactUrl: null,
    phone: null,
    email: null,
    specialty: null,
    source: null,
    verified: false,
    active: true,
  };
}

@Component({
  selector: 'app-services-page',
  imports: [FormsModule, RequestFeedback, ThriveIcon, FieldFeedback],
  templateUrl: './services.page.html',
})
export class ServicesPage implements OnInit {
  protected readonly language = inject(LanguageService);
  private readonly api = inject(AdminApi);
  protected readonly state = new RequestState();
  protected readonly services = signal<UniversityService[]>([]);
  protected readonly editing = signal(false);
  protected readonly saved = signal(false);
  protected draft = newService();
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
    void this.state.run(async () => this.services.set(await this.api.services()));
  }
  protected edit(service?: UniversityService, event?: Event): void {
    this.returnFocus = (event?.currentTarget as HTMLElement | null) ?? null;
    this.selectedId = service?.id ?? null;
    if (service) {
      const { id, isDemo, ...editable } = service;
      this.draft = editable;
    } else {
      this.draft = newService();
    }
    this.saved.set(false);
    this.editing.set(true);
    afterNextRender(() => this.editorHeading()?.nativeElement.focus(), { injector: this.injector });
  }
  protected save(): void {
    void this.state.run(async () => {
      await this.api.saveService(this.selectedId, this.draft);
      this.editing.set(false);
      this.saved.set(true);
      this.services.set(await this.api.services());
    });
  }
}
