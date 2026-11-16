import '../core/network/thrive_api.dart';
import '../features/account/data/account_repository.dart';
import '../features/guide/data/guide_repository.dart';
import '../features/referrals/data/referral_repository.dart';
import '../features/screening/data/screening_repository.dart';
import '../features/activity/data/activity_repository.dart';

/// Composition stays here; feature screens depend on focused repositories.
class StudentServices {
  StudentServices(ThriveApi api)
    : screening = ScreeningRepository(api),
      guide = GuideRepository(api, PreferenceGuideCache()),
      referrals = ReferralRepository(api),
      account = AccountRepository(api),
      activity = ActivityRepository(api);

  final ScreeningRepository screening;
  final GuideRepository guide;
  final ReferralRepository referrals;
  final AccountRepository account;
  final ActivityRepository activity;
}
