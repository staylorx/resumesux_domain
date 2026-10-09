import 'package:equatable/equatable.dart';

import 'applicant.dart';
import '../docs/cover_letter.dart';
import '../docs/feedback.dart';
import 'job_req.dart';
import '../docs/resume.dart';

/// Represents a complete job application including resume and optional cover letter and feedback,
/// and links to the applicant and job requirement.
/// Applications are saved to disk in a structured format, within an output directory
/// specified by the user, then in `<concern>/<job_title>/application_<timestamp>/*.md` files
class Application with EquatableMixin {
  /// The applicant the application belongs to.
  final Applicant applicant;

  /// The job requirement the application targets.
  final JobReq jobReq;

  /// The resume document included in the application.
  final Resume resume;

  /// An optional cover letter document, or null if not included.
  final CoverLetter? coverLetter;

  /// An optional feedback document, or null if not included.
  final Feedback? feedback;

  /// When the application was created.
  final DateTime createdAt;

  /// When the application was last updated.
  final DateTime updatedAt;

  /// Constructs an [Application]; timestamps default to the current time.
  Application({
    required this.applicant,
    required this.jobReq,
    required this.resume,
    this.coverLetter,
    this.feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Returns a copy of this [Application] with the given fields replaced.
  Application copyWith({
    Applicant? applicant,
    JobReq? jobReq,
    Resume? resume,
    CoverLetter? coverLetter,
    Feedback? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Application(
      applicant: applicant ?? this.applicant,
      jobReq: jobReq ?? this.jobReq,
      resume: resume ?? this.resume,
      coverLetter: coverLetter ?? this.coverLetter,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    applicant,
    jobReq,
    resume,
    coverLetter,
    feedback,
    createdAt,
    updatedAt,
  ];
}
