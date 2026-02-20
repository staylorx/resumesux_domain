import '../../domain/entities/applicant.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/job_req.dart';
import '../../domain/entities/resume.dart';

/// DTO for persisting Application data to Sembast.
class ApplicationDto {
  final String id;
  final String applicantId;
  final String jobReqId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationDto({
    required this.id,
    required this.applicantId,
    required this.jobReqId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Converts to a map for Sembast storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'applicantId': applicantId,
      'jobReqId': jobReqId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates from a map retrieved from Sembast.
  factory ApplicationDto.fromMap(Map<String, dynamic> map) {
    return ApplicationDto(
      id: map['id'] as String,
      applicantId: map['applicantId'] as String,
      jobReqId: map['jobReqId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Converts to domain entity.
  /// Note: This creates an Application with empty applicant and jobReq.
  /// The repository should load the actual applicant and jobReq separately.
  Application toDomain() {
    return Application(
      applicant: Applicant(name: '', email: ''), // Placeholder
      jobReq: JobReq(title: '', content: ''), // Placeholder
      resume: Resume(content: ''), // Placeholder
    );
  }
}
