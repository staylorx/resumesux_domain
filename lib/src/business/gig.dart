import 'package:equatable/equatable.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Represents a professional gig or job experience.
/// It can also be a volunteer position or internship.
class Gig with EquatableMixin {
  final Concern? concern;
  final String? location;
  final String title;
  final String? dates;
  final List<String>? achievements;

  const Gig({
    this.concern,
    this.location,
    required this.title,
    this.dates,
    this.achievements,
  });

  Gig copyWith({
    Concern? concern,
    String? location,
    String? title,
    String? dates,
    List<String>? achievements,
  }) {
    return Gig(
      concern: concern ?? this.concern,
      location: location ?? this.location,
      title: title ?? this.title,
      dates: dates ?? this.dates,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object> get props => [title];
}
