import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class JobReqWithHandle {
  final JobReqHandle handle;
  final JobReq jobReq;
  JobReqWithHandle({required this.handle, required this.jobReq});
}

class JobReqHandle with EquatableMixin {
  final String value;

  const JobReqHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
