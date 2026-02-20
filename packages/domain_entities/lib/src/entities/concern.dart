import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a concern, which can be a company, school, organization, or any entity
/// where a gig occurred or a job requirement is for.
class Concern with EquatableMixin, Taggable {
  final String name;
  final String? description;
  final String? location;

  Concern({
    required this.name,
    this.description,
    this.location,
    List<Tag>? tags,
  }) {
    this.tags = tags ?? [];
  }

  Concern copyWith({
    String? name,
    String? description,
    String? location,
    List<Tag>? tags,
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
