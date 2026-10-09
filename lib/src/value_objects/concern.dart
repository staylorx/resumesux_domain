import 'package:equatable/equatable.dart';

import 'tags.dart';

/// Represents a concern, which can be a company, school, organization, or any entity
/// where a gig occurred or a job requirement is for.
class Concern with EquatableMixin {
  /// The concern's name.
  final String name;

  /// An optional free-form description.
  final String? description;

  /// An optional location associated with the concern.
  final String? location;

  /// Tags associated with the concern.
  final Tags tags;

  /// Creates a [Concern] with the given values.
  Concern({required this.name, this.description, this.location, Tags? tags})
    : tags = tags ?? Tags.empty();

  /// Returns a copy of this concern with the given fields replaced.
  Concern copyWith({
    String? name,
    String? description,
    String? location,
    Tags? tags,
  }) {
    return Concern(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [name, description, location, tags];
}
