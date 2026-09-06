JWAIO 0.3_Alpha - journaux prives de la radio

F*.csv : donnees du vol, une ligne par seconde pendant l'armement.
E*.csv : evenements de diagnostic (armement, validite, demandes audio, Finder).
lastpos.txt : derniere position GPS valide.
lastdistance.txt : distance maximale et trajet total conserves.

Les demandes audio journalisees ne prouvent pas qu'un son a ete entendu.
Conservez les fichiers bruts. Copiez-les sur PC avant analyse ou suppression.
Pour Open Drone Log, convertissez F*.csv avec tools/jwaio_to_opendronelog.py.
E*.csv est un diagnostic, pas une trace GPS a importer.
Sans GPS, les champs de position restent vides.

Ce dossier peut contenir des positions personnelles : ne pas le publier.
Gardez LOGS/JWAIO en place tant que le widget est installe.
