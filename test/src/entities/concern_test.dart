import 'package:test/test.dart' hide Tags;

import 'package:resumesux_domain/src/value_objects/concern.dart';
import 'package:resumesux_domain/src/value_objects/tags.dart' as domain_tags;

void main() {
  group('Given a Concern', () {
    group('When constructing with valid parameters', () {
      test('Then it creates instance with all required fields', () {
        // Arrange
        const name = 'Google';
        const description = 'Tech company';
        const location = 'Mountain View, CA';
        final tags = domain_tags.Tags.fromList(['tech', 'search']);

        // Act
        final concern = Concern(
          name: name,
          description: description,
          location: location,
          tags: tags,
        );

        // Assert
        expect(concern.name, equals(name));
        expect(concern.description, equals(description));
        expect(concern.location, equals(location));
        expect(concern.tags, equals(tags));
      });

      test('Then it creates instance with optional fields as null', () {
        // Arrange
        const name = 'Apple';

        // Act
        final concern = Concern(name: name);

        // Assert
        expect(concern.name, equals(name));
        expect(concern.description, isNull);
        expect(concern.location, isNull);
        expect(concern.tags, equals(domain_tags.Tags.empty()));
      });

      test('Then it defaults tags to empty when not provided', () {
        // Arrange
        const name = 'Microsoft';

        // Act
        final concern = Concern(name: name);

        // Assert
        expect(concern.tags, equals(domain_tags.Tags.empty()));
      });
    });

    group('When comparing instances', () {
      test('Then two instances with same values are equal', () {
        // Arrange
        final concern1 = Concern(
          name: 'Amazon',
          description: 'E-commerce giant',
          location: 'Seattle, WA',
          tags: domain_tags.Tags.fromList(['retail', 'cloud']),
        );
        final concern2 = Concern(
          name: 'Amazon',
          description: 'E-commerce giant',
          location: 'Seattle, WA',
          tags: domain_tags.Tags.fromList(['retail', 'cloud']),
        );

        // Act & Assert
        expect(concern1, equals(concern2));
        expect(concern1.hashCode, equals(concern2.hashCode));
      });

      test('Then instances with different names are not equal', () {
        // Arrange
        final concern1 = Concern(name: 'Google');
        final concern2 = Concern(name: 'Apple');

        // Act & Assert
        expect(concern1, isNot(equals(concern2)));
      });

      test('Then instances with different descriptions are not equal', () {
        // Arrange
        final concern1 = Concern(name: 'Google', description: 'Search engine');
        final concern2 = Concern(name: 'Google', description: 'Tech company');

        // Act & Assert
        expect(concern1, isNot(equals(concern2)));
      });

      test('Then instances with different locations are not equal', () {
        // Arrange
        final concern1 = Concern(name: 'Google', location: 'Mountain View');
        final concern2 = Concern(name: 'Google', location: 'Sunnyvale');

        // Act & Assert
        expect(concern1, isNot(equals(concern2)));
      });

      test('Then instances with different tags are not equal', () {
        // Arrange
        final concern1 = Concern(
          name: 'Google',
          tags: domain_tags.Tags.fromList(['tech']),
        );
        final concern2 = Concern(
          name: 'Google',
          tags: domain_tags.Tags.fromList(['search']),
        );

        // Act & Assert
        expect(concern1, isNot(equals(concern2)));
      });

      test(
        'Then instance with null description equals instance with null description',
        () {
          // Arrange
          final concern1 = Concern(name: 'Google');
          final concern2 = Concern(name: 'Google', description: null);

          // Act & Assert
          expect(concern1, equals(concern2));
        },
      );
    });

    group('When copying with modifications', () {
      late Concern original;

      setUp(() {
        original = Concern(
          name: 'Tesla',
          description: 'Electric car company',
          location: 'Palo Alto, CA',
          tags: domain_tags.Tags.fromList(['automotive', 'electric']),
        );
      });

      test('Then copyWith with no changes returns equivalent instance', () {
        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
        expect(copy, isNot(same(original)));
      });

      test('Then copyWith modifies name only', () {
        // Act
        final copy = original.copyWith(name: 'Tesla Motors');

        // Assert
        expect(copy.name, equals('Tesla Motors'));
        expect(copy.description, equals(original.description));
        expect(copy.location, equals(original.location));
        expect(copy.tags, equals(original.tags));
      });

      test('Then copyWith modifies description only', () {
        // Act
        final copy = original.copyWith(description: 'EV manufacturer');

        // Assert
        expect(copy.name, equals(original.name));
        expect(copy.description, equals('EV manufacturer'));
        expect(copy.location, equals(original.location));
        expect(copy.tags, equals(original.tags));
      });

      test('Then copyWith modifies location only', () {
        // Act
        final copy = original.copyWith(location: 'Austin, TX');

        // Assert
        expect(copy.name, equals(original.name));
        expect(copy.description, equals(original.description));
        expect(copy.location, equals('Austin, TX'));
        expect(copy.tags, equals(original.tags));
      });

      test('Then copyWith modifies tags only', () {
        // Act
        final copy = original.copyWith(
          tags: domain_tags.Tags.fromList(['cars', 'battery']),
        );

        // Assert
        expect(copy.name, equals(original.name));
        expect(copy.description, equals(original.description));
        expect(copy.location, equals(original.location));
        expect(
          copy.tags,
          equals(domain_tags.Tags.fromList(['cars', 'battery'])),
        );
      });
    });

    group('When handling edge cases', () {
      test('Then it handles empty string name', () {
        // Arrange
        const name = '';

        // Act
        final concern = Concern(name: name);

        // Assert
        expect(concern.name, equals(name));
      });

      test('Then it handles empty string description', () {
        // Arrange
        const name = 'Test';
        const description = '';

        // Act
        final concern = Concern(name: name, description: description);

        // Assert
        expect(concern.description, equals(description));
      });

      test('Then it handles empty string location', () {
        // Arrange
        const name = 'Test';
        const location = '';

        // Act
        final concern = Concern(name: name, location: location);

        // Assert
        expect(concern.location, equals(location));
      });

      test('Then it handles empty tags', () {
        // Arrange
        const name = 'Test';
        final tags = domain_tags.Tags.empty();

        // Act
        final concern = Concern(name: name, tags: tags);

        // Assert
        expect(concern.tags, equals(tags));
      });
    });

    group('When demonstrating functional use cases', () {
      test('Then it can represent a tech company', () {
        // Act
        final google = Concern(
          name: 'Google LLC',
          description: 'Multinational technology company',
          location: 'Mountain View, California',
          tags: domain_tags.Tags.fromList([
            'technology',
            'search',
            'advertising',
            'cloud',
          ]),
        );

        // Assert
        expect(google.name, equals('Google LLC'));
        expect(google.description, equals('Multinational technology company'));
        expect(google.location, equals('Mountain View, California'));
        expect(
          google.tags.values,
          containsAll(['technology', 'search', 'advertising', 'cloud']),
        );
      });

      test('Then it can represent an educational institution', () {
        // Act
        final stanford = Concern(
          name: 'Stanford University',
          description: 'Private research university',
          location: 'Stanford, California',
          tags: domain_tags.Tags.fromList([
            'education',
            'research',
            'university',
          ]),
        );

        // Assert
        expect(stanford.name, equals('Stanford University'));
        expect(stanford.description, equals('Private research university'));
        expect(stanford.location, equals('Stanford, California'));
        expect(
          stanford.tags.values,
          containsAll(['education', 'research', 'university']),
        );
      });

      test('Then it can represent a nonprofit organization', () {
        // Act
        final redCross = Concern(
          name: 'American Red Cross',
          description: 'Humanitarian organization',
          location: 'Washington, D.C.',
          tags: domain_tags.Tags.fromList([
            'nonprofit',
            'humanitarian',
            'emergency',
          ]),
        );

        // Assert
        expect(redCross.name, equals('American Red Cross'));
        expect(redCross.description, equals('Humanitarian organization'));
        expect(redCross.location, equals('Washington, D.C.'));
        expect(
          redCross.tags.values,
          containsAll(['nonprofit', 'humanitarian', 'emergency']),
        );
      });

      test('Then it can be updated for company rebranding', () {
        // Arrange
        final original = Concern(
          name: 'Old Company Name',
          description: 'Original description',
          location: 'Original location',
          tags: domain_tags.Tags.fromList(['old', 'tag']),
        );

        // Act
        final rebranded = original.copyWith(
          name: 'New Company Name',
          description: 'Updated description',
          tags: domain_tags.Tags.fromList(['new', 'brand']),
        );

        // Assert
        expect(rebranded.name, equals('New Company Name'));
        expect(rebranded.description, equals('Updated description'));
        expect(rebranded.location, equals('Original location')); // unchanged
        expect(rebranded.tags.values, containsAll(['new', 'brand']));
      });
    });
  });
}
