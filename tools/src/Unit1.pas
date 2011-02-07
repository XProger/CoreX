unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Math, Buttons, ShellAPI;

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    RandomTB: TTrackBar;
    Label3: TLabel;
    RoomCountTB: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    RoomMinTB: TTrackBar;
    Label4: TLabel;
    RoomMaxTB: TTrackBar;
    Label5: TLabel;
    GroundCostTB: TTrackBar;
    Label6: TLabel;
    TunnelCostTB: TTrackBar;
    Label7: TLabel;
    RoomCostTB: TTrackBar;
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    TilingCB: TCheckBox;
    SpeedButton1: TSpeedButton;
    Edit1: TEdit;
    ColumnCostTB: TTrackBar;
    Label8: TLabel;
    procedure Generate;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeTB(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
// for triangulation
  PVertex = ^TVertex;
  PEdge   = ^TEdge;
  TIndex = LongInt;

  TVertex = record
    x, y : Single;
  end;

  TEdge = record
      Idx  : LongInt;
      Dest : PVertex;
      Next : PEdge;
      Twin : PEdge;
    end;

  TEdgeArray   = array of TEdge;
  TIndexArray  = array of TIndex;
  TVertexArray = array of TVertex;

  TRoom = class
    constructor Create;
  public
    NRect : TRect;
    class var
      Rooms : array of TRoom;
    class procedure Clear;
    class procedure Center;
    class procedure Bake;
    class procedure Link;
  end;

  TLight = record
    X, Y, Z : Single;
    Color : record
        r, g, b: Single;
      end;
    Radius : Single;
  end;

  TMaskMatrix = array of array of Byte;

  TRandMask = array of record
      ID  : LongInt;
      idx : LongInt;
      rot : LongInt;
    end;

  TMask = record
    Rand   : Boolean;
    Inst   : Boolean;
    Name   : string;
    Tile   : TBitmap;
    Matrix : array of TMaskMatrix;
    procedure Compare(ID: LongInt; var RandMask: TRandMask; x, y: LongInt); overload;
    procedure Compare(ID: LongInt; var RandMask: TRandMask; const Rect: TRect); overload;
    procedure Bake(const Rect: TRect; idx: LongInt);
  end;

const
  MAP_SIZE  = 64;
  MAP_SCALE = 10;

var
  Form1 : TForm1;
  Page  : TBitmap;
  Map   : array [0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of Word;
  Mask  : array of TMask;

  DMap  : array [0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of Word;

  Lights : array of TLight;

  ROOM_SIZE_MIN    : LongInt = 4;
  ROOM_SIZE_MAX    : LongInt = 8;
  RAND_SEED        : LongInt = -1;
  ROOM_COUNT       : LongInt = 10;

  COST_GROUND      : LongInt = 3;
  COST_TUNNEL      : LongInt = 2;
  COST_ROOM        : LongInt = 1;
  COST_COLUMN      : Single = 1;

implementation

{$R *.dfm}

function ToPoint(const v: TVertex): TPoint;
begin
  Result.X := Round(v.x);
  Result.Y := Round(v.y);
end;

procedure Triangulate(const Vertex: TVertexArray; out Index: TIndexArray);
const
  BOUND_MAX = High(Word);
  Bound : array [0..2] of TVertex = ((x: 0; y: -BOUND_MAX), (x: BOUND_MAX; y: BOUND_MAX), (x: -BOUND_MAX; y: BOUND_MAX));
var
  EdgeCount, IndexCount : LongInt;
  Edge : TEdgeArray;

  procedure SetEdge(e: PEdge; Dest: PVertex; Next, Twin: PEdge; Idx: LongInt);
  begin
    e^.Idx  := Idx;
    e^.Dest := Dest;
    e^.Next := Next;
    e^.Twin := Twin;
  end;

  function IsBound(e: PEdge): Boolean;
  begin
    Result := (e = @Edge[0]) or (e = @Edge[1]) or (e = @Edge[2]) or
              (e = @Edge[3]) or (e = @Edge[4]) or (e = @Edge[5]);
  end;

  function IsExists(const v: TVertex): Boolean;
  var
    i : LongInt;
  begin
    for i := 0 to EdgeCount - 1 do
      if (Edge[i].Dest^.x = v.x) and (Edge[i].Dest^.y = v.y) then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;

  function IsRight(const v, a, b: TVertex): Boolean;
  begin
    Result := (b.x - a.x) * (v.y - a.y) - (v.x - a.x) * (b.y - a.y) < 0;
  end;

  function InCircle(const v, a, b, c: TVertex): Boolean;
  var
    p, q, r : TVertex;
  begin
    p.x := b.x - a.x;
    p.y := b.y - a.y;
    q.x := c.x - a.x;
    q.y := c.y - a.y;
    r.x := v.x - a.x;
    r.y := v.y - a.y;
    Result := (sqr(p.x) + sqr(p.y)) * (q.x * r.y - q.y * r.x) -
              (sqr(q.x) + sqr(q.y)) * (p.x * r.y - p.y * r.x) +
              (sqr(r.x) + sqr(r.y)) * (p.x * q.y - p.y * q.x) > 0;
  end;

  function InTriangle(const v: TVertex): PEdge;
  const
    p : TVertex = (x: 0; y: 0);
  var
    e : PEdge;
  begin
    e := @Edge[0];
    while IsRight(v, e^.Twin^.Dest^, e^.Dest^) do
      if IsRight(e^.Next^.Dest^, p, v) then
        e := e^.Next^.Twin
      else
        e := e^.Next^.Next^.Twin;
    Result := e^.Twin;
  end;

  procedure Swap(e: PEdge);
  begin
    e^.Idx  := e^.Next^.Idx;
    e^.Dest := e^.Next^.Dest;
    e^.Twin^.Idx  := e^.Twin^.Next^.Idx;
    e^.Twin^.Dest := e^.Twin^.Next^.Dest;
    e^.Next^.Next^.Next := e^.Twin^.Next;
    e^.Twin^.Next^.Next^.Next := e^.Next;
    e^.Next := e^.Next^.Next;
    e^.Twin^.Next := e^.Twin^.Next^.Next;
    e^.Next^.Next^.Next := e;
    e^.Twin^.Next^.Next^.Next := e^.Twin;
  end;

  procedure Organize(e: PEdge);
  begin
    if IsBound(e) then
      Exit;
    if InCircle(e^.Twin^.Next^.Dest^, e^.Dest^, e^.Next^.Dest^, e^.Twin^.Dest^) then
    begin
      Swap(e);
      Organize(e^.Next^.Next);
      Organize(e^.Twin^.Next);
    end;
  end;

  procedure Insert(Idx: LongInt);
  type
    TEdgeVector = array [0..5] of TEdge;
  var
    e  : PEdge;
    v  : PVertex;
    ev : ^TEdgeVector;
  begin
    if IsExists(Vertex[Idx]) then
      Exit;
    v := @Vertex[Idx];
    e := InTriangle(v^);
    ev := @Edge[EdgeCount];
    SetEdge(@ev[0], v, @ev[5], @ev[1], Idx);
    SetEdge(@ev[1], e^.Dest, e^.Next, @ev[0], e^.Idx);
    SetEdge(@ev[2], v, @ev[1], @ev[3], Idx);
    SetEdge(@ev[3], e^.Next^.Dest, e^.Next^.Next, @ev[2], e^.Next^.Idx);
    SetEdge(@ev[4], v, @ev[3], @ev[5], Idx);
    SetEdge(@ev[5], e^.Twin^.Dest, e, @ev[4], e^.Twin^.Idx);

    e^.Next^.Next^.Next := @ev[4];
    e^.Next^.Next := @ev[2];
    e^.Next := @ev[0];
    Organize(ev[5].Next);
    Organize(ev[1].Next);
    Organize(ev[3].Next);
    Inc(EdgeCount, 6);
  end;

var
  i : LongInt;
begin
  SetLength(Edge, Length(Vertex) * 12); // with reserved
// init triangle superstructure
  SetEdge(@Edge[0], @Bound[2], @Edge[2], @Edge[1], -1);
  SetEdge(@Edge[1], @Bound[0], nil, @Edge[0], -1);
  SetEdge(@Edge[2], @Bound[1], @Edge[4], @Edge[3], -1);
  SetEdge(@Edge[3], @Bound[2], nil, @Edge[2], -1);
  SetEdge(@Edge[4], @Bound[0], @Edge[0], @Edge[5], -1);
  SetEdge(@Edge[5], @Bound[1], nil, @Edge[4], -1);
  EdgeCount := 6;
// triangulate
  for i := 0 to Length(Vertex) - 1 do
    Insert(i);
// get indices
  SetLength(Index, Length(Vertex) * 6); // with reserved
  IndexCount := 0;
  for i := 3 to EdgeCount div 2 - 1 do
    with Edge[i * 2] do
      if (Idx > -1) and (Next^.Idx > -1) and (Next^.Next^.Idx > -1) then
      begin
        Index[IndexCount + 0] := Idx;
        Index[IndexCount + 1] := Next^.Idx;
        Index[IndexCount + 2] := Next^.Next^.Idx;
        Inc(IndexCount, 3);
        Next^.Next^.Idx := -1;
        Next^.Idx := -1;
        Idx := -1;
      end;
  SetLength(Index, IndexCount);
end;

procedure Connect(const Pos, TargetPos: TPoint);
const
  Course : array [0..3] of TPoint = ((X: -1; Y: 0), (X: 0; Y: -1), (X: 1; Y: 0), (X: 0; Y: 1));
var
  BMap : array [0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of record
      State  : Boolean;
//      ID     : LongInt;
      Weight : LongInt;
      Cost   : LongInt;
      Prev   : TPoint;
    end;
  List  : array [Word] of TPoint;//array [0..MAP_SIZE * MAP_SIZE - 1] of TPoint;
  Count : LongInt;
  i, n, x, y : LongInt;
  p : TPoint;
begin
// clear way map
  FillChar(BMap, SizeOf(BMap), 0);

  for y := 0 to MAP_SIZE - 1 do
    for x := 0 to MAP_SIZE - 1 do
      BMap[x, y].Weight := COST_GROUND;

// room borders
  for i := 0 to Length(TRoom.Rooms) - 1 do
    with TRoom.Rooms[i].NRect do
    begin
      for y in [Top - 1, Bottom] do
        for x in [Left - 1..Right] do
          if (x >= 0) and (y >= 0) and (x < MAP_SIZE) and (y < MAP_SIZE) then
            BMap[x, y].Weight := COST_GROUND * 2;
      for x in [Left - 1, Right] do
        for y in [Top..Bottom - 1] do
          if (x >= 0) and (y >= 0) and (x < MAP_SIZE) and (y < MAP_SIZE) then
            BMap[x, y].Weight := COST_GROUND * 2;
    end;

  for y := 0 to MAP_SIZE - 1 do
    for x := 0 to MAP_SIZE - 1 do
      case Map[x, y] of
        0 : ;//BMap[x, y].Weight := COST_GROUND; // none
        1 : BMap[x, y].Weight := COST_TUNNEL; // corridor
      else
        BMap[x, y].Weight := COST_ROOM; // room
//        BMap[x, y].ID     := Map[x, y];
        with TRoom.Rooms[Map[x, y] - 10].NRect do
          if ((x = Left) or (x = Right - 1)) and ((y = Top) or (y = Bottom - 1)) then
            BMap[x, y].State := True;
      end;

// find path A*
  BMap[Pos.X, Pos.Y].State := True;
  List[0] := Pos;
  Count   := 1;
  while Count > 0 do
  begin
  // search min cost node
    n := 0;
    for i := 0 to Count - 1 do
      if BMap[List[i].X, List[i].Y].Cost < BMap[List[n].X, List[n].Y].Cost then
        n := i;
    p := List[n];
  // delete node
    Dec(Count);
    List[n] := List[Count];
  // course of nearest nodes
    for i := 0 to 3 do
    begin
      x := p.X + Course[i].X;
      y := p.Y + Course[i].Y;
      if (x < 1) or (x >= MAP_SIZE - 1) or
         (y < 1) or (y >= MAP_SIZE - 1) or
         BMap[x, y].State then
        continue;
    // finish check
      if (x = TargetPos.X) and (Y = TargetPos.Y) then
      begin
      // reconstruct path
        while not ((p.X = Pos.X) and (p.Y = Pos.Y)) do
        begin
          if Map[p.X, p.Y] = 0 then
            Map[p.X, p.Y] := 1;
          p := BMap[p.X, p.Y].Prev;
        end;
        Exit;
      end;
    // add node
      BMap[x, y].Prev := p;

      if (BMap[x, y].Weight < 0) and (BMap[p.X, p.Y].Weight < 0) then
        BMap[x, y].Weight := BMap[x, y].Weight * 10;

      if ((p.X - x) = (BMap[p.X, p.Y].Prev.X - p.X)) and
         ((p.Y - y) = (BMap[p.X, p.Y].Prev.Y - p.Y)) then
        BMap[x, y].Cost := BMap[p.X, p.Y].Cost + abs(BMap[x, y].Weight)
      else
        BMap[x, y].Cost := BMap[p.X, p.Y].Cost + abs(BMap[x, y].Weight) * 2;

      BMap[x, y].State := True;
      List[Count].X := x;
      List[Count].Y := y;
      Inc(Count);
    end;
  end;
end;

{ TMask }
procedure TMask.Compare(ID: LongInt; var RandMask: TRandMask; x, y: LongInt);

  function Cmp(x, y: LongInt): Boolean;
  begin
    if y > 2 then
      y := 2;
    Result := x = y;
  end;

  function CompareMatrix(const Matrix: TMaskMatrix; d: LongInt): Boolean;
  const
    Dir : array [0..3, 0..8, 0..1] of LongInt = (
    // 0
      ((-1, -1), ( 0, -1), ( 1, -1),
       (-1,  0), ( 0,  0), ( 1,  0),
       (-1,  1), ( 0,  1), ( 1,  1)),
    // 90
      ((-1,  1), (-1,  0), (-1, -1),
       ( 0,  1), ( 0,  0), ( 0, -1),
       ( 1,  1), ( 1,  0), ( 1, -1)),
    // 180
      (( 1,  1), ( 0,  1), (-1,  1),
       ( 1,  0), ( 0,  0), (-1,  0),
       ( 1, -1), ( 0, -1), (-1, -1)),
    // 270
      (( 1, -1), ( 1,  0), ( 1,  1),
       ( 0, -1), ( 0,  0), ( 0,  1),
       (-1, -1), (-1,  0), (-1,  1))
    );
  var
    i : LongInt;
  begin
    if Cmp(Matrix[1, 1], Map[x, y]) then
    begin
      Result := True;
      for i := 0 to 8 do
        if not Cmp(Matrix[i div 3, i mod 3], Map[x + Dir[d][i][0], y + Dir[d][i][1]]) then
        begin
          Result := False;
          break;
        end;
    end else
      Result := False;
  end;

var
  i, j : LongInt;
begin
  for i := 0 to Length(Matrix) - 1 do
    for j := 0 to 3 do
      if CompareMatrix(Matrix[i], j) then
      begin
        SetLength(RandMask, Length(RandMask) + 1);
        RandMask[Length(RandMask) - 1].ID  := ID;
        RandMask[Length(RandMask) - 1].idx := i;
        RandMask[Length(RandMask) - 1].rot := j;
      end;
end;

procedure TMask.Compare(ID: LongInt; var RandMask: TRandMask; const Rect: TRect);
var
  i : LongInt;
begin
  for i := 0 to Length(Matrix) - 1 do
    if (Length(Matrix[i]) <= Rect.Bottom - Rect.Top) and
       (Length(Matrix[i][0]) <= Rect.Right - Rect.Left) then
    begin
      SetLength(RandMask, Length(RandMask) + 1);
      RandMask[Length(RandMask) - 1].ID  := ID;
      RandMask[Length(RandMask) - 1].idx := i;
    end;
end;

procedure TMask.Bake(const Rect: TRect; idx: LongInt);
var
  x, y, tx, ty : Integer;
begin
  with Rect do
  begin
    tx := Left + ((Right - Left) - Length(Matrix[idx][0])) div 2;
    ty := Top + ((Bottom - Top) - Length(Matrix[idx])) div 2;
  end;

  for y := 1 to Length(Matrix[idx]) - 2 do
    for x := 1 to Length(Matrix[idx][y]) - 2 do
      if Matrix[idx][y][x] = 3 then
        Map[tx + x, ty + y] := 3;
end;

procedure ReadMasks;
var
  F : TextFile;
  s : string;
  i, j : LongInt;

  procedure SetMatrixLine(s: string);
  var
    i : LongInt;
    Line : LongInt;
  begin
    with Mask[Length(Mask) - 1] do
    begin
      i := Length(Matrix) - 1;
      Line := Length(Matrix[i]);
      SetLength(Matrix[i], Line + 1);
      SetLength(Matrix[i][Line], Length(s));
      for i := 0 to Length(s) - 1 do
        case s[i + 1] of
          '0' : Matrix[Length(Matrix) - 1][Line][i] := 0;
          't' : Matrix[Length(Matrix) - 1][Line][i] := 1;
          'r' : Matrix[Length(Matrix) - 1][Line][i] := 2;
          'c' : Matrix[Length(Matrix) - 1][Line][i] := 3;
        end;
    end;
  end;

begin
  AssignFile(F, 'mesh/mask.txt');
  Reset(F);
  while not Eof(F) do
  begin
    Readln(F, s);
    if s = '' then
      continue;

    if (s[1] <> '/') and (s[1] <> '%') then
    begin
      with Mask[Length(Mask) - 1] do
      begin
        SetLength(Matrix, Length(Matrix) + 1);
        Inst := False;
      end;

      repeat
        SetMatrixLine(s);
        Readln(F, s);
      until s = '';

    end else
    begin
      SetLength(Mask, Length(Mask) + 1);
      with Mask[Length(Mask) - 1] do
      begin
        Inst := True;
        Rand := s[1] = '%';
        Name := Copy(s, 2, 255);
        Tile := TBitmap.Create;
        Tile.LoadFromFile('mesh/' + Name + '.bmp');
        Matrix := nil;
      end;
    end;
  end;
  CloseFile(F);

  j := Length(Mask) - 1;
  for i := Length(Mask) - 2 downto 0 do
    if Mask[i].Inst then
    begin
      Mask[i].Matrix := Mask[j].Matrix;
      Mask[i].Rand   := Mask[j].Rand;
    end else
      j := i;
end;

procedure FreeMasks;
var
  i : LongInt;
begin
  for i := 0 to Length(Mask) - 1 do
    if not Mask[i].Inst then
      Mask[i].Tile.Free;
end;


{ TRoom }
function RectIntersect(const Rect1, Rect2: TRect): Boolean;
begin
  Result := not ((Rect1.Left   > Rect2.Right)  or
                 (Rect1.Right  < Rect2.Left)   or
                 (Rect1.Top    > Rect2.Bottom) or
                 (Rect1.Bottom < Rect2.Top));
end;

function RectDist(const Rect1, Rect2: TRect): Single;
begin
  Result := sqrt(sqr(((Rect1.Left + Rect1.Right) - (Rect2.Left + Rect2.Right)) * 0.5) +
                 sqr(((Rect1.Top + Rect1.Bottom) - (Rect2.Top + Rect2.Bottom)) * 0.5));
end;

constructor TRoom.Create;
label
  Place;
var
  i, t : LongInt;
begin
  t := 0;
Place:
  Inc(t);
  if t > 100 then
    raise EFCreateError.Create(nil, '');

  NRect.Right  := Random(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN;
  NRect.Bottom := Random(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN;
  NRect.Left   := Random(MAP_SIZE - NRect.Right - 1) + 1;
  NRect.Top    := Random(MAP_SIZE - NRect.Bottom - 1) + 1;
  NRect.Bottom := NRect.Top + NRect.Bottom;
  NRect.Right  := NRect.Left + NRect.Right;

  for i := 0 to Length(Rooms) - 1 do
   if RectIntersect(NRect, Rooms[i].NRect) then
     goto Place;

{
  NRect.Left   := 0;
  NRect.Right  := Random(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN;
  NRect.Bottom := Random(ROOM_SIZE_MAX - ROOM_SIZE_MIN + 1) + ROOM_SIZE_MIN;
  NRect.Top    := Random(MAP_SIZE - NRect.Bottom);
  NRect.Bottom := NRect.Top + NRect.Bottom;

  for i := 0 to Length(Rooms) - 1 do
    with Rooms[i].NRect do
      if not ((Top > NRect.Bottom) or (Bottom < NRect.Top)) and (NRect.Left - 1 < Right) then
        NRect.Left := Right + 1;

  NRect.Right := NRect.Right + NRect.Left;

  if NRect.Right > MAP_SIZE then
    goto Place;
}
  SetLength(Rooms, Length(Rooms) + 1);
  Rooms[Length(Rooms) - 1] := Self;
end;

class procedure TRoom.Clear;
var
  i : LongInt;
begin
  for i := 0 to Length(Rooms) - 1 do
    Rooms[i].Free;
  Rooms := nil;
end;

class procedure TRoom.Center;
var
  i, x, y, MinX, MaxX, MinY, MaxY : LongInt;
begin
  MinX := MAP_SIZE;
  MaxX := 0;
  MinY := MinX;
  MaxY := MaxX;
  for i := 0 to Length(Rooms) - 1 do
    with Rooms[i].NRect do
    begin
      MinX := Min(MinX, Left);
      MinY := Min(MinY, Top);
      MaxX := Max(MaxX, Right);
      MaxY := Max(MaxY, Bottom);
    end;
  x := ((MaxX - MinX) + MAP_SIZE) div 2 - MaxX;
  y := ((MaxY - MinY) + MAP_SIZE) div 2 - MaxY;
  for i := 0 to Length(Rooms) - 1 do
    with Rooms[i].NRect do
    begin
      Inc(Left, x);
      Inc(Top, y);
      Inc(Right, x);
      Inc(Bottom, y);
    end;
end;

class procedure TRoom.Bake;
var
  i, x, y : LongInt;
begin
  for i := 0 to Length(Rooms) - 1 do
    with Rooms[i].NRect do
      for y := Top to Bottom - 1 do
        for x := Left to Right - 1 do
          Map[x, y] := i + 10;
end;

class procedure TRoom.Link;
var
  i : LongInt;
  Vertex : TVertexArray;
  Index  : TIndexArray;
  Link   : array of array [0..1] of LongInt;

  procedure AddLink(Index1, Index2: LongInt);
  var
    i : LongInt;
  begin
  // check existing link
    for i := 0 to Length(Link) - 1 do
      if ((Link[i][0] = Index1) and (Link[i][1] = Index2)) or
         ((Link[i][1] = Index1) and (Link[i][0] = Index2)) then
        Exit;
  // add new link
    SetLength(Link, Length(Link) + 1);
    Link[Length(Link) - 1][0] := Index1;
    Link[Length(Link) - 1][1] := Index2;
  end;

begin
  SetLength(Vertex, Length(Rooms));
  for i := 0 to Length(Rooms) - 1 do
    with Rooms[i].NRect do
    begin
      Vertex[i].x := (Left + Right) * 0.5 + (Right - Left) * 0.01;
      Vertex[i].y := (Top + Bottom) * 0.5 + (Bottom - Top) * 0.01;
    end;

  Triangulate(Vertex, Index);
  for i := 0 to Length(Index) div 3 - 1 do
  begin
    AddLink(Index[i * 3 + 0], Index[i * 3 + 1]);
    AddLink(Index[i * 3 + 1], Index[i * 3 + 2]);
    AddLink(Index[i * 3 + 2], Index[i * 3 + 0]);
  end;

  for i := 0 to Length(Link) - 1 do
    Connect(ToPoint(Vertex[Link[i][0]]), ToPoint(Vertex[Link[i][1]]));
end;

procedure Clear;
begin
  FillChar(Map, SizeOf(Map), 0);
  Page.Canvas.Brush.Color := clBlack;
  Page.Canvas.FillRect(Rect(0, 0, Page.Width, Page.Height));
end;

procedure TForm1.Generate;
const
  Colors : array [0..1] of LongWord = (
    $FFFFFF, $000000
  );

var
  i, j, x, y : LongInt;
  RandMask : TRandMask;
begin
  RAND_SEED     := RandomTB.Position;
  ROOM_COUNT    := RoomCountTB.Position;
  ROOM_SIZE_MIN := RoomMinTB.Position;
  ROOM_SIZE_MAX := Max(ROOM_SIZE_MIN, RoomMaxTB.Position);
  if ROOM_SIZE_MAX <> RoomMaxTB.Position then
    RoomMaxTB.Position := ROOM_SIZE_MAX;

  COST_GROUND   := GroundCostTB.Position;
  COST_TUNNEL   := TunnelCostTB.Position;
  COST_ROOM     := RoomCostTB.Position;
  COST_COLUMN   := ColumnCostTB.Position / 100;

  Clear;
  TRoom.Clear;

  RandSeed := RAND_SEED;

  StatusBar1.Panels[0].Text := '';
  for i := 0 to ROOM_COUNT - 1 do
    try
      TRoom.Create;
    except
      StatusBar1.Panels[0].Text := 'Error: Can''t create room';
      break;
    end;

  TRoom.Center;
  TRoom.Bake;
  TRoom.Link;

// lights
  RandSeed := RAND_SEED;
  SetLength(Lights, Length(TRoom.Rooms));
  for i := 0 to Length(Lights) - 1 do
    with TRoom.Rooms[i].NRect, Lights[i] do
    begin
      X := Top + (Bottom - Top) * (random * 0.2 + 0.4) - MAP_SIZE div 2;
      Y := 0.6;
      Z := MAP_SIZE - 1 - (Left + (Right - Left) * (random * 0.2 + 0.4)) - MAP_SIZE div 2;
      Radius := Max(Right - Left, Bottom - Top) * 0.5 * (random * 0.5 + 0.8);
      with Color do
      begin
        r := 0.2 + random * 0.5;
        g := 0.2 + random * 0.5;
        b := 0.2 + random * 0.5;
      end;
    end;

// random mask
  RandSeed := RAND_SEED;
  for i := 0 to Length(TRoom.Rooms) - 1 do
    if random < COST_COLUMN  then
    begin
      RandMask := nil;
      for j := 0 to Length(Mask) - 1 do
        with Mask[j] do
          if Rand then
            Mask[j].Compare(j, RandMask, TRoom.Rooms[i].NRect);

      if RandMask <> nil then
      begin
        j := Random(Length(RandMask));
        Mask[RandMask[j].ID].Bake(TRoom.Rooms[i].NRect, RandMask[j].idx);
      end;
    end;

  for y := 0 to MAP_SIZE - 1 do
    for x := 0 to MAP_SIZE - 1 do
    begin
      RandSeed := Map[x, y];
      if Map[x, y] > 0 then
        Page.Canvas.Pixels[x, y] := RGB(Random(256 - 32) + 32, Random(256 - 32) + 32, Random(256 - 32) + 32);
    end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
const
  Rot : array [0..1, 0..3] of Extended = ((1, 0, -1, 0), (0, 1, 0.000001, -1));
var
  x, y : LongInt;
  i, j : Integer;
  M    : TXForm;
  Flag : Boolean;
  RoomMask : LongInt;
  RandMask : TRandMask;
begin
  PaintBox1.Width  := MAP_SIZE * MAP_SCALE;
  PaintBox1.Height := MAP_SIZE * MAP_SCALE;
  PaintBox1.Canvas.StretchDraw(Rect(0, 0, MAP_SIZE * MAP_SCALE, MAP_SIZE * MAP_SCALE), Page);

  FillChar(DMap, SizeOf(DMap), 0);

  RoomMask := 0;
  for i := 0 to Length(Mask) - 1 do
    if (not Mask[i].Rand) and
       (Length(Mask[i].Matrix) > 0) and
       (Mask[i].Matrix[0][1][1] = 3) then
    begin
      RoomMask := i;
      break;
    end;

  if TilingCB.Checked then
  begin
    SetGraphicsMode(PaintBox1.Canvas.Handle, GM_ADVANCED);
  // fixed mask
    for y := 1 to MAP_SIZE - 2 do
      for x := 1 to MAP_SIZE - 2 do
      begin
        j := 0;
        Flag := False;
        if Map[x, y] = 3 then // room
        begin
          i := RoomMask;
          Flag := True;
        end else
        begin
          RandMask := nil;
          for i := 0 to Length(Mask) - 1 do
            if not Mask[i].Rand then
              Mask[i].Compare(i, RandMask, x, y);

          if RandMask <> nil then
          begin
            Flag := True;
            i := Random(Length(RandMask));
            j := RandMask[i].rot;
            i := RandMask[i].ID;
          end else
            i := 0;
        end;

        if Flag then
        begin
          DMap[x, y] := (i + 1) * 10 + j;
          M.eM11 :=  Rot[0][j];
          M.eM12 := -Rot[1][j];
          M.eM21 :=  Rot[1][j];
          M.eM22 :=  Rot[0][j];
          M.eDx  := x * MAP_SCALE + 5;
          M.eDy  := y * MAP_SCALE + 5;
          SetWorldTransform(PaintBox1.Canvas.Handle, M);
          PaintBox1.Canvas.Draw(-5, -5, Mask[i].Tile);
        end else
          if Map[x, y] > 0 then
            if StatusBar1.Panels[0].Text = '' then
              StatusBar1.Panels[0].Text := 'Error: not all blocks implemented';
      end;

    M.eM11 := 1;
    M.eM12 := 0;
    M.eM21 := 0;
    M.eM22 := 1;
    M.eDx  := 0;
    M.eDy  := 0;
    SetWorldTransform(PaintBox1.Canvas.Handle, M);


    PaintBox1.Canvas.Brush.Style := bsClear;
    for i := 0 to Length(Lights) - 1 do
      with Lights[i] do
      begin
        with Color do
          PaintBox1.Canvas.Pen.Color := RGB(Round(b * 255), Round(g * 255), Round(r * 255));
        PaintBox1.Canvas.Ellipse(Round((MAP_SIZE - 1 - (Z + MAP_SIZE div 2) - Radius) * MAP_SCALE), Round((X + MAP_SIZE div 2 - Radius) * MAP_SCALE),
                                 Round((MAP_SIZE - 1 - (Z + MAP_SIZE div 2) + Radius) * MAP_SCALE), Round((X + MAP_SIZE div 2 + Radius) * MAP_SCALE));
      end;
    PaintBox1.Canvas.Brush.Style := bsSolid;


    SetGraphicsMode(PaintBox1.Canvas.Handle, GM_COMPATIBLE);
  end;


end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  F : File;
  i : LongInt;
begin
  AssignFile(F, 'map.dmp');
  Rewrite(F, 1);
  BlockWrite(F, DMap, SizeOf(DMap));
  i := Length(Lights);
  BlockWrite(F, i, SizeOf(i));
  BlockWrite(F, Lights[0], Length(Lights) * SizeOf(Lights[0]));
  CloseFile(F);

  ShellExecute(Handle, 'open', 'dview.exe', PChar('map.dmp ' + Edit1.Text), PChar(ExtractFileDir(ParamStr(0))), SW_SHOW);
end;

procedure TForm1.ChangeTB(Sender: TObject);
begin
  Generate;
  PaintBox1.Repaint;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReadMasks;
  Page := TBitmap.Create;
  Page.SetSize(MAP_SIZE, MAP_SIZE);
  Generate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeMasks;
  Page.Free;
end;

end.
