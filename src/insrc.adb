--------------------------------------------------------------------------------
-- NOM DU CSU (corps)               : InSrc.adb
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

with Ada.Exceptions;                                 use Ada.Exceptions;
with Ada.Strings.Wide_Wide_Maps;                     use Ada.Strings.Wide_Wide_Maps;
with Ada.Characters.Wide_Wide_Latin_1;               use Ada.Characters.Wide_Wide_Latin_1;
with Ada.Strings.Wide_Wide_Maps.Wide_Wide_Constants; use Ada.Strings.Wide_Wide_Maps.Wide_Wide_Constants;
with BasicDef;

package body InSrc is

   use UXStrings.Text_IO;

   Asciinul : constant Wide_Wide_Character := NUL;
   Asciietx : constant Wide_Wide_Character := ETX;
   Asciieot : constant Wide_Wide_Character := EOT;
   Asciibel : constant Wide_Wide_Character := BEL;
   Asciitab : constant Wide_Wide_Character := HT;
   Asciilf  : constant Wide_Wide_Character := LF;
   Asciiff  : constant Wide_Wide_Character := FF;
   Asciicr  : constant Wide_Wide_Character := CR;
   Asciinak : constant Wide_Wide_Character := NAK;
   Asciisp  : constant Wide_Wide_Character := ' ';

   -- caractère séparateur de ligne pour le système considéré
   Newlinechar : constant Wide_Wide_Character := Asciilf;

   NormAsciiCharRange : constant Wide_Wide_Character_Range := (Low => Space, High => LC_Y_Diaeresis);
   Normasciicharset   : constant Wide_Wide_Character_Set   := To_Set ((NormAsciiCharRange));

   Identcharset   : constant Wide_Wide_Character_Set := To_Set ('_') or Decimal_Digit_Set or Letter_Set;
   Chiffrecharset : constant Wide_Wide_Character_Set := Decimal_Digit_Set;
   Hexacharset    : constant Wide_Wide_Character_Set := Hexadecimal_Digit_Set;
   Blanccharset   : constant Wide_Wide_Character_Set :=
     (To_Set (Asciibel) or To_Set (Asciitab) or To_Set (Asciilf) or To_Set (Asciiff) or To_Set (Asciicr) or
      To_Set (Asciisp)) and
     not To_Set (Newlinechar);

   type TGenericErr is (ManqueApos, ManqueComment);

   -- Procédure donnant le nom et la ligne courante du fichier source.
   procedure Status (Object : not null access TSourceMgr; Name : out UXString; Ligne : out Natural) is
   begin
      Name  := BasicDef.FSplitName (Object.FName);
      Ligne := Object.CptLigne;
   end Status;

   procedure FileRead (F : in out File_Type; Buffer : in out Ttextbuff) is
      Ch : Wide_Wide_Character;
   begin
      while not End_Of_File (F) loop
         if End_Of_Line (F) then
            Skip_Line (F);
            Append (Buffer, Line_Mark);
         else
            Get (F, Ch);
            Append (Buffer, Ch);
         end if;
      end loop;
   exception
      when E : others =>
         Put_Line (From_UTF_8 (Exception_Information (E)));
         Raise_Exception
           (Exception_Identity (E), To_UTF_8 ("Erreur de lecture du fichier source : """ & Name (F) & """."));
   end FileRead;

   -- Procédure de lecture du contenu du fichier source.
   procedure Open (Object : not null access TSourceMgr; Name : UXString) is
   begin
      Object.FName    := Name;
      Object.CptCar   := 0;
      Object.CptLigne := 1;
      Open (Object.FRef, In_File, Name, UTF_8, LF_Ending);
      Put_Line ("Lecture de " & BasicDef.FSplitName (Name) & " ...");
      FileRead (Object.FRef, Object.TextBuff);
      Close (Object.FRef);
      Append (Object.TextBuff, Asciieot);
      Object.ChTemp := Element (Object.TextBuff, 1);
   exception
      when E : others =>
         Raise_Exception
           (Exception_Identity (E),
            Exception_Message (E) & To_UTF_8 ("Erreur d'ouverture du fichier source """ & Name & """."));
   end Open;

   -- Procédure de lecture d'un caractère du buffer contenant le texte source.
   -- Le caractère lu est dans Ch1, le suivant est dans Ch2.
   procedure Read (Object : not null access TSourceMgr; Ch1, Ch2 : out Wide_Wide_Character) is
   begin
      Ch1           := Object.ChTemp;
      Object.CptCar := Object.CptCar + 1;
      if Object.ChTemp = Newlinechar then
         Object.CptLigne := Object.CptLigne + 1;
      end if;
      if Object.ChTemp /= Asciieot then
         Object.ChTemp := Element (Object.TextBuff, Integer'Succ (Object.CptCar));
      end if;
      Ch2 := Object.ChTemp;
   end Read;

   -- Procédure de destruction du buffer.
   procedure Close (Object : not null access TSourceMgr) is
   begin
      Object.FName    := Null_UXString;
      Object.TextBuff := From_Unicode (Asciieot);
   end Close;

   -- Renvoie la chaîne en minuscule.
   function LowStr (S : UXString) return UXString is
   begin
      return To_Lower (S);
   end LowStr;

   -- Affiche la raison de l'erreur.
   procedure AffGenericErr (Id : TGenericErr) is
      function Image is new UXStrings.Conversions.Scalar_Image (TGenericErr);
   begin
      Put_Line ("Erreur generique : " & Image (Id));
   end AffGenericErr;

   -- Affiche une chaîne à la suite d'une erreur.
   procedure AffChaineErr (Chaine : UXString) is
   begin
      Put_Line (Chaine);
   end AffChaineErr;

-- Lit un ou plusieurs caractère dans le texte source et le ou les transforme en éléments lexicaux.
   procedure ReadToken (TokenId : out TTokenId; Token : out Ttokenstr) is
      Ch, ChSuivant : Wide_Wide_Character;

      -- Lit une chaîne de caractères.
      procedure ReadChaine is
      begin
         Read (SrcAuto, Ch, ChSuivant);
         while Is_In (Ch, Normasciicharset) loop
            if (Ch = '`') and (ChSuivant = '`') then
               Read (SrcAuto, Ch, ChSuivant);
            end if;
            if Ch = Asciietx then
               Ch := Asciinul;
            end if;
            if (Ch = '`') and (ChSuivant /= '`') then
               Ch := Asciietx;
            end if;
            if Ch /= Asciietx then
               Token := Token & Ch;
               Read (SrcAuto, Ch, ChSuivant);
            end if;
         end loop;
         case Ch is
            when Asciieot =>
               AffGenericErr (ManqueApos);
               TokenId := ErrorId;
            when Asciietx =>
               TokenId := CarId;
            when others =>
               AffChaineErr ("" & Ch); -- !!!!
               TokenId := ErrorId;
         end case;
      end ReadChaine;

      -- Lit un commentaire.
      procedure ReadComment is
         Enr : Boolean := True;
      begin
         if Ch = '(' then
            Read (SrcAuto, Ch, ChSuivant);
         end if;
         Read (SrcAuto, Ch, ChSuivant);
         while not Is_In (Ch, To_Set (Asciieot) or To_Set (Asciietx)) loop
            if Ch = Newlinechar then
               Enr := False;
            end if;
            if Ch = Asciietx then
               Ch := Asciinul;
            end if;
            if Ch = '}' then
               Ch := Asciietx;
            end if;
            if (Ch = '*') and (ChSuivant = ')') then
               Read (SrcAuto, Ch, ChSuivant);
               Ch := Asciietx;
            end if;
            if Ch /= Asciietx then
               if Enr then
                  Token := Token & Ch;
               end if;
               Read (SrcAuto, Ch, ChSuivant);
            end if;
         end loop;
         if Ch = Asciietx then
            TokenId := CommentId;
         else
            AffGenericErr (ManqueComment);
            TokenId := ErrorId;
         end if;
      end ReadComment;

      -- Lit un commentaire d'une ligne.
      procedure ReadCommentSingleLine is
      begin
         if Ch = '-' then
            Read (SrcAuto, Ch, ChSuivant);
         end if;
         Read (SrcAuto, Ch, ChSuivant);
         while not Is_In (Ch, To_Set (Asciieot) or To_Set (Asciietx)) loop
            if Ch = Newlinechar then
               Ch := Asciietx;
            else
               Token := Token & Ch;
               Read (SrcAuto, Ch, ChSuivant);
            end if;
         end loop;
         if Ch = Asciietx then
            TokenId := CommentId;
         else
            AffGenericErr (ManqueComment);
            TokenId := ErrorId;
         end if;
      end ReadCommentSingleLine;

      -- Lit un identificateur.
      procedure ReadIdent is
      begin
         Token := Token & Ch;
         while Is_In (ChSuivant, Identcharset) loop
            Read (SrcAuto, Ch, ChSuivant);
            Token := Token & Ch;
         end loop;
         IdAuto.Recherche (LowStr (Token), TokenId);
      end ReadIdent;

   begin
      Token   := Null_UXString;
      TokenId := ErrorId;
      Read (SrcAuto, Ch, ChSuivant);
      while Is_In (Ch, Blanccharset) loop
         Read (SrcAuto, Ch, ChSuivant);
      end loop;
      case Ch is
         when Asciieot =>
            TokenId := EotId;
         when Newlinechar =>
            TokenId := NewlineId;
         when '`' =>
            ReadChaine;
         when '(' =>
            if ChSuivant = '*' then
               ReadComment;
            else
               TokenId := ErrorId;
            end if;
         when '-' =>
            if ChSuivant = '-' then
               ReadCommentSingleLine;
            else
               TokenId := ErrorId;
            end if;
         when '+' =>
            TokenId := PlusId;
         when '.' =>
            if ChSuivant = '.' then
               TokenId := PointpointId;
               Read (SrcAuto, Ch, ChSuivant);
            else
               TokenId := UnknownId;
            end if;
         when ',' =>
            TokenId := VirgId;
         when 'A' .. 'Z' | 'a' .. 'z' | '_' =>
            ReadIdent;
         when '{' =>
            ReadComment;
         when others =>
            TokenId := UnknownId;
      end case;
   end ReadToken;

end InSrc;
