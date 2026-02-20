import 'package:equatable/equatable.dart';
import 'tag.dart';

// TODO, what to do with skills, which could be considered "smart" tags? But we want to connect a skill
// to a particular gig.

// So an asset would be a chunk of text, so a degree might be a chunk of text describing the degree, and
// it would have a tag of type education associated with it. A license or certification would be another chunk of text,
// with a tag of type license or certification associated with it.

// One of things we're _not_ doing here is trying to collect a list of every possible school,
// or degree-granting institution, or license/certification authority.

/// Represents an asset (license, certification, education, etc.) containing content and optional associated tags.
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
