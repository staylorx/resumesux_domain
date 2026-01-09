import 'package:equatable/equatable.dart';

/// Represents a tag with a name.
class Tag with EquatableMixin {
  final String name;

  Tag({required this.name});

  Tag copyWith({String? name}) {
    return Tag(name: name ?? this.name);
  }

  @override
  List<Object> get props => [name];
}

/// Mixin that provides tagging functionality.
mixin Taggable {
  late final List<Tag> tags;

  /// Adds a tag to the collection.
  void addTag({required Tag tag}) {
    tags.add(tag);
  }

  /// Removes a tag from the collection.
  void removeTag({required Tag tag}) {
    tags.remove(tag);
  }
}
