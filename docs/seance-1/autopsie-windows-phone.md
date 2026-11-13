# Séance 1 · Autopsie d'un système : Windows Phone

**Système choisi :** Windows Phone, devenu Windows 10 Mobile, de Microsoft.
**Vie :** lancé fin 2010 (Windows Phone 7), fin du support le **10 décembre 2019** [1].

Microsoft lui-même a écrit l'acte de décès : sa page de fin de support recommande aux utilisateurs de **passer à un appareil Android ou iOS** [1].

## Trois causes, classées par poids

### 1. Écosystème d'applications : le cercle vicieux (cause principale)

C'est la cause la plus lourde, et Microsoft l'a reconnue publiquement. En octobre 2017, Joe Belfiore, vice-président du groupe Systèmes d'exploitation, a expliqué que Microsoft avait « essayé très fort » d'attirer les développeurs, allant jusqu'à les payer et à écrire des applications pour eux, mais que **le nombre d'utilisateurs était trop faible** pour que les entreprises investissent [2].

C'est exactement l'effet de réseau vu en cours : peu d'utilisateurs → peu d'applications → peu d'utilisateurs. Belfiore a ajouté que lui-même avait changé de plateforme pour la diversité des applications [2].

*Famille du cours : écosystème d'applications.*

### 2. Stratégie et timing : arrivé tard, changé de cap souvent

Windows Phone 7 sort fin 2010, **trois ans après l'iPhone** (2007) et deux ans après le premier Android (2008) : le marché est déjà partagé entre deux écosystèmes. Microsoft rachète ensuite la division téléphones de Nokia pour environ 7,2 milliards de dollars (annoncé en 2013, finalisé en 2014). Dès **juillet 2015**, il en déprécie environ **7,6 milliards** et supprime environ **7 800 postes**, surtout dans les téléphones ; Satya Nadella annonce qu'il ne cherche plus à développer une activité téléphones autonome [3].

Racheter un constructeur puis l'abandonner en un an montre une stratégie instable : les développeurs et les acheteurs n'avaient aucune raison de parier sur la plateforme.

*Famille du cours : stratégie et timing.*

### 3. Modèle de plateforme : ni ouvert, ni intégré

Windows Phone imposait des règles strictes aux constructeurs (comme Apple), sans contrôler leur matériel (comme Android). Résultat : il n'avait ni la variété de prix d'Android, ni l'expérience intégrée d'iOS. Au moment du rachat raté, IDC estimait la part de marché de Windows sur smartphones à environ **3,2 %** pour 2015 [3].

*Famille du cours : modèle de plateforme.*

## Pourquoi cet ordre

| Rang | Cause | Pourquoi ce poids |
|---|---|---|
| 1 | Écosystème d'applications | Cause reconnue par Microsoft lui-même ; même l'argent n'a pas suffi à attirer les développeurs. |
| 2 | Stratégie et timing | Elle explique pourquoi l'écosystème n'a jamais démarré : arrivée tardive, puis rachat de Nokia abandonné. |
| 3 | Modèle de plateforme | Réelle, mais secondaire : avec assez d'applications, le modèle hybride aurait pu tenir. |

La rupture d'interface (clavier physique contre multitouch) ne s'applique pas ici : Windows Phone était tactile dès le départ.

## Ce que CampusFlow en retient

Une plateforme sans applications meurt, et un développeur seul n'a pas les moyens de viser une plateforme minoritaire. CampusFlow vise donc **les plateformes déjà majoritaires chez ses utilisateurs**, avec un seul code pour ne pas multiplier les coûts (voir [decision-campusflow.md](decision-campusflow.md)).

## Sources

1. Microsoft, [Windows 10 Mobile End of Support: FAQ](https://support.microsoft.com/en-us/help/4485197/windows-10-mobile-end-of-support-faq) : fin du support le 10 décembre 2019 et recommandation de passer à Android ou iOS.
2. Fortune, [Microsoft Confirms Windows Phone Is Dead](https://fortune.com/2017/10/09/microsoft-windows-phone-dead/), 9 octobre 2017, et GSMArena, [Microsoft confirms Windows Phone is dead](https://m.gsmarena.com/microsoft_windows_phone_dead-news-27612.php) : déclarations de Joe Belfiore.
3. TechCrunch, [Microsoft Writes Down $7.6B Of Its Nokia Acquisition, Announces 7,800 Layoffs](https://techcrunch.com/2015/07/08/microsoft-writes-down-7-6b-of-its-nokia-acquisition-announces-7800-layoffs), 8 juillet 2015, et PCWorld, [Microsoft restructuring Windows Phone business, slashes 7,800 jobs](https://www.pcworld.com/article/428456/microsoft-restructuring-windows-phone-business-slashes-7800-jobs.html) : dépréciation, suppressions de postes, part de marché IDC.
