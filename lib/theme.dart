import 'package:flutter/material.dart';

/// Design system de CampusFlow (séance 2) : tokens définis une fois,
/// réutilisés partout.
abstract final class Tokens {
  // Couleur
  static const accent = Color(0xFFEC3013); // un seul accent

  // Espacements
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;

  // Arrondi
  static const rayon = 12.0;

  // Cible tactile minimale (Material : 48 dp)
  static const cible = 48.0;

  // Classes de taille de fenêtre (Material 3)
  static const moyen = 600.0; // rail de navigation
  static const etendu = 840.0; // liste et détail côte à côte
}

ThemeData campusTheme(Brightness luminosite) {
  final couleurs = ColorScheme.fromSeed(
    seedColor: Tokens.accent,
    brightness: luminosite,
  );

  return ThemeData(
    colorScheme: couleurs,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: Tokens.m, vertical: Tokens.s / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.rayon),
        side: BorderSide(color: couleurs.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, Tokens.cible)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, Tokens.cible)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Tokens.rayon)),
    ),
  );
}
