import 'package:fpdart/fpdart.dart';
import '../../../../src/core/failure.dart';
import '../entities/asset.dart';

abstract class AssetRepository {
  Future<Either<Failure, List<Asset>>> getAllAssets();
}
