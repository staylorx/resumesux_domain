import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class GigWithHandle {
  final GigHandle handle;
  final Gig gig;
  GigWithHandle({required this.handle, required this.gig});
}

class GigHandle with EquatableMixin {
  final String value;

  const GigHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
