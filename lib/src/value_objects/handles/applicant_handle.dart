import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class ApplicantWithHandle {
  final ApplicantHandle handle;
  final Applicant applicant;
  ApplicantWithHandle({required this.handle, required this.applicant});
}

class ApplicantHandle with EquatableMixin {
  final String value;

  const ApplicantHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
