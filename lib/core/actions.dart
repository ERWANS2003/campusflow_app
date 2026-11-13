import 'package:flutter/material.dart';

import 'package:campusflow_app/core/api_exception.dart';

/// Lance une action réseau. En cas d'échec, l'erreur s'affiche dans un
/// SnackBar au lieu de faire planter l'écran. Renvoie true si tout s'est bien passé.
///
/// On passe le ScaffoldMessenger (et non le context) : il reste valable même si
/// l'écran se ferme pendant que la requête attend sa réponse.
Future<bool> tenter(ScaffoldMessengerState messages, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } on ApiException catch (e) {
    messages.showSnackBar(SnackBar(content: Text(e.message)));
    return false;
  }
}
