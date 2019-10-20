--------------------------------------------------------------------------------
-- NOM DU CSU (corps)               : ArbMgr.adb
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

with Ada.Unchecked_Deallocation;
package body ArbMgr with
   SPARK_Mode,
   Refined_State => (ArbMgrState => (Arbre, AJour), ListeState => Liste, CurElmtState => CurElmt)
is

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

   -- Définition du tableau pour le ré-équilibrage de l'arbre
   type TTab is array (Positive range <>) of PNoeud;
   type PTab is access TTab;

   -- Échange de propriétaire
   procedure Échange (NA, NB : in out PNoeud) is
      NC : constant PNoeud := NA;
   begin
      NA := NB;
      NB := NC;
   end Échange;

   -- Ajoute un élément à l'arbre binaire en le triant par l'ordre défini par la clef.
   procedure Ajoute (Clef : TClef; Element : TElement) is
      NoeudNouveau : PNoeud;

      procedure AjouteDans (Noeud : not null PNoeud) with
         Global => (In_Out => NoeudNouveau, Input => Clef)
      is
      begin
         if Clef /= Noeud.Clef then
            if Clef < Noeud.Clef then
               if Noeud.Gauche /= null then
                  AjouteDans (Noeud.Gauche);
               else
                  Noeud.Gauche := NoeudNouveau;
               end if;
            else
               if Noeud.Droit /= null then
                  AjouteDans (Noeud.Droit);
               else
                  Noeud.Droit := NoeudNouveau;
               end if;
            end if;
         end if;
         NoeudNouveau := null; --  Relache l'accès
      end AjouteDans;

   begin
      AJour        := False;
      NoeudNouveau := new TNoeud'(Gauche => null, Droit => null, Suivant => null, Clef => Clef, Element => Element);
      if Arbre /= null then
         AjouteDans (Arbre);
      else
         Arbre := NoeudNouveau;
      end if;
      NoeudNouveau := null; --  Relache l'accès
   end Ajoute;

   -- Procédure qui balance l'arbre de façon à minimiser le temps de recherche
   procedure Balance is
      Tab : PTab := null;

      procedure Free is new Ada.Unchecked_Deallocation (TTab, PTab);

      procedure PlaceDansTab (Noeud : in out PNoeud) with
         Global => (In_Out => Tab)
      is
         TabVide : TTab (2 .. 1);
      begin
         if Noeud.Gauche /= null then
            PlaceDansTab (Noeud.Gauche);
         end if;
         if Tab = null then
            Tab := new TTab'(TabVide & Noeud);  -- premier élément du tableau
         else
            declare
               AncienTab : PTab := Tab;
            begin
               Tab := new TTab'(AncienTab (AncienTab'Range) & Noeud);  -- les suivants
               Free (AncienTab);
            end;
         end if;
         if Noeud.Droit /= null then
            PlaceDansTab (Noeud.Droit);
         end if;
         Noeud := null;
      end PlaceDansTab;

      procedure PlaceDansArbre (Noeud : out PNoeud; Premier, Dernier : Positive) with
         Global => (In_Out => Tab)
      is
         Index : Positive;
      begin
         Index := (Premier + Dernier) / 2;
         Échange (Noeud, Tab (Index));
         if Premier /= Index then
            PlaceDansArbre (Noeud.Gauche, Premier, Index - 1);
         else
            Noeud.Gauche := null;
         end if;
         if Dernier /= Index then
            PlaceDansArbre (Noeud.Droit, Index + 1, Dernier);
         else
            Noeud.Droit := null;
         end if;
      end PlaceDansArbre;

      procedure PlaceDansListe (Noeud : out PNoeud) with
         Global => (In_Out => Tab)
      is
      begin
         Noeud := Tab (Tab'First);
         for Index in Tab'First .. Tab'Last - 1 loop
            Tab (Index).Suivant := Tab (Index + 1);
         end loop;
         Tab (Tab'Last).Suivant := null;
      end PlaceDansListe;

   begin
      if Arbre /= null then
         PlaceDansTab (Arbre);
         PlaceDansArbre (Arbre, Tab'First, Tab'Last);
         PlaceDansListe (Liste);
         Free (Tab);
         AJour := True;
      end if;
   end Balance;

   -- Procédure qui recherche un élément dans l'arbre binaire et qui renvoie son Element.
   procedure Recherche (Clef : TClef; Element : out TElement) is
      procedure RechercheDans (Noeud : not null PNoeud) is
      begin
         if Clef = Noeud.Clef then
            Element := Noeud.Element;
         elsif Clef < Noeud.Clef then
            if Noeud.Gauche /= null then
               RechercheDans (Noeud.Gauche);
            end if;
         elsif Noeud.Droit /= null then
            RechercheDans (Noeud.Droit);
         end if;
      end RechercheDans;

   begin
      Element := NonDefini;
      if not AJour and then AutoBal then
         Balance;
      end if;
      if Arbre /= null then
         RechercheDans (Arbre);
      end if;
   end Recherche;

   -- Procédure retournant le premier élément de la liste triée
   procedure RetournePremier (Element : out TElement) is
   begin
      if not AJour and then AutoBal then
         Balance;
      end if;
      CurElmt := Liste;
      Liste   := null;  --  Relache l'accès
      if CurElmt /= null then
         Element := CurElmt.Element;
      else
         Element := NonDefini;
      end if;
   end RetournePremier;

   -- Procédure retournant l'élément suivant de la liste triée
   procedure RetourneSuivant (Element : out TElement) is
   begin
      if CurElmt /= null then
         CurElmt := CurElmt.Suivant;
      end if;
      if CurElmt /= null then
         Element := CurElmt.Element;
      else
         Element := NonDefini;
      end if;
   end RetourneSuivant;

   -- Procédure de destruction de l'arbre binaire.
   procedure Detruit is

      procedure Free is new Ada.Unchecked_Deallocation (TNoeud, PNoeud);

      procedure Elimine (Noeud : not null PNoeud) is
      begin
         if Noeud.Gauche /= null then
            Elimine (Noeud.Gauche);
         end if;
         if Noeud.Droit /= null then
            Elimine (Noeud.Droit);
         end if;
         declare
            Dum : PNoeud := Noeud;
         begin
            Free (Dum);
         end;
      end Elimine;

   begin
      if Arbre /= null then
         Elimine (Arbre);
      end if;
      Arbre   := null;
      CurElmt := null;
      Liste   := null;
      AJour   := False;
   end Detruit;

end ArbMgr;
