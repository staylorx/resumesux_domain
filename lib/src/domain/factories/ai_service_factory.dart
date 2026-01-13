import 'package:http/http.dart' as http;
import 'package:resumesux_domain/src/data/data.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Factory for creating AiServiceImpl
AiService createAiServiceImpl({
  Logger? logger,
  required http.Client httpClient,
  required AiProvider provider,
}) => AiServiceImpl(logger: logger, httpClient: httpClient, provider: provider);
