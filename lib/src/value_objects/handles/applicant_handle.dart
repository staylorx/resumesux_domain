// domain/value_objects/task_handle.dart - Domain-opaque handle

import 'package:equatable/equatable.dart';

class ApplicantHandle with EquatableMixin {
  final String value;

  const ApplicantHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
