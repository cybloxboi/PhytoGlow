import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';
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
                      return const _MissingRouteDataPage();
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
                      return const _MissingRouteDataPage();
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
          _NotFoundPage(attemptedPath: state.uri.path),
    );
  }

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

    return MaterialApp.router(
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
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

class _MissingRouteDataPage extends StatelessWidget {
  const _MissingRouteDataPage();

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(context, 'Phyto Glow'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '404 Not Found',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.attemptedPath});

  final String attemptedPath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(context, 'Phyto Glow'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ไม่พบหน้าที่ต้องการ',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ลิงก์ที่เปิดอยู่ไม่มีอยู่ในแอป หรืออาจถูกย้ายออกแล้ว',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          attemptedPath,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => context.goNamed('home'),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('กลับหน้าแรก'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
