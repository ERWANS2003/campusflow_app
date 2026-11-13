# Séance 2 · Persona et job stories

## Persona : Amina Ouédraogo *(personne fictive)*

| | |
|---|---|
| **Âge, études** | 22 ans, Master 1 Informatique, Ouagadougou |
| **Appareil** | Smartphone Android d'entrée de gamme (écran 6,5 pouces, 3 Go de RAM, stockage presque plein) |
| **Connexion** | Forfait mobile limité, Wi-Fi seulement à l'université ; coupures fréquentes |
| **Usage** | Utilise son téléphone d'une main, souvent dans les transports ; écrit les dates dans un cahier et sur WhatsApp |
| **Contexte** | 6 cours ce semestre, des projets en binôme, un stage à trouver |
| **Frustration** | Les échéances sont dispersées : e-mails des enseignants, plateforme de l'université, groupes WhatsApp. Elle découvre parfois un rendu la veille. |
| **Objectif** | Ne plus rater un rendu, et savoir en un coup d'œil ce qui l'attend cette semaine. |
| **Citation** | « J'ai toutes les dates, mais jamais au même endroit. » |

**Ce que le persona impose à la conception :**
- une liste lisible en quelques secondes, sans fouiller ;
- ajouter une tâche en 3 appuis, à une main ;
- une appli légère, qui affiche un message clair quand le réseau coupe ;
- de gros boutons (48 dp minimum) et un texte qui reste lisible agrandi.

## Job stories

Modèle : **Quand** [situation], **je veux** [action], **pour** [résultat].

1. **Quand** un rendu approche, **je veux** voir ce qui est dû cette semaine, **pour** planifier mon travail sans ouvrir trois applications.
2. **Quand** un enseignant annonce une nouvelle échéance en cours, **je veux** l'ajouter en quelques secondes depuis mon téléphone, **pour** ne pas oublier de la recopier plus tard.

Chaque job story se traduit en écran :

| Job story | Écran | Mesure de réussite |
|---|---|---|
| 1. Voir la semaine | Échéances, groupe « Cette semaine » en tête après les retards | L'information est visible dès l'ouverture, 0 appui |
| 2. Ajouter vite | Bouton « Nouvelle tâche » → titre → Enregistrer | 3 appuis, valeurs par défaut pour le reste (cours, date de demain, rappel 1 jour avant) |
