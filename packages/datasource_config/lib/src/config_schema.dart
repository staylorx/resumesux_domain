/// JSON Schema for validating config.yaml structure
/// This schema defines the expected types, required fields, and nested structure
/// for the configuration file used by the resume generation application.
/// It ensures that all necessary configuration is present and properly typed.
const Map<String, dynamic> configSchema = {
  '\$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    // Root config object containing all application settings
    'config': {
      'type': 'object',
      'properties': {
        // Optional custom prompt for AI generation (empty string if not provided)
        'customPrompt': {'type': 'string'},
        // Required directory path where generated files will be saved
        'outputDir': {'type': 'string'},
        // Boolean flag to include cover letter in generated output
        'includeCover': {'type': 'boolean'},
        // Boolean flag to include AI-generated feedback on resume
        'includeFeedback': {'type': 'boolean'},
        // Optional path to the digest directory (defaults to 'digest')
        'digestPath': {'type': 'string'},
        // Optional array defining the order of fields for output folder structure
        'folderOrder': {
          'type': 'array',
          'items': {
            'type': 'string',
            'enum': [
              'applicant_name',
              'jobreq_title',
              'concern',
              'applicant_location',
              'jobreq_location',
              'concern_location',
            ],
          },
        },
        // Applicant information object with personal details
        'applicant': {
          'type': 'object',
          'properties': {
            // Full legal name of the applicant
            'name': {'type': 'string'},
            // Preferred name for display purposes
            'preferred_name': {'type': 'string'},
            // Email address for contact
            'email': {'type': 'string'},
            // Address object with mailing information
            'address': {
              'type': 'object',
              'properties': {
                // Primary street address line
                'street1': {'type': 'string'},
                // Optional secondary street address line (e.g., apartment number)
                'street2': {'type': 'string'},
                // City name
                'city': {'type': 'string'},
                // State or province code
                'state': {'type': 'string'},
                // Postal code (accepts both string and number formats)
                'zip': {
                  'type': ['string', 'number'],
                },
              },
              // Required address fields for complete mailing information
              'required': ['street1', 'city', 'state', 'zip'],
              'additionalProperties': false,
            },
            // Phone number as formatted string
            'phone': {'type': 'string'},
            // LinkedIn profile URL
            'linkedin': {'type': 'string'},
            // GitHub profile URL
            'github': {'type': 'string'},
            // Optional portfolio website URL
            'portfolio': {'type': 'string'},
          },
          // Required applicant information fields
          'required': [
            'name',
            'preferred_name',
            'email',
            'address',
            'phone',
            'linkedin',
            'github',
          ],
          'additionalProperties': false,
        },
        // Providers object containing LLM provider configurations
        'providers': {
          'type': 'object',
          // Pattern to match any provider name as key
          'patternProperties': {
            '.*': {
              'type': 'object',
              'properties': {
                // API endpoint URL for the provider
                'url': {'type': 'string'},
                // API key for authentication (can be environment variable reference)
                'key': {'type': 'string'},
                // Optional flag to mark this provider as default
                'default': {'type': 'boolean'},
                // Array of available models for this provider
                'models': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      // Model name/identifier
                      'name': {'type': 'string'},
                      // Optional flag to mark this model as default for the provider
                      'default': {'type': 'boolean'},
                      // Optional model-specific settings
                      'settings': {
                        'type': 'object',
                        'properties': {
                          // Temperature setting for model randomness (0.0 to 1.0)
                          'temperature': {'type': 'number'},
                        },
                        // No additional settings allowed beyond temperature
                        'additionalProperties': false,
                      },
                    },
                    // Model name is required, others are optional
                    'required': ['name'],
                    'additionalProperties': false,
                  },
                },
              },
              // Required fields for each provider configuration
              'required': ['url', 'key', 'models'],
              'additionalProperties': false,
            },
          },
          // No additional properties allowed in providers object
          'additionalProperties': false,
        },
      },
      // Required top-level configuration fields
      'required': [
        'outputDir',
        'includeCover',
        'includeFeedback',
        'applicant',
        'providers',
      ],
      'additionalProperties': false,
    },
  },
  // The root object must contain the config key
  'required': ['config'],
  'additionalProperties': false,
};
