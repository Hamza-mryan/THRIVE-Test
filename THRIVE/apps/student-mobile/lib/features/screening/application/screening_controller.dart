import 'package:flutter/foundation.dart';

import '../data/screening_repository.dart';

class ScreeningController extends ChangeNotifier {
  ScreeningController({
    required this.repository,
    required this.instrument,
    required this.session,
  }) {
    final firstUnanswered = instrument.items.indexWhere(
      (item) => !session.answers.containsKey(item.code),
    );
    index = firstUnanswered < 0 ? 0 : firstUnanswered;
  }
  final ScreeningRepository repository;
  final Instrument instrument;
  ScreeningSession session;
  late int index;
  bool busy = false;
  Object? error;
  ScreeningResult? result;
  bool _disposed = false;
  InstrumentItem get item => instrument.items[index];
  int? get selected => session.answers[item.code];
  bool get allAnswered =>
      instrument.items.every((item) => session.answers.containsKey(item.code));

  Future<void> choose(int value) async {
    if (busy) return;
    await _run(
      () async =>
          session = await repository.answer(session.id, item.code, value),
    );
  }

  void move(int target) {
    if (busy || target < 0 || target >= instrument.items.length) return;
    index = target;
    error = null;
    notifyListeners();
  }

  Future<void> submit() async {
    if (busy || !allAnswered) return;
    await _run(() async => result = await repository.submit(session.id));
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = failure;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
