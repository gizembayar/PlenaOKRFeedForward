import 'package:material_ui/material_ui.dart';

/// NOT DUL, BUT COOL. — renk sistemi (Mini Brand Board / 01).
abstract final class Brand {
  static const kobalt = Color(0xFF2944B5);
  static const krem = Color(0xFFF5EFDD);
  static const limon = Color(0xFFF3DB65);
  static const mercan = Color(0xFFEF604D);
  static const siyah = Color(0xFF202020);
  static const beyaz = Color(0xFFFFFFFF);

  /// Kart zeminleri için yumuşak tonlar (vizyon dokümanındaki pastel kartlar).
  static const kobaltSoft = Color(0xFFE4E7F7);
  static const limonSoft = Color(0xFFFFF1CC);
  static const mercanSoft = Color(0xFFFCE5DF);
  static const kartZemin = Color(0xFFFBF9F3);
  static const cizgi = Color(0xFFE2DCCB);

  /// İkincil metin: krem zemin üzerinde ~7:1 kontrast (35+ yaş için okunaklı).
  static const metin2 = Color(0xFF57524A);

  /// Yumuşak, sıcak gölge — kartlara derinlik verir.
  static const golge = [
    BoxShadow(color: Color(0x14202020), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const slogan = 'Hayatımda koca bir değişiklik var.';
  static const name = 'NOT DUL, BUT COOL.';
}

/// Inter Display Black / logo, Inter Bold / başlık, Inter Regular / metin.
abstract final class BrandText {
  static TextStyle logo({double size = 48, Color color = Brand.kobalt}) =>
      TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: -size * 0.055,
        height: 1.06,
        color: color,
      );

  static TextStyle heading({double size = 28, Color color = Brand.kobalt}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -size * 0.02,
        height: 1.1,
        color: color,
      );

  static TextStyle label({Color color = Brand.kobalt, double size = 12}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: color,
      );

  static TextStyle body({Color color = Brand.siyah, double size = 16}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        height: 1.55,
        color: color,
      );

  static TextStyle italic({Color color = Brand.kobalt, double size = 18}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: color,
      );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Brand.kobalt,
      primary: Brand.kobalt,
      onPrimary: Brand.krem,
      secondary: Brand.limon,
      onSecondary: Brand.siyah,
      tertiary: Brand.mercan,
      surface: Brand.krem,
      onSurface: Brand.siyah,
      error: Brand.mercan,
    ),
    scaffoldBackgroundColor: Brand.krem,
  );
  final text = base.textTheme.apply(
    fontFamily: 'Inter',
    bodyColor: Brand.siyah,
    displayColor: Brand.kobalt,
  );
  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Brand.krem,
      foregroundColor: Brand.kobalt,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: BrandText.heading(size: 20),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.kobalt,
        foregroundColor: Brand.krem,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Brand.kobalt,
        side: const BorderSide(color: Brand.kobalt, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: const StadiumBorder(),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Brand.kobalt,
      contentTextStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Brand.krem,
        fontSize: 15,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      fillColor: Brand.beyaz,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.cizgi),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.cizgi),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.kobalt, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Brand.beyaz,
      selectedColor: Brand.limon,
      side: const BorderSide(color: Brand.cizgi),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Brand.beyaz,
      height: 72,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Brand.limon,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Brand.beyaz,
      indicatorColor: Brand.limon,
    ),
  );
}

/// Türkçe büyük harf: i → İ, ı → I (Dart'ın toUpperCase'i yerel ayardan bağımsızdır).
extension TurkishCase on String {
  String get trUpper => replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}
