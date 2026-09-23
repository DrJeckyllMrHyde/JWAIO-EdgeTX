# JWAIO Cleaner — rapports antivirus

**Résultat au 15 septembre 2026 : VirusTotal signale 5 détections sur 69 moteurs ; Jotti ne signale aucune détection sur 13 moteurs.** Ce fichier ne doit pas être présenté comme « certifié inoffensif » ou comme ayant zéro alerte antivirus.

## Fichier analysé

| Propriété | Valeur |
|---|---|
| Nom | `JWAIO-Cleaner.exe` |
| Version | 0.1 Preview |
| Taille | 299 520 octets |
| SHA-256 | `e41575b496a3298df5b76de15e7e0dd58d3c65d6170d98295e2b08f23129d8b3` |
| SHA-1 | `6d164c8a9df3bd2cfccb1e78b9517cf4d09640f8` |
| MD5 | `291eba5d25c27817344c81959e6034f1` |
| Signature Authenticode | Non signé |

## Rapports publics

| Service | Résultat observé | Date de l'analyse |
|---|---|---|
| [VirusTotal — rapport du fichier](https://www.virustotal.com/gui/file/e41575b496a3298df5b76de15e7e0dd58d3c65d6170d98295e2b08f23129d8b3/detection) | **5/69 détections** | 15/09/2026, 08:13:34, Europe/Paris |
| [Jotti — rapport 5gc2mp87km](https://virusscan.jotti.org/fr-FR/filescanjob/5gc2mp87km) | **0/13 détections** | 15/09/2026, 08:12:25, Europe/Paris |

Les listes des moteurs se recoupent : on ne doit pas additionner les dénominateurs pour prétendre à 82 antivirus indépendants. Les rapports en ligne peuvent évoluer après de nouvelles analyses.

### Détections VirusTotal observées

| Moteur | Libellé |
|---|---|
| Arctic Wolf | `Unsafe` |
| Elastic | `Malicious (high Confidence)` |
| Malwarebytes | `MachineLearning/Anomalous.96%` |
| MaxSecure | `Trojan.Malware.300983.susgen` |
| SecureAge | `Malicious` |

Plusieurs libellés sont génériques ou issus de modèles d'apprentissage automatique. Cela ne suffit pas à conclure à des faux positifs. Microsoft, Bitdefender, Kaspersky, ESET et Avast, entre autres, n'affichaient pas de détection dans le rapport VirusTotal observé. Cette absence de détection n'annule pas les cinq alertes.

## Vérifier son téléchargement

Téléchargez uniquement depuis la release du dépôt **DrJeckyllMrHyde/JWAIO-EdgeTX**. Dans PowerShell, depuis le dossier contenant le fichier :

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath .\JWAIO-Cleaner.exe
```

Le SHA-256 doit être exactement celui indiqué ci-dessus. Une empreinte identique établit que les rapports concernent votre fichier ; elle ne prouve pas à elle seule son innocuité. Si elle diffère, ces rapports ne s'appliquent pas à votre téléchargement.

Ne désactivez pas votre antivirus et n'ajoutez pas d'exclusion pour lancer le programme. Si votre protection le bloque, utilisez la [désinstallation manuelle](INSTALLATION.md#désinstaller) en attendant l'examen des alertes.

## Contrôles complémentaires

Le [code source](../tools/JWAIO-Cleaner/) est disponible. Le programme est conçu pour analyser uniquement les dossiers JWAIO/SIXTY9 du stockage sélectionné, sauvegarder les skins demandés, puis supprimer les fichiers après confirmation. Il ne contient pas de fonction de téléchargement, d'installation, de modification du registre ou de désactivation d'antivirus. Ces observations sur le code ne remplacent pas une expertise indépendante du binaire.

Les 45 vérifications automatisées du moteur ont réussi sur l'ordinateur de développement. Les essais antérieurs sur 11 copies d'archives ont vérifié le nettoyage et les sauvegardes. J'ai ensuite testé le logiciel avec succès sur des radios physiques **RadioMaster TX15 et TX16**, sans problème constaté. La suppression autorisée par l'utilisateur est définitive et une interruption matérielle peut laisser un nettoyage partiel.

## Suivi nécessaire

### Premier examen des indicateurs

Dans l'onglet [Behavior de VirusTotal](https://www.virustotal.com/gui/file/e41575b496a3298df5b76de15e7e0dd58d3c65d6170d98295e2b08f23129d8b3/behavior), CAPA associe l'indicateur T1027 à `System.Convert::ToBase64String` (« encode data using Base64 »). Dans `Engine.cs`, cet appel sert uniquement à représenter l'empreinte SHA-256 calculée pour vérifier les copies et détecter les modifications. Il ne masque pas une charge exécutable. Ce rapprochement explique cet indicateur CAPA, pas les cinq verdicts antivirus dont les critères détaillés ne sont pas fournis.

L'énumération des lecteurs et des dossiers correspond à la détection du stockage et à l'analyse ciblée. La présence de ces capacités ne suffit pas à qualifier le logiciel de malveillant.

Après disponibilité des rapports CAPE et Zenbox, le résumé affiche « NOT FOUND » pour les détections comportementales, les communications réseau et les fichiers déposés, mais comporte deux règles Sigma de niveau moyen. Cela ne vaut pas validation : des actions système et indicateurs supplémentaires sont présents.

La règle « Unsigned Image Loaded Into LSASS Process » concerne `C:\13iiahz0\dll\JKUVuYr.dll`, chargé dans `C:\Windows\System32\lsass.exe`, avec le SHA-256 `0bf011593b5cff9f46909e5998786e30d98440bffe7251163570ca11cd38e07c`. Ce n'est pas l'empreinte de Cleaner. L'origine de cette DLL et le lien causal avec Cleaner ne sont pas établis par le résumé consulté. Elle peut relever de l'environnement d'analyse ; cette hypothèse reste à confirmer. La seconde règle est « Sysmon File Executable Creation Detected ». Les événements regroupés ne permettent pas de lever les cinq verdicts antivirus.

Une comparaison locale, sans exécuter le fichier analysé, a confronté l'EXE original à une nouvelle compilation des sources : les empreintes des corps IL de **81 méthodes/constructeurs**, les **2 ressources intégrées** et les **5 références d'assemblages .NET** correspondent. Ce contrôle partiel confirme la concordance du code compilé inspecté et des images ; ce n'est ni une comparaison exhaustive de toutes les métadonnées ni une attestation d'innocuité.

**État au 16 septembre 2026 : j'ai autorisé la publication de la Preview avec les résultats des analyses, malgré les alertes non résolues.** Le binaire de la release est strictement celui analysé ; son SHA-256 a été revérifié dans les pièces jointes GitHub. La compilation et les tests GitHub Actions ont également réussi. Aucun binaire n'est diffusé dans les artefacts publics des workflows.

Les procédures de réexamen sont notamment documentées par [Malwarebytes](https://help.malwarebytes.com/hc/en-us/articles/31589211404571-Report-a-false-positive-to-Malwarebytes-Support), [Elastic](https://discuss.elastic.co/t/submitting-false-positives/232322) et [SecureAge](https://knowledgebase.secureage.com/secureaplus/en-us/Content/technical-information/reporting-false-positives-to-secureaplus.htm). Aucune décision d'analyste ni confirmation de faux positif n'a été obtenue. Malwarebytes a accusé réception sous le ticket 8601862, Elastic a enregistré son formulaire et SecureAge a confirmé la transmission du fichier à son équipe de détection.

### Demandes de réexamen envoyées

Le 16 septembre 2026, j'ai autorisé la transmission du fichier public, de ses empreintes, des sources et des éléments techniques aux cinq éditeurs concernés. Les demandes ont été envoyées à **Elastic**, **Malwarebytes**, **SecureAge**, **Arctic Wolf** et **MaxSecure**. Malwarebytes a créé le ticket privé **8601862** ; Elastic a confirmé l'enregistrement de son formulaire ; SecureAge a confirmé le téléversement du fichier exact de 299 520 octets et sa transmission à l'équipe de détection. Les demandes Arctic Wolf et MaxSecure ont été adressées aux contacts publiés par VirusTotal.

Ces accusés d'envoi ne constituent ni une réponse d'analyste, ni une confirmation de faux positif, ni une levée des détections. Les coordonnées personnelles du contact ne sont pas publiées dans ce rapport. La prochaine mise à jour devra consigner séparément chaque réponse et revérifier le rapport VirusTotal du même SHA-256.

Faire examiner le fichier exact par les éditeurs concernés avant d'affirmer qu'il s'agit de faux positifs. Chaque nouvel EXE, y compris une recompilation, nécessite sa propre empreinte et ses propres rapports. Aucune attestation d'innocuité n'est émise ici.

## Diagnostic complémentaire et possibilités de correction

Contrôle du fichier original du 15 septembre 2026 : SHA-256 inchangé, signature Authenticode absente, champs FileDescription, CompanyName et ProductName vides, FileVersion et ProductVersion à `0.0.0.0`. La version annoncée « 0.1 Preview » n'est donc pas renseignée dans les propriétés Windows de cet EXE.

### Ce que les alertes permettent de conclure

- **Malwarebytes** : selon sa [documentation officielle](https://www.malwarebytes.com/blog/detections/machinelearning-anomalous-100), la famille MachineLearning/Anomalous mesure un écart par rapport aux fichiers légitimes du jeu d'entraînement. Le « 96 % » observé ne doit pas être présenté comme une probabilité de 96 % que Cleaner soit un virus. Les caractéristiques précises responsables de ce score ne sont pas publiées pour ce fichier.
- **Arctic Wolf, Elastic, MaxSecure et SecureAge** : les libellés du rapport ne désignent ni une ligne de code à corriger ni une preuve exploitable de compromission. Le mot Trojan dans un libellé générique ne permet pas, seul, d'attribuer une famille ou un comportement précis.
- **Indicateur CAPA** : l'encodage Base64 a une fonction légitime vérifiée dans le code (comparaison d'empreintes SHA-256). Remplacer cet encodage ne constituerait pas une correction de sécurité démontrée et ne garantirait pas de lever les cinq alertes.
- **Événement LSASS** : l'attribution reste ouverte comme indiqué plus haut. Il ne faut ni l'imputer à Cleaner sans preuve ni l'écarter comme instrumentation de sandbox sans confirmation.

### Corrections possibles, avec leurs limites

1. **Renseigner l'identité du produit et sa version dans la compilation suivante.** C'est une amélioration concrète de traçabilité pour Windows et les analystes ; aucun lien causal avec les cinq verdicts n'est établi. Ce changement n'a pas été appliqué au binaire analysé.
2. **Signer la future release avec une identité vérifiée.** Cela permet d'identifier l'éditeur et de vérifier l'intégrité. Cela nécessite un certificat ou service de signature et une validation d'identité ; aucune signature n'a été ajoutée. [Microsoft](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation) précise que même un EXE signé peut encore présenter un avertissement SmartScreen. SmartScreen et les cinq détections VirusTotal sont des mécanismes distincts.
3. **Faire réexaminer le fichier exact par les cinq éditeurs.** C'est la voie pertinente pour faire corriger un faux positif confirmé. [VirusTotal](https://docs.virustotal.com/docs/false-positive) agrège les verdicts et renvoie leur correction aux éditeurs concernés. Le 16 septembre 2026, les cinq demandes ont été transmises avec l'empreinte, les libellés, le rapport public, les sources et le signalement de l'événement LSASS dont l'attribution reste incertaine.
4. **Vérifier ensuite la décision et le binaire destiné à la diffusion.** Après réponse des éditeurs, relancer l'analyse du fichier exact. Toute modification ou signature crée un nouveau fichier à analyser séparément.

**Bilan de cet examen :** des faux positifs sont possibles, mais ils ne sont pas confirmés. Aucune cause précise commune aux cinq moteurs et aucun correctif de code levant leurs alertes n'ont été établis. Le binaire original est conservé sans modification. Le 16 septembre 2026, j'ai autorisé sa publication en Preview avec ces résultats explicitement indiqués ; cette décision ne lève pas les alertes.

[Guide Cleaner](CLEANER.md) · [Retour au widget JWAIO](../README.md)
