unit xmd;

//{$DEFINE DEBUG}

{$IFDEF DEBUG}
//  {$DEFINE DEBUG_NODE}
//  {$DEFINE DEBUG_BBOX}
  {$DEFINE DEBUG_MESH}
{$ENDIF}

interface

uses
  Windows, CoreX, NvTriStrip, xmt;

{$REGION 'Common converter definitions'}
type
  TJoint = record
    Weight : Single;
    Joint  : array [0..1] of LongInt;
  end;

  TJointArray = array of TJoint;

  TUpAxis = (uaX, uaY, uaZ);

  TSourceID = (SID_UNKNOWN, SID_VERTEX, SID_POSITION, SID_TANGENT, SID_BINORMAL, SID_NORMAL, SID_TEXCOORD0, SID_TEXCOORD1, SID_COLOR, SID_JOINT, SID_WEIGHT, SID_BIND_MATRIX, SID_INPUT, SID_OUTPUT, SID_INTERPOLATION, SID_IN_TANGENT, SID_OUT_TANGENT);
  TSource = record
    SourceURL : string;
    Offset    : LongInt;
    Stride    : LongInt;
    ValueI    : TIntArray;
    ValueF    : TFloatArray;
    ValueS    : TStrArray;
    ValueJ    : TJointArray;
  end;
  TSourceArray = array [TSourceID] of TSource;

const
  UpAxisName : array [TUpAxis] of Char = ('X', 'Y', 'Z');
  SourceName : array [TSourceID] of string = ('UNKNOWN', 'VERTEX', 'POSITION', 'TEXTANGENT', 'TEXBINORMAL', 'NORMAL', 'TEXCOORD', 'TEXCOORD', 'COLOR', 'JOINT', 'WEIGHT', 'INV_BIND_MATRIX', 'INPUT', 'OUTPUT', 'INTERPOLATION', 'IN_TANGENT', 'OUT_TANGENT');

var
  UnitScale : Single;
  UpAxis    : TUpAxis;

{$ENDREGION}

{$REGION 'Mesh format'}
type
  TIndex = Word;
  TIndexArray = array of TIndex;

  TVertex = record
    Coord    : TVec3f;
    Tangent  : TVec3f;
    Binormal : TVec3f;
    Normal   : TVec3f;
    TexCoord : array [0..1] of TVec2f;
    Color    : TVec4f;
    Joint    : TJoint;
  end;
  TVertexArray = array of TVertex;

  TVertexIndex = record
    Coord    : LongInt;
    Tangent  : LongInt;
    Binormal : LongInt;
    Normal   : LongInt;
    TexCoord : array [0..1] of LongInt;
    Color    : LongInt;
  end;
  TVertexIndexArray = array of TVertexIndex;

  TNodeMesh = object
    Name   : string;
    Attrib : TMeshAttribs;
    Index  : TIndexArray;
    Vertex : TVertexArray;
    BBox   : TBox;
    Mesh   : TMesh;
    JName  : TStrArray;
  private
    procedure CalculateTBN;
    procedure CalculateBBox;
    procedure Optimize;
  public
    procedure Compile(Source: TSourceArray);
    procedure Free;
    procedure Save(const FileName: string);
  end;
{$ENDREGION}

{$REGION 'Light format'}
  TLight = record
    Color : TVec3f;
  end;
{$ENDREGION}

{$REGION 'Node format'}
type
  PNode = ^TNode;
  TNode = record
    Parent    : LongInt;
    Matrix    : TMat4f;
    AMatrix   : TMat4f;
    Joint     : Boolean;
    Source    : TSourceArray;
    Mesh      : TNodeMesh;
    Material  : TNodeMaterial;
    Id        : string;
    Name      : string;
    MeshURL   : string;
    MatURL    : string;
    MatSymbol : string;
    SkinURL   : string;
    JointURL  : string;
    JointBind : TMat4f;
  end;
  TNodeArray = array of TNode;

const
  ZeroNode : TNode = (
    Parent : 0;
    Matrix : (e00: 1; e10: 0; e20: 0; e30: 0;
              e01: 0; e11: 1; e21: 0; e31: 0;
              e02: 0; e12: 0; e22: 1; e32: 0;
              e03: 0; e13: 0; e23: 0; e33: 1);
    Joint  : False;
    Name     : '';
    MeshURL  : '';
    MatURL   : '';
    SkinURL  : '';
    JointURL : '';
  );
{$ENDREGION}
        
var
  FlipBinormal : Boolean = True;//False;
  Nodes : TNodeArray;
  BaseNodes : LongInt;

  procedure Convert(const FileName: string);

  procedure Info(const Text: string);
  procedure Error(const Text: string);
  procedure Warning(const Text: string);
  procedure Hint(const Text: string);

  function ConvURL(const URL: string): string;
  function ExtractFileName(const FileName: string): string;
  function ExtractFileDir(const FileName: string): string;
  function DeleteExt(const FileName: string): string;

  function ParseMatrix(const Str: string): TMat4f;

implementation

{$REGION 'Common functions'}
procedure Info(const Text: string);
begin
  Writeln(Text);
end;

procedure Error(const Text: string);
begin
  Writeln('! Error: ', Text);
  Readln;
end;

procedure Warning(const Text: string);
begin
  Writeln('! Warning: ', Text);
end;

procedure Hint(const Text: string);
begin
  Writeln('! Hint: ', Text);
end;

