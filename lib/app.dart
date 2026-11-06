import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/preferences_provider.dart';
import 'router.dart';
import 'theme.dart';

class CampusFlowApp extends ConsumerWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sombre = ref.watch(preferencesProvider.select((p) => p.themeSombre));

    return MaterialApp.router(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: campusTheme(Brightness.light),
      darkTheme: campusTheme(Brightness.dark),
      themeMode: sombre ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
