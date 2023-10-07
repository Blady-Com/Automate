Générateur Ada d'automates à états finis.

1) Les sources

. programme de génération d'automates (src) :
basicdef.adb
basicdef.ads
genauto.adb
insrc.adb
insrc.ads
outsrc.adb
outsrc.ads
srcseq.adb
srcseq.ads
srcseq.auto

. programme exemple (robot) :
eventmgr.adb
eventmgr.ads
robot.adb
robseq.adb
robseq.ads
robseq.auto

2) Description

  a) plateforme :
Toute plateforme avec un compilateur Ada 2012.
Les programmes ont été compilés et testés avec GNAT FSF 12.1 sur macOS 13.6.

  b) création des exécutables :
Programme 'genauto' : gprbuild -P automate.gpr genauto.adb
Programme 'robot'   : gprbuild -P automate.gpr robot.adb

  c) mode d'emploi :
Toutes les explications nécessaires au fonctionnement des programmes
se trouve dans le texte Automate_Ada.pdf.
Génération des package des automates srcseq et robseq :
cd src; ../bin/genauto srcseq.auto
cd robot; ../bin/genauto robseq.auto
L'affichage de chaque étape de la traduction s'active en positionnant à True
la constante Debug dans genauto.adb.

3) Mode d'affichage syntaxique pour SubEthaEdit (SEE - www.codingmonkeys.de/subethaedit)

Le mode AutoScript.mode pour SEE active la coloration de la syntaxe propre à la
description des automates.
Le mode doit être placé dans:
$HOME/Library/Application Support/SubEthaEdit/Modes/AutoScript.mode
SEE reconnaît alors automatiquement la syntaxe de l'automate au moyen de
l'extension ".auto".

4) Mode d'affichage syntaxique pour BBEdit (www.barebones.com/products/bbedit)

Le mode AutoScript.plist pour BBEdit active la coloration de la syntaxe propre à la
description des automates.
Le mode doit être placé dans:
$HOME/Library/Application Support/BBEdit/Language Modules/AutoScript.plist
BBEdit reconnaît alors automatiquement la syntaxe de l'automate au moyen de
l'extension ".auto".

5) Historique

- 3.0a : utilisation de UXStrings et Ada.Containers.Ordered_Maps
         paramètres de l'automate déplacés dans le fichier de description
         invocation du fichier de description de l'automate en ligne de commande
         instructions de débug déplacées dans le fichier description
- 2.2b : corrections mineures (perte de mémoire, suppression attribut class, vérification des null)
- 2.2a : ajout de la prise en compte des commentaires d'une seule ligne
         commençant par --, les unités externes ne sont plus mises dans l'unité
         spécification générée, le mode Debug affiche les éléments chaînés
         par un +, le status de terminaison du programme est rendu à l'OS,
         quelques fonctions utilitaires sont réécrites avec la nouvelle
         bibliothèque Ada 2005. Coloration de la syntaxe propre à l'automate
         avec l'utilitaire SubEthaEdit.
- 2.1a : deuxième version publique an Ada.
- 1.0a : première version publique en Pascal.

6) Licence

Tous les fichiers sont fournis au titre de la licence CeCILL (https://cecill.info) version 2.1

Pascal Pignard, mai 2001, janvier 2002, juillet 2008, mars 2017, octobre 2023.
