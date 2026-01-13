import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a resume.
class GenerateResumeUsecase {
  final Logger logger = LoggerFactory.create(name: 'GenerateResumeUsecase');
  final DigestRepository digestRepository;
  final AiService aiService;
  final ResumeRepository? resumeRepository;

  /// Creates a new instance of [GenerateResumeUsecase].
  GenerateResumeUsecase({
    required this.digestRepository,
    required this.aiService,
    this.resumeRepository,
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
    logger.info('Generating resume');

    final digestResult = await digestRepository.getAllDigests();
    if (digestResult.isLeft()) {
      logger.severe(
        'Failed to get digests: ${digestResult.getLeft().toNullable()!.message}',
      );
      return Left(digestResult.getLeft().toNullable()!);
    }

    final digests = digestResult.getOrElse((failure) => []);
    if (digests.isEmpty) {
      logger.severe('No digests found');
      return Left(ValidationFailure(message: 'No digest found'));
    }

    final digest = digests.first;
    logger.info(
      'Using digest with ${digest.gigsContent.length} gigs and ${digest.assetsContent.length} assets',
    );

    final fullPrompt = _buildResumePrompt(
      jobReq: jobReq.content,
      gigs: digest.gigsContent,
      assets: digest.assetsContent,
      customPrompt: prompt,
      applicant: applicant,
    );

    logger.info('Full prompt length: ${fullPrompt.length}');
    logger.fine('Full prompt: $fullPrompt');

    logger.info('Calling AI service for resume generation');
    final result = await aiService.generateContent(prompt: fullPrompt);
    if (result.isLeft()) {
      logger.severe(
        'AI service failed: ${result.getLeft().toNullable()!.message}',
      );
      return Left(result.getLeft().toNullable()!);
    }
    final content = result.getOrElse((_) => '');
    logger.info('AI response length: ${content.length}');
    logger.fine('AI response: $content');
    resumeRepository?.setLastAiResponse({'content': content});
    return Right(Resume(content: content));
  }

  String _buildResumePrompt({
    required String jobReq,
    required List<String> gigs,
    required List<String> assets,
    required String customPrompt,
    required Applicant applicant,
  }) {
    final header = _buildApplicantHeader(applicant: applicant);
    return '''
$header

Generate an ATS-optimized resume. $customPrompt

Job Requirements:
$jobReq

Work Experiences:
${gigs.map((g) => '---\n$g').join('\n')}

Qualifications:
${assets.map((a) => '---\n$a').join('\n')}

Please generate a resume in markdown format optimized for ATS systems.
Do not hallucinate any information. Use only the provided data.
Include all provided work experiences and qualifications. Do not add any skills, experiences, or qualifications not explicitly provided in the Work Experiences and Qualifications sections. If the provided data does not match the job requirements, still use only the provided data without modification or addition. Limit the resume to 1-2 pages. Quantify achievements where possible.
Output only the plain markdown content without any code blocks, backticks, or additional explanatory text.
''';
  }

  String _buildApplicantHeader({required Applicant applicant}) {
    final address = applicant.address;
    return '''
Applicant Information:
Name: ${applicant.name}
Preferred Name: ${applicant.preferredName}
Email: ${applicant.email}
Phone: ${applicant.phone}
${address != null ? 'Address: ${address.street1}${address.street2 != null ? ', ${address.street2}' : ''}, ${address.city}, ${address.state} ${address.zip}' : ''}
LinkedIn: ${applicant.linkedin}
GitHub: ${applicant.github}
Portfolio: ${applicant.portfolio}
''';
  }
}
