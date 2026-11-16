import '../../../core/network/thrive_api.dart';

class SupportService {
  const SupportService({
    required this.id,
    required this.level,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.hoursAr,
    required this.hoursEn,
    required this.locationAr,
    required this.locationEn,
    required this.bookingMethod,
    required this.isDemo,
    required this.verified,
    this.contactUrl,
    this.phone,
    this.email,
    this.specialty,
    this.source,
  });
  final String id;
  final String level;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String hoursAr;
  final String hoursEn;
  final String locationAr;
  final String locationEn;
  final String bookingMethod;
  final bool isDemo;
  final bool verified;
  final String? contactUrl;
  final String? phone;
  final String? email;
  final String? specialty;
  final String? source;
  factory SupportService.fromJson(Map<String, dynamic> json) => SupportService(
    id: json['id'] as String,
    level: json['level'] as String,
    nameAr: json['nameAr'] as String,
    nameEn: json['nameEn'] as String,
    descriptionAr: json['descriptionAr'] as String,
    descriptionEn: json['descriptionEn'] as String,
    hoursAr: json['hoursAr'] as String,
    hoursEn: json['hoursEn'] as String,
    locationAr: json['locationAr'] as String,
    locationEn: json['locationEn'] as String,
    bookingMethod: json['bookingMethod'] as String,
    isDemo: json['isDemo'] as bool,
    verified: json['verified'] as bool,
    contactUrl: json['contactUrl'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    specialty: json['specialty'] as String?,
    source: json['source'] as String?,
  );
}

class Referral {
  const Referral({
    required this.id,
    required this.serviceNameAr,
    required this.serviceNameEn,
    required this.level,
    required this.status,
    required this.createdAtUtc,
    required this.isDemo,
  });
  final String id;
  final String serviceNameAr;
  final String serviceNameEn;
  final String level;
  final String status;
  final DateTime createdAtUtc;
  final bool isDemo;
  bool get canCancel =>
      const ['Requested', 'Received', 'Scheduled'].contains(status);
  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
    id: json['id'] as String,
    serviceNameAr: json['serviceNameAr'] as String,
    serviceNameEn: json['serviceNameEn'] as String,
    level: json['level'] as String,
    status: json['status'] as String,
    createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    isDemo: json['isDemo'] as bool,
  );
}

class ReferralRepository {
  ReferralRepository(this.api);
  final ThriveApi api;
  Future<List<SupportService>> services(String level) async =>
      (await api.request(
            'GET',
            '/api/v1/services?level=${Uri.encodeQueryComponent(level)}',
          ) as List)
          .map((x) => SupportService.fromJson(x as Map<String, dynamic>))
          .toList();
  Future<Referral> request(String serviceId) async => Referral.fromJson(
    await api.request(
      'POST',
      '/api/v1/referrals',
      body: {'serviceId': serviceId, 'shareConsent': true},
    ) as Map<String, dynamic>,
  );
  Future<List<Referral>> referrals() async =>
      (await api.request('GET', '/api/v1/me/referrals') as List)
          .map((x) => Referral.fromJson(x as Map<String, dynamic>))
          .toList();
  Future<Referral> cancel(String id) async => Referral.fromJson(
    await api.request('POST', '/api/v1/me/referrals/$id/cancel')
        as Map<String, dynamic>,
  );
}
