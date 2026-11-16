import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Check in. Reach out. Thrive.'**
  String get brandTagline;

  /// No description provided for @welcomeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'A little space for you'**
  String get welcomeEyebrow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next step\ntowards feeling better.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Understand how you feel, explore helpful resources, and find your way to human support — at your pace.'**
  String get welcomeBody;

  /// No description provided for @heroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'GROW AT YOUR OWN PACE'**
  String get heroEyebrow;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Small steps.\nMore possibilities.'**
  String get heroTitle;

  /// No description provided for @benefitCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for a check-in'**
  String get benefitCheckTitle;

  /// No description provided for @benefitCheckBody.
  ///
  /// In en, this message translates to:
  /// **'A clear starting point to understand your support needs.'**
  String get benefitCheckBody;

  /// No description provided for @benefitConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Find the right support'**
  String get benefitConnectTitle;

  /// No description provided for @benefitConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Resources and verified university services in one place.'**
  String get benefitConnectBody;

  /// No description provided for @benefitChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices matter'**
  String get benefitChoiceTitle;

  /// No description provided for @benefitChoiceBody.
  ///
  /// In en, this message translates to:
  /// **'Research participation is optional and separate from service use.'**
  String get benefitChoiceBody;

  /// No description provided for @developmentSignIn.
  ///
  /// In en, this message translates to:
  /// **'Explore with a development account'**
  String get developmentSignIn;

  /// No description provided for @universitySignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with your university'**
  String get universitySignIn;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @developmentNotice.
  ///
  /// In en, this message translates to:
  /// **'Development preview · synthetic account · not a live student service'**
  String get developmentNotice;

  /// No description provided for @identityPending.
  ///
  /// In en, this message translates to:
  /// **'University sign-in will be available when your university connection is ready.'**
  String get identityPending;

  /// No description provided for @screeningBoundary.
  ///
  /// In en, this message translates to:
  /// **'THRIVE supports screening and referral. It does not provide diagnosis, treatment, or continuous monitoring.'**
  String get screeningBoundary;

  /// No description provided for @urgentHelp.
  ///
  /// In en, this message translates to:
  /// **'Need urgent help? Reach out now'**
  String get urgentHelp;

  /// No description provided for @consentEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your choice, clearly explained'**
  String get consentEyebrow;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we begin.'**
  String get consentTitle;

  /// No description provided for @consentIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to read how the service works. Research participation is always a separate choice.'**
  String get consentIntro;

  /// No description provided for @serviceConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the service'**
  String get serviceConsentTitle;

  /// No description provided for @serviceConsentLabel.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to use the service under this policy.'**
  String get serviceConsentLabel;

  /// No description provided for @researchConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Research participation · optional'**
  String get researchConsentTitle;

  /// No description provided for @researchConsentLabel.
  ///
  /// In en, this message translates to:
  /// **'I separately agree to research participation under this policy.'**
  String get researchConsentLabel;

  /// No description provided for @researchOptional.
  ///
  /// In en, this message translates to:
  /// **'You can leave research unchecked and continue using the service. This preview policy is for development review only.'**
  String get researchOptional;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save my choices and continue'**
  String get saveAndContinue;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving your choices…'**
  String get saving;

  /// No description provided for @policyVersion.
  ///
  /// In en, this message translates to:
  /// **'Policy version: {version}'**
  String policyVersion(String version);

  /// No description provided for @homeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'One step at a time'**
  String get homeEyebrow;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your space.'**
  String get homeTitle;

  /// No description provided for @homeBody.
  ///
  /// In en, this message translates to:
  /// **'A place to check in, learn, and reach out when you need support.'**
  String get homeBody;

  /// No description provided for @homeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to figure it out alone.'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Find a starting point that feels right for you. Seeking support is always your choice.'**
  String get homeBannerBody;

  /// No description provided for @modulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pathways to support'**
  String get modulesTitle;

  /// No description provided for @checkTitle.
  ///
  /// In en, this message translates to:
  /// **'THRIVE Check'**
  String get checkTitle;

  /// No description provided for @checkBody.
  ///
  /// In en, this message translates to:
  /// **'A guided self-check to help understand your support needs.'**
  String get checkBody;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'THRIVE Guide'**
  String get guideTitle;

  /// No description provided for @guideBody.
  ///
  /// In en, this message translates to:
  /// **'Practical resources for everyday balance and wellbeing.'**
  String get guideBody;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'THRIVE Connect'**
  String get connectTitle;

  /// No description provided for @connectBody.
  ///
  /// In en, this message translates to:
  /// **'Find support through verified university services.'**
  String get connectBody;

  /// No description provided for @plusTitle.
  ///
  /// In en, this message translates to:
  /// **'THRIVE Plus'**
  String get plusTitle;

  /// No description provided for @plusBody.
  ///
  /// In en, this message translates to:
  /// **'Explore pathways to verified specialist support.'**
  String get plusBody;

  /// No description provided for @modulePending.
  ///
  /// In en, this message translates to:
  /// **'Coming in the next development stages'**
  String get modulePending;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your check-in history'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No check-ins yet. Your history will appear here once the screening pathway is available.'**
  String get historyEmpty;

  /// No description provided for @developmentHomeNotice.
  ///
  /// In en, this message translates to:
  /// **'Connected development preview: labeled demonstrations and services use synthetic data and do not deliver a live clinical service.'**
  String get developmentHomeNotice;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'You deserve support now.'**
  String get safetyTitle;

  /// No description provided for @safetyIntro.
  ///
  /// In en, this message translates to:
  /// **'If you feel unsafe or need immediate support, contact local emergency services or seek in-person help nearby.'**
  String get safetyIntro;

  /// No description provided for @safetyTrustedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach out to someone you trust'**
  String get safetyTrustedTitle;

  /// No description provided for @safetyTrustedBody.
  ///
  /// In en, this message translates to:
  /// **'Let a trusted person know that you need support, and move to a safe place if you can.'**
  String get safetyTrustedBody;

  /// No description provided for @safetyContactsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Verified university contact details are not available in this preview. Do not rely on this app for an emergency response.'**
  String get safetyContactsUnavailable;

  /// No description provided for @safetyBoundary.
  ///
  /// In en, this message translates to:
  /// **'THRIVE is not an emergency service and does not monitor you continuously.'**
  String get safetyBoundary;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t connect. Check your connection and try again. Your choices have not been confirmed saved.'**
  String get connectionError;

  /// No description provided for @sessionError.
  ///
  /// In en, this message translates to:
  /// **'Your session is unavailable or expired. Sign out and start again.'**
  String get sessionError;

  /// No description provided for @policyChangedError.
  ///
  /// In en, this message translates to:
  /// **'The policy has changed. Sign out and start again to read the current version.'**
  String get policyChangedError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t save these choices. Review your selections and try again.'**
  String get validationError;

  /// No description provided for @serviceError.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Please try again shortly.'**
  String get serviceError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @actionError.
  ///
  /// In en, this message translates to:
  /// **'We could not complete this action. Check your connection, refresh, and try again.'**
  String get actionError;

  /// No description provided for @demoCheckNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a usability demonstration only. The response total is technical and has no psychological or diagnostic meaning.'**
  String get demoCheckNotice;

  /// No description provided for @clinicalToolsPending.
  ///
  /// In en, this message translates to:
  /// **'Clinical instruments such as HADS and PSS remain disabled until licensing and institution approval are complete.'**
  String get clinicalToolsPending;

  /// No description provided for @noInstruments.
  ///
  /// In en, this message translates to:
  /// **'No instrument is enabled'**
  String get noInstruments;

  /// No description provided for @startCheck.
  ///
  /// In en, this message translates to:
  /// **'Start demonstration'**
  String get startCheck;

  /// No description provided for @demoLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo · synthetic data'**
  String get demoLabel;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submitCheck.
  ///
  /// In en, this message translates to:
  /// **'Submit and view result'**
  String get submitCheck;

  /// No description provided for @answersSavedOnServer.
  ///
  /// In en, this message translates to:
  /// **'Each answer is saved when the server confirms it. Resume this session from your history.'**
  String get answersSavedOnServer;

  /// No description provided for @pauseCheck.
  ///
  /// In en, this message translates to:
  /// **'Pause and resume later'**
  String get pauseCheck;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Demonstration complete'**
  String get resultTitle;

  /// No description provided for @technicalTotal.
  ///
  /// In en, this message translates to:
  /// **'Technical total: {score} of {max}'**
  String technicalTotal(int score, int max);

  /// No description provided for @ruleVersion.
  ///
  /// In en, this message translates to:
  /// **'Rule version: {version}'**
  String ruleVersion(String version);

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'Your history starts here'**
  String get noHistory;

  /// No description provided for @noHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Start a session from THRIVE Check. Your progress and demonstration results will appear here.'**
  String get noHistoryBody;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get viewResult;

  /// No description provided for @resumeCheck.
  ///
  /// In en, this message translates to:
  /// **'Resume session'**
  String get resumeCheck;

  /// No description provided for @offlineGuides.
  ///
  /// In en, this message translates to:
  /// **'Showing your saved offline copies. Check content versions when you reconnect.'**
  String get offlineGuides;

  /// No description provided for @searchGuides.
  ///
  /// In en, this message translates to:
  /// **'Search resources'**
  String get searchGuides;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @savedGuidesOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved resources only'**
  String get savedGuidesOnly;

  /// No description provided for @noResources.
  ///
  /// In en, this message translates to:
  /// **'No matching resources'**
  String get noResources;

  /// No description provided for @noResourcesBody.
  ///
  /// In en, this message translates to:
  /// **'Try another search or clear your filters. Only published resources are shown.'**
  String get noResourcesBody;

  /// No description provided for @readResource.
  ///
  /// In en, this message translates to:
  /// **'Read resource'**
  String get readResource;

  /// No description provided for @demoResourceNotice.
  ///
  /// In en, this message translates to:
  /// **'Development content explaining how to use the app. It is not treatment or approved clinical guidance.'**
  String get demoResourceNotice;

  /// No description provided for @resourceSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String resourceSource(String source);

  /// No description provided for @reviewPending.
  ///
  /// In en, this message translates to:
  /// **'No approved clinical review is recorded for this content.'**
  String get reviewPending;

  /// No description provided for @reviewDate.
  ///
  /// In en, this message translates to:
  /// **'Reviewed: {date}'**
  String reviewDate(String date);

  /// No description provided for @contentVersion.
  ///
  /// In en, this message translates to:
  /// **'Content version: {version}'**
  String contentVersion(String version);

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove saved copy'**
  String get removeDownload;

  /// No description provided for @downloadGuide.
  ///
  /// In en, this message translates to:
  /// **'Save for offline reading'**
  String get downloadGuide;

  /// No description provided for @directoryIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a service and review its details before requesting support. Sharing minimum necessary information requires your consent.'**
  String get directoryIntro;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No service is currently available'**
  String get noServices;

  /// No description provided for @noServicesBody.
  ///
  /// In en, this message translates to:
  /// **'Verified services will appear when enabled by the university. Urgent help remains available.'**
  String get noServicesBody;

  /// No description provided for @verifiedService.
  ///
  /// In en, this message translates to:
  /// **'Verified service'**
  String get verifiedService;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service details'**
  String get serviceDetails;

  /// No description provided for @demoServiceNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a simulated service for testing referrals inside the system. Requests do not reach a healthcare provider or book real appointments.'**
  String get demoServiceNotice;

  /// No description provided for @serviceHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get serviceHours;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get serviceLocation;

  /// No description provided for @bookingMethod.
  ///
  /// In en, this message translates to:
  /// **'Request and booking process'**
  String get bookingMethod;

  /// No description provided for @shareReferralConsent.
  ///
  /// In en, this message translates to:
  /// **'I consent to sharing the minimum necessary information with this referral service.'**
  String get shareReferralConsent;

  /// No description provided for @requestReferral.
  ///
  /// In en, this message translates to:
  /// **'Request referral'**
  String get requestReferral;

  /// No description provided for @referralSent.
  ///
  /// In en, this message translates to:
  /// **'Your referral request was created. Track it in My referrals; creation does not mean completion or a confirmed appointment.'**
  String get referralSent;

  /// No description provided for @referralAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'You already have an open request for this service. Check My referrals before sending another.'**
  String get referralAlreadyOpen;

  /// No description provided for @referralRequestBoundary.
  ///
  /// In en, this message translates to:
  /// **'Referral status is updated by authorized staff. Decisions remain with you and the qualified professional.'**
  String get referralRequestBoundary;

  /// No description provided for @myReferrals.
  ///
  /// In en, this message translates to:
  /// **'My referrals'**
  String get myReferrals;

  /// No description provided for @noReferrals.
  ///
  /// In en, this message translates to:
  /// **'No referral requests yet'**
  String get noReferrals;

  /// No description provided for @noReferralsBody.
  ///
  /// In en, this message translates to:
  /// **'Explore support options through THRIVE Connect or THRIVE Plus.'**
  String get noReferralsBody;

  /// No description provided for @cancelReferral.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelReferral;

  /// No description provided for @cancelReferralConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this request? You can create another request later.'**
  String get cancelReferralConfirm;

  /// No description provided for @keepReferral.
  ///
  /// In en, this message translates to:
  /// **'Keep request'**
  String get keepReferral;

  /// No description provided for @referralRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get referralRequested;

  /// No description provided for @referralReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get referralReceived;

  /// No description provided for @referralScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get referralScheduled;

  /// No description provided for @referralCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get referralCompleted;

  /// No description provided for @referralDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get referralDeclined;

  /// No description provided for @referralCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get referralCancelled;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account and choices'**
  String get accountTitle;

  /// No description provided for @consentSettings.
  ///
  /// In en, this message translates to:
  /// **'Consent settings'**
  String get consentSettings;

  /// No description provided for @withdrawConsent.
  ///
  /// In en, this message translates to:
  /// **'Withdraw service consent'**
  String get withdrawConsent;

  /// No description provided for @withdrawConsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal stops access to service features and withdraws research consent too. Decision records remain under the applicable retention policy.'**
  String get withdrawConsentConfirm;

  /// No description provided for @confirmWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get confirmWithdraw;

  /// No description provided for @accountPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your current session is memory-only. Answers, results and sign-in tokens are not stored on your device. You may explicitly save published resources for offline reading.'**
  String get accountPrivacy;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @navReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get navReferrals;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @openPath.
  ///
  /// In en, this message translates to:
  /// **'Open pathway'**
  String get openPath;

  /// No description provided for @historyReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Open History to view completed sessions or resume a saved session.'**
  String get historyReadyBody;

  /// No description provided for @openSavedGuides.
  ///
  /// In en, this message translates to:
  /// **'Read saved resources offline'**
  String get openSavedGuides;

  /// No description provided for @openNamedPath.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String openNamedPath(String title);

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @policyDraftNotice.
  ///
  /// In en, this message translates to:
  /// **'Development information, not an approved launch policy. The university must approve the final text before collecting real student data.'**
  String get policyDraftNotice;

  /// No description provided for @dataCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'What data does the app use?'**
  String get dataCollectedTitle;

  /// No description provided for @dataCollectedBody.
  ///
  /// In en, this message translates to:
  /// **'The server uses account and university identifiers, consent decisions and policy version, session answers and results, and referral records. Daily feeling entries are optional. Downloaded resources do not require personal notes.'**
  String get dataCollectedBody;

  /// No description provided for @dataPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Why is this data used?'**
  String get dataPurposeTitle;

  /// No description provided for @dataPurposeBody.
  ///
  /// In en, this message translates to:
  /// **'To provide the service, save progress and history, track support requests, enforce access rights, and audit operations. Research participation is separate and refusing it does not block service. Daily feelings are not used to calculate diagnosis or risk.'**
  String get dataPurposeBody;

  /// No description provided for @dataSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Access and sharing'**
  String get dataSharingTitle;

  /// No description provided for @dataSharingBody.
  ///
  /// In en, this message translates to:
  /// **'Student records are scoped to their identity and university. Administration shows directories, referral status, and aggregates without individual answers. Referrals require separate sharing consent. The current preview does not deliver referrals to external providers.'**
  String get dataSharingBody;

  /// No description provided for @dataChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices and retention'**
  String get dataChoicesTitle;

  /// No description provided for @dataChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'You can change research consent, withdraw service consent, and remove today\'s feeling. Withdrawal does not automatically delete prior records. Retention periods, deletion requests, and the official contact await university policy. Tokens, answers, and results are not stored locally; only published public resources can be downloaded.'**
  String get dataChoicesBody;

  /// No description provided for @serviceScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Service limits'**
  String get serviceScopeTitle;

  /// No description provided for @serviceScopeBody.
  ///
  /// In en, this message translates to:
  /// **'THRIVE supports screening, referral, and education. It does not diagnose, treat, provide emergency response, or continuously monitor users. Medical decisions remain with licensed professionals. Help remains accessible without completing a questionnaire.'**
  String get serviceScopeBody;

  /// No description provided for @demoUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the development preview'**
  String get demoUseTitle;

  /// No description provided for @demoUseBody.
  ///
  /// In en, this message translates to:
  /// **'Accounts, questions, and services labeled demo test the product. They do not produce a real psychological result or confirm a care appointment. Resource sources, versions, and review status are displayed explicitly.'**
  String get demoUseBody;

  /// No description provided for @contactPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Official information and help'**
  String get contactPolicyTitle;

  /// No description provided for @contactPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'University services, professionals, and help contacts become operational only after verification and approval. Help is always accessible. Check the displayed contact status and do not rely on the preview for emergency response.'**
  String get contactPolicyBody;

  /// No description provided for @humanSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach human support'**
  String get humanSupportTitle;

  /// No description provided for @humanSupportBody.
  ///
  /// In en, this message translates to:
  /// **'If you want additional support, explore university counseling or specialist services. The decision remains with you and a professional; these links do not depend on the demonstration total.'**
  String get humanSupportBody;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get activityTitle;

  /// No description provided for @activityCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get activityCompleted;

  /// No description provided for @activityOpenReferrals.
  ///
  /// In en, this message translates to:
  /// **'Open support requests'**
  String get activityOpenReferrals;

  /// No description provided for @dailyMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today? Optional'**
  String get dailyMoodTitle;

  /// No description provided for @dailyMoodNotice.
  ///
  /// In en, this message translates to:
  /// **'A personal entry you can change or remove. It is not screening, diagnosis, or a risk assessment and does not affect access to support.'**
  String get dailyMoodNotice;

  /// No description provided for @moodVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very difficult'**
  String get moodVeryLow;

  /// No description provided for @moodLow.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get moodLow;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get moodVeryGood;

  /// No description provided for @removeTodayMood.
  ///
  /// In en, this message translates to:
  /// **'Remove today\'s entry'**
  String get removeTodayMood;

  /// No description provided for @moodWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feelings over the past seven days'**
  String get moodWeekTitle;

  /// No description provided for @moodNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get moodNotRecorded;

  /// No description provided for @emergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact emergency services'**
  String get emergencyContactTitle;

  /// No description provided for @emergencyContactPending.
  ///
  /// In en, this message translates to:
  /// **'An approved emergency contact is not configured in this preview. A call action cannot be offered until the service and number are verified.'**
  String get emergencyContactPending;

  /// No description provided for @universityHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'University support and human assistance'**
  String get universityHelpTitle;

  /// No description provided for @universityHelpPending.
  ///
  /// In en, this message translates to:
  /// **'The university support channel and response hours await verification. No team monitors this preview or receives an emergency request from it.'**
  String get universityHelpPending;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Requires verification'**
  String get verificationRequired;

  /// No description provided for @safePlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe place'**
  String get safePlaceTitle;

  /// No description provided for @safePlaceBody.
  ///
  /// In en, this message translates to:
  /// **'If possible, move to a safe place and ask someone you trust to stay with you until you receive direct help.'**
  String get safePlaceBody;

  /// No description provided for @activitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved steps, all in one place.'**
  String get activitySubtitle;

  /// No description provided for @moodChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feelings over time'**
  String get moodChartTitle;

  /// No description provided for @moodChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your own check-ins, without judgement or clinical interpretation.'**
  String get moodChartSubtitle;

  /// No description provided for @moodChartRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} days recorded'**
  String moodChartRecorded(int count, int total);

  /// No description provided for @moodChartLegend.
  ///
  /// In en, this message translates to:
  /// **'Recorded feeling'**
  String get moodChartLegend;

  /// No description provided for @moodChartGapNotice.
  ///
  /// In en, this message translates to:
  /// **'The 1–5 scale reflects your own choice. Gaps are unrecorded days, not zero values.'**
  String get moodChartGapNotice;

  /// No description provided for @moodChartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first point starts with you'**
  String get moodChartEmptyTitle;

  /// No description provided for @moodChartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'If you wish, record your feeling today to see it here. Earlier days stay empty.'**
  String get moodChartEmptyBody;

  /// No description provided for @chartSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get chartSevenDays;

  /// No description provided for @chartThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get chartThirtyDays;

  /// No description provided for @historyOverview.
  ///
  /// In en, this message translates to:
  /// **'Your journey so far'**
  String get historyOverview;

  /// No description provided for @historyOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'Saved sessions you can return to at any time.'**
  String get historyOverviewBody;

  /// No description provided for @historySessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved sessions'**
  String historySessionCount(int count);

  /// No description provided for @directoryAllSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get directoryAllSpecialties;

  /// No description provided for @specialtyPsychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get specialtyPsychology;

  /// No description provided for @specialtyPsychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry'**
  String get specialtyPsychiatry;

  /// No description provided for @specialtyGeneral.
  ///
  /// In en, this message translates to:
  /// **'General support'**
  String get specialtyGeneral;

  /// No description provided for @serviceSource.
  ///
  /// In en, this message translates to:
  /// **'Directory source'**
  String get serviceSource;

  /// No description provided for @serviceSourceMissing.
  ///
  /// In en, this message translates to:
  /// **'No verified source has been added'**
  String get serviceSourceMissing;

  /// No description provided for @serviceUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified directory entry'**
  String get serviceUnverified;

  /// No description provided for @servicePhone.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get servicePhone;

  /// No description provided for @serviceEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get serviceEmail;

  /// No description provided for @serviceWebsite.
  ///
  /// In en, this message translates to:
  /// **'Provider website'**
  String get serviceWebsite;

  /// No description provided for @serviceContactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This contact method could not be opened on this device'**
  String get serviceContactUnavailable;

  /// No description provided for @serviceContactBoundary.
  ///
  /// In en, this message translates to:
  /// **'Contact opens another app and does not automatically share screening results.'**
  String get serviceContactBoundary;

  /// No description provided for @directorySpecialistIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a support specialty and review the service before requesting a referral.'**
  String get directorySpecialistIntro;

  /// No description provided for @serviceRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next step'**
  String get serviceRequestTitle;

  /// No description provided for @serviceBookingInternal.
  ///
  /// In en, this message translates to:
  /// **'In-app referral request'**
  String get serviceBookingInternal;

  /// No description provided for @guideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'A little space for yourself'**
  String get guideEyebrow;

  /// No description provided for @topicStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get topicStress;

  /// No description provided for @topicExams.
  ///
  /// In en, this message translates to:
  /// **'Exam worries'**
  String get topicExams;

  /// No description provided for @topicSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep & rest'**
  String get topicSleep;

  /// No description provided for @topicTime.
  ///
  /// In en, this message translates to:
  /// **'Time planning'**
  String get topicTime;

  /// No description provided for @topicBreathing.
  ///
  /// In en, this message translates to:
  /// **'Gentle breathing'**
  String get topicBreathing;

  /// No description provided for @topicGrounding.
  ///
  /// In en, this message translates to:
  /// **'Grounding'**
  String get topicGrounding;

  /// No description provided for @topicProduct.
  ///
  /// In en, this message translates to:
  /// **'Using THRIVE'**
  String get topicProduct;

  /// No description provided for @draftEducationNotice.
  ///
  /// In en, this message translates to:
  /// **'Educational drafts based on public sources, pending university specialist review. These are not treatment or clinically approved materials.'**
  String get draftEducationNotice;

  /// No description provided for @openOriginalSource.
  ///
  /// In en, this message translates to:
  /// **'Original source'**
  String get openOriginalSource;

  /// No description provided for @breathingPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'A space to breathe'**
  String get breathingPracticeTitle;

  /// No description provided for @breathingPracticeBody.
  ///
  /// In en, this message translates to:
  /// **'Follow the rhythm if comfortable, or stop whenever you like.'**
  String get breathingPracticeBody;

  /// No description provided for @breatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in gently'**
  String get breatheIn;

  /// No description provided for @breatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out gently'**
  String get breatheOut;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get startPractice;

  /// No description provided for @pausePractice.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pausePractice;

  /// No description provided for @resetPractice.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetPractice;

  /// No description provided for @practiceReady.
  ///
  /// In en, this message translates to:
  /// **'At your own pace'**
  String get practiceReady;

  /// No description provided for @practiceComplete.
  ///
  /// In en, this message translates to:
  /// **'Time complete. Take your time.'**
  String get practiceComplete;

  /// No description provided for @resumeJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get resumeJourneyTitle;

  /// No description provided for @pastSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your previous check-ins'**
  String get pastSessionsTitle;

  /// No description provided for @accountIntro.
  ///
  /// In en, this message translates to:
  /// **'Your space. Your choices.'**
  String get accountIntro;

  /// No description provided for @referralsIntro.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your support requests and the next step.'**
  String get referralsIntro;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
