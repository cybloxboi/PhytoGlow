import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/pages/error_handling/missing_route_data_page.dart';
import 'package:phyto_glow/pages/error_handling/not_found_page.dart';
import 'package:phyto_glow/pages/fluorescent_detection_page.dart';
import 'package:phyto_glow/pages/home_page.dart';
import 'package:phyto_glow/pages/result_page.dart';
import 'package:phyto_glow/pages/white_blood_cell_analysis_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const PhytoGlow());
}

class PhytoGlow extends StatelessWidget {
  const PhytoGlow({super.key});

  static const Color _seedColor = Color(0xFF3F51B5);
  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _secondaryColor = Color(0xFF00BFA5);
  static const Color _tertiaryColor = Color(0xFF8F4700);
  static const Color _neutralColor = Color(0xFF77767E);
  static final GoRouter _router = _buildRouter();

  static GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'fluorescent',
              name: 'fluorescent',
              builder: (context, state) => const FluorescentDetectionPage(),
              routes: [
                GoRoute(
                  path: 'result',
                  name: 'fluorescent-result',
                  builder: (context, state) {
                    final data = state.extra;

                    if (data is! ResultPageData) {
                      return const MissingRouteDataPage();
                    }

                    return ResultPage(
                      imageBytes: data.imageBytes,
                      imageName: data.imageName,
                      result: data.result,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'wbc',
              name: 'wbc',
              builder: (context, state) => const WhiteBloodCellAnalysisPage(),
              routes: [
                GoRoute(
                  path: 'result',
                  name: 'wbc-result',
                  builder: (context, state) {
                    final data = state.extra;

                    if (data is! ResultPageData) {
                      return const MissingRouteDataPage();
                    }

                    return ResultPage(
                      imageBytes: data.imageBytes,
                      imageName: data.imageName,
                      result: data.result,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],

      errorBuilder: (context, state) =>
          NotFoundPage(attemptedPath: state.uri.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notoSansThaiFamily = GoogleFonts.notoSansThai().fontFamily!;
    final lightBaseTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    );
    final darkBaseTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
    );
    final lightTheme = _buildTheme(
      baseTheme: lightBaseTheme,
      brightness: Brightness.light,
      textTheme: GoogleFonts.manropeTextTheme(lightBaseTheme.textTheme),
      primaryTextTheme: GoogleFonts.manropeTextTheme(
        lightBaseTheme.primaryTextTheme,
      ),
      fallbackFamily: notoSansThaiFamily,
    );
    final darkTheme = _buildTheme(
      baseTheme: darkBaseTheme,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.manropeTextTheme(darkBaseTheme.textTheme),
      primaryTextTheme: GoogleFonts.manropeTextTheme(
        darkBaseTheme.primaryTextTheme,
      ),
      fallbackFamily: notoSansThaiFamily,
    );

    return MaterialApp.router(
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }

  ThemeData _buildTheme({
    required ThemeData baseTheme,
    required Brightness brightness,
    required TextTheme textTheme,
    required TextTheme primaryTextTheme,
    required String fallbackFamily,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: brightness,
        ).copyWith(
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor,
          surface: isDark ? const Color(0xFF171A24) : Colors.white,
          onSurface: isDark ? const Color(0xFFE8EAF2) : const Color(0xFF1C1B1F),
          outline: isDark ? const Color(0xFF8B93A7) : _neutralColor,
          outlineVariant: isDark
              ? const Color(0xFF8B93A7).withValues(alpha: 0.32)
              : _neutralColor.withValues(alpha: 0.35),
        );

    return baseTheme.copyWith(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0E1118)
          : const Color(0xFFF6F7FB),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.32 : 0.12),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _applyThaiFallback(
        textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          decorationColor: scheme.onSurface,
        ),
        fallbackFamily,
      ),
      primaryTextTheme: _applyThaiFallback(
        primaryTextTheme.apply(
          bodyColor: scheme.onPrimary,
          displayColor: scheme.onPrimary,
          decorationColor: scheme.onPrimary,
        ),
        fallbackFamily,
      ),
    );
  }

  TextTheme _applyThaiFallback(TextTheme textTheme, String fallbackFamily) {
    TextStyle? withFallback(TextStyle? style) {
      if (style == null) {
        return null;
      }

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
