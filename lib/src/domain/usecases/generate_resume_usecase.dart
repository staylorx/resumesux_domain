import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

/// Use case for generating a resume.
class GenerateResumeUsecase {
  final DigestRepository digestRepository;
  final AiService aiService;

  /// Creates a new instance of [GenerateResumeUsecase].
  GenerateResumeUsecase({
    required this.digestRepository,
    required this.aiService,
  });

  /// Generates a resume for the given job requirement and applicant.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The base prompt for AI generation.
  ///
  /// Returns: [Either<Failure, Resume>] the generated resume or a failure.
  Future<Either<Failure, Resume>> call({
    required JobReq jobReq,
    required Applicant applicant,
    required String prompt,
  }) async {
    logger.info('[GenerateResumeUsecase] Generating resume');

    final digestResult = await digestRepository.getAllDigests();
    if (digestResult.isLeft()) {
      return Left(digestResult.getLeft().toNullable()!);
    }

    final digests = digestResult.getOrElse((failure) => []);
    if (digests.isEmpty) {
      return Left(ValidationFailure(message: 'No digest found'));
    }

    final digest = digests.first;

    final fullPrompt = _buildResumePrompt(
      jobReq: jobReq.content,
      gigs: digest.gigsContent,
      assets: digest.assetsContent,
      customPrompt: prompt,
      applicant: applicant,
    );

    final result = await aiService.generateContent(prompt: fullPrompt);
    return result.map((content) {
      logger.fine(
        '[GenerateResumeUsecase] Resume content length: ${content.length}',
      );
      return Resume(content: content);
    });
  }

  String _buildResumePrompt({
    required String jobReq,
    required List<String> gigs,
    required List<String> assets,
    required String customPrompt,
    required Applicant applicant,
  }) {
    final header = _buildApplicantHeader(applicant);
    return '''
$header

Generate an ATS-optimized resume. $customPrompt

Job Requirements:
$jobReq

Work Experience (Gigs):
${gigs.join('\n\n')}

Assets (Education, Skills, etc.):
${assets.join('\n\n')}

Please generate a resume in markdown format optimized for ATS systems.
Do not halucinate any information. Use only the provided data.
Perform strict relevance checking before including any asset or gig. Only include items that are directly relevant to the job requirements. Omit any irrelevant or unrelated content entirely, such as non-tech certifications (e.g., pilot licenses) if the job is tech-focused.
Do not include any work experience or assets that are not directly related to or explicitly mentioned in the job requirements. Prioritize recent work experience (last 10 years) and modern technologies. Exclude any experiences or skills from before 2010 or legacy technologies like SOA, Oracle WebLogic, BPEL unless they are directly relevant to the job requirements. Limit the resume to 1-2 pages, focusing on 4-5 most relevant recent roles. Quantify achievements where possible and ensure focus on modern backend/API skills.
''';
  }

  String _buildApplicantHeader(Applicant applicant) {
    return '''
Applicant Information:
Name: {{ name }}
Preferred Name: {{ preferred_name }}
Email: {{ email }}
Phone: {{ phone }}
{% if address %}Address: {{ address.street1 }}{% if address.street2 %}, {{ address.street2 }}{% endif %}, {{ address.city }}, {{ address.state }} {{ address.zip }}
{% endif %}LinkedIn: {{ linkedin }}
GitHub: {{ github }}
Portfolio: {{ portfolio }}
''';
  }
}
