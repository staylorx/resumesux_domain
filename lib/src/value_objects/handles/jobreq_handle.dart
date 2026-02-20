import 'package:equatable/equatable.dart';

class JobReqHandle with EquatableMixin {
  final String value;

  const JobReqHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
