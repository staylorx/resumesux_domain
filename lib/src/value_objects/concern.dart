import 'package:equatable/equatable.dart';

import 'tags.dart';

/// Represents a concern, which can be a company, school, organization, or any entity
/// where a gig occurred or a job requirement is for.
class Concern with EquatableMixin {
  final String name;
  final String? description;
  final String? location;
  final Tags tags;
  Concern({required this.name, this.description, this.location, Tags? tags})
    : tags = tags ?? Tags.empty();

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
