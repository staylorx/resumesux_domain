import 'package:equatable/equatable.dart';

/// Represents a job requirement or job posting.
class JobReq with EquatableMixin {
  final String id;
  final String title;
  final String content;
  final bool processed;
  final DateTime? createdDate;
  final String? whereFound;

  const JobReq({
    required this.id,
    required this.title,
    required this.content,
    this.processed = false,
    this.createdDate,
    this.whereFound,
  });

  JobReq copyWith({
    String? id,
    String? title,
    String? content,
    bool? processed,
    DateTime? createdDate,
    String? whereFound,
  }) {
    return JobReq(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      processed: processed ?? this.processed,
      createdDate: createdDate ?? this.createdDate,
      whereFound: whereFound ?? this.whereFound,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    processed,
    createdDate,
    whereFound,
  ];
}
