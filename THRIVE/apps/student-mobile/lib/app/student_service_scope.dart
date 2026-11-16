import 'package:flutter/widgets.dart';

import 'student_services.dart';

class StudentServiceScope extends InheritedWidget {
  const StudentServiceScope({
    required this.services,
    required super.child,
    super.key,
  });
  final StudentServices? services;
  static StudentServices? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<StudentServiceScope>()
      ?.services;
  @override
  bool updateShouldNotify(StudentServiceScope oldWidget) =>
      services != oldWidget.services;
}
