# stripe_app

For local testing, provide Stripe keys without committing them:

```sh
flutter run \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_key \
  --dart-define=STRIPE_SECRET_KEY=sk_test_your_key
```

Never ship `STRIPE_SECRET_KEY` in a client application. Create PaymentIntents
on a trusted backend before using this project in production.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
