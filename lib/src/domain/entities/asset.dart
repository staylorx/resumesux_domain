import 'package:equatable/equatable.dart';
import 'tag.dart';

// TODO, what to do with skills, which are also tags? But we want to connect a skill
// to a particular gig.

/// Represents an asset containing content and optional associated tags.
class Asset with EquatableMixin, Taggable {
  final String content;

  Asset({List<Tag>? tags, required this.content}) {
    this.tags = tags ?? [];
  }

  Asset copyWith({List<Tag>? tags, String? content}) {
    return Asset(
      tags: tags != null ? List.from(tags) : List.from(this.tags),
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [tags, content];
}
