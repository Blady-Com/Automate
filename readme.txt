Générateur Ada d'automates à états finis.

1) les sources :

. programme de génération d'automates (src) :
arbmgr.adb
arbmgr.ads
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
srcseq.in

. programme exemple (robot) :
eventmgr.adb
eventmgr.ads
robot.adb
robseq.adb
robseq.ads
robseq.auto
robseq.in

2) description :

  a) plateforme :
Les programmes ont été compilés et testés avec GNAT GPL 2016 sur macOS 10.11.

  b) création des exécutables :
Programme 'genauto' : gnatmake genauto.adb
Programme 'robot'   : cd robot; gnatmake -gnatW8 robot.adb
(option -gnatW8 pour prendre correctement en compte les touches fléchées)

  c) mode d'emploi :
Toutes les explications nécessaires au fonctionnement des programmes
se trouve dans le texte Automate_Ada.pdf.
Génération des package des automates srcseq et robseq :
cd src; ../obj/genauto < srcseq.in
cd robot; ../obj/genauto < robseq.in
L'affichage de chaque étape de la traduction s'active en positionnant à True
la constante Debug dans genauto.adb.

3) Mode pour SubEthaEdit (SEE - www.codingmonkeys.de/subethaedit)

Le mode AutoScript.mode pour SEE active la coloration de la syntaxe propre à la
description des automates.
Le mode doit être placé dans:
~/Library/Application Support/SubEthaEdit/Modes/AutoScript.mode
ou
/Library/Application Support/SubEthaEdit/Modes/AutoScript.mode
SEE reconnaît alors automatiquement la syntaxe de l'automate au moyen de
l'extension ".auto".
Pour cela les fichiers sources des automates ont vu leur extension changée
de ".txt" en ".auto".

4) Historiques :
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

Pascal Pignard, mai 2001, janvier 2002, juillet 2008, mars 2017.

