import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a job requirement or job posting.
class JobReq extends Doc with EquatableMixin {
  final String title;
  final String? salary;
  final String? location;
  final Concern? concern;
  final DateTime? createdDate;
  final String? whereFound;

  JobReq({
    required this.title,
    required super.content,
    super.contentType = 'text/markdown',
    this.salary,
    this.location,
    this.concern,
    this.createdDate,
    this.whereFound,
  });

  @override
  JobReq copyWith({String? content, String? contentType}) {
    return JobReq(
      title: title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      salary: salary,
      location: location,
      concern: concern,
      createdDate: createdDate,
      whereFound: whereFound,
    );
  }

  @override
  List<Object?> get props => [
    title,
    content,
    contentType,
    salary,
    location,
    concern,
    createdDate,
    whereFound,
  ];
}
