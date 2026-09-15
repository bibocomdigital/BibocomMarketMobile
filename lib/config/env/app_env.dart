/// Configuration runtime. Passer les valeurs via `--dart-define`.
///
/// Backend cloné (`BiboMarketBack`) : Docker expose `3007 → 3000`.
/// Émulateur Android :
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3007/api`
final class AppEnv {
  const AppEnv._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3007/api',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const isRelease = bool.fromEnvironment('dart.vm.product');
}
