--------------------------------------------------------------------------------
-- NOM DU CSU (principal)           : GenAuto.adb
-- AUTEUR DU CSU                    : P. Pignard
-- VERSION DU CSU                   : 3.0a
-- DATE DE LA DERNIERE MISE A JOUR  : Octobre 2023
-- ROLE DU CSU                      : Programme de génération automatique d'automates.
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

with Ada.Command_Line;  use Ada.Command_Line;
with BasicDef;          use BasicDef;
with InSrc;             use InSrc;
with OutSrc;            use OutSrc;
with SrcSeq;            use SrcSeq;
with UXStrings;         use UXStrings;
with UXStrings.Text_IO; use UXStrings.Text_IO;

procedure Genauto is

   Debug : constant Boolean := True;

   FName, UName : UXString;
   FObject      : File_Type;
   Ok           : Boolean;
   Time         : Natural;

begin
   -- Change the default to LF and UTF-8
   Line_Mark (LF_Ending);
   Ending (Current_Output, LF_Ending);
   Scheme (Current_Output, UTF_8);
   Ending (Current_Input, LF_Ending);
   Scheme (Current_Input, UTF_8);

   Put_Line ("Entrer les informations suivantes :");
   New_Line;
   Put ("Type des événements : ");
   Get_Line (TEventStr);
   Put ("Contexte de l'événement : ");
   Get_Line (EventDesStr);
   Put ("Type du contexte de l'événement : ");
   Get_Line (TEventDesStr);
   Put ("Constante événement nul : ");
   Get_Line (NullEventStr);
   Put ("Procédure de gestion des événements : ");
   Get_Line (GetEventStr);
   Put ("Unité(s) à inclure : ");
   Get_Line (UserUnitStr);

   --Initialisation des objets utilisés.
   DefaultInitList := new TTextListMgr;

   DefaultEventList := new TTextListMgr;

   DefaultDefaultList := new TTextListMgr;

   StateList := new TStateListMgr;

   EventList := new TEnumListMgr;

   ObjectList := new TTextListMgr;

   CallUnitList := new TEnumListMgr;

   -- Génération du 'langage' de l'automate.
   IdAuto.Insert ("action", ActionId);
   IdAuto.Insert ("automate", AutomId);
   IdAuto.Insert ("call", CallId);
   IdAuto.Insert ("default", DefaultId);
   IdAuto.Insert ("end", EndId);
   IdAuto.Insert ("error", ErrId);
   IdAuto.Insert ("event", EventId);
   IdAuto.Insert ("from", FromId);
   IdAuto.Insert ("gosub", GosubId);
   IdAuto.Insert ("init", InitId);
   IdAuto.Insert ("out", OutId);
   IdAuto.Insert ("same", SameId);
   IdAuto.Insert ("to", ToId);

   Put ("Nom du fichier source : ");
   Get_Line (FName);

   Time := Horlogems;

   SrcAuto := new TSourceMgr;
   Open (SrcAuto, FName);
   -- Exécution de l'automate.
   StartSrcSeq (Ok, Debug);
   Close (SrcAuto);

   IdAuto.Clear;

   Put_Line ("Temps passé : " & Image (Horlogems - Time) & " milisecondes.");

   if Ok then
      FName := FSplitName (FName);
      UName := TruncLast (FName);

      -- Création de la spécification du package
      Put ("Nom de l'unité Ada (spec : " & UName & ".ads) : ");
      Get_Line (FName);
      if FName = Null_UXString then
         FName := UName & ".ads";
      end if;

      Create (FObject, Out_File, FName, UTF_8, LF_Ending);

      Put_Line (FObject, "package " & AName & " is");
      New_Line (FObject);

      Put_Line (FObject, "   procedure Start" & AName & " (Result : out Boolean; Debug : Boolean := False);");
      New_Line (FObject);
      Put_Line (FObject, "end " & AName & ";");

      Close (FObject);

      -- Création du corps du package
      Put ("Nom de l'unité Ada (corps : " & UName & ".adb) : ");
      Get_Line (FName);
      if FName = Null_UXString then
         FName := UName & ".adb";
      end if;

      Create (FObject, Out_File, FName, UTF_8, LF_Ending);

      if UserUnitStr /= Null_UXString then
         Put_Line (FObject, "with " & UserUnitStr & ';');
      end if;
      if not CallUnitList.Is_Empty then
         Put (FObject, "with ");
         TWriteToFile (CallUnitList, FObject);
         Put_Line (FObject, ";");
      end if;

      if UserUnitStr /= Null_UXString then
         Put_Line (FObject, "use  " & UserUnitStr & ';');
      end if;
      if not CallUnitList.Is_Empty then
         Put (FObject, "use  ");
         TWriteToFile (CallUnitList, FObject);
         Put_Line (FObject, ";");
      end if;

      New_Line (FObject);

      Put_Line (FObject, "package body " & AName & " is");
      New_Line (FObject);

      Put (FObject, "  type TState is (stError, stQuit, ");
      TWriteToFile (StateList, FObject);
      Put_Line (FObject, ");");
      New_Line (FObject);

      Put_Line
        (FObject,
         "procedure Automate (StartState : TState; Event : in out " & TEventStr & "; " & EventDesStr & " : in out " &
         TEventDesStr & "; Result : out Boolean; Debug : Boolean := False) is");
      Put_Line (FObject, "  State : TState := StartState;");
      New_Line (FObject);

      WriteToFile (ObjectList, FObject);

      Put_Line (FObject, "  begin");
      Put_Line (FObject, "  Result := Event = " & NullEventStr & ";");
      Put_Line (FObject, "  while (State /= stError) and (State /= stQuit) loop");
      Put_Line (FObject, "    while Event = " & NullEventStr & " loop");
      Put_Line (FObject, "      " & GetEventStr & "(Event, " & EventDesStr & ");");
      Put_Line (FObject, "    end loop;");
      Put_Line (FObject, "    if Debug then"); -- Todo: transfer following lines in an user debug subprogram
      Put_Line (FObject, "      Put(From_UTF_8 (TState'Image(State)) & ""; "" & Image(Event));");
      Put_Line (FObject, "      if not Result then");
      Put_Line (FObject, "        Put(""+"");");
      Put_Line (FObject, "        Result := True;");
      Put_Line (FObject, "      end if;");
      Put_Line (FObject, "      Put_Line(""; "" & " & EventDesStr & ");");
      Put_Line (FObject, "    end if;");
      Put_Line (FObject, "    case State is");

      AWriteToFile (StateList, FObject);

      Put_Line (FObject, "      when stError | stQuit =>");
      Put_Line (FObject, "        null;");
      Put_Line (FObject, "      end case;");
      Put_Line (FObject, "    end loop;");
      Put_Line (FObject, "  Result := State /= stError;");
      Put_Line (FObject, "  end Automate;");
      New_Line (FObject);
      Put_Line (FObject, "procedure Start" & AName & "(Result : out Boolean; Debug : Boolean := False) is");
      Put_Line (FObject, "  Event : " & TEventStr & ";");
      Put_Line (FObject, "  " & EventDesStr & " : " & TEventDesStr & ";");
      Put_Line (FObject, "  begin");

      Put_Line (FObject, "  " & GetEventStr & "(Event, " & EventDesStr & ");");
      CWriteToFile (StateList, FObject);

      Put_Line (FObject, "  end Start" & AName & ";");
      New_Line (FObject);
      Put_Line (FObject, "end " & AName & ";");

      Close (FObject);
   else
      Set_Exit_Status (Failure);
   end if;

   Done (DefaultInitList);

   Done (DefaultEventList);

   Done (DefaultDefaultList);

   Done (ObjectList);

   Done (StateList);

   Done (EventList);

   Done (CallUnitList);

   Put_Line ("Fin de la génération.");

end Genauto;
