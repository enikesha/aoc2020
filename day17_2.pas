{ fpc day17_2.pas && ./day17_2 < day17_input.txt }
program day17_2;

const
   Size  = 16;
   Steps = 6;

type
   StatusType = (Inactive, Active);
   BoardType  = array[-Size..Size,-Size..Size,-Size..Size,-Size..Size] of StatusType;

var
   Board   : BoardType;
   X,Y,Z,W : Integer;

procedure Clear(var NewBoard : BoardType);
begin
   for W := -Size to Size do
      for Z := -Size to Size do
         for Y := -Size to Size do
            for X := -Size to Size do
               NewBoard[X,Y,Z,W] := Inactive;
end;

procedure ReadBoard;
var
   Line  : String;
   C     : Char;
begin
   Clear(Board);

   Y := 0;
   Z := 0;
   W := 0;
   while not eof do
   begin
      readln(Line);
      X := 0;
      for C in Line do
      begin
         if C = '#' then Board[X,Y,Z,W] := Active;
         X := succ(X)
      end;
      Y := succ(Y)
   end
end;


procedure Simulate;
var
   NextBoard   : BoardType;
   Neighbors   : Integer;
   DX,DY,DZ,DW : Integer;
begin
   Clear(NextBoard);

   for W := -Size+1 to Size-1 do
      for Z := -Size+1 to Size-1 do
         for Y := -Size+1 to Size-1 do
            for X := -Size+1 to Size-1 do
            begin
               Neighbors := 0;
               for DX := -1 to 1 do
                  for DY := -1 to 1 do
                     for DZ := -1 to 1 do
                        for DW := -1 to 1 do
                           if Board[X+DX,Y+DY,Z+DZ,W+DW] = Active then
                              Neighbors := succ(Neighbors);
               if Board[X,Y,Z,W] = Active then
               begin
                  if (Neighbors = 3) or (Neighbors = 4) then NextBoard[X,Y,Z,W] := Active
               end
               else if Neighbors = 3 then NextBoard[X,Y,Z,W] := Active;
            end;
   Board := NextBoard;
end;

function CountBoard : Integer;
var
   Counter : Integer;
begin
   Counter := 0;
   for W := -Size to Size do
      for Z := -Size to Size do
         for Y := -Size to Size do
            for X := -Size to Size do
               if Board[X,Y,Z,W] = Active then Counter := succ(Counter);

   CountBoard := Counter
end;

var
   Step : Integer;
begin
   ReadBoard;

   writeln('Input');

   for Step := 1 to Steps do
   begin
      Simulate;
      writeln('Step = ', Step, ', Count = ', CountBoard);
   end;
end.
