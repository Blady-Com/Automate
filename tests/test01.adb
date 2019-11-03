with ArbMgr;
with Ada.Numerics.Discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;

procedure Test01 is

   subtype Str4 is String (1..4);
   package Arb01 is new ArbMgr (Positive, Str4, "null");

   package Rand_Pos is new Ada.Numerics.Discrete_Random (Positive);

   Gen_Pos : Rand_Pos.Generator;
   R : Str4;

begin
   for I in 1 .. 10 loop
      Arb01.Ajoute (Rand_Pos.Random (Gen_Pos), Positive'Image(Rand_Pos.Random (Gen_Pos))(1..4));
   end loop;
   Arb01.Ajoute (9999, "9999");
   Arb01.Recherche (9999, R);
   Put_Line (R);
end;
