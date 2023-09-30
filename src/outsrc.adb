--------------------------------------------------------------------------------
-- NOM DU CSU (corps)               : OutSrc.adb
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 3.0a
-- DATE DE LA DERNIERE MISE A JOUR  : Octobre 2023
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
-- COPYRIGHT                        : (c) Pascal Pignard 2023
-- LICENCE                          : CeCILL V2.1 (https://cecill.info)
-- CONTACT                          : http://blady.pagesperso-orange.fr
--------------------------------------------------------------------------------

package body OutSrc is

   -- Ajout d'une chaîne sans changer de ligne.
   procedure Add (Object : not null access TTextListMgr; S : UXString) is
   begin
      if not Object.Is_Empty then
         Object.Replace_Element (Object.Last, Object.Last_Element & S);
      else
         Object.Append (S);
      end if;
   end Add;

   -- Ajout d'une chaîne avec changement de ligne.
   procedure AddNew (Object : not null access TTextListMgr; S : UXString) is
   begin
      Object.Add (S);
      Object.Append (Null_UXString);
   end AddNew;

   -- Ecriture du texte dans un fichier.
   procedure WriteToFile (Object : not null access TTextListMgr; F : File_Type) is
   begin
      for L of Object.all loop
         Put_Line (F, L);
      end loop;
   end WriteToFile;

   -- Transfert le texte dans un autre objet.
   procedure CopyTo (Object : not null access TTextListMgr; DstText : not null access TTextListMgr) is
   begin
      for L of Object.all loop
         DstText.AddNew (L);
      end loop;
   end CopyTo;

   -- Procédure de destruction du texte.
   procedure Done (Object : not null access TTextListMgr) is
   begin
      Object.Clear;
   end Done;

   -- Ajoute un élément s'il ne l'a pas déjà été
   procedure AddUniq (Object : not null access TEnumListMgr; S : UXString) is
   begin
      Object.Append_Unique (S);
   end AddUniq;

   -- Ecrit la liste sous forme d'un type énuméré
   procedure TWriteToFile (Object : not null access TEnumListMgr; F : File_Type) is
   begin
      Put (F, Object.Join (','));
   end TWriteToFile;

   -- Ecrit la liste sous forme d'un appel de procédure
   procedure AWriteToFile (Object : not null access TStateListMgr; F : File_Type) is
   begin
      for L of Object.all loop
         Put_Line (F, "      when " & L & " => Action" & L & ";");
      end loop;
   end AWriteToFile;

   -- Ecrit la liste sous forme d'un appel à la procedure de départ de l'automate
   procedure CWriteToFile (Object : not null access TStateListMgr; F : File_Type) is
   begin
      Put_Line (F, "  Automate(" & Object.First_Element & ", Event, " & EventDesStr & ", Result, Debug);");
   end CWriteToFile;

end OutSrc;
