# JWAIO Cleaner

Outil portable Windows 10/11 pour désinstaller JWAIO, avec conservation optionnelle des skins et journaux de vol.

**La release reste en brouillon pendant l'examen des alertes antivirus. Aucun EXE public pour le moment.**

[Guide débutant](../../docs/CLEANER.md) · [Rapports antivirus](../../docs/CLEANER-ANTIVIRUS.md) · [Retour au widget JWAIO](../../README.md)

## Construire et tester

Depuis PowerShell sur Windows 10/11 standard :

```powershell
.\build-windows.ps1
.\test-windows.ps1
```

Le binaire et son SHA-256 sont produits dans `dist/`. Le script de tests crée un dossier temporaire dédié et en affiche le chemin ; ces fichiers de développement sont conservés pour inspection. L'application distribuée n'effectue aucune de ces écritures de test.

`Engine.cs` contient le moteur de détection, sauvegarde et suppression. `Program.cs` contient l'interface. `Tests.cs` vérifie les choix de conservation et les erreurs ; `ArchiveTests.cs` sert aux essais sur des copies d'archives extraites. Le compilateur est celui du .NET Framework fourni par Windows. Aucun téléchargement de bibliothèque n'est nécessaire.

GitHub Actions compile et teste le programme sans exposer de binaire téléchargeable pendant l'examen des alertes. Chaque nouvel EXE doit être analysé séparément avant publication : une recompilation peut changer l'empreinte, même sans modification du code. Les rapports de la Preview ne valent que pour le SHA-256 indiqué.

Code sous la licence Apache-2.0 du dépôt. Les visuels JWAIO existants restent soumis à [LICENSE-ASSETS.md](../../LICENSE-ASSETS.md).
