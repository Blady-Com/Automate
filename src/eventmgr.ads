package EventMgr is

   type TEvent is (EvNul, Descend, Gauche, Droite, Monte, Prend, Lache);
   subtype TEventDes is Character;

   procedure GetNextEvent (Event : out TEvent; EventDes : out TEventDes);

end EventMgr;
