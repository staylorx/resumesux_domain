// ignore_for_file: constant_identifier_names

/// Enum representing the fields that can be used to construct folder names in the output directory structure.
/// Each field corresponds to a property from Applicant, JobReq, or Concern entities.
enum FolderField {
  /// The applicant's full name
  applicant_name,

  /// The job requirement's title
  jobreq_title,

  /// The concern (company/organization) name
  concern,

  /// The applicant's location (derived from address.city)
  applicant_location,

  /// The job requirement's location
  jobreq_location,

  /// The concern's location
  concern_location,
}
