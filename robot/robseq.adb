with Ada.Text_IO, EventMgr;
use  Ada.Text_IO, EventMgr;

package body RobSeq is

  type TState is (stError, stQuit, DroiteHautOuvert, GaucheHautOuvert, DroiteBasOuvert, GaucheBasOuvert, DroiteHautFerme, GaucheHautFerme, DroiteBasFerme, GaucheBasFerme);

procedure Automate (TheState : TState; Event : in out TEvent; EventDes : in out TEventDes; Result : out Boolean; Debug : Boolean := False) is
  State : TState := TheState;

procedure ActionDroiteHautOuvert is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Descend =>
      Put_Line("État du bras : DroiteBasOuvert");
      State := DroiteBasOuvert;
    when Gauche =>
      Put_Line("État du bras : GaucheHautOuvert");
      State := GaucheHautOuvert;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionGaucheHautOuvert is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Descend =>
      Put_Line("État du bras : GaucheBasOuvert");
      State := GaucheBasOuvert;
    when Droite =>
      Put_Line("État du bras : DroiteHautOuvert");
      State := DroiteHautOuvert;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionDroiteBasOuvert is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Monte =>
      Put_Line("État du bras : DroiteHautOuvert");
      State := DroiteHautOuvert;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionGaucheBasOuvert is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Prend =>
      Put_Line("Objet pris");
      State := GaucheBasFerme;
    when Monte =>
      Put_Line("État du bras : GaucheHautOuvert");
      State := GaucheHautOuvert;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionDroiteHautFerme is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Lache =>
      Put_Line("Objet perdu");
      State := DroiteHautOuvert;
    when Descend =>
      Put_Line("État du bras : DroiteBasFerme");
      State := DroiteBasFerme;
    when Gauche =>
      Put_Line("État du bras : GaucheHautFerme");
      State := GaucheHautFerme;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionGaucheHautFerme is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Lache =>
      Put_Line("Objet perdu");
      State := GaucheHautOuvert;
    when Descend =>
      Put_Line("État du bras : GaucheBasFerme");
      State := GaucheBasFerme;
    when Droite =>
      Put_Line("État du bras : DroiteHautFerme");
      State := DroiteHautFerme;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionDroiteBasFerme is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Lache =>
      Put_Line("Objet posé. Fin.");
      State := stQuit;
    when Monte =>
      Put_Line("État du bras : DroiteHautFerme");
      State := DroiteHautFerme;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


procedure ActionGaucheBasFerme is
  DumEvent : TEvent;

  begin
  DumEvent := evNul;
  case Event is
    when Lache =>
      Put_Line("Objet lâché");
      State := GaucheBasOuvert;
    when Monte =>
      Put_Line("État du bras : GaucheHautFerme");
      State := GaucheHautFerme;
    when others =>
      Put_Line("Ordre incorrect !!!");
      null;
    end case;
  Event := DumEvent;
  end;


  begin
  Result := Event = evNul;
  while (State /= stError) and (State /= stQuit) loop
    while Event = evNul loop
      GetNextEvent(Event, EventDes);
    end loop;
    if Debug then
      Put(TState'Image(State) & "; " & TEvent'Image(Event));
      if not Result then
        Put("+");
        Result := True;
      end if;
      Put_Line("; " & EventDes);
    end if;
    case State is
      when DroiteHautOuvert => ActionDroiteHautOuvert;
      when GaucheHautOuvert => ActionGaucheHautOuvert;
      when DroiteBasOuvert => ActionDroiteBasOuvert;
      when GaucheBasOuvert => ActionGaucheBasOuvert;
      when DroiteHautFerme => ActionDroiteHautFerme;
      when GaucheHautFerme => ActionGaucheHautFerme;
      when DroiteBasFerme => ActionDroiteBasFerme;
      when GaucheBasFerme => ActionGaucheBasFerme;
      when others =>
        null;
      end case;
    end loop;
  Result := State /= stError;
  end Automate;

procedure StartRobSeq(Result : out Boolean; Debug : Boolean := False) is
  Event : TEvent;
  EventDes : TEventDes;
  begin
  GetNextEvent(Event, EventDes);
  Automate(DroiteHautOuvert, Event, EventDes, Result, Debug);
  end StartRobSeq;

end RobSeq;
