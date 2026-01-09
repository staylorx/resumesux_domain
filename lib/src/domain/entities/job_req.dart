import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a job requirement or job posting.
class JobReq with EquatableMixin {
  final String id;
  final String title;
  final String content;
  final String? salary;
  final String? location;
  final Concern? concern;
  final String state;
  final DateTime? createdDate;
  final String? whereFound;

  const JobReq({
    required this.id,
    required this.title,
    required this.content,
    this.salary,
    this.location,
    this.concern,
    this.state = 'raw',
    this.createdDate,
    this.whereFound,
  });

  JobReq copyWith({
    String? id,
    String? title,
    String? content,
    String? salary,
    String? location,
    Concern? concern,
    String? state,
    DateTime? createdDate,
    String? whereFound,
  }) {
    return JobReq(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      salary: salary ?? this.salary,
      location: location ?? this.location,
      concern: concern ?? this.concern,
      state: state ?? this.state,
      createdDate: createdDate ?? this.createdDate,
      whereFound: whereFound ?? this.whereFound,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    salary,
    location,
    concern,
    state,
    createdDate,
    whereFound,
  ];
}
