module Day12
  ( day12,
    day12_2
  ) where

import Prelude hiding (Left, Right)

inputFile :: String
inputFile = "day12_input.txt"

data Axis = NS | EW deriving (Show, Eq, Ord)
data Coordinate = Coordinate Axis Int deriving (Show, Eq, Ord)
data Position = Position Coordinate Coordinate deriving (Show, Eq, Ord)
data Direction = North | East | South | West deriving (Show, Eq, Ord, Enum, Bounded)

update :: Coordinate -> Direction -> Int -> Coordinate
update (Coordinate axis val) dir value = Coordinate axis $ val + (mul axis dir) * value
  where mul NS dir = case dir of
          North -> 1
          South -> -1
          _ -> 0
        mul EW dir = case dir of
          East -> 1
          West -> -1
          _ -> 0

updatePos :: Position -> Direction -> Int -> Position
updatePos (Position nw ew) dir value = Position (update nw dir value) (update ew dir value)

data Rotation = Left | Right deriving (Show, Eq)
right :: Direction -> Direction
right d | d == maxBound = minBound | otherwise = succ d

left :: Direction -> Direction
left d | d == minBound = maxBound | otherwise = pred d

rotate :: Direction -> Rotation -> Int -> Direction
rotate d r a = iterate (rot r) d !! (a `div` 90)
  where rot Right = right
        rot Left  = left

data Ship = Ship Position Direction deriving (Show, Eq, Ord)
startPosition :: Int -> Int -> Position
startPosition ns ew = Position (startCoord NS ns) (startCoord EW ew)
  where startCoord axis val = Coordinate axis val
startShip :: Ship
startShip = Ship (startPosition 0 0) East

data Op = DirOp Direction | RotOp Rotation | Forward deriving (Show, Eq)
data Instruction = Instruction Op Int deriving (Show, Eq)

readInstr :: String -> Instruction
readInstr (o:v) = Instruction (op o) (value v)
  where op o = case o of
          'N' -> DirOp North
          'S' -> DirOp South
          'E' -> DirOp East
          'W' -> DirOp West
          'L' -> RotOp Left
          'R' -> RotOp Right
          'F' -> Forward
        value = read

navi :: Ship -> Instruction -> Ship
navi s (Instruction (DirOp d) value) = move s d value
  where move (Ship pos d) dir value = Ship (updatePos pos dir value) d
navi s (Instruction (RotOp r) value) = turn s r value
  where turn (Ship pos dir) r value = Ship pos $ rotate dir r value
navi s (Instruction Forward value) = forward s value
  where forward (Ship pos dir) value = Ship (updatePos pos dir value) dir

data Waypoint = Waypoint Position deriving (Show, Eq)
data WayShip = WayShip Position Waypoint deriving (Show, Eq)
startWayShip :: WayShip
startWayShip = WayShip (startPosition 0 0) $ Waypoint (startPosition 1 10)

navi2 :: WayShip -> Instruction -> WayShip
navi2 s (Instruction (DirOp d) value) = move s d value
  where move (WayShip pos (Waypoint wpos)) dir value = WayShip pos $ Waypoint $ updatePos wpos dir value
navi2 s (Instruction (RotOp r) value) = turn s r value
  where turn (WayShip pos way) r value = WayShip pos $ Waypoint $ rotway way r value
        rotway (Waypoint wpos) Right val = iterate cw wpos !! (val `div` 90)
        rotway way Left val = rotway way Right $ 360 - val
        cw (Position (Coordinate NS ns) (Coordinate EW ew)) = Position (Coordinate NS (-ew)) (Coordinate EW ns)
navi2 s (Instruction Forward value) = forward s value
  where forward (WayShip pos way) value = WayShip (stepWay pos way value) way
        stepWay pos (Waypoint wpos) steps = add (add pos wpos North steps) wpos East steps
        add pos wpos axis steps = updatePos pos axis $ steps * getAxis axis wpos
        getAxis North (Position (Coordinate NS ns) _) = ns
        getAxis East  (Position _ (Coordinate EW ew)) = ew


manhattan :: Position -> Int
manhattan (Position ns ew) = absPos ns + absPos ew
  where absPos (Coordinate _ x) = abs x

day12 :: IO Int
day12 = do
  content <- readFile inputFile
  return $ shipMan $ foldl navi startShip $ map readInstr $ lines content
    where shipMan (Ship pos _) = manhattan pos

day12_2 :: IO Int
day12_2 = do
  content <- readFile inputFile
  return $ wayMan $ foldl navi2 startWayShip $ map readInstr $ lines content
    where wayMan (WayShip pos _) = manhattan pos
