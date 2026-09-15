# BiboMarket Mobile

Socle Flutter — Clean Architecture feature-first, Riverpod, GoRouter.

**Lire [ARCHITECTURE.md](./ARCHITECTURE.md) avant toute contribution.**

## Stack

- État / DI : `flutter_riverpod`
- Navigation : `go_router`
- Réseau : `dio` + interceptor JWT
- Stockage : `flutter_secure_storage`, `shared_preferences`

## Démarrage

```bash
flutter pub get
flutter run
```

## Structure

```
lib/
  config/     env, router
  core/       réseau, storage, erreurs, thème, auth Google
  features/   auth, home
  shared/     widgets et helpers communs
  screens/    splash / onboarding
```

Référence : `lib/features/auth`.
