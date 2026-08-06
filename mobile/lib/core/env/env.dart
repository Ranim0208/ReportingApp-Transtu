import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed wrapper around .env variables.
/// Always access env values through this class — never dotenv.env[] directly.
class Env {
  Env._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? '192.168.100.9:8080';

  static String get appName => dotenv.env['APP_NAME'] ?? 'Transtu';
}
