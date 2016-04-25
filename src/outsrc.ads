--------------------------------------------------------------------------------
-- NOM DU CSU (spécification)       : OutSrc.ads
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 2.0b
-- DATE DE LA DERNIERE MISE A JOUR  : 18 février 2001
-- ROLE DU CSU                      : Unité de gestion du package résultat.
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
--
--------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with BasicDef;    use BasicDef;

package OutSrc is

   -- Objet assurant l'écriture du package Ada
   type TTextListMgr is tagged private;
   type PTextListMgr is access TTextListMgr'Class;

   procedure Add (Object : access TTextListMgr'Class; S : TText);
   procedure Add (Object : access TTextListMgr'Class; S : String);
   procedure AddNew (Object : access TTextListMgr'Class; S : TText);
   procedure AddNew (Object : access TTextListMgr'Class; S : String);
   procedure WriteToFile (Object : access TTextListMgr'Class; F : File_Type);
   procedure CopyTo (Object : access TTextListMgr'Class; DstText : access TTextListMgr'Class);
   procedure Done (Object : access TTextListMgr'Class);

   -- Objet assurant l'écriture d'énumérés
   type TEnumListMgr is new TTextListMgr with private;
   type PEnumListMgr is access TEnumListMgr'Class;

   -- Ajoute un élément s'il ne l'a pas déjà été
   procedure AddUniq (Object : access TEnumListMgr'Class; S : TText);
   -- Ecrit le type des énumérés dans le fichier F
   procedure TWriteToFile (Object : access TEnumListMgr'Class; F : File_Type);

   -- Objet assurant l'écriture des états de l'automate
   type TStateListMgr is new TEnumListMgr with private;
   type PStateListMgr is access TStateListMgr'Class;

   -- Ecrit le corps des états dans le fichier F
   procedure AWriteToFile (Object : access TStateListMgr'Class; F : File_Type);
   -- Ecrit l'appel du premier état dans le fichier F
   procedure CWriteToFile (Object : access TStateListMgr'Class; F : File_Type);

   -- Variables utilisées dans l'automate :

   -- Référence de l'objet assurant la gestion du texte de l'initialisation
   DefaultInitList : PTextListMgr;

   -- Référence de l'objet assurant la gestion du texte des événements
   DefaultEventList : PTextListMgr;

   -- Référence de l'objet assurant la gestion du texte par défaut
   DefaultDefaultList : PTextListMgr;

   -- Référence de l'objet assurant la gestion du nom des états
   StateList : PStateListMgr;

   -- Référence de l'objet assurant la gestion du nom des des évènements
   EventList : PEnumListMgr;

   -- Référence de l'objet assurant la gestion du texte objet de l'unité Pascal
   ObjectList : PTextListMgr;

   -- Référence d'un objet texte
   DefaultOutputList : PTextListMgr;

   -- Référence de l'objet assurant la gestion du nom des unités
   CallUnitList : PEnumListMgr;

   FlLocalDefault, FlDefaultDefault, FlGosub : Boolean;
   TEventStr,
   EventDesStr,
   TEventDesStr,
   NullEventStr,
   StateToStr,
   GetEventStr,
   UserUnitStr : TText;
   AName       : TText;
   NomFich     : TText;
   LigneFich   : Natural;

private

   type TTextList;
   type PTextList is access TTextList;
   -- Ligne de texte du package Ada
   type TTextList is record
      Next : PTextList;
      Text : TText;
   end record;

   -- Objet assurant l'écriture du package Ada
   type TTextListMgr is tagged record
      FirstElt, CurElt : PTextList := null;
      CurStr           : TText     := To_Unbounded_String ("");
   end record;

   -- Objet assurant l'écriture d'énumérés
   type TEnumListMgr is new TTextListMgr with null record;

   -- Objet assurant l'écriture des états de l'automate
   type TStateListMgr is new TEnumListMgr with null record;

end OutSrc;
