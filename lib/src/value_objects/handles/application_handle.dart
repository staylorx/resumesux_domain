import 'package:equatable/equatable.dart';

class ApplicationHandle with EquatableMixin {
  final String value;

  const ApplicationHandle(this.value);

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
