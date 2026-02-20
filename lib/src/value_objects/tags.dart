import 'package:equatable/equatable.dart';

/// Represents a collection of tags as an immutable set of strings.
class Tags with EquatableMixin {
  final Set<String> values;

  const Tags(this.values);

  /// Creates an empty Tags instance.
  const Tags.empty() : values = const {};

  /// Creates a Tags instance from a list of strings, removing duplicates.
  factory Tags.fromList(List<String> list) => Tags(Set.from(list));

  /// Adds a tag to the collection.
  Tags add(String tag) => Tags(Set.from(values)..add(tag));

  /// Removes a tag from the collection.
  Tags remove(String tag) => Tags(Set.from(values)..remove(tag));

  /// Checks if the collection contains a specific tag.
  bool contains(String tag) => values.contains(tag);

  /// Returns the number of tags.
  int get length => values.length;

  /// Checks if the collection is empty.
  bool get isEmpty => values.isEmpty;

  /// Checks if the collection is not empty.
  bool get isNotEmpty => values.isNotEmpty;

  Tags copyWith({Set<String>? values}) {
    return Tags(values ?? this.values);
  }

  @override
  List<Object> get props => [values];
}
