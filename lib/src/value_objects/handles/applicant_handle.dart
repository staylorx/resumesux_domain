import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// An [ApplicantHandle] paired with the [Applicant] it references.
class ApplicantWithHandle {
  /// The applicant's handle.
  final ApplicantHandle handle;

  /// The applicant referenced by [handle].
  final Applicant applicant;

  /// Creates an [ApplicantWithHandle] for the given handle and applicant.
  ApplicantWithHandle({required this.handle, required this.applicant});
}

/// An immutable identifier for an applicant.
class ApplicantHandle with EquatableMixin {
  /// The raw handle value.
  final String value;

  /// Creates an [ApplicantHandle] wrapping the given value.
  const ApplicantHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
