# stripe_app

## Variables de entorno

Copia la plantilla y completa las claves locales:

```sh
cp .env.example .env
flutter run --dart-define-from-file=.env
```

`.env` está excluido de Git. Nunca distribuyas `STRIPE_SECRET_KEY` dentro de la
aplicación; crea los PaymentIntents desde un backend seguro antes de producción.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
