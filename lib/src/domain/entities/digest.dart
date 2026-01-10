import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'gig.dart';

/// Represents a digest containing lists of gigs and assets.
class Digest with EquatableMixin {
  // Lists of gigs and assets included in the digest.
  // Possible to not have a one yet
  final List<Gig>? gigs;
  // Possible to have none yet.
  final List<Asset>? assets;

  const Digest({this.gigs, this.assets});

  Digest copyWith({List<Gig>? gigs, List<Asset>? assets}) {
    return Digest(gigs: gigs ?? this.gigs, assets: assets ?? this.assets);
  }

  List<String> get gigsContent =>
      gigs
          ?.map(
            (gig) =>
                '${gig.concern} - ${gig.title}\n${gig.achievements?.join('\n') ?? ''}',
          )
          .toList() ??
      [];

  List<String> get assetsContent =>
      assets?.map((asset) => asset.content).toList() ?? [];

  @override
  List<Object?> get props => [gigs, assets];
}
