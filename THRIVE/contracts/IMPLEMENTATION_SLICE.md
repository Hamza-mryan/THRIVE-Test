# Functional development MVP contract

This contract extends the onboarding foundation. Runtime health services remain disabled until institution-approved configuration/content is supplied. Seeded instruments, services and resources are labeled isDemo and enabled only for explicitly enabled Development identity. Never invent clinical tool wording, thresholds, emergency contacts or professional credentials.

API base: /api/v1. JSON camelCase, identifiers strings, timestamps ISO UTC, enum values strings. Existing consent and identity endpoints remain compatible. Standard failures ProblemDetails: 400 validation, 401 unauthenticated, 403 role/consent denial, 404 out-of-scope/missing resource, 409 invalid transition. Read/write queries always scope to authenticated university and subject as appropriate.

## Identity and consent

Development session existing endpoint adds persona `admin` (role UniversityAdmin, university demo-university). Student personas have role Student; existing student API behavior remains. Account auth tokens stay in memory. GET /me unchanged, may add role. Admin routes enforce UniversityAdmin; student data routes Student. Do not merely hide links.

Student functional routes require current service consent. Onboarding routes allow authenticated students before consent. Public current policy and help stay available. Research refusal never blocks service. PUT /me/consents remains for onboarding/research updates. POST /me/consents/withdraw records service=false,research=false in append-only decision/audit; it revokes functional access until service is reaccepted.

## Screening

- GET /instruments -> Instrument[]
- POST /screening/sessions {instrumentCode} -> Session
- GET /screening/sessions/{id} -> Session
- PUT /screening/sessions/{id}/answers/{itemCode} {value:int} -> Session
- POST /screening/sessions/{id}/submit -> ScreeningResult
- GET /me/screenings -> Session[] newest first

Instrument: {code,titleAr,titleEn,version,isDemo,items:Item[]}
Item: {code,promptAr,promptEn,options:[{value:int,labelAr,labelEn}]}
Session: {id,instrumentCode,instrumentVersion,status:'InProgress'|'Completed',startedAtUtc,completedAtUtc:null|string,answers:[{itemCode,value}],result:null|ScreeningResult}
ScreeningResult: {sessionId,instrumentCode,state:'Demo',rawScore:int,maxScore:int,ruleVersion,reasonAr,reasonEn,createdAtUtc,isDemo:true}

Only custom usability questionnaire DEMO-CHECK is seeded (three nonclinical product-experience questions). Result is a technical sum and explicitly has no psychological interpretation or clinical color band. Do not claim HADS/PSS testing is operational. Validate options, item ownership, completeness, submitted immutability and current consent; repeated submit returns same result without duplication. No client final score accepted.

## Guide

- GET /guide/resources -> Resource[] published only
- GET /guide/resources/{id} -> Resource

Resource: {id,slug,titleAr,titleEn,summaryAr,summaryEn,bodyAr,bodyEn,category,source,reviewedAtUtc:null|string,version,isDemo,published:bool}

Seed product-navigation/help content rather than unreviewed treatment advice. Mobile supports search/category/detail and explicit offline download of public published guides. Only public guide content can persist locally, never tokens/answers/scores. Label source and review absence honestly.

## Services and referrals

- GET /services?level=Counseling|Specialist -> Service[]
- POST /referrals {serviceId,shareConsent:bool} -> Referral
- GET /me/referrals -> Referral[]
- POST /me/referrals/{id}/cancel -> Referral

Service: {id,level:'Counseling'|'Specialist',nameAr,nameEn,descriptionAr,descriptionEn,hoursAr,hoursEn,locationAr,locationEn,bookingMethod,contactUrl:null|string,isDemo,verified:bool,active:bool}
Referral: {id,serviceId,serviceNameAr,serviceNameEn,level,status:'Requested'|'Received'|'Scheduled'|'Completed'|'Declined'|'Cancelled',createdAtUtc,updatedAtUtc,isDemo}

Seed one simulated service per level, with no invented contact credentials or phone numbers. Explicit isDemo notice in students and admin. Live directory shows only active verified services; demo identity may see active simulated entries. Share consent required. Prevent duplicate open referral to same service for same student. Cancel only nonterminal own referrals. No actual external email, SMS, calendar or notification integration in this slice.

## Admin

- GET /admin/services -> Service[] includes drafts/inactive in own university
- POST /admin/services ServiceWrite -> Service
- PUT /admin/services/{id} ServiceWrite -> Service
- GET /admin/resources -> Resource[] includes drafts
- POST /admin/resources ResourceWrite -> Resource
- PUT /admin/resources/{id} ResourceWrite -> Resource
- GET /admin/referrals -> Referral[] no student identity/answers/scores
- PUT /admin/referrals/{id}/status {status} -> Referral
- GET /admin/reports/aggregate -> {screeningsCount:int|null,referralsCount:int|null,completedReferralsCount:int|null,minCellSize:int,availableResourcesCount:int,availableServicesCount:int}

ServiceWrite fields: level,nameAr,nameEn,descriptionAr,descriptionEn,hoursAr,hoursEn,locationAr,locationEn,bookingMethod,contactUrl:null|string,verified:bool,active:bool. ResourceWrite: slug,titleAr,titleEn,summaryAr,summaryEn,bodyAr,bodyEn,category,source,version,published:bool. isDemo, university and reviewer metadata are server-owned. Synthetic admin writes remain isDemo in development; cannot turn demo services into verified operational services. Live verified publishing needs institution review metadata; keep unverified until available.

Status transitions: Requested -> Received|Declined; Received -> Scheduled|Declined; Scheduled -> Completed|Declined; student may cancel Requested|Received|Scheduled. Terminal statuses immutable; repeat same status idempotent. No automatic Completed on request/click.

Aggregate report requires minimum-cell suppression (default5) for each sensitive metric; count<5 returns null and UI explains suppression. Resource/service counts are directory operations, not health metrics. No filters permitting individual-health drilldown.

All three apps include meaningful loading/empty/error states and Arabic/English labels. Runtime remains a fully connected development MVP with production integration gates clearly documented.
