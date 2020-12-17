{ fpc day17.pas && ./day17 < day17_input.txt }
Program day17;

Uses math;

const
   Steps     = 6;
   N         = 4;
   BoardBits = 5;

   AxisMax   = 1 shl BoardBits;
   LastIndex = 1 shl (N*BoardBits) - 1;
   Axes : array [1..6] of char = ('X', 'Y', 'Z', 'W', 'V', 'Y');

type
   StatusType = (Inactive, Active);
   DimType    = 1..N;
   AxisType   = 0..AxisMax-1;
   IndexType  = 0..LastIndex;
   BoardType  = array [0..LastIndex] of StatusType;
   PointType  = array [1..N] of AxisType;

var
   Board : BoardType;
   I     : IndexType;
   Dim   : DimType;

procedure Clear(var NewBoard : BoardType);
begin
   for I in IndexType do NewBoard[I] := Inactive;
end;

procedure ReadBoard;
var
   Line : String;
   C    : Char;
   Off  : Integer;
begin
   Clear(Board);

   { Middle of the board }
   I := AxisMax shr 1;
   for Dim := N-1 downto 1 do
      I := (I shl BoardBits) + (AxisMax shr 1);
   while not eof do
   begin
      readln(Line);
      Off := 0;
      for C in Line do
      begin
         if C = '#' then Board[I+Off] := Active;
         Inc(Off);
      end;
      I := I + AxisMax
   end
end;

function GetPoint(I : IndexType) : PointType;
var
   Point : PointType;
begin
   for Dim := 1 to N do
   begin
      Point[Dim] := I mod AxisMax;
      I := I shr BoardBits
   end;

   GetPoint := Point
end;

function GetIndex(Point : PointType) : IndexType;
var
   I : IndexType;
begin
   I := Point[N];
   for Dim := N-1 downto 1 do
      I := (I shl BoardBits) + Point[Dim];

   GetIndex := I
end;

procedure WritePoint(Prefix : String; Point : PointType);
begin
   write(Prefix);
   for Dim in DimType do
   begin
      write(Axes[Dim], ' = ', Point[Dim] - (AxisMax shr 1));
      if Dim = N then
         writeln
      else
         write(', ');
   end
end;

procedure WriteBoard;
var
   MinPoint, MaxPoint, LastPoint, Point : PointType;
   InBounds                             : Boolean;
begin
   for Dim in DimType do
   begin
      MinPoint[Dim] := AxisMax-1;
      MaxPoint[Dim] := 0;
      LastPoint[Dim] := 0
   end;

   for I in IndexType do
      if Board[I] = Active then
      begin
         Point := GetPoint(I);
         for Dim in DimType do
         begin
            if Point[Dim] < MinPoint[Dim] then MinPoint[Dim] := Point[Dim];
            if Point[Dim] > MaxPoint[Dim] then MaxPoint[Dim] := Point[Dim]
         end
      end;

   for I := GetIndex(MinPoint) to GetIndex(MaxPoint) do
   begin
      Point := GetPoint(I);
      InBounds := true;
      for Dim in DimType do
         if (Point[Dim] < MinPoint[Dim]) or (Point[Dim] > MaxPoint[Dim]) then InBounds := false;
      if InBounds then
      begin
         for Dim := N downto 3 do
            if Point[Dim] <> LastPoint[Dim] then
            begin
               writeln;
               write(Axes[Dim], '=', Point[Dim] - (AxisMax shr 1))
            end;
         if Point[2] <> LastPoint[2] then Writeln;
         if Board[I] = Active then
            write('#')
         else
            write('.');
         LastPoint := Point;
      end;
   end;
   writeln
end;

procedure Simulate;
var
   NewBoard   : BoardType;
   NeighPoint : PointType;
   Point      : PointType;
   J, K       : IndexType;
   Neighbors  : Integer;
begin
   Clear(NewBoard);

   for I in IndexType do
   begin
      Point := GetPoint(I);
      Neighbors := 0;

      for J := 0 to (3 ** N)-1 do
      begin
         K := J;
         for Dim in DimType do
         begin
            NeighPoint[Dim] := Max(Min(Point[Dim] + (K mod 3) - 1, AxisMax-1), 0);
            K := K div 3
         end;
         if Board[GetIndex(NeighPoint)] = Active then Inc(Neighbors);
      end;

      if Board[I] = Active then
      begin
         if (Neighbors = 3) or (Neighbors = 4) then NewBoard[I] := Active;
      end
      else if Neighbors = 3 then NewBoard[I] := Active;
   end;

   Board := NewBoard;
end;

function CountBoard : Integer;
var
   Counter : Integer;
begin
   Counter := 0;
   for I in IndexType do
      if Board[I] = Active then Inc(Counter);

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
      WriteBoard;
      writeln('Step = ', Step, ', Count = ', CountBoard);
   end;
end.
