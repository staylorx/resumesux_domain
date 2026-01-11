import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for generating a cover letter.
class GenerateCoverLetterUsecase {
  final Logger logger = LoggerFactory.create(
    name: 'GenerateCoverLetterUsecase',
  );
  final DigestRepository digestRepository;
  final AiService aiService;

  /// Creates a new instance of [GenerateCoverLetterUsecase].
  GenerateCoverLetterUsecase({
    required this.digestRepository,
    required this.aiService,
  });

  /// Generates a cover letter for the given job requirement, resume, and applicant.
  ///
  /// Parameters:
  /// - [jobReq]: The job requirement.
  /// - [resume]: The generated resume.
  /// - [applicant]: The applicant information.
  /// - [prompt]: The prompt for AI generation.
  ///
  /// Returns: [Either<Failure, CoverLetter>] the generated cover letter or a failure.
  Future<Either<Failure, CoverLetter>> call({
    required JobReq jobReq,
    required Resume resume,
    required Applicant applicant,
    required String prompt,
  }) async {
    logger.info('Generating cover letter');

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
      resume: resume.content,
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
    required String resume,
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

Generated Resume:
$resume

Work Experience (Gigs):
${gigs.join('\n\n')}

Assets (Education, Skills, etc.):
${assets.join('\n\n')}

Please generate a professional cover letter in markdown format.
Do not hallucinate any information. Use only the provided data.
Include all provided work experiences and qualifications. Do not add any skills, experiences, or qualifications not explicitly provided in the Work Experience and Assets sections. If the provided data does not match the job requirements, still use only the provided data without modification or addition. Keep the cover letter concise, under 250 words, with 3-4 paragraphs and bullet points for specific achievements. Avoid repetition.
Output only the plain markdown content without any code blocks, backticks, or additional explanatory text.
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
