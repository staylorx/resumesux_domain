import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

// An asset would be a chunk of text, so a degree might be a chunk of text describing the degree, and
// it would have a tag of type education associated with it. A license or certification would be another chunk of text,
// with a tag of type license or certification associated with it.

// One of things we're _not_ doing here is trying to collect a list of every possible school,
// or degree-granting institution, or license/certification authority.

/// Represents an asset (license, certification, education, etc.) containing content and optional associated tags.
class Asset with EquatableMixin {
  final String content;
  final Tags tags;

  Asset({Tags? tags, required this.content}) : tags = tags ?? Tags.empty();

  Asset copyWith({Tags? tags, String? content}) {
    return Asset(tags: tags ?? this.tags, content: content ?? this.content);
  }

  @override
  List<Object?> get props => [tags, content];
}
