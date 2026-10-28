// Formatage des dates en français, sans dépendance externe.

const _jours = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
const _mois = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

DateTime _jour(DateTime d) => DateTime(d.year, d.month, d.day);

/// Nombre de jours calendaires entre aujourd'hui et [d] (négatif si passé).
int ecartEnJours(DateTime d, {DateTime? maintenant}) =>
    _jour(d).difference(_jour(maintenant ?? DateTime.now())).inDays;

/// « aujourd'hui », « demain », « ven. », « il y a 3 j », « 12 nov. »
String jourRelatif(DateTime d, {DateTime? maintenant}) {
  final ecart = ecartEnJours(d, maintenant: maintenant);
  return switch (ecart) {
    0 => "aujourd'hui",
    1 => 'demain',
    -1 => 'hier',
    > 1 && < 7 => '${_jours[d.weekday - 1].substring(0, 3)}.',
    < -1 && > -7 => 'il y a ${-ecart} j',
    _ => '${d.day} ${_mois[d.month - 1]}',
  };
}

/// « 17 h », « 23 h 59 »
String heure(DateTime d) =>
    d.minute == 0 ? '${d.hour} h' : '${d.hour} h ${d.minute.toString().padLeft(2, '0')}';

/// « vendredi 30 oct. à 17 h »
String dateLongue(DateTime d) =>
    '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]} à ${heure(d)}';

/// « 1 jour avant », « 2 h avant »
String libelleRappel(Duration? rappel) {
  if (rappel == null) return 'Aucun';
  if (rappel.inDays >= 1) {
    return '${rappel.inDays} jour${rappel.inDays > 1 ? 's' : ''} avant';
  }
  return '${rappel.inHours} h avant';
}
