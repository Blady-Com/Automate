--------------------------------------------------------------------------------
-- NOM DU CSU (spécification)       : ArbMgr.ads
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 2.0b
-- DATE DE LA DERNIERE MISE A JOUR  : 1 mai 2001
-- ROLE DU CSU                      : Unité de gestion d'un arbre binaire.
--
--
-- FONCTIONS EXPORTEES DU CSU       : Ajoute, Balance, Recherche,
--                                    RetournePremier, RetourneSuivant, Detruit
--
-- FONCTIONS LOCALES DU CSU         :
--
--
-- NOTES                            :
--
-- COPYRIGHT                        : (c) Pascal Pignard 2001
-- LICENCE                          : CeCILL V2.1 (https://cecill.info)
-- CONTACT                          : http://blady.pagesperso-orange.fr
--------------------------------------------------------------------------------

generic

   -- Type de la clef de tri
   type TClef is private;

   -- Type des éléments triés suivant la clef
   type TElement is private;

   -- Element neutre indiquant notamment une recherche non aboutie
   NonDefini : TElement;

   -- Appel à la fonction Balance automatiquement lors d'un accès
   AutoBal : Boolean := True;

   -- Relation d'ordre de la clef de tri
   with function "<" (Left, Right : TClef) return Boolean is <>;

package ArbMgr is

   -- Procédures assurant la gestion de l'arbre binaire.
   procedure Ajoute (Clef : TClef; Element : TElement);
   procedure Balance;
   procedure Recherche (Clef : TClef; Element : out TElement);
   function RetournePremier return TElement;
   function RetourneSuivant return TElement;
   procedure Detruit;

end ArbMgr;
