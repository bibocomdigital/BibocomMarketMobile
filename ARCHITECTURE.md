# Architecture BiboMarket Mobile

Clean Architecture **feature-first** (Flutter).
Riverpod = état + injection. GoRouter = navigation.

## Organisation

```
lib/
  main.dart
  app.dart
  config/          env, router
  core/            réseau, storage, erreurs, thème, auth Google
  features/        domaines métier
  shared/          widgets et helpers communs
  screens/         splash / onboarding uniquement
```

Toute nouvelle UI métier va dans `features/<x>/presentation/`. `screens/` ne reçoit plus de pages.

## Features

| Feature | Couches | Rôle |
|---|---|---|
| `auth` | domain + data + presentation + providers | Référence à copier |
| `home` | presentation | Écran après connexion |

Pas de features `course`, `payment`, `quiz`, `certification` dans ce socle.

## Couches d’une feature

```
features/<nom>/
  domain/          entities, interfaces repository, use cases
  data/            models, datasources, repository impl
  presentation/    pages, widgets
  providers/       Riverpod (DI + état)
```

- `domain` : jamais Flutter, Dio, Retrofit, Riverpod, Freezed
- `presentation` : jamais Dio, datasource, ni impl repository
- mapping DTO → entity : `toEntity()` sur le model (`data`)

## Flux

```
UI (pages)
  → Riverpod providers
    → UseCase
      → Repository
        → DataSource (Dio)
          → API backend
```

Exemple auth :

`LoginPage` → `loginUseCaseProvider` → `LoginUseCase` → `AuthRepositoryImpl` → `AuthRemoteDataSource`

## Stack

| Besoin | Package |
|---|---|
| État / DI | `flutter_riverpod` |
| Navigation | `go_router` (redirections selon session) |
| Réseau | `dio` + interceptor JWT |
| Tokens | `flutter_secure_storage` |
| Préférences | `shared_preferences` |
| Auth Google | `google_sign_in` (`core/auth`) |

## Navigation

- session en restauration → splash
- non authentifié hors routes publiques → login (ou onboarding)
- authentifié sur splash / onboarding / login → home

## Ajouter une feature

1. Dossier `lib/features/<nom>/` en copiant `auth`
2. Route dans `AppRoutes` + `GoRouter`
3. DI dans `providers/`
4. La page ne fait que `ref.watch` / `ref.read`
