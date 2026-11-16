// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get brandTagline => 'Check in. Reach out. Thrive.';

  @override
  String get welcomeEyebrow => 'A little space for you';

  @override
  String get welcomeTitle => 'Your next step\ntowards feeling better.';

  @override
  String get welcomeBody =>
      'Understand how you feel, explore helpful resources, and find your way to human support — at your pace.';

  @override
  String get heroEyebrow => 'GROW AT YOUR OWN PACE';

  @override
  String get heroTitle => 'Small steps.\nMore possibilities.';

  @override
  String get benefitCheckTitle => 'Make room for a check-in';

  @override
  String get benefitCheckBody =>
      'A clear starting point to understand your support needs.';

  @override
  String get benefitConnectTitle => 'Find the right support';

  @override
  String get benefitConnectBody =>
      'Resources and verified university services in one place.';

  @override
  String get benefitChoiceTitle => 'Your choices matter';

  @override
  String get benefitChoiceBody =>
      'Research participation is optional and separate from service use.';

  @override
  String get developmentSignIn => 'Explore with a development account';

  @override
  String get universitySignIn => 'Continue with your university';

  @override
  String get connecting => 'Connecting…';

  @override
  String get developmentNotice =>
      'Development preview · synthetic account · not a live student service';

  @override
  String get identityPending =>
      'University sign-in will be available when your university connection is ready.';

  @override
  String get screeningBoundary =>
      'THRIVE supports screening and referral. It does not provide diagnosis, treatment, or continuous monitoring.';

  @override
  String get urgentHelp => 'Need urgent help? Reach out now';

  @override
  String get consentEyebrow => 'Your choice, clearly explained';

  @override
  String get consentTitle => 'Before we begin.';

  @override
  String get consentIntro =>
      'Take a moment to read how the service works. Research participation is always a separate choice.';

  @override
  String get serviceConsentTitle => 'Using the service';

  @override
  String get serviceConsentLabel =>
      'I have read and agree to use the service under this policy.';

  @override
  String get researchConsentTitle => 'Research participation · optional';

  @override
  String get researchConsentLabel =>
      'I separately agree to research participation under this policy.';

  @override
  String get researchOptional =>
      'You can leave research unchecked and continue using the service. This preview policy is for development review only.';

  @override
  String get saveAndContinue => 'Save my choices and continue';

  @override
  String get saving => 'Saving your choices…';

  @override
  String policyVersion(String version) {
    return 'Policy version: $version';
  }

  @override
  String get homeEyebrow => 'One step at a time';

  @override
  String get homeTitle => 'Welcome to your space.';

  @override
  String get homeBody =>
      'A place to check in, learn, and reach out when you need support.';

  @override
  String get homeBannerTitle => 'You don’t have to figure it out alone.';

  @override
  String get homeBannerBody =>
      'Find a starting point that feels right for you. Seeking support is always your choice.';

  @override
  String get modulesTitle => 'Your pathways to support';

  @override
  String get checkTitle => 'THRIVE Check';

  @override
  String get checkBody =>
      'A guided self-check to help understand your support needs.';

  @override
  String get guideTitle => 'THRIVE Guide';

  @override
  String get guideBody =>
      'Practical resources for everyday balance and wellbeing.';

  @override
  String get connectTitle => 'THRIVE Connect';

  @override
  String get connectBody =>
      'Find support through verified university services.';

  @override
  String get plusTitle => 'THRIVE Plus';

  @override
  String get plusBody => 'Explore pathways to verified specialist support.';

  @override
  String get modulePending => 'Coming in the next development stages';

  @override
  String get historyTitle => 'Your check-in history';

  @override
  String get historyEmpty =>
      'No check-ins yet. Your history will appear here once the screening pathway is available.';

  @override
  String get developmentHomeNotice =>
      'Connected development preview: labeled demonstrations and services use synthetic data and do not deliver a live clinical service.';

  @override
  String get signOut => 'Sign out';

  @override
  String get safetyTitle => 'You deserve support now.';

  @override
  String get safetyIntro =>
      'If you feel unsafe or need immediate support, contact local emergency services or seek in-person help nearby.';

  @override
  String get safetyTrustedTitle => 'Reach out to someone you trust';

  @override
  String get safetyTrustedBody =>
      'Let a trusted person know that you need support, and move to a safe place if you can.';

  @override
  String get safetyContactsUnavailable =>
      'Verified university contact details are not available in this preview. Do not rely on this app for an emergency response.';

  @override
  String get safetyBoundary =>
      'THRIVE is not an emergency service and does not monitor you continuously.';

  @override
  String get close => 'Close';

  @override
  String get connectionError =>
      'We couldn’t connect. Check your connection and try again. Your choices have not been confirmed saved.';

  @override
  String get sessionError =>
      'Your session is unavailable or expired. Sign out and start again.';

  @override
  String get policyChangedError =>
      'The policy has changed. Sign out and start again to read the current version.';

  @override
  String get validationError =>
      'We couldn’t save these choices. Review your selections and try again.';

  @override
  String get serviceError =>
      'The service is unavailable right now. Please try again shortly.';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get actionError =>
      'We could not complete this action. Check your connection, refresh, and try again.';

  @override
  String get demoCheckNotice =>
      'This is a usability demonstration only. The response total is technical and has no psychological or diagnostic meaning.';

  @override
  String get clinicalToolsPending =>
      'Clinical instruments such as HADS and PSS remain disabled until licensing and institution approval are complete.';

  @override
  String get noInstruments => 'No instrument is enabled';

  @override
  String get startCheck => 'Start demonstration';

  @override
  String get demoLabel => 'Demo · synthetic data';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get submitCheck => 'Submit and view result';

  @override
  String get answersSavedOnServer =>
      'Each answer is saved when the server confirms it. Resume this session from your history.';

  @override
  String get pauseCheck => 'Pause and resume later';

  @override
  String get resultTitle => 'Demonstration complete';

  @override
  String technicalTotal(int score, int max) {
    return 'Technical total: $score of $max';
  }

  @override
  String ruleVersion(String version) {
    return 'Rule version: $version';
  }

  @override
  String get noHistory => 'Your history starts here';

  @override
  String get noHistoryBody =>
      'Start a session from THRIVE Check. Your progress and demonstration results will appear here.';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In progress';

  @override
  String get viewResult => 'View result';

  @override
  String get resumeCheck => 'Resume session';

  @override
  String get offlineGuides =>
      'Showing your saved offline copies. Check content versions when you reconnect.';

  @override
  String get searchGuides => 'Search resources';

  @override
  String get allCategories => 'All categories';

  @override
  String get savedGuidesOnly => 'Saved resources only';

  @override
  String get noResources => 'No matching resources';

  @override
  String get noResourcesBody =>
      'Try another search or clear your filters. Only published resources are shown.';

  @override
  String get readResource => 'Read resource';

  @override
  String get demoResourceNotice =>
      'Development content explaining how to use the app. It is not treatment or approved clinical guidance.';

  @override
  String resourceSource(String source) {
    return 'Source: $source';
  }

  @override
  String get reviewPending =>
      'No approved clinical review is recorded for this content.';

  @override
  String reviewDate(String date) {
    return 'Reviewed: $date';
  }

  @override
  String contentVersion(String version) {
    return 'Content version: $version';
  }

  @override
  String get removeDownload => 'Remove saved copy';

  @override
  String get downloadGuide => 'Save for offline reading';

  @override
  String get directoryIntro =>
      'Choose a service and review its details before requesting support. Sharing minimum necessary information requires your consent.';

  @override
  String get noServices => 'No service is currently available';

  @override
  String get noServicesBody =>
      'Verified services will appear when enabled by the university. Urgent help remains available.';

  @override
  String get verifiedService => 'Verified service';

  @override
  String get serviceDetails => 'Service details';

  @override
  String get demoServiceNotice =>
      'This is a simulated service for testing referrals inside the system. Requests do not reach a healthcare provider or book real appointments.';

  @override
  String get serviceHours => 'Opening hours';

  @override
  String get serviceLocation => 'Location';

  @override
  String get bookingMethod => 'Request and booking process';

  @override
  String get shareReferralConsent =>
      'I consent to sharing the minimum necessary information with this referral service.';

  @override
  String get requestReferral => 'Request referral';

  @override
  String get referralSent =>
      'Your referral request was created. Track it in My referrals; creation does not mean completion or a confirmed appointment.';

  @override
  String get referralAlreadyOpen =>
      'You already have an open request for this service. Check My referrals before sending another.';

  @override
  String get referralRequestBoundary =>
      'Referral status is updated by authorized staff. Decisions remain with you and the qualified professional.';

  @override
  String get myReferrals => 'My referrals';

  @override
  String get noReferrals => 'No referral requests yet';

  @override
  String get noReferralsBody =>
      'Explore support options through THRIVE Connect or THRIVE Plus.';

  @override
  String get cancelReferral => 'Cancel request';

  @override
  String get cancelReferralConfirm =>
      'Cancel this request? You can create another request later.';

  @override
  String get keepReferral => 'Keep request';

  @override
  String get referralRequested => 'Requested';

  @override
  String get referralReceived => 'Received';

  @override
  String get referralScheduled => 'Scheduled';

  @override
  String get referralCompleted => 'Completed';

  @override
  String get referralDeclined => 'Declined';

  @override
  String get referralCancelled => 'Cancelled';

  @override
  String get accountTitle => 'My account and choices';

  @override
  String get consentSettings => 'Consent settings';

  @override
  String get withdrawConsent => 'Withdraw service consent';

  @override
  String get withdrawConsentConfirm =>
      'Withdrawal stops access to service features and withdraws research consent too. Decision records remain under the applicable retention policy.';

  @override
  String get confirmWithdraw => 'Confirm withdrawal';

  @override
  String get accountPrivacy =>
      'Your current session is memory-only. Answers, results and sign-in tokens are not stored on your device. You may explicitly save published resources for offline reading.';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navGuide => 'Guide';

  @override
  String get navReferrals => 'Referrals';

  @override
  String get navAccount => 'Account';

  @override
  String get openPath => 'Open pathway';

  @override
  String get historyReadyBody =>
      'Open History to view completed sessions or resume a saved session.';

  @override
  String get openSavedGuides => 'Read saved resources offline';

  @override
  String openNamedPath(String title) {
    return 'Open $title';
  }

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get policyDraftNotice =>
      'Development information, not an approved launch policy. The university must approve the final text before collecting real student data.';

  @override
  String get dataCollectedTitle => 'What data does the app use?';

  @override
  String get dataCollectedBody =>
      'The server uses account and university identifiers, consent decisions and policy version, session answers and results, and referral records. Daily feeling entries are optional. Downloaded resources do not require personal notes.';

  @override
  String get dataPurposeTitle => 'Why is this data used?';

  @override
  String get dataPurposeBody =>
      'To provide the service, save progress and history, track support requests, enforce access rights, and audit operations. Research participation is separate and refusing it does not block service. Daily feelings are not used to calculate diagnosis or risk.';

  @override
  String get dataSharingTitle => 'Access and sharing';

  @override
  String get dataSharingBody =>
      'Student records are scoped to their identity and university. Administration shows directories, referral status, and aggregates without individual answers. Referrals require separate sharing consent. The current preview does not deliver referrals to external providers.';

  @override
  String get dataChoicesTitle => 'Your choices and retention';

  @override
  String get dataChoicesBody =>
      'You can change research consent, withdraw service consent, and remove today\'s feeling. Withdrawal does not automatically delete prior records. Retention periods, deletion requests, and the official contact await university policy. Tokens, answers, and results are not stored locally; only published public resources can be downloaded.';

  @override
  String get serviceScopeTitle => 'Service limits';

  @override
  String get serviceScopeBody =>
      'THRIVE supports screening, referral, and education. It does not diagnose, treat, provide emergency response, or continuously monitor users. Medical decisions remain with licensed professionals. Help remains accessible without completing a questionnaire.';

  @override
  String get demoUseTitle => 'Using the development preview';

  @override
  String get demoUseBody =>
      'Accounts, questions, and services labeled demo test the product. They do not produce a real psychological result or confirm a care appointment. Resource sources, versions, and review status are displayed explicitly.';

  @override
  String get contactPolicyTitle => 'Official information and help';

  @override
  String get contactPolicyBody =>
      'University services, professionals, and help contacts become operational only after verification and approval. Help is always accessible. Check the displayed contact status and do not rely on the preview for emergency response.';

  @override
  String get humanSupportTitle => 'Reach human support';

  @override
  String get humanSupportBody =>
      'If you want additional support, explore university counseling or specialist services. The decision remains with you and a professional; these links do not depend on the demonstration total.';

  @override
  String get activityTitle => 'Your activity';

  @override
  String get activityCompleted => 'Completed sessions';

  @override
  String get activityOpenReferrals => 'Open support requests';

  @override
  String get dailyMoodTitle => 'How do you feel today? Optional';

  @override
  String get dailyMoodNotice =>
      'A personal entry you can change or remove. It is not screening, diagnosis, or a risk assessment and does not affect access to support.';

  @override
  String get moodVeryLow => 'Very difficult';

  @override
  String get moodLow => 'Difficult';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodGood => 'Good';

  @override
  String get moodVeryGood => 'Very good';

  @override
  String get removeTodayMood => 'Remove today\'s entry';

  @override
  String get moodWeekTitle => 'Your feelings over the past seven days';

  @override
  String get moodNotRecorded => 'Not recorded';

  @override
  String get emergencyContactTitle => 'Contact emergency services';

  @override
  String get emergencyContactPending =>
      'An approved emergency contact is not configured in this preview. A call action cannot be offered until the service and number are verified.';

  @override
  String get universityHelpTitle => 'University support and human assistance';

  @override
  String get universityHelpPending =>
      'The university support channel and response hours await verification. No team monitors this preview or receives an emergency request from it.';

  @override
  String get verificationRequired => 'Requires verification';

  @override
  String get safePlaceTitle => 'Move to a safe place';

  @override
  String get safePlaceBody =>
      'If possible, move to a safe place and ask someone you trust to stay with you until you receive direct help.';

  @override
  String get activitySubtitle => 'Your saved steps, all in one place.';

  @override
  String get moodChartTitle => 'Your feelings over time';

  @override
  String get moodChartSubtitle =>
      'Your own check-ins, without judgement or clinical interpretation.';

  @override
  String moodChartRecorded(int count, int total) {
    return '$count of $total days recorded';
  }

  @override
  String get moodChartLegend => 'Recorded feeling';

  @override
  String get moodChartGapNotice =>
      'The 1–5 scale reflects your own choice. Gaps are unrecorded days, not zero values.';

  @override
  String get moodChartEmptyTitle => 'Your first point starts with you';

  @override
  String get moodChartEmptyBody =>
      'If you wish, record your feeling today to see it here. Earlier days stay empty.';

  @override
  String get chartSevenDays => '7 days';

  @override
  String get chartThirtyDays => '30 days';

  @override
  String get historyOverview => 'Your journey so far';

  @override
  String get historyOverviewBody =>
      'Saved sessions you can return to at any time.';

  @override
  String historySessionCount(int count) {
    return '$count saved sessions';
  }

  @override
  String get directoryAllSpecialties => 'All';

  @override
  String get specialtyPsychology => 'Psychology';

  @override
  String get specialtyPsychiatry => 'Psychiatry';

  @override
  String get specialtyGeneral => 'General support';

  @override
  String get serviceSource => 'Directory source';

  @override
  String get serviceSourceMissing => 'No verified source has been added';

  @override
  String get serviceUnverified => 'Unverified directory entry';

  @override
  String get servicePhone => 'Call';

  @override
  String get serviceEmail => 'Email';

  @override
  String get serviceWebsite => 'Provider website';

  @override
  String get serviceContactUnavailable =>
      'This contact method could not be opened on this device';

  @override
  String get serviceContactBoundary =>
      'Contact opens another app and does not automatically share screening results.';

  @override
  String get directorySpecialistIntro =>
      'Choose a support specialty and review the service before requesting a referral.';

  @override
  String get serviceRequestTitle => 'Your next step';

  @override
  String get serviceBookingInternal => 'In-app referral request';

  @override
  String get guideEyebrow => 'A little space for yourself';

  @override
  String get topicStress => 'Stress';

  @override
  String get topicExams => 'Exam worries';

  @override
  String get topicSleep => 'Sleep & rest';

  @override
  String get topicTime => 'Time planning';

  @override
  String get topicBreathing => 'Gentle breathing';

  @override
  String get topicGrounding => 'Grounding';

  @override
  String get topicProduct => 'Using THRIVE';

  @override
  String get draftEducationNotice =>
      'Educational drafts based on public sources, pending university specialist review. These are not treatment or clinically approved materials.';

  @override
  String get openOriginalSource => 'Original source';

  @override
  String get breathingPracticeTitle => 'A space to breathe';

  @override
  String get breathingPracticeBody =>
      'Follow the rhythm if comfortable, or stop whenever you like.';

  @override
  String get breatheIn => 'Breathe in gently';

  @override
  String get breatheOut => 'Breathe out gently';

  @override
  String get startPractice => 'Start practice';

  @override
  String get pausePractice => 'Pause';

  @override
  String get resetPractice => 'Reset';

  @override
  String get practiceReady => 'At your own pace';

  @override
  String get practiceComplete => 'Time complete. Take your time.';

  @override
  String get resumeJourneyTitle => 'Pick up where you left off';

  @override
  String get pastSessionsTitle => 'Your previous check-ins';

  @override
  String get accountIntro => 'Your space. Your choices.';

  @override
  String get referralsIntro =>
      'Keep track of your support requests and the next step.';
}
