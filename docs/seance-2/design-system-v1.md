# Séance 2 · Design system v1

Une page de référence : on définit une fois, on réutilise partout. En Flutter, tout est centralisé dans [`lib/core/theme.dart`](../../lib/core/theme.dart) (séance 4) : aucun écran n'écrit de couleur ni de taille en dur.

## 1. Couleurs

**Un seul accent : `#EC3013`** (rouge). La palette complète est générée par Material 3 avec `ColorScheme.fromSeed(seedColor: Color(0xFFEC3013))`, qui produit des teintes harmonisées et lisibles, en thème clair et en thème sombre.

| Rôle | Clair | Sombre | Usage |
|---|---|---|---|
| `primary` | `#904B3E` | `#FFB4A6` | Boutons principaux, en-têtes de groupe, onglet actif |
| `onPrimary` | `#FFFFFF` | `#561E14` | Texte sur un bouton principal |
| `primaryContainer` | `#FFDAD3` | `#733428` | Avatar des cours, fond d'icône |
| `secondaryContainer` | `#FFDAD3` | `#5D3F3A` | Carte de tâche sélectionnée (tablette) |
| `surface` | `#FFF8F6` | `#1A1110` | Fond des écrans |
| `onSurface` | `#231918` | `#F1DFDB` | Texte courant |
| `onSurfaceVariant` | `#534340` | `#D8C2BD` | Texte secondaire (cours, date) |
| `error` | `#BA1A1A` | `#FFB4AB` | Tâche en retard, messages d'erreur |

### Contraste du texte : objectif 4,5:1 (WCAG AA)

Rapports **mesurés** sur les couleurs réellement générées par Flutter :

| Texte / fond | Clair | Sombre | ≥ 4,5:1 ? |
|---|---|---|---|
| `onSurface` / `surface` (texte courant) | 16,35:1 | 14,42:1 | ✅ |
| `onSurfaceVariant` / `surface` (texte secondaire) | 8,91:1 | 10,93:1 | ✅ |
| `primary` / `surface` (en-têtes, liens) | 6,13:1 | 10,90:1 | ✅ |
| `onPrimary` / `primary` (bouton principal) | 6,44:1 | 7,75:1 | ✅ |
| `onPrimaryContainer` / `primaryContainer` | 7,21:1 | 7,21:1 | ✅ |
| `onSecondaryContainer` / `secondaryContainer` | 7,25:1 | 7,25:1 | ✅ |
| `error` / `surface` (retards, erreurs) | 6,16:1 | 10,93:1 | ✅ |

**Pourquoi ne pas écrire le texte directement en `#EC3013` ?** Du blanc sur `#EC3013` n'atteint qu'environ **4,2:1** : c'est assez pour une icône ou un grand logo (seuil de 3:1), mais pas pour du texte courant. L'accent pur est donc réservé au **logo** ; le texte utilise les teintes plus foncées générées par `fromSeed`.

## 2. Typographie

Police **Roboto** (Material), embarquée dans l'application (`assets/fonts`) pour fonctionner sans Internet. Échelle Material 3 :

| Style | Taille | Graisse | Usage |
|---|---|---|---|
| `headlineMedium` | 28 sp | Bold | Nom « CampusFlow » sur l'écran de connexion |
| `headlineSmall` | 24 sp | Bold | Titre d'une tâche dans le détail |
| `titleLarge` | 22 sp | Regular | Titre de la barre d'application |
| `titleSmall` | 14 sp | Bold | En-têtes de groupe (« Cette semaine · 3 ») |
| `bodyLarge` | 16 sp | Regular | Texte courant, description |
| `bodyMedium` | 14 sp | Regular | Sous-titre d'une carte (cours · date) |

Les tailles sont en **sp** : elles suivent la taille de texte choisie dans les réglages du téléphone, et l'écran doit rester utilisable à 200 % (aucune hauteur figée).

## 3. Espacements et formes

| Token | Valeur | Usage |
|---|---|---|
| `Tokens.s` | 8 dp | Petit écart, entre une icône et son texte |
| `Tokens.m` | 16 dp | Marges des écrans et des cartes |
| `Tokens.l` | 24 dp | Séparation des blocs |
| `Tokens.rayon` | 12 dp | Arrondi des cartes et des champs |
| `Tokens.cible` | **48 dp** | Hauteur minimale de toute zone d'appui |

## 4. Trois composants

| Composant | Anatomie | Règles |
|---|---|---|
| **Bouton principal** (`FilledButton`) | Fond `primary`, texte `onPrimary`, hauteur 48 dp, coins arrondis | Une seule action principale par écran (« Se connecter », « Marquer comme fait », « Enregistrer »). Désactivé pendant une requête, avec un indicateur de chargement. |
| **Carte de tâche** (`TaskCard`) | Case à cocher 48 dp · titre en gras · « cours · date » · chevron | Titre barré si faite ; sous-titre en couleur `error` si en retard ; libellé lu par le lecteur d'écran (titre, cours, échéance, état). |
| **Champ de saisie** (`TextFormField`) | Libellé flottant, bordure arrondie 12 dp, icône à gauche | Message d'erreur sous le champ (« Le titre est obligatoire. ») ; clavier adapté (e-mail) ; formulaire défilant pour ne jamais être caché par le clavier. |

## 5. Tailles de fenêtre visées

| Classe | Largeur | Navigation | Contenu |
|---|---|---|---|
| Compact (téléphone) | < 600 dp | Barre de navigation en bas | Une colonne ; le détail s'ouvre en plein écran |
| Moyen (petite tablette, pliable) | 600 à 839 dp | Rail de navigation à gauche | Une colonne |
| Étendu (tablette, paysage) | ≥ 840 dp de contenu | Rail de navigation à gauche | Liste et détail côte à côte |

Téléphone de référence pour les maquettes : **360 × 800 dp**.
