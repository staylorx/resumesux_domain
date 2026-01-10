import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a cover letter.
class GenerateCoverLetterUsecase {
  final Logger logger = LoggerFactory.create('GenerateCoverLetterUsecase');
  final DigestRepository digestRepository;
  final AiService aiService;

  /// Creates a new instance of [GenerateCoverLetterUsecase].
  GenerateCoverLetterUsecase({
    required this.digestRepository,
    required this.aiService,
  });

  /// Generates a cover letter for the given job requirement and applicant.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The prompt for AI generation.
  ///
  /// Returns: [Either<Failure, CoverLetter>] the generated cover letter or a failure.
  Future<Either<Failure, CoverLetter>> call({
    required JobReq jobReq,
    required Applicant applicant,
    required String prompt,
  }) async {
    logger.info('[GenerateCoverLetterUsecase] Generating cover letter');

    final digestResult = await digestRepository.getAllDigests();
    if (digestResult.isLeft()) {
      return Left(digestResult.getLeft().toNullable()!);
    }

    final digests = digestResult.getOrElse((failure) => []);
    if (digests.isEmpty) {
      return Left(ValidationFailure(message: 'No digest found'));
    }

    final digest = digests.first;

    final fullPrompt = _buildCoverLetterPrompt(
      jobReq: jobReq.content,
      gigs: digest.gigsContent,
      assets: digest.assetsContent,
      customPrompt: prompt,
      applicant: applicant,
    );

    final result = await aiService.generateContent(prompt: fullPrompt);
    return result.map((content) => CoverLetter(content: content));
  }

  String _buildCoverLetterPrompt({
    required String jobReq,
    required List<String> gigs,
    required List<String> assets,
    required String customPrompt,
    required Applicant applicant,
  }) {
    final header = _buildApplicantHeader(applicant: applicant);
    return '''
$header

Generate a professional cover letter. $customPrompt

Job Requirements:
$jobReq

Work Experience (Gigs):
${gigs.join('\n\n')}

Assets (Education, Skills, etc.):
${assets.join('\n\n')}

Please generate a professional cover letter in markdown format.
Do not halucinate any information. Use only the provided data.
Perform strict relevance checking before inclusion: only include work experience (gigs) and assets that are directly relevant to the job requirements. Omit any irrelevant or unrelated content entirely, such as non-tech certifications for tech-focused jobs or unrelated personal qualifications. Do not include any work experience or assets that are not directly related to or explicitly mentioned in the job requirements. Prioritize recent work experience (last 10 years) and modern technologies. Exclude any experiences or skills from before 2010 or legacy technologies like SOA, Oracle WebLogic, BPEL unless they are directly relevant to the job requirements. Keep the cover letter concise, under 250 words, with 3-4 paragraphs and bullet points for specific achievements. Focus on job-relevant experiences and avoid repetition.
''';
  }

  String _buildApplicantHeader({required Applicant applicant}) {
    return '''
Applicant Information:
Name: ${applicant.name}
Preferred Name: ${applicant.preferredName ?? ''}
Email: ${applicant.email}
Phone: ${applicant.phone ?? ''}
${applicant.address != null ? 'Address: ${applicant.address!.street1}${applicant.address!.street2 != null ? ', ${applicant.address!.street2}' : ''}, ${applicant.address!.city}, ${applicant.address!.state} ${applicant.address!.zip}' : ''}
LinkedIn: ${applicant.linkedin ?? ''}
GitHub: ${applicant.github ?? ''}
Portfolio: ${applicant.portfolio ?? ''}
''';
  }
}
