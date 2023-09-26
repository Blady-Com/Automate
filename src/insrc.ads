--------------------------------------------------------------------------------
-- NOM DU CSU (spécification)       : InSrc.ads
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 3.0a
-- DATE DE LA DERNIERE MISE A JOUR  : Octobre 2023
-- ROLE DU CSU                      : Unité de gestion des textes sources.
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
with UXStrings.Text_IO;
with UXStrings.Conversions;
with Ada.Containers.Ordered_Maps;

package InSrc is

   -- Objet assurant la gestion du fichier source.
   type TSourceMgr is tagged limited private;
   type PSourceMgr is access TSourceMgr;

   procedure Open (Object : not null access TSourceMgr; Name : UXString);
   procedure Read (Object : not null access TSourceMgr; Ch1, Ch2 : out Wide_Wide_Character);
   procedure Status (Object : not null access TSourceMgr; Name : out UXString; Ligne : out Natural);
   procedure Close (Object : not null access TSourceMgr);

   -- Eléments lexicaux
   type TTokenId is
     (NullId, EotId, NewlineId, ErrorId, UnknownId, CallId, CarId, CommentId, UndefId, AutomId, DefaultId, OutId, ErrId,
      FromId, InitId, EventId, ActionId, VirgId, PlusId, PointpointId, ToId, GosubId, EndId, SameId);

   function Image is new UXStrings.Conversions.Scalar_Image (TTokenId);

   -- Contexte de l'élément lexical
   subtype Ttokenstr is UXString;

   -- Lit un ou plusieurs caractères dans le texte source et le ou les transforme en éléments lexicaux.
   procedure ReadToken (TokenId : out TTokenId; Token : out Ttokenstr);

   -- Référence du package assurant la gestion des mots clés
   package IdAutoUnit is new Ada.Containers.Ordered_Maps (UXString, TTokenId);
   IdAuto : IdAutoUnit.Map;

   SrcAuto : PSourceMgr;     -- Référence de l'objet assurant la gestion du texte source de l'automate

private

   subtype Ttextbuff is UXString;

   -- Objet assurant la gestion du fichier source.
   type TSourceMgr is tagged limited record
      FName            : UXString;
      FRef             : UXStrings.Text_IO.File_Type;
      FLen             : UXStrings.Text_IO.Count;
      CptCar, CptLigne : Natural;
      TextBuff         : Ttextbuff;
      ChTemp           : Wide_Wide_Character;
   end record;

end InSrc;
