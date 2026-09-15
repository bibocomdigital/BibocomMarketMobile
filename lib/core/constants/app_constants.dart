abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const cachedUser = 'cached_user';
  static const onboardingDone = 'onboarding_done';
}

abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const googleAuth = '/auth/google';
  static const me = '/auth/me';
}
