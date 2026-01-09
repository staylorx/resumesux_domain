import 'package:fpdart/fpdart.dart';
import 'package:resume_suckage_domain/resume_suckage_domain.dart';

abstract class ConfigRepository {
  Future<Either<Failure, Config>> loadConfig({String? configPath});
  Future<Either<Failure, AiProvider>> getProvider({
    required String providerName,
    String? configPath,
  });
  Future<Either<Failure, AiProvider?>> getDefaultProvider({String? configPath});
  bool hasDefaultModel({required AiProvider provider});
}
