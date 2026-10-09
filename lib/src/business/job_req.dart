import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a job requirement or job posting.
class JobReq extends Document with EquatableMixin {
  /// The title of the job.
  final String title;

  /// The advertised salary, as free text.
  final String? salary;

  /// The location of the job.
  final String? location;

  /// The concern (company or organization) posting the job.
  final Concern? concern;

  /// When the job was created or posted.
  final DateTime? createdDate;

  /// Where the job posting was found.
  final String? whereFound;

  /// Constructs a [JobReq] with the given details.
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
