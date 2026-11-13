import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Preferences = ({bool rappels, bool themeSombre});

/// Préférences du profil, lues aussi par MaterialApp (thème) et le détail (rappel).
class PreferencesNotifier extends Notifier<Preferences> {
  @override
  Preferences build() => (rappels: true, themeSombre: false);

  void changerRappels(bool valeur) => state = (rappels: valeur, themeSombre: state.themeSombre);

  void changerTheme(bool sombre) => state = (rappels: state.rappels, themeSombre: sombre);
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, Preferences>(PreferencesNotifier.new);
