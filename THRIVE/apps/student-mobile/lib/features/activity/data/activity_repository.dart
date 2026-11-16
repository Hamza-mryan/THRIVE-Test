import '../../../core/network/thrive_api.dart';

String diaryDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class MoodEntry {
  const MoodEntry(this.day, this.value);
  final DateTime day;
  final int value;
  factory MoodEntry.fromJson(Map<String, dynamic> json) =>
      MoodEntry(DateTime.parse(json['day'] as String), json['value'] as int);
}

class StudentActivityData {
  const StudentActivityData(
    this.completed,
    this.inProgress,
    this.openReferrals,
    this.moods,
  );
  final int completed;
  final int inProgress;
  final int openReferrals;
  final List<MoodEntry> moods;
}

class ActivityRepository {
  ActivityRepository(this.api, {DateTime Function()? clock})
    : now = clock ?? DateTime.now;
  final ThriveApi api;
  final DateTime Function() now;

  Future<StudentActivityData> current() async {
    final today = now();
    final values = await Future.wait([
      api.request('GET', '/api/v1/me/activity'),
      api.request(
        'GET',
        '/api/v1/me/moods?from=${diaryDay(DateTime(today.year, today.month, today.day - 29))}&to=${diaryDay(today)}',
      ),
    ]);
    final summary = values[0] as Map<String, dynamic>;
    return StudentActivityData(
      summary['completedScreenings'] as int,
      summary['inProgressScreenings'] as int,
      summary['openReferrals'] as int,
      (values[1] as List)
          .map((value) => MoodEntry.fromJson(value as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> save(int value) => api.request(
    'PUT',
    '/api/v1/me/moods/${diaryDay(now())}',
    body: {'value': value},
  );
  Future<void> removeToday() =>
      api.request('DELETE', '/api/v1/me/moods/${diaryDay(now())}');
}
