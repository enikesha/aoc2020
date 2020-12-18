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
   AxisType   = 0..AxisMax;
   IndexType  = 0..LastIndex;
   BoardType  = array [0..LastIndex] of StatusType;
   PointType  = array [1..N] of AxisType;
   PBoardType = ^BoardType;

var
   PBoard        : PBoardType;
   Point         : PointType;
   I             : IndexType;
   Dim           : DimType;
   BoardMinPoint : PointType;
   BoardMaxPoint : PointType;

procedure Clear(NewBoard: PBoardType);
begin
   for I in IndexType do NewBoard^[I] := Inactive;
end;

procedure ReadBoard;
var
   Line : String;
   C    : Char;
begin
   Clear(PBoard);

   { Middle of the board }
   I := AxisMax shr 1;
   for Dim := N-1 downto 1 do
      I := (I shl BoardBits) + (AxisMax shr 1);
   while not eof do
   begin
      readln(Line);
      for C in Line do
      begin
         if C = '#' then PBoard^[I] := Active;
         Inc(I);
      end;
      I := I - Length(Line) + AxisMax;
   end
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


procedure IterateOrthotope(var I : IndexType; var Point, MinPoint, MaxPoint : PointType);
begin
   Inc(Point[1]);
   Inc(I);
   for Dim := 1 to N - 1 do
      if Point[Dim] > MaxPoint[Dim] then
      begin
         Point[Dim] := MinPoint[Dim];
         inc(Point[Dim+1]);
         I := I - succ(MaxPoint[Dim]-MinPoint[Dim])*(1 shl (pred(Dim)*BoardBits)) + (1 shl (Dim*BoardBits))
      end
      else
         break;
end;

procedure FindBoardBounds(var MinPoint, MaxPoint : PointType; offs : Integer);
begin
   for Dim in DimType do
   begin
      MinPoint[Dim] := AxisMax-1;
      MaxPoint[Dim] := 0;
      Point[Dim]    := 0;
   end;

   I := 0;
   repeat
      if PBoard^[I] = Active then
         for Dim in DimType do
         begin
            if (Point[Dim]-offs) < MinPoint[Dim] then MinPoint[Dim] := Point[Dim] - offs;
            if (Point[Dim]+offs) > MaxPoint[Dim] then MaxPoint[Dim] := Point[Dim] + offs
         end;
      IterateOrthotope(I, Point, BoardMinPoint, BoardMaxPoint);
   until I = LastIndex;
end;

procedure WriteBoard;
var
   MinPoint  : PointType;
   MaxPoint  : PointType;
   LastPoint : PointType;
   J         : IndexType;
begin
   for Dim in DimType do
   begin
      Point[Dim]     := 0;
      LastPoint[Dim] := 0
   end;

   FindBoardBounds(MinPoint, MaxPoint, 0);
   WritePoint('Min ', MinPoint);
   WritePoint('Max ', MaxPoint);

   Point := MinPoint;
   I := GetIndex(MinPoint);
   J := GetIndex(MaxPoint);

   while I <= J do
   begin
      for Dim := N downto 3 do
         if Point[Dim] <> LastPoint[Dim] then
         begin
            writeln;
            write(Axes[Dim], '=', Point[Dim] - (AxisMax shr 1))
         end;
      if Point[2] <> LastPoint[2] then Writeln;
      if PBoard^[I] = Active then
         write('#')
      else
         write('.');

      LastPoint := Point;
      IterateOrthotope(I,Point,MinPoint,MaxPoint);
   end;
   writeln
end;

procedure Simulate(PNextBoard : PBoardType );
var
   MinPoint      : PointType;
   MaxPoint      : PointType;
   MinNeighPoint : PointType;
   MaxNeighPoint : PointType;
   NeighPoint    : PointType;
   J, K, L       : IndexType;
   Neighbors     : Integer;
begin
   Clear(PNextBoard);

   FindBoardBounds(MinPoint, MaxPoint, 1);

   Point := MinPoint;
   I := GetIndex(MinPoint);
   J := GetIndex(MaxPoint);

   while I <= J do
   begin
      for Dim in DimType do
      begin
         MinNeighPoint[Dim] := Point[Dim] - 1;
         MaxNeighPoint[Dim] := Point[Dim] + 1
      end;

      NeighPoint := MinNeighPoint;
      K := GetIndex(MinNeighPoint);
      L := GetIndex(MaxNeighPoint);

      Neighbors := 0;
      while K <= L do
      begin
         if PBoard^[K] = Active then Inc(Neighbors);
         IterateOrthotope(K,NeighPoint,MinNeighPoint,MaxNeighPoint);
      end;

      if PBoard^[I] = Active then
      begin
         if (Neighbors = 3) or (Neighbors = 4) then PNextBoard^[I] := Active;
      end
      else if Neighbors = 3 then PNextBoard^[I] := Active;

      IterateOrthotope(I,Point,MinPoint,MaxPoint);
   end;
end;

function CountBoard : Integer;
var
   Counter : Integer;
begin
   Counter := 0;
   for I in IndexType do
      if PBoard^[I] = Active then Inc(Counter);

   CountBoard := Counter
end;

var
   Step       : Integer;
   PNextBoard : PBoardType;
   PTmpBoard  : PBoardType;
begin
   for Dim in DimType do
   begin
      BoardMinPoint[Dim] := 0;
      BoardMaxPoint[Dim] := AxisMax-1
   end;
   New(PBoard);
   New(PNextBoard);

   ReadBoard;
   writeln('Input');
   WriteBoard;

   for Step := 1 to Steps do
   begin
      Simulate(PNextBoard);
      PTmpBoard  := PBoard;
      PBoard     := PNextBoard;
      PNextBoard := PTmpBoard;
      writeln('Step = ', Step, ', Count = ', CountBoard);
   end;
   {WriteBoard;}
end.