procedure WriteMat4f(const m: TMat4f);
begin
  with m do
  begin
    Writeln(' Matrix:');
    Writeln('  ', e00:0:2, #9, e10:0:2, #9, e20:0:2, #9, e30:0:2);
    Writeln('  ', e01:0:2, #9, e11:0:2, #9, e21:0:2, #9, e31:0:2);
    Writeln('  ', e02:0:2, #9, e12:0:2, #9, e22:0:2, #9, e32:0:2);
    Writeln('  ', e03:0:2, #9, e13:0:2, #9, e23:0:2, #9, e33:0:2);
  end;
end;

procedure WriteQuat(const q: TQuat);
begin
  with q do
  begin
    Writeln(' Quat:');
    Writeln('  ', x:0:2, #9, y:0:2, #9, z:0:2, #9, w:0:2);
  end;
end;

function ParseMatrix(const Str: string): TMat4f;
var
  Value : TFloatArray;
begin
  Value := ParseFloat(Str);
  if Length(Value) <> 16 then
  begin
    Error('Invalid matrix format "' + Str + '"');
    Exit;
  end;
  Result := TMat4f(Pointer(@Value[0])^);
end;

function ValidMatrix(const M: TMat4f; const Name: string): Boolean;
const
  ValidScale : TVec3f = (x: 1; y: 1; z: 1);
var
  Scale, v : TVec3f;
begin
  v := Vec3f(M.e00, M.e10, M.e20);
  Scale.x := v.Length;
  v := Vec3f(M.e01, M.e11, M.e21);
  Scale.y := v.Length;
  v := Vec3f(M.e02, M.e12, M.e22);
  Scale.z := v.Length;
  Result := Scale = ValidScale;
  if not Result then
    with Scale do
      Error('Invalid scale value for "' + Name + '": (' + Conv(x, 2) + ', ' + Conv(y, 2) + ', ' + Conv(z, 2) + ')');
end;

function ConvMatrix(const M: TMat4f): TMat4f;
const
  XM : TMat4f = (
    e00:  0; e10:  1; e20:  0; e30:  0;
    e01: -1; e11:  0; e21:  0; e31:  0;
    e02:  0; e12:  0; e22:  1; e32:  0;
    e03:  0; e13:  0; e23:  0; e33:  1;
  );
  ZM : TMat4f = (
    e00:  1; e10:  0; e20:  0; e30:  0;
    e01:  0; e11:  0; e21: -1; e31:  0;
    e02:  0; e12:  1; e22:  0; e32:  0;
    e03:  0; e13:  0; e23:  0; e33:  1;
  );
begin
  case UpAxis of
    uaX : Result := XM * M * XM.Inverse;
    uaZ : Result := ZM * M * ZM.Inverse;
  else
    Result := M;
  end;
  Result := Result.Transpose;
  Result.Pos := Result.Pos * UnitScale;
end;

function ConvURL(const URL: string): string;
begin
  Result := URL;
  if (URL <> '') and (URL[1] = '#') then
    Delete(Result, 1, 1);
end;

function ExtractFileName(const FileName: string): string;
var
  i : LongInt;
begin
  Result := FileName;
  for i := Length(Result) downto 1 do
    if (Result[i] = '/') or (Result[i] = '\') then
    begin
      if i = Length(Result) then
        Result := ''
      else
        Result := Copy(Result, i + 1, Length(Result));
      break;
    end;
end;

function ExtractFileDir(const FileName: string): string;
var
  i : LongInt;
begin
  Result := '';
  for i := Length(FileName) downto 1 do
    if (FileName[i] = '/') or (FileName[i] = '\') then
    begin
      Result := Copy(FileName, 1, i);
      break;
    end;
end;

function DeleteExt(const FileName: string): string;
var
  i : LongInt;
begin
  Result := FileName;
  for i := Length(Result) downto 1 do
    if Result[i] = '.' then
    begin
      Result := Copy(Result, 1, i - 1);
      break;
    end;

  while Pos('%20', Result) > 0 do
  begin
    i := Pos('%20', Result);
    Delete(Result, i, 3);
    Insert(' ', Result, i);
  end;
end;
{$ENDREGION}

var
  TriCount, MeshCount : LongInt;
  XML : TXML;

{$REGION 'TNodeMesh'}
procedure TNodeMesh.CalculateTBN;
var
  i  : LongInt;
  v  : TVertex;
  e  : array [0..1] of TVec3f;
  st : array [0..1] of TVec2f;
  tn : TVec3f;
  k : Single;
  Basis : array of record
      T, B : TVec3f;
    end;
  ResVertex : TVertexArray;
  Count, Idx : LongInt;
begin
// Calculate per triangle Tangent & Binormal
  SetLength(Basis, Length(Index) div 3);
  for i := 0 to Length(Basis) - 1 do
  begin
    with Vertex[Index[i * 3 + 0]] do
    begin
      e[0] := Vertex[Index[i * 3 + 1]].Coord - Coord;
      e[1] := Vertex[Index[i * 3 + 2]].Coord - Coord;

      st[0] := Vertex[Index[i * 3 + 1]].TexCoord[0] - TexCoord[0];
      st[1] := Vertex[Index[i * 3 + 2]].TexCoord[0] - TexCoord[0];
    end;

    k := st[0].x * st[1].y - st[1].x * st[0].y;

    if abs(k) > EPS then
      k := 1 / k
    else
      k := 0;

    Basis[i].T := Vec3f(st[1].y * e[0].x - st[0].y * e[1].x,
                        st[1].y * e[0].y - st[0].y * e[1].y,
                        st[1].y * e[0].z - st[0].y * e[1].z) * k;
    Basis[i].T := Basis[i].T.Normal;
    Basis[i].B := Vec3f(st[0].x * e[1].x - st[1].x * e[0].x,
                        st[0].x * e[1].y - st[1].x * e[0].y,
                        st[0].x * e[1].z - st[1].x * e[0].z) * k;
    Basis[i].B := Basis[i].B.Normal;
  end;

// Reconstruct mesh
  SetLength(ResVertex, Length(Index)); // with reserved
  FillChar(v, SizeOf(v), 0);

  Count := 0;
  for i := 0 to Length(Index) - 1 do
  begin
    v := Vertex[Index[i]];
    v.Tangent  := Basis[i div 3].T;
    v.Binormal := Basis[i div 3].B;

    Idx := 0;
    while Idx < Count  do
      with ResVertex[Idx] do
      begin
        if (Coord = v.Coord) and (Normal = v.Normal) and (TexCoord[0] = v.TexCoord[0]) and
           (Tangent.Dot(v.Tangent) > 0.5) and (Binormal.Dot(v.Binormal) > 0.5) then
        begin
          Tangent  := (Tangent + v.Tangent);
          Tangent  := Tangent.Normal;
          Binormal := (Binormal + v.Binormal);
          Binormal := Binormal.Normal;
          if (TexCoord[1] = v.TexCoord[1]) and (Color = v.Color) and
             (Joint.Weight = v.Joint.Weight) and (Joint.Joint[0] = v.Joint.Joint[0]) and (Joint.Joint[1] = v.Joint.Joint[1]) then
            break;
        end;
        Inc(Idx);
      end;

    if Idx = Count then
    begin
      ResVertex[Count] := v;
      Inc(Count);
    end;
    Index[i] := Idx;
  end;
  SetLength(ResVertex, Count);
// Basis orthonormalization
  for i := 0 to Length(ResVertex) - 1 do
    with ResVertex[i] do
    begin
      tn := Tangent;
      Tangent := Tangent - Normal * Normal.Dot(Tangent);
      Tangent := Tangent.Normal;
      if Binormal.Dot(Normal.Cross(tn)) < 0 then
        Binormal := Tangent.Cross(Normal)
      else
        Binormal := Normal.Cross(Tangent);
      Binormal := Binormal.Normal;
      if FlipBinormal then
        Binormal := Binormal * -1;
    end;
  Vertex := ResVertex;
end;

procedure TNodeMesh.CalculateBBox;
var
  i : LongInt;
begin
  BBox.Min := Vertex[0].Coord;
  BBox.Max := BBox.Min;
  for i := 0 to Length(Vertex) - 1 do
  begin
    BBox.Min := Vertex[i].Coord.Min(BBox.Min);
    BBox.Max := Vertex[i].Coord.Max(BBox.Max);
  end;

  {$IFDEF DEBUG_BBOX}
    with BBox do
      Info(' BBox: (' + Conv(Min.x, 2) + ', ' + Conv(Min.y, 2) + ', ' + Conv(Min.z, 2) + ') - (' +
                        Conv(Max.x, 2) + ', ' + Conv(Max.y, 2) + ', ' + Conv(Max.z, 2) + ')');
  {$ENDIF}
end;

procedure TNodeMesh.Optimize;
var
  VertexRemap         : TVertexArray;
  Groups, GroupsRemap : PNVTSPrimitiveGroup;
  GroupCount          : Word;
  i                   : LongInt;
begin
  nvtsSetCacheSize(32);
  nvtsSetStitchStrips(False);
  nvtsSetListOnly(True);

  nvtsGenerateStrips(@Index[0], Length(Index), Groups, GroupCount);
  nvtsRemapIndices(Groups, GroupCount, Length(Vertex), GroupsRemap);

  SetLength(VertexRemap, Length(Vertex));
  Move(Vertex[0], VertexRemap[0], Length(Vertex) * SizeOf(TVertex));

  for i := 0 to GroupsRemap^.numIndices - 1 do
  begin
    Index[i] := GroupsRemap^.indices[i];
    Vertex[Index[i]] := VertexRemap[Groups^.indices[i]];
  end;
end;

procedure TNodeMesh.Compile(Source: TSourceArray);
const
  FormatFlags : array [SID_POSITION..SID_JOINT] of TMaterialAttrib = (
    maCoord, maCoord, maBinormal, maNormal, maTexCoord0, maTexCoord1, maColor, maJoint
  );

  procedure GetIndex(Idx: LongInt; S: TSourceID; out Value: LongInt);
  begin
    if (S in [SID_POSITION..SID_COLOR]) and (FormatFlags[S] in Attrib) and (Source[S].ValueI <> nil) then
      Value := Source[S].ValueI[Idx]
    else
      Value := 0;
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TVec4f); overload;
  begin
    if (S in [SID_POSITION..SID_COLOR]) and (FormatFlags[S] in Attrib) and (Source[S].ValueF <> nil) then
      with Source[S] do
        Move(ValueF[Stride * Idx], Value, Stride * SizeOf(ValueF[0]))
    else
    Value := NullVec4f;
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TJoint); overload;
  begin
    with Source[SID_JOINT] do
      if ValueJ <> nil then
        Value := ValueJ[Idx]
      else
        FillChar(Value, SizeOf(Value), 0);
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TVec3f); overload;
  var
    v : TVec4f;
  begin
    GetValue(Idx, S, v);
    Value := Vec3f(v.x, v.y, v.z);
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TVec2f); overload;
  var
    v : TVec4f;
  begin
    GetValue(Idx, S, v);
    Value := Vec2f(v.x, v.y);
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: Single); overload;
  var
    v : TVec4f;
  begin
    GetValue(Idx, S, v);
    Value := v.x;
  end;

var
  i : LongInt;
  S : TSourceID;
  Count, Idx : LongInt;
  v : TVertexIndex;
  VIndex : TVertexIndexArray;
begin
  Attrib := [];
  for S := SID_POSITION to SID_JOINT do
    if Source[S].SourceURL <> '' then
      Attrib := Attrib + [FormatFlags[S]];
  Attrib := Attrib + [maBinormal];
// Construct index & vertex
  SetLength(Index, Length(Source[SID_POSITION].ValueI));
  SetLength(VIndex, Length(Index));
  FillChar(v, SizeOf(v), 0);

  Count := 0;
  for i := 0 to Length(Index) - 1 do
  begin
    GetIndex(i, SID_POSITION, v.Coord);
    v.Tangent  := 0;
    v.Binormal := 0;
    GetIndex(i, SID_NORMAL, v.Normal);
    GetIndex(i, SID_TEXCOORD0, v.TexCoord[0]);
    GetIndex(i, SID_TEXCOORD1, v.TexCoord[1]);
    GetIndex(i, SID_COLOR, v.Color);

    Idx := 0;
    while Idx < Count  do
      with VIndex[Idx] do
        if (Coord = v.Coord) and
           {(Tangent = v.Tangent) and (Binormal = v.Binormal) and} (Normal = v.Normal) and
           (TexCoord[0] = v.TexCoord[0]) and (TexCoord[1] = v.TexCoord[1]) and
           (Color = v.Color) then
          break
        else
          Inc(Idx);

    if Idx = Count then
    begin
      VIndex[Count] := v;
      Inc(Count);
    end;
    Index[i] := Idx;
  end;

  if Count > High(Word) then
    Error('Index count (' + Conv(Count) + ') > ' + Conv(High(Word)));

  SetLength(Vertex, Count);
  for i := 0 to Count - 1 do
    with Vertex[i] do
    begin
      GetValue(VIndex[i].Coord, SID_POSITION, Coord);
      GetValue(VIndex[i].Tangent, SID_TANGENT, Tangent);
      GetValue(VIndex[i].Binormal, SID_BINORMAL, Binormal);
      GetValue(VIndex[i].Normal, SID_NORMAL, Normal);
      GetValue(VIndex[i].TexCoord[0], SID_TEXCOORD0, TexCoord[0]);
      GetValue(VIndex[i].TexCoord[1], SID_TEXCOORD1, TexCoord[1]);
      GetValue(VIndex[i].Color, SID_COLOR, Color);
      GetValue(VIndex[i].Coord, SID_JOINT, Joint); // Coord Index = Joint Index
    end;

// Convert to Y-up axis
  for i := 0 to Length(Vertex) - 1 do
    with Vertex[i] do
    begin
      TexCoord[0] := Vec2f(TexCoord[0].x, -TexCoord[0].y);
      TexCoord[1] := Vec2f(TexCoord[1].x, -TexCoord[1].y);

      Coord := Coord * UnitScale;
      case UpAxis of
        uaX :
          begin
            Coord  := Vec3f(-Coord.y, Coord.x, Coord.z);
            Normal := Vec3f(-Normal.y, Normal.x, Normal.z);
          end;
        uaZ :
          begin
            Coord  := Vec3f(Coord.x, Coord.z, -Coord.y);
            Normal := Vec3f(Normal.x, Normal.z, -Normal.y);
          end;
      end;
    end;

// Joint Names
  JName := Source[SID_JOINT].ValueS;
  Info(' Joints : ' + Conv(Length(JName)));

  CalculateTBN;

  {$IFDEF DEBUG_MESH}
    Info(' Format : (T: ' + Conv(Length(Index) div 3) + '; V: ' + Conv(Length(Vertex)) + ')');
  {$ENDIF}

  CalculateBBox;
end;

procedure TNodeMesh.Free;
begin
  if Mesh <> nil then
    Mesh.Free;
end;

procedure TNodeMesh.Save(const FileName: string);
const
  Mode : TMeshMode = mmTriList;
  AttribSize : array [TMaterialAttrib] of LongInt = (12, 4, 4, 8, 8, 4, 4);
var
  Stream : TStream;
  ma : TMaterialAttrib;
  i, Count, Stride : LongInt;
  v4b : TVec4ub;
  v2s : TVec2s;
  v4s : TVec4s;
  v2f : TVec2f;
  v3f : TVec3f;
  v4f : TVec4f;
  MinT, MaxT : array [0..1] of TVec2f;
begin
  Stream := TStream.Init(FileName + EXT_XMS, True);
  if Stream <> nil then
  begin
//    Stream.Write(Params, SizeOf(Params));
    Stream.Write(BBox, SizeOf(BBox));
    Stream.Write(Mode, SizeOf(Mode));
    Stream.Write(Attrib, SizeOf(Attrib));
  // indices
    Stride := SizeOf(Index[0]);
    Count  := Length(Index);
    Stream.Write(Count, SizeOf(Count));
    if Count > 0 then
    begin
      Stride := SizeOf(Index[0]);
      Stream.Write(Stride, SizeOf(Stride));
      for i := 0 to Count - 1 do
        Stream.Write(Index[i], Stride);
    end;
  // vertices
    Count := Length(Vertex);
    Stream.Write(Count, SizeOf(Count));
    if Count > 0 then
    begin
      Stride := 0;
      for ma := Low(ma) to High(ma) do
        if ma in Attrib then
          Inc(Stride, AttribSize[ma]);
      Stream.Write(Stride, SizeOf(Stride));
      for i := 0 to Count - 1 do
        with Vertex[i] do
          for ma in Attrib do
            case ma of
              maCoord :
                Stream.Write(Coord, SizeOf(Coord));
              maBinormal, maNormal :
                begin
                  if ma = maBinormal then
                    v3f := Vertex[i].Binormal
                  else
                    v3f := Vertex[i].Normal;
                  v4b.x := Clamp(LongInt(Round((v3f.x * 0.5 + 0.5) * High(Byte))), Low(Byte), High(Byte));
                  v4b.y := Clamp(LongInt(Round((v3f.y * 0.5 + 0.5) * High(Byte))), Low(Byte), High(Byte));
                  v4b.z := Clamp(LongInt(Round((v3f.z * 0.5 + 0.5) * High(Byte))), Low(Byte), High(Byte));
                  if ma = maBinormal then
                  begin
                    v3f := Normal.Cross(Binormal);
                    v4b.w := Clamp(LongInt(Round((Sign(v3f.Dot(Tangent)) * 0.5 + 0.5) * High(Byte))), Low(Byte), High(Byte))
                  end else
                    v4b.w := 0; // align
                  Stream.Write(v4b, SizeOf(v4b));
                end;
              maTexCoord0, maTexCoord1 :
                begin
                  if ma = maTexCoord0 then
                    v2f := TexCoord[0]
                  else
                    v2f := TexCoord[1];
//                  v2s.x := Clamp(LongInt(Round(v2f.x * 1024)), Low(SmallInt), High(SmallInt));
  //                v2s.y := Clamp(LongInt(Round(v2f.y * 1024)), Low(SmallInt), High(SmallInt));
    //              Stream.Write(v2s, SizeOf(v2s));
                  Stream.Write(v2f, SizeOf(v2f))
                end;
              maColor :
                begin
                  with Color do
                  begin
                    v4b.x := Clamp(LongInt(Round(x * High(Byte))), Low(Byte), High(Byte));
                    v4b.y := Clamp(LongInt(Round(y * High(Byte))), Low(Byte), High(Byte));
                    v4b.z := Clamp(LongInt(Round(z * High(Byte))), Low(Byte), High(Byte));
                    v4b.w := Clamp(LongInt(Round(w * High(Byte))), Low(Byte), High(Byte));
                  end;
                  Stream.Write(v4b, SizeOf(v4b));
                end;
              maJoint :
                begin
                // precalc joint index in shader uniform array (joint in shader is two vec4)
                  v4b.x := Joint.Joint[0] * 2;
                  v4b.y := Joint.Joint[1] * 2;
                // one weight (second = 1.0 - weight)
                  v4b.z := Clamp(LongInt(Round(Joint.Weight * High(Byte))), Low(Byte), High(Byte));
                  v4b.w := 0;
                  Stream.Write(v4b, SizeOf(v4b));
                end;
            end;
    end;
  // joint names
    Count := Length(JName);
    Stream.Write(Count, SizeOf(Count));
    for i := 0 to Count - 1 do
      Stream.WriteAnsi(AnsiString(JName[i]));
    Stream.Free;
  end else
    Error('Can''t save "' + FileName + '"');
end;
{$ENDREGION}

{$REGION 'GetSkin'}
function GetSkin(const XML: TXML; const URL: string): TXML;
var
  i : LongInt;
begin
  with XML['library_controllers'] do
    for i := 0 to Count - 1 do
      with NodeI[i] do
        if Params['id'] = URL then
        begin
          Result := Node['skin'];
          Exit;
        end;
  Error('Can''t find controller "' + URL + '"');
  Result := nil;
end;
{$ENDREGION}

{$REGION 'GetMesh'}
procedure GetInputs(const SourceXML, XML: TXML; var Source: TSourceArray);

  function GetSourceID(const Semantic, SourceURL: string): TSourceID;
  var
    S    : TSourceID;
    Flag : Boolean;
  begin
    Result := SID_UNKNOWN;
    Flag   := True;
    for S := Low(S) to High(S) do
      if (SourceName[S] = Semantic) then
      begin
        Flag := False;
        if (Source[S].SourceURL = '') or (Source[S].SourceURL = SourceURL) then
        begin
          Source[S].SourceURL := SourceURL;
          Result := S;
          Exit;
        end;
      end;
    if Flag then
      Warning('Unknown input semantic "' + Semantic + '"');
  end;

var
  i, j : LongInt;
  S : TSourceID;
begin
  with XML do
    for i := 0 to Count - 1 do
      with NodeI[i] do
        if Tag = 'input' then
        begin
          S := GetSourceID(Params['semantic'], ConvURL(Params['source']));
          if S <> SID_UNKNOWN then
          begin
            Source[S].Offset := Conv(Params['offset'], -1);
            if S = SID_VERTEX then
            begin
              Source[S].SourceURL := '';
              for S := Low(S) to High(S) do
                if Source[S].Offset = -1 then
                  Source[S].Offset := Source[SID_VERTEX].Offset;
            end else
              with SourceXML do
                for j := 0 to Count - 1 do
                  with NodeI[j] do
                    if Tag = 'source' then
                      for S := Low(S) to High(S) do
                        if Params['id'] = Source[S].SourceURL then
                        begin
                          if Node['float_array'] <> nil then
                            if Source[S].ValueF = nil then
                              Source[S].ValueF := ParseFloat(Node['float_array'].Content);
                          if Node['Name_array'] <> nil then
                            Source[S].ValueS := ParseStr(Node['Name_array'].Content);
                          Source[S].Stride := Conv(Node['technique_common']['accessor'].Params['stride'], 1);
                        end;
          end;
        end;
end;


function GetMesh(const XML: TXML; const MeshURL, SkinURL, MatSymbol: string; out Source: TSourceArray): Boolean;

  procedure GetIndices(const InputXML, SkinXML: TXML);
  const
    MAX_WEIGHTS = 6;
  var
    i, j, k, Idx : LongInt;
    w : Single;
    S : TSourceID;
    IntArray, CountArray : TIntArray;
    IndexCount  : LongInt;
    IndexStride : LongInt;
    MaxWeight : array [0..1] of Single;
    MaxJoint  : array [0..1] of LongInt;
    JointMap  : array of LongInt;
    JointName : TStrArray;

    function AddJoint(Idx: LongInt): LongInt;
    var
      i : LongInt;
    begin
      for i := 0 to Length(JointMap) - 1 do
        if Idx = JointMap[i] then
        begin
          Result := i;
          Exit;
        end;
      Result := Length(JointMap);
      SetLength(JointMap, Result + 1);
      JointMap[Result] := Idx;
    end;

  begin
  // geometry
    with InputXML do
    begin
    // collect polygons indices
      IntArray := nil;
      for i := 0 to Count - 1 do
        if NodeI[i].Tag = 'p' then
        begin
          CountArray := ParseInt(NodeI[i].Content);
          j := Length(IntArray);
          SetLength(IntArray, j + Length(CountArray));
          Move(CountArray[0], IntArray[j], Length(CountArray) * SizeOf(IntArray[0]));
        end;
      IndexCount  := Conv(Params['count'], 0) * 3;
      IndexStride := Length(IntArray) div IndexCount;
    end;

    for S := Low(S) to SID_COLOR do
      if Source[S].SourceURL <> '' then
      begin
        SetLength(Source[S].ValueI, IndexCount);
        for i := 0 to IndexCount - 1 do
          Source[S].ValueI[i] := IntArray[i * IndexStride + Source[S].Offset];
      end;

  // skin controller
    if SkinXML = nil then
      Exit;
  // weights / joint indices
    with SkinXML['vertex_weights'] do
    begin
      CountArray := ParseInt(Node['vcount'].Content);
      IntArray   := ParseInt(Node['v'].Content);
      IndexCount := Conv(Params['count'], 0);

      for i := 0 to IndexCount - 1 do
        if CountArray[i] > MAX_WEIGHTS then
        begin
          Error(Conv(CountArray[i]) + ' influence joints per vertex (max ' + Conv(MAX_WEIGHTS) + ')');
          Exit;
        end;

    // get joint/weight indices
      SetLength(Source[SID_WEIGHT].ValueI, IndexCount * MAX_WEIGHTS);
      SetLength(Source[SID_JOINT].ValueI, IndexCount * MAX_WEIGHTS);
      SetLength(Source[SID_JOINT].ValueJ, IndexCount);
      FillChar(Source[SID_WEIGHT].ValueI[0], SizeOf(Source[SID_WEIGHT].ValueI[0]) * IndexCount * MAX_WEIGHTS, 0);
      FillChar(Source[SID_JOINT].ValueI[0], SizeOf(Source[SID_JOINT].ValueI[0]) * IndexCount * MAX_WEIGHTS, 0);
      FillChar(Source[SID_JOINT].ValueJ[0], SizeOf(Source[SID_JOINT].ValueJ[0]) * IndexCount, 0);
      Idx := 0;
      for i := 0 to IndexCount - 1 do
        for j := 0 to CountArray[i] - 1 do
          for k := 0 to 1 do // joints, weights offsets
          begin
            if Source[SID_JOINT].Offset = k then // joint index
              Source[SID_JOINT].ValueI[i * MAX_WEIGHTS + j] := IntArray[Idx]
            else // weight index
              Source[SID_WEIGHT].ValueI[i * MAX_WEIGHTS + j] := IntArray[Idx];
            Inc(Idx);
          end;

    // calc weights & joints values
      for i := 0 to IndexCount - 1 do
      begin
        FillChar(MaxWeight, SizeOf(MaxWeight), 0);
        FillChar(MaxJoint, SizeOf(MaxJoint), 0);
        for j := 0 to CountArray[i] - 1 do
        begin
          Idx := Source[SID_WEIGHT].ValueI[i * MAX_WEIGHTS + j];
          w   := Source[SID_WEIGHT].ValueF[Idx];
          if w > EPS then
            if w > MaxWeight[0] then
            begin
              MaxWeight[1] := MaxWeight[0];
              MaxJoint[1]  := MaxJoint[0];
              MaxWeight[0] := w;
              MaxJoint[0]  := Source[SID_JOINT].ValueI[i * MAX_WEIGHTS + j];
            end else
              if w > MaxWeight[1] then
              begin
                MaxWeight[1] := w;
                MaxJoint[1]  := Source[SID_JOINT].ValueI[i * MAX_WEIGHTS + j];
              end;
        end;
      // weights normalization
        if CountArray[i] = 1 then
          MaxJoint[1] := MaxJoint[0];
        w := 1 - (MaxWeight[0] + MaxWeight[1]);
        Source[SID_JOINT].ValueJ[i].Weight   := MaxWeight[0] + (w * 0.5);
        Source[SID_JOINT].ValueJ[i].Joint[0] := AddJoint(MaxJoint[0]);
        Source[SID_JOINT].ValueJ[i].Joint[1] := AddJoint(MaxJoint[1]);

        if (MaxJoint[0] > 127) or (MaxJoint[1] > 127) then
          Error(Conv(Max(MaxJoint[0], MaxJoint[1])) + ' influence joints per mesh (max: 127)');
      end;

    // convert sid to joint name
      SetLength(JointName, Length(JointMap));
      for i := 0 to Length(JointMap) - 1 do
        for j := BaseNodes to Length(Nodes) - 1 do
          if Nodes[j].Joint and (Nodes[j].JointURL = Source[SID_JOINT].ValueS[JointMap[i]]) then
          begin
            JointName[i] := Nodes[j].Name;
            Move(Source[SID_BIND_MATRIX].ValueF[JointMap[i] * 16], Nodes[j].JointBind, SizeOf(TMat4f));
            Nodes[j].JointBind := ConvMatrix(Nodes[j].JointBind);
            break;
          end;
      Source[SID_JOINT].ValueS := JointName;
    end;
  end;

var
  i, j : LongInt;
  InputXML : TXML;
  SkinXML  : TXML;
begin
  {$IFDEF DEBUG_MESH}
    Info('Mesh: ' + MeshURL + ' (' + MatSymbol + ')');
  {$ENDIF}

  Result := False;
  FillChar(Source, SizeOf(Source), 0);
  with XML['library_geometries'] do
    for i := 0 to Count - 1 do
      if NodeI[i].Params['id'] = MeshURL then
        with NodeI[i] do
        begin
          InputXML := Node['mesh'];
          if InputXML = nil then
            Exit; // spline etc. is not supported

          GetInputs(InputXML, InputXML['vertices'], Source);
{
          if InputXML['triangles'] = nil then
            Warning('Non triangulated geometry "' + MeshURL + '"');
}
          for j := 0 to InputXML.Count - 1 do
            if ((InputXML.NodeI[j].Tag = 'triangles') or
                (InputXML.NodeI[j].Tag = 'polylist') or
                (InputXML.NodeI[j].Tag = 'polygons')) and
               (InputXML.NodeI[j].Params['material'] = MatSymbol) then
            begin
            // Read inputs
              GetInputs(InputXML, InputXML.NodeI[j], Source); // triangles->inputs
              if SkinURL <> '' then
              begin
                SkinXML := GetSkin(XML, SkinURL);
                if SkinXML <> nil then
                begin
                  GetInputs(SkinXML, SkinXML['joints'], Source);
                  GetInputs(SkinXML, SkinXML['vertex_weights'], Source);
                end;
              end else
                SkinXML := nil;
            // Read indices
              GetIndices(InputXML.NodeI[j], SkinXML);
              Result := True;
            end;
          Exit;
        end;
end;
{$ENDREGION}

{$REGION 'GetNodes'}
procedure GetNodes(const MainXML: TXML; var Nodes: TNodeArray);

  procedure CollectNodes(const XML: TXML; Parent: LongInt);
  var
    i, j : LongInt;
    MatNode : TXML;
    MNode : TNode;
    ParentIdx : LongInt;
  begin
    with XML do
      for i := 0 to Count - 1 do
        with NodeI[i] do
          if Tag = 'node' then
          begin
            MNode := ZeroNode;
            MNode.Parent   := Parent;
            MNode.Name     := Params['name'];
            MNode.Joint    := Params['type'] = 'JOINT';
            MNode.JointURL := Params['sid'];
            MNode.Id       := Params['id'];

            MatNode := nil;
          // Matrix
            if Node['matrix'] <> nil then
              MNode.Matrix := ParseMatrix(Node['matrix'].Content);
            MNode.Matrix := ConvMatrix(MNode.Matrix);
          // Mesh
          // without skin
            if Node['instance_geometry'] <> nil then
              with Node['instance_geometry'] do
              begin
                MNode.MeshURL := ConvURL(Params['url']);
                MatNode := Node['bind_material'];
              end;
          // with skin
            if Node['instance_controller'] <> nil then
              with Node['instance_controller'] do
              begin
                MNode.SkinURL := ConvURL(Params['url']);
                MatNode := Node['bind_material'];
                MNode.MeshURL := ConvURL(GetSkin(MainXML, MNode.SkinURL).Params['source']);
              end;

            ParentIdx := Length(Nodes);
            SetLength(Nodes, ParentIdx + 1);
            Nodes[ParentIdx] := MNode;

            MNode.Parent := ParentIdx;
            MNode.Matrix.Identity;

          // Material
            if MatNode <> nil then
              with MatNode['technique_common'] do
                for j := 0 to Count - 1 do
                  with NodeI[j] do
                    if Tag = 'instance_material' then
                    begin
                      MNode.MatURL    := ConvURL(Params['target']);
                      MNode.MatSymbol := Params['symbol'];
                      SetLength(Nodes, Length(Nodes) + 1);
                      Nodes[Length(Nodes) - 1] := MNode;
                      {$IFDEF DEBUG_NODE}
                        Writeln('Node ID : ', j);
                        Writeln(' Parent   : ', MNode.Parent);
                        Writeln(' Name     : ', MNode.Name);
                        if MNode.MeshURL <> '' then
                          Writeln(' MeshURL  : ', MNode.MeshURL);
                        if MNode.MatName <> '' then
                          Writeln(' MatName  : ', MNode.MatName);
                        if MNode.MatURL <> '' then
                          Writeln(' MatURL   : ', MNode.MatURL);
                        if MNode.SkinURL <> '' then
                          Writeln(' SkinURL  : ', MNode.SkinURL);
                        if MNode.JointURL <> '' then
                          Writeln(' JointURL : ', MNode.JointURL);
                        WriteMat4f(MNode.Matrix);
                      {$ENDIF}
                    end;

            Nodes[ParentIdx].MeshURL   := '';
            Nodes[ParentIdx].MatURL    := '';
            Nodes[ParentIdx].MatSymbol := '';

            CollectNodes(XML.NodeI[i], ParentIdx);
          end;
  end;

begin
  CollectNodes(MainXML['library_visual_scenes']['visual_scene'], -1);
end;
{$ENDREGION}

{$REGION 'Skeleton'}
procedure SaveSkeleton(const Name: string);
var
  Stream : TStream;
  i, j : LongInt;
  M : TMat4f;

  Joint : array of record
    Id        : string;
    ParentId  : string;
    Parent    : TJointIndex;
    Bind      : TDualQuat;
    Frame     : TDualQuat;
    Name      : string;
    HasBind   : Boolean;
  end;

begin
  Info('Save skeleton to "' + Name + EXT_XSK + '"');

  Joint := nil;
  for i := BaseNodes to Length(Nodes) - 1 do
    if Nodes[i].Joint then
    begin
      SetLength(Joint, Length(Joint) + 1);
      with Joint[Length(Joint) - 1] do
      begin
        Id := Nodes[i].Id;

        if (Nodes[i].Parent > -1) and (Nodes[Nodes[i].Parent].Joint) then
          ParentId := Nodes[Nodes[i].Parent].Id
        else
          ParentId := '';

        HasBind := Nodes[i].JointBind.Det > EPS;

        Name := Nodes[i].Name;

        M := Nodes[i].Matrix;
        Frame := DualQuat(M.Rot, M.Pos);

        M := Nodes[i].JointBind;
        Bind := DualQuat(M.Rot, M.Pos);
      end;
    end;

  // recalc parent indices
  for i := 0 to Length(Joint) - 1 do
    if Joint[i].ParentId = '' then
      Joint[i].Parent := -1
    else
      for j := 0 to Length(Joint) - 1 do
        if Joint[j].Id = Joint[i].ParentId then
        begin
          Joint[i].Parent := j;
          break;
        end;

// info log
  Info(' Index'#9'Parent'#9'Bind'#9'Joint Name');
  for i := 0 to Length(Joint) - 1 do
    if Joint[i].HasBind then
      Writeln(' ', i, #9, Joint[i].Parent, #9, '+', #9, Joint[i].Name)
    else
      Writeln(' ', i, #9, Joint[i].Parent, #9, '-', #9, Joint[i].Name);

// save to file
  Stream := TStream.Init('cache/' + Name + EXT_XSK, True);
  if Stream <> nil then
  begin
    i := Length(Joint);
    Stream.Write(i, SizeOf(i));
    for i := 0 to Length(Joint) - 1 do
      Stream.WriteAnsi(AnsiString(Joint[i].Name));
    for i := 0 to Length(Joint) - 1 do
    begin
      Stream.Write(Joint[i].Parent, SizeOf(Joint[i].Parent));
      Stream.Write(Joint[i].Bind, SizeOf(Joint[i].Bind));
      Stream.Write(Joint[i].Frame, SizeOf(Joint[i].Frame));
    end;
    Stream.Free;
  end;
end;
{$ENDREGION}

{$REGION 'Animation'}
procedure SaveAnimation(const Name: string);
type
  TFrameFlag = (ffRotX, ffRotY, ffRotZ, ffPosX, ffPosY, ffPosZ);
var
  i, j, k, t : LongInt;
  M : TMat4f;
  Stream  : TStream;
  NodeIdx : LongInt;
  Source  : TSourceArray;
  SourceId, TargetId : string;
  FCount, FPS : LongInt;
  Joint : array of record
      Name  : string;
      Frame : array of TMat4f;
    end;
  Flag : array of set of TFrameFlag;
  SData : array of Single;
  SCount : LongInt;
  Rot, nRot : TQuat;
  Pos, nPos : TVec3f;

  procedure AddData(x: Single);
  begin
    SData[SCount] := x;
    Inc(SCount);
  end;

begin
  Info('Save animation to "' + Name + EXT_XAN + '"');
// info log
  Joint  := nil;
  FPS    := 1;
  FCount := 0;
  Info(' Joint Name');
  if XML['library_animations'] <> nil then
    with XML['library_animations'] do
      for i := 0 to Count - 1 do
        if (NodeI[i].Tag = 'animation') and (NodeI[i]['channel'] <> nil) then
          with NodeI[i] do
            for j := 0 to Count - 1 do
              if NodeI[j].Tag = 'channel' then
              begin
              // get channel params
                with NodeI[j] do
                begin
                  SourceId := ConvURL(Params['source']);
                  TargetId := Params['target'];
                  for k := Length(TargetId) downto 1 do
                    if TargetId[k] = '/' then
                    begin
                      TargetId := Copy(TargetId, 1, k - 1);
                      break;
                    end;
                end;
              // get node by TargetId (in global NodeArray)
                NodeIdx := -1;
                for k := BaseNodes to Length(Nodes) - 1 do
                  if Nodes[k].Joint and // only joint animation export
                    (Nodes[k].Id = TargetId) then
                  begin
                    NodeIdx := k;
                    break;
                  end;
              // get channel sampler
                if NodeIdx > -1 then
                  for k := 0 to Count - 1 do
                    if (NodeI[k].Tag = 'sampler') and (NodeI[k].Params['id'] = SourceID) then
                    begin
                      Source[SID_INPUT].SourceURL := '';
                      Source[SID_OUTPUT].SourceURL := '';
                      Source[SID_INTERPOLATION].SourceURL := '';
                      Source[SID_INPUT].ValueF  := nil;
                      Source[SID_OUTPUT].ValueF := nil;
                      Source[SID_INTERPOLATION].ValueF := nil;
                      GetInputs(XML['library_animations'].NodeI[i], NodeI[k], Source);
                      Writeln(' ', TargetId);

                    // frames count
                      if (FCount > 0) and (Length(Source[SID_INPUT].ValueF) <> FCount) then
                      begin
                        Error('Invalid frames count (sampler must be baked)');
                        Exit;
                      end else
                        FCount := Length(Source[SID_INPUT].ValueF);
                    // frames per second
                      if FCount > 1 then
                        FPS := Round(1 / (Source[SID_INPUT].ValueF[1] - Source[SID_INPUT].ValueF[0]));

                      SetLength(Joint, Length(Joint) + 1);
                      with Joint[Length(Joint) - 1] do
                      begin
                        Name := TargetId;
                        SetLength(Frame, FCount);
                        for t := 0 to FCount - 1 do
                        begin
                          Move(Source[SID_OUTPUT].ValueF[t * 16], M, SizeOf(M));
                          Frame[t] := ConvMatrix(M);
                        end;
                      end;
                      break;
                    end;
              end;

  Info(' FPS    : ' + Conv(FPS));
  Info(' Frames : ' + Conv(FCount));

// save to file
  if FCount > 0 then
  begin
    Stream := TStream.Init('cache/' + Name + EXT_XAN, True);
    if Stream <> nil then
    begin
      i := Length(Joint);
      Stream.Write(i, SizeOf(i));
      for i := 0 to Length(Joint) - 1 do
        Stream.WriteAnsi(AnsiString(Joint[i].Name));
      Stream.Write(FPS, SizeOf(FPS));
      Stream.Write(FCount, SizeOf(FCount));

      SetLength(Flag, FCount);
      SetLength(SData, FCount * 6); // 6 = Rot & Pos
      for i := 0 to Length(Joint) - 1 do
      begin
        Rot := Quat(0, 0, 0, 1);
        Pos := Vec3f(0, 0, 0);
        SCount := 0;
        for j := 0 to FCount - 1 do
        begin
        // collect flags of changes
          Flag[j] := [];
          nRot := Joint[i].Frame[j].Rot;
          nPos := Joint[i].Frame[j].Pos;
          nRot := nRot.Normal;
          if nRot.w < 0 then // to reconstruct w in TAnimData.Create, w must be greater than 0
            nRot := nRot * -1;
          if abs(nRot.x - Rot.x) > EPS then Flag[j] := Flag[j] + [ffRotX];
          if abs(nRot.y - Rot.y) > EPS then Flag[j] := Flag[j] + [ffRotY];
          if abs(nRot.z - Rot.z) > EPS then Flag[j] := Flag[j] + [ffRotZ];
          if abs(nPos.x - Pos.x) > EPS then Flag[j] := Flag[j] + [ffPosX];
          if abs(nPos.y - Pos.y) > EPS then Flag[j] := Flag[j] + [ffPosY];
          if abs(nPos.z - Pos.z) > EPS then Flag[j] := Flag[j] + [ffPosZ];
          Rot := nRot;
          Pos := nPos;
        // collect changed data
          if ffRotX in Flag[j] then AddData(Rot.x);
          if ffRotY in Flag[j] then AddData(Rot.y);
          if ffRotZ in Flag[j] then AddData(Rot.z);
          if ffPosX in Flag[j] then AddData(Pos.x);
          if ffPosY in Flag[j] then AddData(Pos.y);
          if ffPosZ in Flag[j] then AddData(Pos.z);
        end;
        Stream.Write(Flag[0], SizeOf(Flag[0]) * FCount);
        Stream.Write(SCount, SizeOf(SCount));
        Stream.Write(SData[0], SizeOf(SData[0]) * SCount);
      end;
      Stream.Free;
    end;
  end else
    Info(' no animation');
end;
{$ENDREGION}

{$REGION 'Convert'}
procedure InitNodeProc(NodeIdx: LongInt); stdcall;

  function GetNodeMatrix(Idx: LongInt): TMat4f;
  begin
    if Nodes[Idx].Parent <> -1 then
      Result := Nodes[Idx].Matrix * GetNodeMatrix(Nodes[Idx].Parent)
    else
      Result := Nodes[Idx].Matrix;
  end;

begin
  with Nodes[NodeIdx] do
    if GetMesh(XML, MeshURL, SkinURL, MatSymbol, Source) then
    begin
      ValidMatrix(Matrix, Name);
      AMatrix := GetNodeMatrix(NodeIdx);
      Nodes[NodeIdx].Mesh.Compile(Nodes[NodeIdx].Source);
    //  Node^.Source := nil;
      Inc(TriCount, Length(Nodes[NodeIdx].Mesh.Index) div 3);
      Inc(MeshCount);
    end else
      MeshURL := '';
end;

procedure Convert(const FileName: string);
var
  i : LongInt;
  Thread : array of TThread;
  Skinned : Boolean;
begin
  XML := TXML.Load(FileName);
  with XML['asset'] do
  begin
    UnitScale := Conv(Node['unit'].Params['meter'], 1.0);
    case Node['up_axis'].Content[1] of
      'X' : UpAxis := uaX;
      'Z' : UpAxis := uaZ;
    else
      UpAxis := uaY;
    end;
  end;

  Info('Unit Scale : ' + Conv(UnitScale, 4));
  Info('Up Axis    : ' + UpAxisName[UpAxis]);

  BaseNodes := Length(Nodes);

  GetNodes(XML, Nodes);
  TriCount := 0;
  MeshCount := 0;
// Init threads
  SetLength(Thread, 1);//Render.CPUCount);
  for i := 0 to Length(Thread) - 1 do
    Thread[i].CPUMask := 1 shl i;
// Init nodes content
  Info('Convertation...');
  for i := BaseNodes to Length(Nodes) - 1 do
    if (Nodes[i].MeshURL <> '') then //and (Pos('m_', Nodes[i].MeshURL) = 1) then
      InitNodeProc(i)
    else
      Nodes[i].MeshURL := '';
  Info(' Mesh : ' + Conv(MeshCount));
  Info(' Tri  : ' + Conv(TriCount));
{
// Init nodes render
  Info('Optimization...');
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
      Nodes[i].Mesh.Optimize;
}
// Save skeleton
  Skinned := False;
  for i := BaseNodes to Length(Nodes) - 1 do
    if Nodes[i].Joint then
    begin
      Skinned := True;
      break;
    end;

  if Skinned then
    SaveSkeleton(DeleteExt(ExtractFileName(FileName)));
  SaveAnimation(DeleteExt(ExtractFileName(FileName)));

// Save/Init materials & meshes
  Info('Initialization...');
  for i := BaseNodes to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
    begin
      GetMaterial(XML, Nodes[i].MatURL, Nodes[i].Material);

      if Nodes[i].Mesh.JName <> nil then
        Nodes[i].Material.Skin := True;

      Writeln('mat: ', Nodes[i].Material.Name);
      Nodes[i].Material.Save('cache/' + Nodes[i].Material.Name);
      Nodes[i].Material.Material := TMaterial.Load(Nodes[i].Material.Name);
      Nodes[i].Mesh.Name := Nodes[i].MeshURL + '_' + Nodes[i].MatSymbol;
      Nodes[i].Mesh.Save('cache/' + Nodes[i].Mesh.Name);
      Nodes[i].Mesh.Mesh := TMesh.Load(Nodes[i].Mesh.Name);
      Nodes[i].Mesh.Mesh.Material := Nodes[i].Material.Material;
    end;

  XML.Free;
end;
{$ENDREGION}

end.
