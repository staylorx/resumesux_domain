import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// A [JobReqHandle] paired with the [JobReq] it references.
class JobReqWithHandle {
  /// The job requirement's handle.
  final JobReqHandle handle;

  /// The job requirement referenced by [handle].
  final JobReq jobReq;

  /// Creates a [JobReqWithHandle] for the given handle and job requirement.
  JobReqWithHandle({required this.handle, required this.jobReq});
}

/// An immutable identifier for a job requirement.
class JobReqHandle with EquatableMixin {
  /// The raw handle value.
  final String value;

  /// Creates a [JobReqHandle] wrapping the given value.
  const JobReqHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
