with Ada.Text_IO, EventMgr;
use  Ada.Text_IO, EventMgr;

package body RobSeq is

  type TState is (stError, stQuit, DroiteHautOuvert,GaucheHautOuvert,DroiteBasOuvert,GaucheBasOuvert,DroiteHautFerme,GaucheHautFerme,DroiteBasFerme,GaucheBasFerme);

procedure Automate (StartState : TState; Event : in out TEvent; EventDes : in out TEventDes; Result : out Boolean; Debug : Boolean := False) is
  State : TState := StartState;

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
    end case;
  Event := DumEvent;
  end;


  begin
  while (State /= stError) and (State /= stQuit) loop
    Result := Event = evNul;
    while Event = evNul loop
      GetNextEvent(Event, EventDes);
    end loop;
    if Debug then
      Put(State'Image & "; ");
      if not Result then
        Put("+ ");
      end if;
      Put_Line(Event'Image & "; " & EventDes);
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
      when stError | stQuit =>
        null;
      end case;
    end loop;
  Result := State /= stError;
  end Automate;

procedure StartRobSeq(Result : out Boolean; Debug : Boolean := False) is
  Event : TEvent := evNul;
  EventDes : TEventDes;
  begin
  Automate(DroiteHautOuvert, Event, EventDes, Result, Debug);
  end StartRobSeq;

end RobSeq;
