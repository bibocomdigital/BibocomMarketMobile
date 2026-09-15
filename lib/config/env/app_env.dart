/// Configuration runtime. Passer les valeurs via `--dart-define`.
///
/// Exemple :
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3005/api`
final class AppEnv {
  const AppEnv._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3005/api',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const isRelease = bool.fromEnvironment('dart.vm.product');
}
