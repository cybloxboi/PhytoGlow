import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phyto_glow/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhytoGlow());
}

class PhytoGlow extends StatelessWidget {
  const PhytoGlow({super.key});

  static const Color _seedColor = Color(0xFF3F51B5);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _secondaryColor = Color(0xFF00BFA5);
  static const Color _tertiaryColor = Color(0xFF8F4700);
  static const Color _neutralColor = Color(0xFF77767E);

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData();
    final lightScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor,
          surface: Colors.white,
          onSurface: const Color(0xFF1C1B1F),
          outline: _neutralColor,
          outlineVariant: _neutralColor.withValues(alpha: 0.35),
        );
    final notoSansThaiFamily = GoogleFonts.notoSansThai().fontFamily!;
    final manropeTextTheme = GoogleFonts.manropeTextTheme(baseTheme.textTheme);
    final manropePrimaryTextTheme = GoogleFonts.manropeTextTheme(
      baseTheme.primaryTextTheme,
    );

    return MaterialApp(
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: baseTheme.copyWith(
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.surface,
          foregroundColor: lightScheme.onSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: lightScheme.surface,
          shadowColor: _neutralColor.withValues(alpha: 0.12),
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: _applyThaiFallback(manropeTextTheme, notoSansThaiFamily),
        primaryTextTheme: _applyThaiFallback(
          manropePrimaryTextTheme,
          notoSansThaiFamily,
        ),
      ),
      home: HomePage(),
    );
  }

  TextTheme _applyThaiFallback(TextTheme textTheme, String fallbackFamily) {
    TextStyle? withFallback(TextStyle? style) {
      if (style == null) return null;
      return style.copyWith(fontFamilyFallback: <String>[fallbackFamily]);
    }

    return textTheme.copyWith(
      displayLarge: withFallback(textTheme.displayLarge),
      displayMedium: withFallback(textTheme.displayMedium),
      displaySmall: withFallback(textTheme.displaySmall),
      headlineLarge: withFallback(textTheme.headlineLarge),
      headlineMedium: withFallback(textTheme.headlineMedium),
      headlineSmall: withFallback(textTheme.headlineSmall),
      titleLarge: withFallback(textTheme.titleLarge),
      titleMedium: withFallback(textTheme.titleMedium),
      titleSmall: withFallback(textTheme.titleSmall),
      bodyLarge: withFallback(textTheme.bodyLarge),
      bodyMedium: withFallback(textTheme.bodyMedium),
      bodySmall: withFallback(textTheme.bodySmall),
      labelLarge: withFallback(textTheme.labelLarge),
      labelMedium: withFallback(textTheme.labelMedium),
      labelSmall: withFallback(textTheme.labelSmall),
    );
  }
}
