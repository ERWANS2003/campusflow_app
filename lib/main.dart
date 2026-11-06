import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'state/campus_store.dart';

Future<void> main() async {
  await initializeDateFormatting('fr'); // noms de jours et de mois en français
  runApp(CampusFlowApp(store: CampusStore()));
}
