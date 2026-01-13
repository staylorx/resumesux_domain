import 'package:equatable/equatable.dart';

import 'applicant.dart';
import 'cover_letter.dart';
import 'feedback.dart';
import 'job_req.dart';
import 'resume.dart';

/// Represents a complete job application including resume and optional cover letter and feedback,
/// and links to the applicant and job requirement.
/// Applications are saved to disk in a structured format, within an output directory
/// specified by the user, then in `<concern>/<job_title>/application_<timestamp>/*.md` files
class Application with EquatableMixin {
  final Applicant applicant;
  final JobReq jobReq;
  final Resume resume;
  final CoverLetter? coverLetter;
  final Feedback? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

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
