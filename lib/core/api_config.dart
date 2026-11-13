import 'package:flutter/foundation.dart';

/// Adresse de l'API json-server (dossier server/).
///
/// Sur l'émulateur Android, `localhost` désigne l'émulateur lui-même :
/// le PC qui fait tourner le serveur s'appelle 10.0.2.2.
/// Téléphone réel sur le même Wi-Fi : passer l'adresse du PC,
/// `flutter run --dart-define=API_URL=http://192.168.1.20:3000`.
String adresseApi() {
  const imposee = String.fromEnvironment('API_URL');
  if (imposee.isNotEmpty) return imposee;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
