/// Derleme zamanı yapılandırması. Değerler `--dart-define` ile verilir:
///
/// ```
/// flutter run -d chrome \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ... \
///   --dart-define=SITE_URL=https://notdulbutcool.com
/// ```
///
/// SUPABASE_URL boşsa uygulama **demo modda** çalışır: giriş ve ödeme
/// simüle edilir, böylece tasarım ve akışlar backend olmadan denenebilir.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Stripe Checkout dönüş adresleri için web sitesinin kök adresi.
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// iOS'ta dijital abonelik satışı App Store kurallarına tabidir.
  /// `true` iken iOS uygulamasında satın alma butonu yerine
  /// "üyeliğini web sitesinden yönetebilirsin" bilgisi gösterilir.
  static const hidePurchaseOnIos = bool.fromEnvironment(
    'HIDE_PURCHASE_ON_IOS',
    defaultValue: true,
  );

  static bool get isDemo => supabaseUrl.isEmpty || supabaseAnonKey.isEmpty;
}
