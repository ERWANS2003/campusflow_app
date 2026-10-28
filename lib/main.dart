import 'package:flutter/material.dart';

import 'app.dart';
import 'state/campus_store.dart';

void main() {
  runApp(CampusFlowApp(store: CampusStore()));
}
