--------------------------------------------------------------------------------
-- NOM DU CSU (spécification)       : ArbMgr.ads
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 3.0a
-- DATE DE LA DERNIERE MISE A JOUR  : 27 juillet 2019
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
--
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

package ArbMgr with
   SPARK_Mode
--     Abstract_State => (ArbMgrState, ListeState, CurElmtState, OtherState)
is

   -- Workaround du to a limitation of SPARK community 2019,should be in package body
   -- Définition d'un noeud pour la gestion de l'arbre binaire.
   type TNoeud;
   type PNoeud is access TNoeud;
   type TNoeud is record
      Gauche  : PNoeud;       -- branche inférieure de l'arbre
      Droit   : PNoeud;       -- branche supérieure de l'arbre
      Suivant : PNoeud;       -- liste croissante
      Clef    : TClef;        -- clef de comparaison
      Element : TElement;     -- stockage de l'élément à trier ou à rechercher
   end record;

   Arbre   : PNoeud  := null;
   CurElmt : PNoeud  := null;
   Liste   : PNoeud  := null;
   AJour   : Boolean := False;

   -- Procédures assurant la gestion de l'arbre binaire.
   procedure Ajoute (Clef : TClef; Element : TElement) with
--        Global => (In_Out => ArbMgrState);
      Global => (In_Out => Arbre);
   procedure Balance with
--        Global => (In_Out => ArbMgrState, Output => ListeState);
      Global => (In_Out => Arbre, Output => Liste);
   procedure Recherche (Clef : TClef; Element : out TElement) with
--        Global => (In_Out => ArbMgrState, Output => ListeState);
      Global => (In_Out => Arbre, Output => Liste);
   function RetournePremier return TElement with
--        Global => (Input => (ArbMgrState, ListeState, CurElmtState));
      Global => (Input => (Arbre, Liste, CurElmt));
   function RetourneSuivant return TElement with
--        Global => (Input => CurElmtState);
      Global => (Input => CurElmt);
   procedure Detruit with
--        Global => (In_Out => ArbMgrState, Output => (ListeState, CurElmtState));
      Global => (In_Out => Arbre, Output => (Liste, CurElmt));

end ArbMgr;
