import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class ApplicationWithHandle {
  final ApplicationHandle handle;
  final Application application;
  ApplicationWithHandle({required this.handle, required this.application});
}

class ApplicationHandle with EquatableMixin {
  final String value;

  const ApplicationHandle(this.value);

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
