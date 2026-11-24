import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';
import '../data/models.dart';
import 'backend.dart';
import 'session.dart';

/// iOS'ta dijital abonelik satışı App Store kurallarına tabidir; varsayılan
/// olarak iOS uygulamasında satın alma gizlenir ve web'e yönlendirilir.
bool get purchaseHiddenOnThisPlatform =>
    !kIsWeb &&
    defaultTargetPlatform == TargetPlatform.iOS &&
    AppConfig.hidePurchaseOnIos;

/// Üyelik satın alma akışı:
/// 1. Giriş yoksa → kayıt sayfasına (dönüşte plan seçili kalır)
/// 2. Supabase Edge Function → Stripe Checkout Session
/// 3. Web'de aynı sekmede, mobilde uygulama içi tarayıcıda ödeme sayfası
/// 4. Stripe webhook → `profiles.tier` güncellenir → uygulama tazelenir
Future<void> startCheckout(
  BuildContext context,
  Tier tier,
  BillingPeriod period,
) async {
  final session = context.sessionRead;
  final messenger = ScaffoldMessenger.of(context);
  if (!session.signedIn) {
    context.go('/kayit?plan=${tier.id}&donem=${period.name}');
    return;
  }
  if (purchaseHiddenOnThisPlatform) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Üyeliğini notdulbutcool.com üzerinden yönetebilirsin.'),
      ),
    );
    return;
  }
  try {
    final url = await session.backend.createCheckout(tier, period);
    if (url == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Demo mod: ${tier.name} üyeliğin aktif. Hoş geldin!'),
        ),
      );
      return;
    }
    await launchUrl(
      url,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.inAppBrowserView,
      webOnlyWindowName: '_self',
    );
  } on AuthFailure catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}

Future<void> openBillingPortal(BuildContext context) async {
  final session = context.sessionRead;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final url = await session.backend.createPortal();
    if (url == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Demo mod: üyelik KEŞİF planına döndü.')),
      );
      return;
    }
    await launchUrl(
      url,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.inAppBrowserView,
      webOnlyWindowName: '_self',
    );
  } on AuthFailure catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}
