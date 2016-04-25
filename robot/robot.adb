-- Programme destiné à faire la démonstration d'un langage de description d'automates
-- appliqué à un bras de robot.

with Ada.Text_IO; use Ada.Text_IO;
with RobSeq; use RobSeq;

procedure Robot is

  Ok: Boolean;

begin
  Put_Line("Programme de manipulation d'un bras de robot :");
  Put_Line("Flèche haute   : le bras monte,");
  Put_Line("Flèche basse   : le bras descend,");
  Put_Line("Flèche droite  : le bras va à droite,");
  Put_Line("Flèche gauche  : le bras va à gauche,");
  Put_Line("p              : le bras prend un objet (en bas à gauche),");
  Put_Line("l              : le bras lâche l'objet (en bas à droite).");
  New_Line;
  Put_Line("Le but est de prendre un objet en bas à gauche");
  Put_Line("puis de le déposer en bas à droite.");
  Put_Line("Etat initial : DroiteHautOuvert");

  StartRobSeq(Ok);

end;