# Séance 1 · Fiche comparative Android / iOS

**Cas réel :** CampusFlow, application étudiante de suivi des échéances, destinée à l'**Afrique francophone** (Burkina Faso en premier).

Pour chacun des 14 critères du cours : ce qui distingue les deux systèmes, puis **ce que ça change dans notre contexte**.

## Conception

| # | Critère | Android | iOS | Ce que ça change en Afrique francophone |
|---|---|---|---|---|
| 1 | Philosophie | Open source (AOSP), nombreux constructeurs | Fermé, Apple contrôle matériel et logiciel | Android existe à tous les prix, y compris des modèles d'entrée de gamme (Tecno, Infinix, itel, Samsung A) : c'est ce que les étudiants peuvent s'offrir. |
| 2 | Architecture | Noyau Linux, HAL, ART, Framework | Darwin/XNU, Core OS, Core Services, Media, Cocoa Touch | Pas d'impact direct pour l'étudiant ; Flutter masque ces différences au développeur. |
| 3 | Environnement | Android Studio sur Windows, macOS, Linux | Xcode, **macOS uniquement** | Les étudiants développeurs ont surtout des PC Windows : développer et tester pour Android ne demande aucun achat. |
| 4 | Langage | Kotlin (Java), Jetpack Compose | Swift, SwiftUI / UIKit | Deux langages = deux compétences. Avec Flutter, un seul langage (Dart) pour les deux. |
| 5 | Modèle d'application | Activités, services ; paquet APK / AAB | Scènes, vues ; paquet IPA | Un APK peut se partager hors magasin (Bluetooth, clé USB, WhatsApp), pratique quand les données mobiles sont chères. Impossible sur iOS. |
| 6 | Cycle de vie | onCreate → onResume → onPause → onDestroy | Active → inactive → arrière-plan → suspendue | Sur les téléphones à peu de mémoire, Android tue souvent l'appli en arrière-plan : il faut sauvegarder l'état (session, formulaire). |
| 7 | Matériel | Très nombreux modèles et gammes | Quelques modèles, un seul constructeur | Écrans de 5 à 7 pouces, peu de RAM, stockage limité : l'appli doit rester légère et adaptative. |

## Exploitation

| # | Critère | Android | iOS | Ce que ça change en Afrique francophone |
|---|---|---|---|---|
| 8 | Permissions | Demandées à l'exécution, permission par permission | Demandées à l'exécution, avec un texte justificatif | CampusFlow ne demande que l'accès Internet et, plus tard, les notifications : moins de permissions = plus de confiance. |
| 9 | Stockage | Bac à sable, stockage cloisonné, **Keystore** | Bac à sable, **Keychain** | Téléphones souvent prêtés ou partagés : le jeton de connexion doit être chiffré (flutter_secure_storage utilise Keystore / Keychain). |
| 10 | Sécurité | Signature, Play Protect, bac à sable | Signature, revue App Store, bac à sable | Les installations hors Play Store sont fréquentes : il faut signer l'APK et le diffuser depuis une source officielle (site de l'université). |
| 11 | Distribution | Google Play, autres magasins, installation directe | App Store ; ouverture variable selon la région | Compte Google Play à paiement unique ; compte Apple Developer payant chaque année. Pour un projet étudiant, Android coûte bien moins cher. |
| 12 | Fragmentation | Forte : versions, constructeurs, tailles d'écran | Faible : adoption rapide des nouvelles versions | Beaucoup d'appareils anciens circulent : viser un SDK minimum raisonnable (Android 7, API 24) et tester sur un émulateur modeste. |
| 13 | Mises à jour | Selon le constructeur et l'opérateur | Directes par Apple | Beaucoup de téléphones ne reçoivent plus de mise à jour : ne pas dépendre de fonctions récentes du système. |
| 14 | Contraintes développeur | Tests sur de nombreux appareils | Mac obligatoire, revue App Store | Sans Mac, la version iOS ne peut pas être compilée ni publiée par l'équipe : elle doit attendre un Mac (ou un service de build). |

## Le marché, qui change tout

| Zone | Android | iOS | Source |
|---|---|---|---|
| Monde (sept. 2026) | 69,17 % | 30,81 % | StatCounter Global Stats, OS mobile, pages vues web |
| Afrique (début 2026) | ≈ 83 % | ≈ 15,8 % | StatCounter, relevé MobiLoud « Android vs iOS Market Share » |
| Amérique du Nord (début 2026) | ≈ 41 % | ≈ 58,7 % | même source |

Ces chiffres mesurent l'**usage web** (part des pages vues), pas le nombre d'appareils ni les ventes (voir la lecture critique de la séance 1). Ils sont à revérifier sur [gs.statcounter.com](https://gs.statcounter.com) au moment de lire cette fiche.

**Conclusion de la fiche :** en Afrique francophone, la question n'est pas « Android ou iOS ? » mais « Android d'abord, iOS sans coût en plus si possible ». La décision est rédigée dans [decision-campusflow.md](decision-campusflow.md).
