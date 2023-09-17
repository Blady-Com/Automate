--------------------------------------------------------------------------------
-- NOM DU CSU (corps)               : BasicDef.adb
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 3.0a
-- DATE DE LA DERNIERE MISE A JOUR  : Octobre 2023
-- ROLE DU CSU                      : Unité de définition de types et procédures.
--
--
-- FONCTIONS EXPORTEES DU CSU       :
--
--
-- FONCTIONS LOCALES DU CSU         :
--
--
-- NOTES                            :
--
-- COPYRIGHT                        : (c) Pascal Pignard 2023
-- LICENCE                          : CeCILL V2.1 (https://cecill.info)
-- CONTACT                          : http://blady.pagesperso-orange.fr
--------------------------------------------------------------------------------

with Ada.Calendar;    use Ada.Calendar;
with Ada.Directories; use Ada.Directories;
with Ada.Strings;

package body BasicDef is

   -- Fonction qui, à partir du chemin complet d'un fichier, retourne le nom du fichier seul.
   function FSplitName (WithPath : UXString) return UXString is
   begin
      return From_UTF_8 (Simple_Name (To_UTF_8 (WithPath)));
   end FSplitName;

   --Renvoie le compteur horaire interne en milisecondes.
   function Horlogems return Natural is
   begin
      return Natural (Seconds (Clock) * 1_000.0);
   end Horlogems;

   -- Fonction retournant une chaîne sans le dernier élément séparé par un point
   function TruncLast (S : UXString) return UXString is
   begin
      return Head (S, Index (S, ".", Ada.Strings.Backward) - 1);
   end TruncLast;

end BasicDef;
