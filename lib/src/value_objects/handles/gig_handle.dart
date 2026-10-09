import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// A [GigHandle] paired with the [Gig] it references.
class GigWithHandle {
  /// The gig's handle.
  final GigHandle handle;

  /// The gig referenced by [handle].
  final Gig gig;

  /// Creates a [GigWithHandle] for the given handle and gig.
  GigWithHandle({required this.handle, required this.gig});
}

/// An immutable identifier for a gig.
class GigHandle with EquatableMixin {
  /// The raw handle value.
  final String value;

  /// Creates a [GigHandle] wrapping the given value.
  const GigHandle(this.value);

  @override
  String toString() => value; // CLI-friendly output

  @override
  List<Object?> get props => [value];
}
