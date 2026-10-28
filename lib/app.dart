import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/campus_store.dart';
import 'theme.dart';

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key, required this.store});

  final CampusStore store;

  @override
  Widget build(BuildContext context) {
    return CampusScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'CampusFlow',
          debugShowCheckedModeBanner: false,
          theme: campusTheme(Brightness.light),
          darkTheme: campusTheme(Brightness.dark),
          themeMode: store.themeSombre ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          // Connexion → Échéances · Cours · Profil
          home: store.utilisateur == null ? const LoginScreen() : const HomeShell(),
        ),
      ),
    );
  }
}
