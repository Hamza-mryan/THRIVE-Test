export type ServiceLevel = 'Counseling' | 'Specialist';
export interface UniversityServiceWrite {
  level: ServiceLevel;
  nameAr: string;
  nameEn: string;
  descriptionAr: string;
  descriptionEn: string;
  hoursAr: string;
  hoursEn: string;
  locationAr: string;
  locationEn: string;
  bookingMethod: string;
  contactUrl: string | null;
  phone?: string | null;
  email?: string | null;
  specialty?: 'Psychology' | 'Psychiatry' | null;
  source?: string | null;
  verified: boolean;
  active: boolean;
}
export interface UniversityService extends UniversityServiceWrite {
  readonly id: string;
  readonly isDemo: boolean;
}
export interface ResourceWrite {
  slug: string;
  titleAr: string;
  titleEn: string;
  summaryAr: string;
  summaryEn: string;
  bodyAr: string;
  bodyEn: string;
  category: string;
  source: string;
  version: string;
  published: boolean;
}
export interface GuideResource extends ResourceWrite {
  readonly id: string;
  readonly reviewedAtUtc: string | null;
  readonly isDemo: boolean;
}
export type ReferralStatus =
  'Requested' | 'Received' | 'Scheduled' | 'Completed' | 'Declined' | 'Cancelled';
export interface Referral {
  readonly id: string;
  readonly serviceId: string;
  readonly serviceNameAr: string;
  readonly serviceNameEn: string;
  readonly level: ServiceLevel;
  readonly status: ReferralStatus;
  readonly createdAtUtc: string;
  readonly updatedAtUtc: string;
  readonly isDemo: boolean;
}
export interface AggregateReport {
  readonly screeningsCount: number | null;
  readonly referralsCount: number | null;
  readonly completedReferralsCount: number | null;
  readonly minCellSize: number;
  readonly availableResourcesCount: number;
  readonly availableServicesCount: number;
}
export interface AdminUser {
  readonly subjectId: string;
  readonly universityId: string;
  readonly displayName: string;
  readonly isDevelopmentIdentity: boolean;
  readonly role: string;
}

/** UI affordance only. The server independently authorizes every transition. */
export function nextReferralStatuses(status: ReferralStatus): readonly ReferralStatus[] {
  switch (status) {
    case 'Requested':
      return ['Received', 'Declined'];
    case 'Received':
      return ['Scheduled', 'Declined'];
    case 'Scheduled':
      return ['Completed', 'Declined'];
    default:
      return [];
  }
}
