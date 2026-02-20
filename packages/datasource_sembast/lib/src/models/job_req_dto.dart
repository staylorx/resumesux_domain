import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/src/domain/entities/job_req.dart';
import 'package:resumesux_domain/src/domain/entities/concern.dart';

/// Data Transfer Object for JobReq, matching the Sembast storage format.
class JobReqDto with EquatableMixin {
  final String id;
  final String title;
  final String content;
  final String? salary;
  final String? location;
  final Map<String, dynamic>? concern;
  final String? createdDate;
  final String? whereFound;

  const JobReqDto({
    required this.id,
    required this.title,
    required this.content,
    this.salary,
    this.location,
    this.concern,
    this.createdDate,
    this.whereFound,
  });

  /// Creates a JobReqDto from a Map (e.g., from Sembast).
  factory JobReqDto.fromMap(Map<String, dynamic> map) {
    return JobReqDto(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      salary: map['salary'] as String?,
      location: map['location'] as String?,
      concern: map['concern'] as Map<String, dynamic>?,
      createdDate: map['createdDate'] as String?,
      whereFound: map['whereFound'] as String?,
    );
  }

  /// Converts the JobReqDto to a Map for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'salary': salary,
      'location': location,
      'concern': concern,
      'createdDate': createdDate,
      'whereFound': whereFound,
    };
  }

  /// Converts to domain entity.
  JobReq toDomain() {
    return JobReq(
      title: title,
      content: content,
      salary: salary,
      location: location,
      concern: concern != null
          ? Concern(
              name: concern!['name'] as String? ?? 'Unknown',
              description: concern!['description'] as String?,
              location: concern!['location'] as String?,
            )
          : null,
      createdDate: createdDate != null ? DateTime.parse(createdDate!) : null,
      whereFound: whereFound,
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
    createdDate,
    whereFound,
  ];
}
