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

   if Argument_Count = 1 then
      FName := From_UTF_8 (Argument (1));
   else
      Put_Line ("Usage : genauto chemin/de/l'automate");
      Set_Exit_Status (Failure);
      return;
   end if;

   --Initialisation des objets utilisés.
   DefaultInitList := new TTextListMgr;

   DefaultEventList := new TTextListMgr;

   DefaultDefaultList := new TTextListMgr;

   DebugEventtList := new TTextListMgr;

   StateList := new TStateListMgr;

   EventList := new TEnumListMgr;

   ObjectList := new TTextListMgr;

   CallUnitList := new TEnumListMgr;

   -- Génération du 'langage' de l'automate.
   IdAuto.Insert ("action", ActionId);
   IdAuto.Insert ("automate", AutomId);
   IdAuto.Insert ("call", CallId);
   IdAuto.Insert ("debug", DebugId);
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

      Put_Line ("Création de la spécification du package : " & UName & ".ads");

      Create (FObject, Out_File, UName & ".ads", UTF_8, LF_Ending);

      Put_Line (FObject, "package " & AName & " is");
      New_Line (FObject);

      Put_Line (FObject, "   procedure Start" & AName & " (Result : out Boolean; Debug : Boolean := False);");
      New_Line (FObject);
      Put_Line (FObject, "end " & AName & ";");

      Close (FObject);

      Put_Line ("Création du corps du package : " & UName & ".adb");

      Create (FObject, Out_File, UName & ".adb", UTF_8, LF_Ending);

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
      Put_Line (FObject, "  while (State /= stError) and (State /= stQuit) loop");
      Put_Line (FObject, "    Result := Event = " & NullEventStr & ";");
      Put_Line (FObject, "    while Event = " & NullEventStr & " loop");
      Put_Line (FObject, "      " & GetEventStr & "(Event, " & EventDesStr & ");");
      Put_Line (FObject, "    end loop;");

      if not DebugEventtList.Is_Empty then
         Put_Line (FObject, "    if Debug then");
         if DebugEventtList.Last_Element = Null_UXString then
            DebugEventtList.Delete_Last;
         end if;
         WriteToFile (DebugEventtList, FObject);
         Put_Line (FObject, "    end if;");
      end if;

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
      Put_Line (FObject, "  Event : " & TEventStr & " := " & NullEventStr & ";");
      Put_Line (FObject, "  " & EventDesStr & " : " & TEventDesStr & ";");
      Put_Line (FObject, "  begin");

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

   Done (DebugEventtList);

   Done (ObjectList);

   Done (StateList);

   Done (EventList);

   Done (CallUnitList);

   Put_Line ("Fin de la génération.");

end Genauto;
