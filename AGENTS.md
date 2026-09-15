# Agents — BiboMarket Mobile

Lire `ARCHITECTURE.md` avant toute modification.

- Clean Architecture feature-first (Flutter).
- Riverpod = état + injection. GoRouter = navigation.
- Flux : UI → providers → UseCase → Repository → DataSource → API.
- Référence : `lib/features/auth`.
- Features présentes : `auth`, `home`. Pas de course / payment / quiz / certification.
- `screens/` = splash / onboarding. Nouvelle UI → `features/<x>/presentation/`.
- `domain` = Dart pur (pas de Flutter / Dio / Riverpod).
