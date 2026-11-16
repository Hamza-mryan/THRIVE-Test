import '../../../core/network/thrive_api.dart';

class AnswerOption {
  const AnswerOption(this.value, this.labelAr, this.labelEn);
  final int value;
  final String labelAr;
  final String labelEn;
  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
    json['value'] as int,
    json['labelAr'] as String,
    json['labelEn'] as String,
  );
}

class InstrumentItem {
  const InstrumentItem(this.code, this.promptAr, this.promptEn, this.options);
  final String code;
  final String promptAr;
  final String promptEn;
  final List<AnswerOption> options;
  factory InstrumentItem.fromJson(Map<String, dynamic> json) => InstrumentItem(
    json['code'] as String,
    json['promptAr'] as String,
    json['promptEn'] as String,
    (json['options'] as List)
        .map((x) => AnswerOption.fromJson(x as Map<String, dynamic>))
        .toList(),
  );
}

class Instrument {
  const Instrument(
    this.code,
    this.titleAr,
    this.titleEn,
    this.version,
    this.isDemo,
    this.items,
  );
  final String code;
  final String titleAr;
  final String titleEn;
  final String version;
  final bool isDemo;
  final List<InstrumentItem> items;
  factory Instrument.fromJson(Map<String, dynamic> json) => Instrument(
    json['code'] as String,
    json['titleAr'] as String,
    json['titleEn'] as String,
    json['version'] as String,
    json['isDemo'] as bool,
    (json['items'] as List)
        .map((x) => InstrumentItem.fromJson(x as Map<String, dynamic>))
        .toList(),
  );
}

class ScreeningResult {
  const ScreeningResult({
    required this.sessionId,
    required this.rawScore,
    required this.maxScore,
    required this.reasonAr,
    required this.reasonEn,
    required this.ruleVersion,
    required this.createdAtUtc,
    required this.isDemo,
  });
  final String sessionId;
  final int rawScore;
  final int maxScore;
  final String reasonAr;
  final String reasonEn;
  final String ruleVersion;
  final DateTime createdAtUtc;
  final bool isDemo;
  factory ScreeningResult.fromJson(Map<String, dynamic> json) =>
      ScreeningResult(
        sessionId: json['sessionId'] as String,
        rawScore: json['rawScore'] as int,
        maxScore: json['maxScore'] as int,
        reasonAr: json['reasonAr'] as String,
        reasonEn: json['reasonEn'] as String,
        ruleVersion: json['ruleVersion'] as String,
        createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
        isDemo: json['isDemo'] as bool,
      );
}

class ScreeningSession {
  const ScreeningSession({
    required this.id,
    required this.instrumentCode,
    required this.status,
    required this.startedAtUtc,
    required this.answers,
    this.result,
  });
  final String id;
  final String instrumentCode;
  final String status;
  final DateTime startedAtUtc;
  final Map<String, int> answers;
  final ScreeningResult? result;
  bool get completed => status == 'Completed';
  factory ScreeningSession.fromJson(Map<String, dynamic> json) =>
      ScreeningSession(
        id: json['id'] as String,
        instrumentCode: json['instrumentCode'] as String,
        status: json['status'] as String,
        startedAtUtc: DateTime.parse(json['startedAtUtc'] as String),
        answers: {
          for (final answer in json['answers'] as List)
            (answer as Map<String, dynamic>)['itemCode'] as String:
                answer['value'] as int,
        },
        result: json['result'] == null
            ? null
            : ScreeningResult.fromJson(json['result'] as Map<String, dynamic>),
      );
}

class ScreeningRepository {
  ScreeningRepository(this.api);
  final ThriveApi api;
  Future<List<Instrument>> instruments() async =>
      (await api.request('GET', '/api/v1/instruments') as List)
          .map((x) => Instrument.fromJson(x as Map<String, dynamic>))
          .toList();
  Future<ScreeningSession> start(String code) async =>
      ScreeningSession.fromJson(
        await api.request(
          'POST',
          '/api/v1/screening/sessions',
          body: {'instrumentCode': code},
        ) as Map<String, dynamic>,
      );
  Future<ScreeningSession> session(String id) async =>
      ScreeningSession.fromJson(
        await api.request('GET', '/api/v1/screening/sessions/$id')
            as Map<String, dynamic>,
      );
  Future<ScreeningSession> answer(
    String id,
    String itemCode,
    int value,
  ) async => ScreeningSession.fromJson(
    await api.request(
      'PUT',
      '/api/v1/screening/sessions/$id/answers/${Uri.encodeComponent(itemCode)}',
      body: {'value': value},
    ) as Map<String, dynamic>,
  );
  Future<ScreeningResult> submit(String id) async => ScreeningResult.fromJson(
    await api.request('POST', '/api/v1/screening/sessions/$id/submit')
        as Map<String, dynamic>,
  );
  Future<List<ScreeningSession>> history() async =>
      (await api.request('GET', '/api/v1/me/screenings') as List)
          .map((x) => ScreeningSession.fromJson(x as Map<String, dynamic>))
          .toList();
}
