import 'package:equatable/equatable.dart';

class GigHandle with EquatableMixin {
  final String value;

  const GigHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
