import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  await initializeDateFormatting('fr'); // noms de jours et de mois en français
  runApp(
    // ProviderScope : le conteneur de tous les fournisseurs, à la racine.
    // retry: null désactive les nouvelles tentatives automatiques de Riverpod 3,
    // pour que l'erreur s'affiche avec son bouton « Réessayer ».
    ProviderScope(
      retry: (_, _) => null,
      child: const CampusFlowApp(),
    ),
  );
}
