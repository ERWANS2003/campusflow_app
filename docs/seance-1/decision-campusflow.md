# Séance 1 · Décision pour CampusFlow

**Cible.** CampusFlow s'adresse aux étudiants de licence et de master des universités d'Afrique francophone, à commencer par le Burkina Faso. Ils utilisent surtout des smartphones Android de gamme moyenne ou d'entrée de gamme, avec peu de mémoire, une connexion mobile parfois coûteuse ou instable, et partagent parfois leur appareil.

**Plateformes.** Android est la priorité absolue : environ 83 % de l'usage mobile en Afrique contre 16 % pour iOS (StatCounter, début 2026), un développement possible sur nos PC Windows, une publication peu coûteuse et la possibilité de distribuer l'APK hors magasin. iOS reste souhaitable pour les étudiants qui en possèdent, mais pas au prix d'un deuxième développement, puisque l'équipe n'a pas de Mac et que le compte Apple Developer est payant chaque année.

**Approche.** Nous retenons une approche **cross-platform avec Flutter** plutôt que le natif. Une seule base de code en Dart produit l'application Android tout de suite, et la version iOS pourra être compilée plus tard sur un Mac sans réécriture. L'autopsie de Windows Phone montre qu'une petite équipe ne peut pas entretenir plusieurs applications : un seul code concentre l'effort sur la qualité. Nous acceptons les compromis de Flutter : une application plus lourde (le moteur est embarqué), d'où une attention particulière à la taille et aux appareils modestes, et une interface dessinée par Flutter plutôt que native.

**En résumé :** Android d'abord, avec Flutter, pour garder iOS ouvert sans doubler le travail.
