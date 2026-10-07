import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_app/models/models.dart';

class StripeService {
  //Singleton
  StripeService._privateConstructor();
  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService() => _instance;

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static const String _secretKey =
      String.fromEnvironment('STRIPE_SECRET_KEY');
  static const String _publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  final headerOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      'Authorization': 'Bearer ${StripeService._secretKey}',
    },
  );

  void init() {
    if (_publishableKey.isEmpty) {
      throw StateError(
        'Missing STRIPE_PUBLISHABLE_KEY. Pass it with --dart-define.',
      );
    }
    Stripe.publishableKey = _publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.example.stripeApp';
  }

  Future<StripeCustomResponse> payWithCardExist({
    required String amount,
    required String currency,
    required CreditCardCustom card,
  }) async {
    try {
      final monthYear = card.expiracyDate.split('/');
      await Stripe.instance.dangerouslyUpdateCardDetails(
        CardDetails(
          number: card.cardNumber,
          expirationMonth: int.parse(monthYear[0]),
          expirationYear: int.parse(monthYear[1]),
          cvc: card.cvv,
        ),
      );
      return _makePaymentIntent(amount: amount, currency: currency);
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payWithNewCard({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentIntent =
          await _createPaymetIntent(amount: amount, currency: currency);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Stripe App',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return StripeCustomResponse(ok: true);
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payApplePayGooglePay({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentIntent =
          await _createPaymetIntent(amount: amount, currency: currency);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Stripe App',
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: currency,
            testEnv: true,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return StripeCustomResponse(ok: true);
    } catch (e) {
      print('Error when trying payApplePayGooglePay: ${e.toString()}');
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<PaymentIntentResponse> _createPaymetIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      if (_secretKey.isEmpty) {
        throw StateError(
          'Missing STRIPE_SECRET_KEY. PaymentIntent creation belongs on a '
          'trusted backend; use --dart-define only for local testing.',
        );
      }
      final dio = Dio();
      final data = {
        'amount': amount,
        'currency': currency,
      };
      final response = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions,
      );

      return PaymentIntentResponse.fromJson(response.data);
    } catch (e) {
      print('Error when trying to create payment intent: ${e.toString()}');
      return PaymentIntentResponse(status: '400');
    }
  }

  Future<StripeCustomResponse> _makePaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentIntent =
          await _createPaymetIntent(amount: amount, currency: currency);

      final paymentResult = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent.clientSecret!,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
        return StripeCustomResponse(ok: true);
      } else {
        return StripeCustomResponse(ok: false, msg: 'Payment failed!');
      }
    } catch (e) {
      print('_makePaymentIntent>>> ${e.toString()}');
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }
}
