{ fpc day17.pas && ./day17 < day17_input.txt }
program day17;

const
   Size  = 20;
   Steps = 6;

type
   StatusType = (Inactive, Active);
   BoardType  = array[-Size..Size,-Size..Size,-Size..Size] of StatusType;

var
   Board : BoardType;
   X,Y,Z : Integer;

procedure Clear(var NewBoard : BoardType);
begin
   for Z := -Size to Size do
      for Y := -Size to Size do
         for X := -Size to Size do
            NewBoard[X,Y,Z] := Inactive;
end;

procedure ReadBoard;
var
   Line  : String;
   C     : Char;
begin
   Clear(Board);

   Y := 0;
   Z := 0;
   while not eof do
   begin
      readln(Line);
      X := 0;
      for C in Line do
      begin
         if C = '#' then Board[X,Y,Z] := Active;
         X := succ(X)
      end;
      Y := succ(Y)
   end
end;

procedure WriteBoard;
var
   MinX,MaxX : Integer;
   MinY,MaxY : Integer;
   MinZ,MaxZ : Integer;
begin
   MinY := Size;
   MaxY := -Size;
   MinX := Size;
   MaxX := -Size;
   MinZ := Size;
   MaxZ := -Size;

   for Z := -Size to Size do
      for Y := -Size to Size do
         for X := -Size to Size do
            if Board[X,Y,Z] = Active then
            begin
               if X < MinX then MinX := X;
               if X > MaxX then MaxX := X;
               if Y < MinY then MinY := Y;
               if Y > MaxY then MaxY := Y;
               if Z < MinZ then MinZ := Z;
               if Z > MaxZ then MaxZ := Z;
            end;

   for Z := MinZ to MaxZ do
   begin
      writeln('z=', Z);
      for Y := MinY to MaxY do
      begin
         for X := MinX to MaxX do
            if Board[X,Y,Z] = Active then
               write('#')
            else
               write('.');
         writeln;
      end;
      writeln
   end;
   writeln
end;

procedure Simulate;
var
   NextBoard : BoardType;
   Neighbors : Integer;
   DX,DY,DZ  : Integer;
begin
   Clear(NextBoard);

   for Z := -Size+1 to Size-1 do
      for Y := -Size+1 to Size-1 do
         for X := -Size+1 to Size-1 do
            begin
               Neighbors := 0;
               for DX := -1 to 1 do
                  for DY := -1 to 1 do
                     for DZ := -1 to 1 do
                        if (not ((DX = 0) and (DY = 0) and (DZ = 0))) and (Board[X+DX,Y+DY,Z+DZ] = Active) then
                           Neighbors := succ(Neighbors);

               if (Neighbors = 3) or ((Neighbors = 2) and (Board[X,Y,Z] = Active)) then NextBoard[X,Y,Z] := Active;
            end;
   Board := NextBoard;
end;

function CountBoard : Integer;
var
   Counter : Integer;
begin
   Counter := 0;
   for Z := -Size to Size do
      for Y := -Size to Size do
         for X := -Size to Size do
            if Board[X,Y,Z] = Active then Counter := succ(Counter);

   CountBoard := Counter
end;

var
   Step : Integer;
begin
   ReadBoard;

   writeln('Input');
   WriteBoard;

   for Step := 1 to Steps do
   begin
      Simulate;
      writeln('Step = ', Step, ', Count = ', CountBoard);
      {WriteBoard;}
   end;
end.
