with Ada.Text_IO; use Ada.Text_IO;

package body EventMgr is

   type TSpecialKey is
     (Normal,
      F1,
      F2,
      F3,
      F4,
      F5,
      F6,
      F7,
      F8,
      F9,
      F10,
      F11,
      F12,
      Ins,
      Del,
      Home,
      EndKey,
      PgDown,
      PgUp,
      Up,
      Down,
      Left,
      Right,
      Unknown);

   procedure ReadKey (Key : out Character; Special : out TSpecialKey; Available : out Boolean) is
   begin
      Special := Normal;
      Get_Immediate (Key, Available);
      if Available then
         case Character'Pos (Key) is
            -- Pour windows
            when 0 =>
               Get_Immediate (Key, Available);
               if Available then
                  case Character'Pos (Key) is
                     when 59 =>
                        Special := F1;
                     when 72 =>
                        Special := Up;
                     when 80 =>
                        Special := Down;
                     when 75 =>
                        Special := Left;
                     when 77 =>
                        Special := Right;
                     when others =>
                        Special := Unknown;
                  end case;
               else
                  Special := Unknown;
               end if;
            -- Pour Mac OS X
            when 27 =>
               Get_Immediate (Key, Available);
               if Available then
                  case Character'Pos (Key) is
                     when 91 =>
                        Get_Immediate (Key, Available);
                        if Available then
                           case Character'Pos (Key) is
                              when 65 =>
                                 Special := Up;
                              when 66 =>
                                 Special := Down;
                              when 67 =>
                                 Special := Right;
                              when 68 =>
                                 Special := Left;
                              when others =>
                                 Special := Unknown;
                           end case;
                        else
                           Special := Unknown;
                        end if;
                     when 79 =>
                        Get_Immediate (Key, Available);
                        if Available then
                           case Character'Pos (Key) is
                              when 80 =>
                                 Special := F1;
                              when 81 =>
                                 Special := F2;
                              when 82 =>
                                 Special := F3;
                              when 83 =>
                                 Special := F4;
                              when others =>
                                 Special := Unknown;
                           end case;
                        else
                           Special := Unknown;
                        end if;
                     when 195 =>
                        Get_Immediate (Key, Available);
                        if Available then
                           case Character'Pos (Key) is
                              when 80 =>
                                 Special := F1;
                              when 81 =>
                                 Special := F2;
                              when 82 =>
                                 Special := F3;
                              when 83 =>
                                 Special := F4;
                              when others =>
                                 Special := Unknown;
                           end case;
                        else
                           Special := Unknown;
                        end if;
                     when others =>
                        Special := Unknown;
                  end case;
               else
                  Special := Unknown;
               end if;
            -- Pour windows
            when 224 =>
               Get_Immediate (Key, Available);
               if Available then
                  case Character'Pos (Key) is
                     when 72 =>
                        Special := Up;
                     when 80 =>
                        Special := Down;
                     when 75 =>
                        Special := Left;
                     when 77 =>
                        Special := Right;
                     when others =>
                        Special := Unknown;
                  end case;
               else
                  Special := Unknown;
               end if;
            when others =>
               null;
         end case;
      end if;
   end ReadKey;

   procedure GetNextEvent (Event : out TEvent; EventDes : out TEventDes) is

      Ok         : Boolean := False;
      KeyPressed : Boolean;
      Special    : TSpecialKey;

   begin
      while not Ok loop
         ReadKey (EventDes, Special, KeyPressed);
         if KeyPressed then
            case Special is
               when Left =>
                  Event := Gauche;
               when Right =>
                  Event := Droite;
               when Up =>
                  Event := Monte;
               when Down =>
                  Event := Descend;
               when Normal =>
                  case EventDes is
                     when 'p' =>
                        Event := Prend;
                     when 'l' =>
                        Event := Lache;
                     when others =>
                        Event := EvNul;
                        Put_Line ("Mauvaise Commande !!!");
                  end case;
               when others =>
                  Event := EvNul;
                  Put_Line ("Mauvaise Commande !!!");
            end case;
            Ok := Event /= EvNul;
         end if;
         delay 0.1;
      end loop;
   end GetNextEvent;

end EventMgr;
