--------------------------------------------------------------------------------
-- NOM DU CSU (spécification)       : BasicDef.ads
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

with UXStrings; use UXStrings;
with UXStrings.Conversions;

package BasicDef is

   -- Fonction qui, à partir du chemin complet d'un fichier, retourne le nom du fichier seul.
   function FSplitName (WithPath : UXString) return UXString;

   --Renvoie le compteur horaire interne en milisecondes.
   function Horlogems return Natural;

   -- Fonction retournant une chaîne sans le dernier élément séparé par un point
   function TruncLast (S : UXString) return UXString;

   function Image is new UXStrings.Conversions.Integer_Image (Natural);

end BasicDef;
