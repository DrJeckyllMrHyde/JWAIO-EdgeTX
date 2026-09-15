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

Les 45 assertions de tests du moteur ont passé localement. Les essais antérieurs sur 11 copies d'archives ont vérifié le nettoyage et les sauvegardes. Les essais sur radio physique restent à réaliser. La suppression autorisée par l'utilisateur est définitive et une interruption matérielle peut laisser un nettoyage partiel.

## Suivi nécessaire

### Premier examen des indicateurs

Dans l'onglet [Behavior de VirusTotal](https://www.virustotal.com/gui/file/e41575b496a3298df5b76de15e7e0dd58d3c65d6170d98295e2b08f23129d8b3/behavior), CAPA associe l'indicateur T1027 à `System.Convert::ToBase64String` (« encode data using Base64 »). Dans `Engine.cs`, cet appel sert uniquement à représenter l'empreinte SHA-256 calculée pour vérifier les copies et détecter les modifications. Il ne masque pas une charge exécutable. Ce rapprochement explique cet indicateur CAPA, pas les cinq verdicts antivirus dont les critères détaillés ne sont pas fournis.

L'énumération des lecteurs et des dossiers correspond à la détection du stockage et à l'analyse ciblée. La présence de ces capacités ne suffit pas à qualifier le logiciel de malveillant. À la première consultation, les analyses dynamiques Zenbox et CAPE étaient encore en cours : aucune conclusion définitive n'en est tirée.

Les procédures de réexamen sont notamment documentées par [Malwarebytes](https://help.malwarebytes.com/hc/en-us/articles/31589211404571-Report-a-false-positive-to-Malwarebytes-Support), [Elastic](https://discuss.elastic.co/t/submitting-false-positives/232322) et [SecureAge](https://knowledgebase.secureage.com/secureaplus/en-us/Content/technical-information/reporting-false-positives-to-secureaplus.htm). Aucune réponse d'éditeur ni confirmation de faux positif n'a été obtenue.

Faire examiner le fichier exact par les éditeurs concernés avant d'affirmer qu'il s'agit de faux positifs. Chaque nouvel EXE, y compris une recompilation, nécessite sa propre empreinte et ses propres rapports. Aucune attestation d'innocuité n'est émise ici.

[Guide Cleaner](CLEANER.md) · [Retour au widget JWAIO](../README.md)
