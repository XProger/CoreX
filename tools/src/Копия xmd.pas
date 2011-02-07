unit xmd;

//{$DEFINE DEBUG}

{$IFDEF DEBUG}
//  {$DEFINE DEBUG_NODE}
//  {$DEFINE DEBUG_BBOX}
  {$DEFINE DEBUG_MESH}
{$ENDIF}

interface

uses
  Windows, CoreX, NvTriStrip;

{$REGION 'Common converter definitions'}
type
  TIntArray = array of LongInt;
  TFloatArray = array of Single;
  TStringArray = array of string;

  TUpAxis = (uaX, uaY, uaZ);

  TSourceID = (SID_UNKNOWN, SID_VERTEX, SID_POSITION, SID_TANGENT, SID_BINORMAL, SID_NORMAL, SID_TEXCOORD0, SID_TEXCOORD1, SID_COLOR, SID_WEIGHT, SID_JOINT, SID_BIND_MATRIX);
  TSource = record
    SourceURL : string;
    Offset    : LongInt;
    Stride    : LongInt;
    ValueI    : TIntArray;
    ValueF    : TFloatArray;
    ValueS    : TStringArray;
  end;
  TSourceArray = array [TSourceID] of TSource;

const
  UpAxisName : array [TUpAxis] of Char = ('X', 'Y', 'Z');
  SourceName : array [TSourceID] of string = ('UNKNOWN', 'VERTEX', 'POSITION', 'TEXTANGENT', 'TEXBINORMAL', 'NORMAL', 'TEXCOORD', 'TEXCOORD', 'COLOR', 'WEIGHT', 'JOINT', 'INV_BIND_MATRIX');

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
    Weight   : TVec2f;
    Joint    : TVec3f;
  end;
  TVertexArray = array of TVertex;

  TVertexIndex = record
    Coord    : LongInt;
    Tangent  : LongInt;
    Binormal : LongInt;
    Normal   : LongInt;
    TexCoord : array [0..1] of LongInt;
    Color    : LongInt;
    Weight   : LongInt;
    Joint    : LongInt;
  end;
  TVertexIndexArray = array of TVertexIndex;

  TNodeMesh = object
    Attrib : TMeshAttribs;
    Index  : TIndexArray;
    Vertex : TVertexArray;
    BBox   : TBox;
  private
    Buffer : array [TBufferType] of TMeshBuffer;
    procedure CalculateTBN;
    procedure CalculateBBox;
    procedure Optimize;
  public
    procedure Init(Source: TSourceArray);
    procedure Free;
    procedure Save(const FileName: string);
    procedure InitVBO;
  end;
{$ENDREGION}

{$REGION 'Material format'}
  TNodeMaterial = record
    URL       : string;
    Name      : string;
    ShadeType : (stLambert, stPhong, stBlinn);
    Params    : TMaterialParams;
    Defines   : array of string;
    Sampler   : array [TMaterialSampler] of string;
    Material  : TMaterial;
    procedure Save(const FileName: string);
  end;

  TNodeMaterialArray = array of TNodeMaterial;
{
  TSamplerFlag = (sfDiffuse, sfNormal, sfSpecular, sfNormalSpecular, sfEmission, sfReflect, sfLighting, sfAmbient);

  TMaterial = record
    Sampler  : TSamplerFlag;
    Diffuse  : TVec4f;
    Specular : TVec4f;
    Ambient  : TVec3f;
    Texture  : array [TSamplerFlag] of string;
  end;
}
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
    Name      : string;
    MeshURL   : string;
    MatURL    : string;
    MatSymbol : string;
    SkinURL   : string;
    JointURL  : string;
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

type
  TDisplayCtrl = class(TControl)
    constructor Create;
    destructor Destroy; override;
  public
    CamPos  : TVec3f;
    CamDist : Single;
    CamRot  : TVec3f;
    CamDrag : (cdNone, cdPos, cdRot, cdZoom);
    CamMPos : TPoint;
    PM, VM  : TMat4f;
    MState  : array [ikMouseL..ikMouseM] of Boolean;
    procedure OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: LongInt);
    procedure OnMouseUp;
    procedure OnMouseMove(Shift: TShiftState; X, Y: LongInt);
    procedure OnRender; override;
  end;


const
  MAP_SIZE  = 64;

var
  FlipBinormal : Boolean = False;
  Display : TDisplayCtrl;

  CAM_SPEED : Single = 10;
  MAP_SCALE : Single = 8;

  DMap   : array [0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of Word;
  DLight : array [0..MAP_SIZE - 1, 0..MAP_SIZE - 1] of array [1..MAX_LIGHTS - 1] of LongInt;
  DRemap : array [1..100] of Byte;
  Lights : array of record
      Pos    : TVec3f;
      Color  : TVec3f;
      Radius : Single;
    end;

  Nodes : TNodeArray;


  procedure Convert(const FileName: string);

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

function ParseCount(const Str: string): LongInt;
var
  i : LongInt;
begin
  Result := 1;
  for i := 1 to Length(Str) do
    if Str[i] = ' ' then
      Result := Result + 1;
end;

function ParseNext(const Str: string; var Pos: LongInt): string;
var
  i : LongInt;
begin
  for i := Pos to Length(Str) + 1 do
    if (Str[i] = ' ') or (i > Length(Str)) then
    begin
      Result := Copy(Str, Pos, i - Pos);
      Pos := i + 1;
      Exit;
    end;
end;

function ParseFloat(const Str: string): TFloatArray;
var
  i, Pos : LongInt;
begin
  SetLength(Result, ParseCount(Str));
  Pos := 1;
  for i := 0 to Length(Result) - 1 do
    Result[i] := Conv(ParseNext(Str, Pos), 0.0);
end;

function ParseInt(const Str: string): TIntArray;
var
  i, Pos : LongInt;
begin
  SetLength(Result, ParseCount(Str));
  Pos := 1;
  for i := 0 to Length(Result) - 1 do
    Result[i] := Conv(ParseNext(Str, Pos), 0);
end;

function ParseString(const Str: string): TStringArray;
var
  i, Pos : LongInt;
begin
  SetLength(Result, ParseCount(Str));
  Pos := 1;
  for i := 0 to Length(Result) - 1 do
    Result[i] := ParseNext(Str, Pos);
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
  Scale : TVec3f;
begin
  Scale.x := Vec3f(M.e00, M.e10, M.e20).Length;
  Scale.y := Vec3f(M.e01, M.e11, M.e21).Length;
  Scale.z := Vec3f(M.e02, M.e12, M.e22).Length;
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
  NodeMatList : TNodeMaterialArray;
  TriCount, MeshCount : LongInt;
  XML : TXML;

{$REGION 'TMesh'}
procedure TNodeMesh.CalculateTBN;
var
  i  : Integer;
  v  : TVertex;
  e  : array [0..1] of TVec3f;
  st : array [0..1] of TVec2f;
  tn : TVec3f;
  k : Single;
  Basis : array of record
      T, B : TVec3f;
    end;
  ResVertex : TVertexArray;
  Count, Idx : Integer;
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

    Basis[i].T := (Vec3f(st[1].y * e[0].x - st[0].y * e[1].x,
                         st[1].y * e[0].y - st[0].y * e[1].y,
                         st[1].y * e[0].z - st[0].y * e[1].z) * k).Normal;
    Basis[i].B := (Vec3f(st[0].x * e[1].x - st[1].x * e[0].x,
                         st[0].x * e[1].y - st[1].x * e[0].y,
                         st[0].x * e[1].z - st[1].x * e[0].z) * k).Normal;
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
          Tangent  := (Tangent + v.Tangent).Normal;
          Binormal := (Binormal + v.Binormal).Normal;
          if (TexCoord[1] = v.TexCoord[1]) and
             (Color = v.Color) and (Weight = v.Weight) and (Joint = v.Joint) then
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
      Tangent := (Tangent - Normal * Normal.Dot(Tangent)).Normal;
      if Binormal.Dot(Normal.Cross(tn)) < 0 then
        Binormal := Tangent.Cross(Normal).Normal
      else
        Binormal := Normal.Cross(Tangent).Normal;
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
  i                   : Integer;
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

procedure TNodeMesh.Init(Source: TSourceArray);
const
  FormatFlags : array [SID_POSITION..SID_JOINT] of TMaterialAttrib = (
    maCoord, maTangent, maBinormal, maNormal, maTexCoord0, maTexCoord1, maColor, maWeight, maJoint
  );

  procedure GetIndex(Idx: LongInt; S: TSourceID; out Value: LongInt);
  begin
    if (S in [SID_POSITION..SID_JOINT]) and (FormatFlags[S] in Attrib) and (Source[S].ValueI <> nil) then
      Value := Source[S].ValueI[Idx]
    else
      Value := 0;
  end;

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TVec4f); overload;
  begin
    if (S in [SID_POSITION..SID_JOINT]) and (FormatFlags[S] in Attrib) and (Source[S].ValueF <> nil) then
      with Source[S] do
        Move(ValueF[Stride * Idx], Value, Stride * SizeOf(ValueF[0]))
    else
    Value := NullVec4f;    
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

// Construct index & vertex
  SetLength(Index, Length(Source[SID_POSITION].ValueI));
  SetLength(VIndex, Length(Index));
  FillChar(v, SizeOf(v), 0);

  Count := 0;
  for i := 0 to Length(Index) - 1 do
  begin
    GetIndex(i, SID_POSITION, v.Coord);
    GetIndex(i, SID_TANGENT, v.Tangent);
    GetIndex(i, SID_BINORMAL, v.Binormal);
    GetIndex(i, SID_NORMAL, v.Normal);
    GetIndex(i, SID_TEXCOORD0, v.TexCoord[0]);
    GetIndex(i, SID_TEXCOORD1, v.TexCoord[1]);
    GetIndex(i, SID_COLOR, v.Color);
    GetIndex(i, SID_WEIGHT, v.Weight);
    GetIndex(i, SID_JOINT, v.Joint);

    Idx := 0;
    while Idx < Count  do
      with VIndex[Idx] do
        if (Coord = v.Coord) and
           (Tangent = v.Tangent) and (Binormal = v.Binormal) and (Normal = v.Normal) and
           (TexCoord[0] = v.TexCoord[0]) and (TexCoord[1] = v.TexCoord[1]) and
           (Color = v.Color) and (Weight = v.Weight) and (Joint = v.Joint) then
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
      GetValue(VIndex[i].Weight, SID_WEIGHT, Weight);
      GetValue(VIndex[i].Joint, SID_JOINT, Joint);
    end;

// Convert to Y-up axis
  for i := 0 to Length(Vertex) - 1 do
    with Vertex[i] do
    begin
      TexCoord[0] := Vec2f(TexCoord[0].x, -TexCoord[0].y);
      TexCoord[1] := Vec2f(TexCoord[1].x, -TexCoord[1].y);

//      Binormal := Binormal * -1;

      Coord := Coord * UnitScale;
      case UpAxis of
        uaX :
          begin
            Coord    := Vec3f(-Coord.y, Coord.x, Coord.z);
            Tangent  := Vec3f(-Tangent.y, Tangent.x, Tangent.z);
            Binormal := Vec3f(-Binormal.y, Binormal.x, Binormal.z);
            Normal   := Vec3f(-Normal.y, Normal.x, Normal.z);
          end;
        uaZ :
          begin
            Coord    := Vec3f(Coord.x, Coord.z, -Coord.y);
            Tangent  := Vec3f(Tangent.x, Tangent.z, -Tangent.y);
            Binormal := Vec3f(Binormal.x, Binormal.z, -Binormal.y);
            Normal   := Vec3f(Normal.x, Normal.z, -Normal.y);
          end;
      end;
    end;

//  CalculateTBN;

  {$IFDEF DEBUG_MESH}
    Info(' Format: (T: ' + Conv(Length(Index) div 3) + '; V: ' + Conv(Length(Vertex)) + ')');
  {$ENDIF}

  CalculateBBox;
  Optimize;
end;

procedure TNodeMesh.Free;
begin
//  Buffer[btIndex].Free;
//  Buffer[btVertex].Free;
end;

procedure TNodeMesh.Save(const FileName: string);
begin
  //
end;

procedure TNodeMesh.InitVBO;
begin
//  Buffer[btIndex]  := TMeshBuffer.Init(btIndex, Length(Index) * SizeOf(Index[0]), @Index[0]);
//  Buffer[btVertex] := TMeshBuffer.Init(btVertex, Length(Vertex) * SizeOf(Vertex[0]), @Vertex[0]);
end;
{$ENDREGION}

{$REGION 'TNodeMaterial'}
procedure TNodeMaterial.Save;

  procedure AddDefine(const Define: string);
  var
    i, j : LongInt;
  begin
  // if not in array
    for i := 0 to Length(Defines) - 1 do
      if Defines[i] = Define then
        Exit;
  // insert
    for i := 0 to Length(Defines) - 1 do
      if Defines[i] > Define then
      begin
        SetLength(Defines, Length(Defines) + 1);
        for j := Length(Defines) - 1 downto i + 1 do
          Defines[j] := Defines[j - 1];
        Defines[i] := Define;
        Exit;
      end;
    SetLength(Defines, Length(Defines) + 1);
    Defines[Length(Defines) - 1] := Define;
  end;

var
  Stream : TStream;
  i, DCount : LongInt;
  ms : TMaterialSampler;
begin
  Defines := nil;
// Set defines
//  Sampler[msReflect] := 'cubemap';
  if Sampler[msDiffuse]  <> '' then AddDefine('MAP_DIFFUSE');
  if Sampler[msNormal]   <> '' then AddDefine('MAP_NORMAL');
  if Sampler[msSpecular] <> '' then AddDefine('MAP_SPECULAR');
  if Sampler[msAmbient]  <> '' then AddDefine('MAP_AMBIENT');
  if Sampler[msReflect]  <> '' then AddDefine('MAP_REFLECT');
  if Sampler[msEmission] <> '' then AddDefine('MAP_EMISSION');

  if Params.Diffuse.w < 1 - EPS then
    Params.BlendType := btNormal;

  if ShadeType in [stPhong, stBlinn] then
    AddDefine('FX_SHADE');
  AddDefine('FX_PLASTIC');

  case ShadeType of
    stPhong : AddDefine('FX_PHONG');
    stBlinn : AddDefine('FX_BLINN');
  end;

// Saving
  Stream := TStream.Init(FileName, True);
  Stream.Write(Params, SizeOf(Params));
  Stream.WriteAnsi('xshader');
  DCount := Length(Defines);
  Stream.Write(DCount, SizeOf(DCount)); // Defines count
  for i := 0 to DCount - 1 do
    Stream.WriteAnsi(AnsiString(Defines[i]));
  for ms := Low(ms) to High(ms) do
    Stream.WriteAnsi(AnsiString(Sampler[ms]));
  Stream.Free;
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
        if Params['id'].Value = URL then
        begin
          Result := Node['skin'];
          Exit;
        end;
  Error('Can''t find controller "' + URL + '"');
  Result := nil;
end;
{$ENDREGION}

{$REGION 'GetMesh'}
function GetMesh(const XML: TXML; const MeshURL, SkinURL, MatSymbol: string; out Source : TSourceArray): Boolean;

  procedure GetInputs(const SourceXML, XML: TXML);

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
            S := GetSourceID(Params['semantic'].Value, ConvURL(Params['source'].Value));
            if S <> SID_UNKNOWN then
            begin
              Source[S].Offset := Conv(Params['offset'].Value, -1);
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
                          if Params['id'].Value = Source[S].SourceURL then
                          begin
                            if Node['float_array'] <> nil then
                              if Source[S].ValueF = nil then
                                Source[S].ValueF := ParseFloat(Node['float_array'].Content);
                            if Node['Name_array'] <> nil then
                              Source[S].ValueS := ParseString(Node['Name_array'].Content);
                            Source[S].Stride := Conv(Node['technique_common']['accessor'].Params['stride'].Value, 1);
                          end;

            end;
          end;
  end;

  procedure GetIndices(const InputXML, SkinXML: TXML);
  var
    i : LongInt;
    S : TSourceID;
    IntArray    : TIntArray;
    IndexCount  : LongInt;
    IndexStride : LongInt;
  begin
    with InputXML do
    begin
      IndexCount  := Conv(Params['count'].Value, 0) * 3;
      IntArray    := ParseInt(Node['p'].Content);
      IndexStride := Length(IntArray) div IndexCount;
    end;

    for S := Low(S) to SID_COLOR do
      if Source[S].SourceURL <> '' then
      begin
        SetLength(Source[S].ValueI, IndexCount);
        for i := 0 to IndexCount - 1 do
          Source[S].ValueI[i] := IntArray[i * IndexStride + Source[S].Offset];
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
      if NodeI[i].Params['id'].Value = MeshURL then
        with NodeI[i] do
        begin
          InputXML := Node['mesh'];
          if InputXML = nil then
            Exit; // spline etc. is not supported

          GetInputs(InputXML, InputXML['vertices']);

          if InputXML['polylist'] <> nil then
          begin
            Error('Non triangulated geometry "' + MeshURL + '"');
            Exit;
          end;

          for j := 0 to InputXML.Count - 1 do
            if (InputXML.NodeI[j].Tag = 'triangles') and (InputXML.NodeI[j].Params['material'].Value = MatSymbol) then
            begin
            {
              if InputXML.Node['triangles'] = nil then

            }
            // Read inputs
              GetInputs(InputXML, InputXML.NodeI[j]); // triangles->inputs
              if SkinURL <> '' then
              begin
                SkinXML := GetSkin(XML, SkinURL);
                if SkinXML <> nil then
                begin
                  GetInputs(SkinXML, SkinXML['joints']);
                  GetInputs(SkinXML, SkinXML['vertex_weights']);
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

{$REGION 'GetMaterial'}
procedure GetMaterial(const XML: TXML; const URL: string; out NodeMaterial: TNodeMaterial);

  function GetSampler(const XMLfx, XMLtex: TXML): string;
  var
    i : LongInt;
    s : string;
    Stream : TStream;
  begin
    Result := '';
    if XMLtex = nil then
      Exit;

    s := XMLtex.Params['texture'].Value;
    with XMLfx['profile_COMMON'] do
    begin
      for i := 0 to Count - 1 do
        if (NodeI[i].Tag = 'newparam') and (NodeI[i].Params['sid'].Value = s) then
        begin
          if NodeI[i]['sampler2D'] = nil then
          begin
            Error(s + ' is not 2d sampler');
            Exit;
          end;
          s := NodeI[i]['sampler2D']['source'].Content;
          break;
        end;

      for i := 0 to Count - 1 do
        if (NodeI[i].Tag = 'newparam') and (NodeI[i].Params['sid'].Value = s) then
        begin
          s := NodeI[i]['surface']['init_from'].Content;
          break;
        end;
    end;

    with XML['library_images'] do
      for i := 0 to Count - 1 do
        if NodeI[i].Params['id'].Value = s then
        begin
          Result := NodeI[i]['init_from'].Content;
          break;
        end;

    Result := ExtractFileName(Result);
    Result := DeleteExt(Result);
    Stream := TStream.Init(Result + '.dds');
    if Stream = nil then
    begin
      Warning('Texture "' + Result + '.dds" not found!');
      Result := '';
    end else
      Stream.Free;
  //  Info('Texture: "' + Result + '"');
  end;

var
  i : LongInt;
  MatFX : string;
  ShXML : TXML;
  str : string;
begin
  for i := 0 to Length(NodeMatList) - 1 do
    if URL = NodeMatList[i].URL then
    begin
      NodeMaterial := NodeMatList[i];
      Exit;
    end;
  MatFX := '';
  FillChar(NodeMaterial, SizeOf(NodeMaterial), 0);
  NodeMaterial.URL := URL;
// read material
  with XML['library_materials'] do
    for i := 0 to Count - 1 do
      with NodeI[i] do
        if Params['id'].Value = URL then
        begin
          NodeMaterial.Name := Params['name'].Value;
          MatFX := ConvURL(Node['instance_effect'].Params['url'].Value);
          break;
        end;
// read MatFX
  if MatFX <> '' then
    with XML['library_effects'] do
      for i := 0 to Count - 1 do
        if NodeI[i].Params['id'].Value = MatFX then
          with NodeI[i].Node['profile_COMMON']['technique'] do
          begin
            ShXML := nil;
            if Node['lambert'] <> nil then
            begin
              NodeMaterial.ShadeType := stLambert;
              ShXML := Node['lambert'];
            end else
              if Node['blinn'] <> nil then
              begin
                NodeMaterial.ShadeType := stBlinn;
                ShXML := Node['blinn'];
              end else
                if Node['phong'] <> nil then
                begin
                  NodeMaterial.ShadeType := stPhong;
                  ShXML := Node['phong'];
                end else
                  Error('Unknown material type in "' + URL + '"');

            NodeMaterial.Sampler[msDiffuse] := '';
            with NodeMaterial.Params do
            begin
              DepthWrite := True;
              AlphaTest  := 1;
              CullFace   := True;
              BlendType  := btNormal;
              Diffuse    := Vec4f(1, 1, 1, 1);
              Emission   := Vec3f(0, 0, 0);
              Reflect    := 0.2;
              Specular   := Vec3f(1, 1, 1);
              Shininess  := 10;
            end;

            if ShXML = nil then
              Exit;

            with ShXML, NodeMaterial, Params do
            begin
              if (Node['shininess'] <> nil) and (Node['shininess']['float'] <> nil) then
              begin
                Shininess := Conv(Node['shininess']['float'].Content, 0.0);
                if (ShadeType = stBlinn) and (Shininess > EPS) then
                  if UpAxis = uaY then // fucking Maya! >_<
                    Shininess := 4 / Shininess;
              end;

              if (Node['reflectivity'] <> nil) and (Node['reflectivity']['float'] <> nil) then
                Reflect := Conv(Node['reflectivity']['float'].Content, 0.0);

            // Diffuse
              if Node['diffuse'] <> nil then
              begin
                Str := GetSampler(XML['library_effects'].NodeI[i], Node['diffuse']['texture']);
                if Str <> '' then
                  Sampler[msDiffuse] := Str;
                if Node['diffuse']['color'] <> nil then
                  Diffuse := TVec4f(Pointer(@ParseFloat(Node['diffuse']['color'].Content)[0])^);
              end;
            // Specular
              if Node['specular'] <> nil then
              begin
                Sampler[msSpecular] := GetSampler(XML['library_effects'].NodeI[i], Node['specular']['texture']);
                if (Node['specular'] <> nil) and (Node['specular']['color'] <> nil) then
                  Specular := TVec3f(Pointer(@ParseFloat(Node['specular']['color'].Content)[0])^)
                else
                  Specular := Vec3f(1, 1, 1);
              end;
            // Ambient
              if Node['ambient'] <> nil then
                Sampler[msAmbient] := GetSampler(XML['library_effects'].NodeI[i], Node['ambient']['texture']);
            // Emission
              if Node['emission'] <> nil then
              begin
                Sampler[msEmission] := GetSampler(XML['library_effects'].NodeI[i], Node['emission']['texture']);
                if Node['emission']['color'] <> nil then
                  Emission := TVec3f(Pointer(@ParseFloat(Node['emission']['color'].Content)[0])^)
                else
                  Emission := Vec3f(1, 1, 1);
              end;
            // Reflect
              if Node['reflective'] <> nil then
                Sampler[msReflect]  := GetSampler(XML['library_effects'].NodeI[i], Node['reflective']['texture']);
            // Transparent
              if (Node['transparency'] <> nil) and (Node['transparency']['float'] <> nil) then
                Diffuse.w := Diffuse.w * ParseFloat(Node['transparency']['float'].Content)[0];

              if Node['transparent'] <> nil then
                if Sampler[msDiffuse] = '' then
                begin
                  Sampler[msDiffuse] := GetSampler(XML['library_effects'].NodeI[i], Node['transparent']['texture']);
                  if Sampler[msDiffuse] <> '' then
                    BlendType := btNormal;
                end;
            end;
            if (Node['extra'] <> nil) and (Node['extra']['technique'] <> nil) then
              with Node['extra']['technique'] do
              begin
                if (Node['bump'] <> nil) and (Node['bump']['texture'] <> nil) then
                  NodeMaterial.Sampler[msNormal] := GetSampler(XML['library_effects'].NodeI[i], Node['bump']['texture']);
                if (Node['spec_level'] <> nil) and (Node['spec_level']['float'] <> nil) then
                  NodeMaterial.Params.Specular := NodeMaterial.Params.Specular * ParseFloat(Node['spec_level']['float'].Content)[0];
              end;
            break;
          end;

  NodeMaterial.Save('cache/' + NodeMaterial.Name + '.xmt');

// Add material to list
  SetLength(NodeMatList, Length(NodeMatList) + 1);
  NodeMatList[Length(NodeMatList) - 1] := NodeMaterial;
end;
{$ENDREGION}

{$REGION 'GetNodes'}
procedure GetNodes(const MainXML: TXML; out Nodes: TNodeArray);

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
            MNode.Name     := Params['name'].Value;
            MNode.Joint    := Params['type'].Value = 'JOINT';
            MNode.JointURL := Params['sid'].Value;

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
                MNode.MeshURL := ConvURL(Params['url'].Value);
                MatNode := Node['bind_material'];
              end;
          // with skin
            if Node['instance_controller'] <> nil then
              with Node['instance_controller'] do
              begin
                MNode.SkinURL := ConvURL(Params['url'].Value);
                MatNode := Node['bind_material'];
                MNode.MeshURL := ConvURL(GetSkin(MainXML, MNode.SkinURL).Params['source'].Value);
              end;

            ParentIdx := Length(Nodes);
            SetLength(Nodes, ParentIdx + 1);
            Nodes[ParentIdx] := MNode;

            MNode.Parent := ParentIdx;

          // Material
            if MatNode <> nil then
              with MatNode['technique_common'] do
                for j := 0 to Count - 1 do
                  with NodeI[j] do
                    if Tag = 'instance_material' then
                    begin
                      MNode.MatURL    := ConvURL(Params['target'].Value);
                      MNode.MatSymbol := Params['symbol'].Value;
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
      Nodes[NodeIdx].Mesh.Init(Nodes[NodeIdx].Source);
    //  Node^.Source := nil;
      Inc(TriCount, Length(Nodes[NodeIdx].Mesh.Index) div 3);
      Inc(MeshCount);
    end else
      MeshURL := '';
end;

procedure Convert(const FileName: string);
var
  i : LongInt;
var
  Thread : array of TThread;
  TID : LongInt;
  Dir : string;
begin
  Dir := ExtractFileDir(FileName);
  if Dir <> '' then
    FileSys.PathAdd('media/' + Dir);
  XML := TXML.Create(FileName);
  with XML['asset'] do
  begin
    UnitScale := Conv(Node['unit'].Params['meter'].Value, 1.0);
    case Node['up_axis'].Content[1] of
      'X' : UpAxis := uaX;
      'Z' : UpAxis := uaZ;
    else
      UpAxis := uaY;
    end;
  end;

  Info('Unit Scale : ' + Conv(UnitScale, 4));
  Info('Up Axis    : ' + UpAxisName[UpAxis]);
  GetNodes(XML, Nodes);
  TriCount := 0;
  MeshCount := 0;
// Init threads
  SetLength(Thread, Render.CPUCount);
  for i := 0 to Length(Thread) - 1 do
    Thread[i].CPUMask := 1 shl i;
  TID := 0;
  IsMultiThread := True;
// Init nodes content
  Info('Convertation...');
  for i := 0 to Length(Nodes) - 1 do
    if (Nodes[i].MeshURL <> '') then //and (Pos('m_', Nodes[i].MeshURL) = 1) then
    begin
      while True do
        if Thread[TID].Done then
        begin
          Thread[TID].Init(@InitNodeProc, Pointer(i), True);
          break;
        end else
        begin
          TID := (TID + 1) mod Length(Thread);
          if TID = 0 then
            Sleep(1);
        end;
    end else
      Nodes[i].MeshURL := '';
// Wait for all threads done
  TID := 0;
  while TID < Length(Thread) do
    if Thread[TID].Done then
      TID := TID + 1
    else
      Sleep(1);

  Info(' Mesh : ' + Conv(MeshCount));
  Info(' Tri  : ' + Conv(TriCount));

// Init nodes render
  Info('Optimization...');
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
    begin
//      Nodes[i].Mesh.Optimize;
      Nodes[i].Mesh.InitVBO;
    end;

  Info('Init materials');
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
    begin
      GetMaterial(XML, Nodes[i].MatURL, Nodes[i].Material);
      Nodes[i].Material.Material := TMaterial.Load(Nodes[i].Material.Name);
    end;

  XML.Free;
end;
{$ENDREGION}

{$REGION 'TDisplayCtrl'}
procedure GetRemap;
var
  F : TextFile;
  Names : array of string;
  s : string;
  i, j, k : Integer;
begin
  AssignFile(F, 'mesh\mask.txt');
  Reset(F);
  while not Eof(F) do
  begin
    Readln(F, s);
    if (s <> '') and ((s[1] = '/') or (s[1] = '%')) then
    begin
      SetLength(Names, Length(Names) + 1);
      Names[Length(Names) - 1] := Copy(s, 2, 255);
    end;
  end;
  CloseFile(F);

  for i := 1 to Length(Names) do
  begin
    k := 0;
    for j := 0 to Length(Nodes) - 1 do
      if Nodes[j].Parent = 0 then
        if Nodes[j].Name = Names[i - 1] then
        begin
          DRemap[i] := k;
          break;
        end else
          Inc(k);
  end;
end;

constructor TDisplayCtrl.Create;
var
  i, j : LongInt;
  x, y : LongInt;
  F : File;
  v : TVec3f;
  Dist, d : Single;
begin
  inherited Create(0, 0, 0, 0);
  Width := 256;
  Align := alClient;

  CamPos  := Vec3f(0, 1.75 / 2, 0);
  CamDist := 2;
  CamRot  := Vec3f(0, 0, 0);

  i := Render.Time;
  Convert('cell.dae');
  Writeln('Total time: ', Render.Time - i, ' ms');

  if ParamStr(1) <> '' then
  begin
    AssignFile(F, ParamStr(1));// 'map.dmp');
    Reset(F, 1);
    BlockRead(F, DMap, SizeOf(DMap));
    BlockRead(F, i, SizeOf(i));
    SetLength(Lights, i);
    BlockRead(F, Lights[0], Length(Lights) * SizeOf(Lights[0]));
    CloseFile(F);
  end;

  FillChar(DLight, SizeOf(DLight), 0);

  for x := 0 to MAP_SIZE - 1 do
    for y := 0 to MAP_SIZE - 1 do
      if DMap[x, y] <> 0 then
      begin
        v := Vec3f(y - 32, 0.6, MAP_SIZE - x - 1 - 32);
        for j := 1 to MAX_LIGHTS - 1 do
        begin
          Dist := 100000;
          for i := 0 to Length(Lights) - 1 do
          begin
            d := v.Dist(Lights[i].Pos) - 2;
            if (d < Lights[i].Radius) and (d < Dist) and
               (DLight[x, y][1] <> i + 1) and
               (DLight[x, y][2] <> i + 1) then
            begin
              Dist := d;
              DLight[x, y][j] := i + 1;
            end;
          end;
          if DLight[x, y][j] = 0 then
            break;
        end;
      end;

  GetRemap;

  if ParamStr(2) <> '' then
    MAP_SCALE := Conv(ParamStr(2), 8.0);
end;

destructor TDisplayCtrl.Destroy;
var
  i : LongInt;
begin
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
    begin
      Nodes[i].Mesh.Free;
      Nodes[i].Material.Material.Free;
    end;
  inherited;
end;

procedure TDisplayCtrl.OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: LongInt);
begin
  if ssAlt in Shift then
    if ((CamDrag = cdRot) and (Button = mbMiddle)) or
       ((CamDrag = cdPos) and (Button = mbLeft)) then
      CamDrag := cdZoom
    else
      if ((CamDrag = cdZoom) and (Button = mbLeft)) or
         ((CamDrag = cdRot) and (Button = mbRight)) or
         (Button = mbMiddle) then
        CamDrag := cdPos
      else
        if Button = mbRight then
          CamDrag := cdZoom
        else
          CamDrag := cdRot;
  GetCursorPos(CamMPos);
end;

procedure TDisplayCtrl.OnMouseUp;
begin
  CamDrag := cdNone;
end;

procedure TDisplayCtrl.OnMouseMove(Shift: TShiftState; X, Y: LongInt);
const
  SENS_POS  = 0.025;
  SENS_ROT  = 0.5;
  SENS_ZOOM = 0.003;
var
  D, L, U, v : TVec3f;
  Pos : TPoint;
begin
  GetCursorPos(Pos);
  D.x := sin(pi - CamRot.y * deg2rad) * cos(CamRot.x * deg2rad);
  D.y := -sin(CamRot.x * deg2rad);
  D.z := cos(pi - CamRot.y * deg2rad) * cos(CamRot.x * deg2rad);

  case CamDrag of
    cdPos :
      begin
        D := D.Normal;
        L := D.Cross(Vec3f(0, 1, 0));
        L := L.Normal;
        U := L.Cross(D);
        U := U.Normal;

        v := Vec3f(0, 0, 0);
        v := v - L * ((Pos.X - CamMPos.x) * SENS_POS * CamDist / 10);
        v := v + U * ((Pos.Y - CamMPos.y) * SENS_POS * CamDist / 10);
        CamPos := CamPos + v;
      end;
    cdRot :
      begin
        CamRot.x := CamRot.x + (Pos.Y - CamMPos.Y) * SENS_ROT;
        CamRot.y := CamRot.y + (Pos.X - CamMPos.X) * SENS_ROT;
        CamRot.x := Min(89.999, Max(-89.999, CamRot.x));
      end;
    cdZoom :
      CamDist := Max(0.01, Min(100, CamDist * (1 - ((Pos.X - CamMPos.X) + (Pos.Y - CamMPos.Y)) * SENS_ZOOM)));
  else
    Exit;
  end;
  CamMPos := Pos;
end;

procedure RenderNode(NodeIdx: LongInt; M: TMat4f);
var
  i : LongInt;
  V : ^TVertex;
begin
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].Parent = NodeIdx then
      RenderNode(i, M);

  if Nodes[NodeIdx].MeshURL <> '' then
    with Nodes[NodeIdx], Mesh, Material do
    begin
{
      b.Min := Nodes[i].AMatrix * BBox.Min;
      b.Max := Nodes[i].AMatrix * BBox.Max;
      if not Visible(b) then
        continue;
}
      V := Buffer[btVertex].DataPtr;
      Buffer[btIndex].Bind;
      Buffer[btVertex].Bind;

      Render.ModelMatrix  := AMatrix * M;
      with Material do
      begin
        Bind;
        Attrib[maCoord].Enable;
        Attrib[maTangent].Enable;
        Attrib[maBinormal].Enable;
        Attrib[maNormal].Enable;
        Attrib[maTexCoord0].Enable;
        Attrib[maTexCoord1].Enable;
        Attrib[maColor].Enable;
        Attrib[maWeight].Enable;
        Attrib[maJoint].Enable;

        Attrib[maCoord].Value(SizeOf(TVertex), V^.Coord);
        Attrib[maTangent].Value(SizeOf(TVertex), V^.Tangent);
        Attrib[maBinormal].Value(SizeOf(TVertex), V^.Binormal);
        Attrib[maNormal].Value(SizeOf(TVertex), V^.Normal);
        Attrib[maTexCoord0].Value(SizeOf(TVertex), V^.TexCoord[0]);
        Attrib[maTexCoord1].Value(SizeOf(TVertex), V^.TexCoord[1]);
        Attrib[maColor].Value(SizeOf(TVertex), V^.Color);
        Attrib[maWeight].Value(SizeOf(TVertex), V^.Weight);
        Attrib[maJoint].Value(SizeOf(TVertex), V^.Joint);

        gl.DrawElements(GL_TRIANGLES, Length(Index), GL_UNSIGNED_SHORT, Buffer[btIndex].DataPtr);

        Attrib[maCoord].Disable;
        Attrib[maTangent].Disable;
        Attrib[maBinormal].Disable;
        Attrib[maNormal].Disable;
        Attrib[maTexCoord0].Disable;
        Attrib[maTexCoord1].Disable;
        Attrib[maColor].Disable;
        Attrib[maWeight].Disable;
        Attrib[maJoint].Disable;
      end;
    end;
end;

procedure RenderBlock(BlockIdx: LongInt; x, y, Dir: LongInt);
var
  i, j : LongInt;
  M : TMat4f;
begin
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].Parent = 0 then
    begin
      Dec(BlockIdx);
      if BlockIdx < 0 then
      begin
        M.Identity;
        M.Translate(Vec3f((y - 32) * MAP_SCALE, 0, ((MAP_SIZE - x - 1) - 32) * MAP_SCALE));
        M.Rotate((Dir) * pi * 0.5, Vec3f(0, 1, 0));

        for j := 1 to MAX_LIGHTS - 1 do
          if DLight[x, y][j] > 0 then
          begin
            Render.Light[j].Color  := Lights[DLight[x, y][j] - 1].Color;
            Render.Light[j].Pos    := Lights[DLight[x, y][j] - 1].Pos * MAP_SCALE;
            Render.Light[j].Radius := Lights[DLight[x, y][j] - 1].Radius * MAP_SCALE;
          end else
          begin
            Render.Light[j].Color  := NullVec3f;
            Render.Light[j].Pos    := NullVec3f;
            Render.Light[j].Radius := 1;
          end;
        RenderNode(i, M);
        break;
      end;
    end;
end;

procedure TDisplayCtrl.OnRender;
var
  Planes : array [0..5] of TVec4f;

  function Plane(x, y, z, w: Single): TVec4f;
  var
    Len : Single;
  begin
    Len := 1 / sqrt(sqr(x) + sqr(y) + sqr(z));
    Result := Vec4f(x, y, z, w) * Len;
  end;

  procedure UpdateCamera;
  var
    Dir, VSpeed : TVec3f;
  begin
    CAM_SPEED := Max(1, (CAM_SPEED + Input.Mouse.Delta.Wheel));

    if Input.Down[ikMouseL] then
    begin
      CamRot.x := CamRot.x + Input.Mouse.Delta.Y * 0.01;
      CamRot.y := CamRot.y + Input.Mouse.Delta.X * 0.01;
      CamRot.x := Clamp(CamRot.x, -pi/2 + EPS, pi/2 - EPS);
    end;
    Dir.x := sin(pi - CamRot.y) * cos(CamRot.x);
    Dir.y := -sin(CamRot.x);
    Dir.z := cos(pi - CamRot.y) * cos(CamRot.x);
    VSpeed := Vec3f(0, 0, 0);
    with Input do
    begin
      if Down[ikW] then VSpeed := VSpeed + Dir;
      if Down[ikS] then VSpeed := VSpeed - Dir;
      if Down[ikD] then VSpeed := VSpeed + Dir.Cross(Vec3f(0, 1, 0));
      if Down[ikA] then VSpeed := VSpeed - Dir.Cross(Vec3f(0, 1, 0));
    end;
    CamPos := CamPos + VSpeed.Normal * (Render.DeltaTime * CAM_SPEED * UnitScale);

    VM.Identity;
    VM.Rotate(CamRot.x, Vec3f(1, 0, 0));
    VM.Rotate(CamRot.y, Vec3f(0, 1, 0));
    VM.Translate(CamPos * -1);
    PM.Perspective(50, Width/Height, 0.1, 100);

    with PM * VM do
    begin
      Planes[0] := Plane(e30 - e00, e31 - e01, e32 - e02, e33 - e03); // right
      Planes[1] := Plane(e30 + e00, e31 + e01, e32 + e02, e33 + e03); // left
      Planes[2] := Plane(e30 - e10, e31 - e11, e32 - e12, e33 - e13); // top
      Planes[3] := Plane(e30 + e10, e31 + e11, e32 + e12, e33 + e13); // bottom
      Planes[4] := Plane(e30 - e20, e31 - e21, e32 - e22, e33 - e23); // near
      Planes[5] := Plane(e30 + e20, e31 + e21, e32 + e22, e33 + e23); // far
    end;

    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(PM);
    gl.MatrixMode(GL_MODELVIEW);
    gl.LoadMatrixf(VM);
  end;

  function Visible(const BBox: TBox): Boolean;
  var
    i : Integer;
  begin
    with BBox do
      for i := 0 to 5 do
        with Planes[i] do
          if (Dot(Max) < 0) and
             (Dot(Vec3f(Min.x, Max.y, Max.z)) < 0) and
             (Dot(Vec3f(Max.x, Min.y, Max.z)) < 0) and
             (Dot(Vec3f(Min.x, Min.y, Max.z)) < 0) and
             (Dot(Vec3f(Max.x, Max.y, Min.z)) < 0) and
             (Dot(Vec3f(Min.x, Max.y, Min.z)) < 0) and
             (Dot(Vec3f(Max.x, Min.y, Min.z)) < 0) and
             (Dot(Min) < 0) then
          begin
            Result := False;
            Exit;
          end;
    Result := True;
  end;

const
  ColorT : TVec3f = (x: 0.05; y: 0.05; z: 0.05);
  ColorB : TVec3f = (x: 0.50; y: 0.50; z: 0.50);
var
  x, y : LongInt;
  b : TBox;
begin
  Render.Viewport := CoreX.Rect(0, 0, Screen.Width, Screen.Height);

  with Render.Ambient do
    gl.ClearColor(x, y, z, 1.0);

  Render.Set2D(0, 1, 1, 0);
{
  Render.DepthTest := False;
  Render.ResetBind;
  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.Color3fv(ColorT); gl.Vertex2f(0, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(0, 0);
    gl.Color3fv(ColorT); gl.Vertex2f(1, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(1, 0);
  gl.Endp;
}

  UpdateCamera;

  if Input.Down[ikSpace] then
    CamPos.y := 1.6;

  Render.ViewPos         := VM.Inverse.Pos;
  Render.Light[0].Pos    := Render.ViewPos;
  Render.Light[0].Color  := Vec3f(0.1, 0.1, 0.1);
  Render.Light[0].Radius := 12;

  Render.CullFace    := True;
  Render.DepthTest   := True;
  Render.Ambient     := Vec3f(0.15, 0.15, 0.20);

  for x := 0 to MAP_SIZE - 1 do
    for y := 0 to MAP_SIZE - 1 do
      if DMap[x, y] <> 0 then
      begin
        b.Min := Vec3f((y - 32 - 0.5) * MAP_SCALE, 0, (MAP_SIZE - x - 1 - 32 - 0.5) * MAP_SCALE);
        b.Max := b.Min + Vec3f(MAP_SCALE, MAP_SCALE, MAP_SCALE);

        if Visible(b) then
          RenderBlock(DRemap[DMap[x, y] div 10], x, y, DMap[x, y] mod 10);
      end;

// Axis
  Render.ResetBind;
  Render.DepthWrite := False;
{
  gl.Beginp(GL_LINES);
  gl.Color3f(0, 0, 0);
  for i := -20 to 20 do
  begin
    gl.Vertex3f(-20 / 10, 0, i / 10);
    gl.Vertex3f(+20 / 10, 0, i / 10);
    gl.Vertex3f(i / 10, 0, -20 / 10);
    gl.Vertex3f(i / 10, 0, +20 / 10);
  end;
  gl.Endp;
}
  gl.Beginp(GL_LINES);
    gl.Color3f(1, 0, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(1, 0, 0);
    gl.Color3f(0, 1, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 1, 0);
    gl.Color3f(0, 0, 1); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 0, 1);
  gl.Endp;
  Render.DepthWrite := True;
end;

(*
procedure TDisplayCtrl.OnRender;
var
  i : LongInt;
  Planes : array [0..3] of TVec4f;

  function Plane(x, y, z, w: Single): TVec4f;
  var
    Len : Single;
  begin
    Len := 1 / sqrt(sqr(x) + sqr(y) + sqr(z));
    Result := Vec4f(x, y, z, w) * Len;
  end;

  procedure UpdateCamera;
  begin
  {
    if Input.Down[KM_L] then
    begin
      CamRot.x := CamRot.x + Input.Mouse.Delta.Y * 0.01;
      CamRot.y := CamRot.y + Input.Mouse.Delta.X * 0.01;
      CamRot.x := Clamp(CamRot.x, -pi/2 + EPS, pi/2 - EPS);
    end;
    Dir.x := sin(pi - CamRot.y) * cos(CamRot.x);
    Dir.y := -sin(CamRot.x);
    Dir.z := cos(pi - CamRot.y) * cos(CamRot.x);
    VSpeed := Vec3f(0, 0, 0);
    with Input do
    begin
      if Down[KK_W] then VSpeed := VSpeed + Dir;
      if Down[KK_S] then VSpeed := VSpeed - Dir;
      if Down[KK_D] then VSpeed := VSpeed + Dir.Cross(Vec3f(0, 1, 0));
      if Down[KK_A] then VSpeed := VSpeed - Dir.Cross(Vec3f(0, 1, 0));
    end;
    CamPos := CamPos + VSpeed.Normal * (Render.DeltaTime * CAM_SPEED * UnitScale);

    VM.Identity;
    VM.Rotate(CamRot.x, Vec3f(1, 0, 0));
    VM.Rotate(CamRot.y, Vec3f(0, 1, 0));
    VM.Translate(CamPos * -1);
    PM.Perspective(68.039, Width/Height, 0.01 * UnitScale, 100 * UnitScale);
  }

    PM.Identity;
    PM.Perspective(68.039, Screen.Width/Screen.Height, 0.01, 100);

    VM.Identity;
    VM.Translate(Vec3f(0, 0, -CamDist));
    VM.Rotate(CamRot.x * deg2rad, Vec3f(1, 0, 0));
    VM.Rotate(CamRot.y * deg2rad, Vec3f(0, 1, 0));
    VM.Translate(Vec3f(-CamPos.x, -CamPos.y, -CamPos.z));

  // calc frustum planes
    with PM * VM do
    begin
      Planes[0] := Plane(e30 - e00, e31 - e01, e32 - e02, e33 - e03); // right
      Planes[1] := Plane(e30 + e00, e31 + e01, e32 + e02, e33 + e03); // left
      Planes[2] := Plane(e30 - e10, e31 - e11, e32 - e12, e33 - e13); // top
      Planes[3] := Plane(e30 + e10, e31 + e11, e32 + e12, e33 + e13); // bottom
    end;

    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(PM);
    gl.MatrixMode(GL_MODELVIEW);
    gl.LoadMatrixf(VM);
  end;

  function Visible(const BBox: TBox): Boolean;
  var
    i : Integer;
  begin
    with BBox do
      for i := 0 to 3 do
        with Planes[i] do
          if (Dot(Max) < 0) and
             (Dot(Vec3f(Min.x, Max.y, Max.z)) < 0) and
             (Dot(Vec3f(Max.x, Min.y, Max.z)) < 0) and
             (Dot(Vec3f(Min.x, Min.y, Max.z)) < 0) and
             (Dot(Vec3f(Max.x, Max.y, Min.z)) < 0) and
             (Dot(Vec3f(Min.x, Max.y, Min.z)) < 0) and
             (Dot(Vec3f(Max.x, Min.y, Min.z)) < 0) and
             (Dot(Min) < 0) then
          begin
            Result := False;
            Exit;
          end;
    Result := True;
  end;

const
  ColorT : TVec3f = (x: 0.05; y: 0.05; z: 0.05);
  ColorB : TVec3f = (x: 0.50; y: 0.50; z: 0.50);
  MouseButton : array [ikMouseL..ikMouseM] of TMouseButton =
    (mbLeft, mbRight, mbMiddle);
var
  ViewPos, LightPos : TVec3f;
  V  : ^TVertex;
  b : TBox;
  k : TInputKey;
  sh : TShiftState;
begin
  Render.Viewport := CoreX.Rect(0, 0, Screen.Width, Screen.Height);

  Render.Set2D(0, 1, 1, 0);
  Render.DepthTest := False;
  Render.ResetBind;
  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.Color3fv(ColorT); gl.Vertex2f(0, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(0, 0);
    gl.Color3fv(ColorT); gl.Vertex2f(1, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(1, 0);
  gl.Endp;

  sh := [];
  if Input.Down[ikShift] then
    sh := sh + [ssShift];
  if Input.Down[ikAlt] then
    sh := sh + [ssAlt];
  if Input.Down[ikCtrl] then
    sh := sh + [ssCtrl];

  for k := Low(MouseButton) to High(MouseButton) do
  begin
  // Down
    if (not MState[k]) and (Input.Down[k]) then
      OnMouseDown(MouseButton[k], sh, 0, 0);
  // Up
    if MState[k] and (not Input.Down[k]) then
      OnMouseUp;
    MState[k] := Input.Down[k];
  end;
  OnMouseMove(sh, 0, 0);

  UpdateCamera;

  ViewPos  := VM.Inverse.Pos;
  LightPos := Vec3f(1, 1, 1) * 10;
//  LightPos := Vec3f(-696.5, 108.839, 298.473);

  Render.ViewPos     := ViewPos;
  Render.LightPos[0] := LightPos;

  Render.CullFace := True;
  Render.DepthTest := True;

  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
      with Nodes[i].Mesh do
      begin                  {
        if Nodes[i].Material.Material.Params.Diffuse.w < 1 then
          continue;         }

        b.Min := Nodes[i].AMatrix * BBox.Min;
        b.Max := Nodes[i].AMatrix * BBox.Max;
        if not Visible(b) then
          continue;

        V := Buffer[btVertex].DataPtr;
        Buffer[btIndex].Bind;
        Buffer[btVertex].Bind;

        Render.ModelMatrix := Nodes[i].AMatrix;
        with Nodes[i].Material.Material do
        begin
          Bind;
          Attrib[maCoord].Enable;
          Attrib[maTangent].Enable;
          Attrib[maBinormal].Enable;
          Attrib[maNormal].Enable;
          Attrib[maTexCoord0].Enable;
          Attrib[maTexCoord1].Enable;
          Attrib[maColor].Enable;
          Attrib[maWeight].Enable;
          Attrib[maJoint].Enable;

          Attrib[maCoord].Value(SizeOf(TVertex), V^.Coord);
          Attrib[maTangent].Value(SizeOf(TVertex), V^.Tangent);
          Attrib[maBinormal].Value(SizeOf(TVertex), V^.Binormal);
          Attrib[maNormal].Value(SizeOf(TVertex), V^.Normal);
          Attrib[maTexCoord0].Value(SizeOf(TVertex), V^.TexCoord[0]);
          Attrib[maTexCoord1].Value(SizeOf(TVertex), V^.TexCoord[1]);
          Attrib[maColor].Value(SizeOf(TVertex), V^.Color);
          Attrib[maWeight].Value(SizeOf(TVertex), V^.Weight);
          Attrib[maJoint].Value(SizeOf(TVertex), V^.Joint);

          gl.DrawElements(GL_TRIANGLES, Length(Index), GL_UNSIGNED_SHORT, Buffer[btIndex].DataPtr);

          Attrib[maCoord].Disable;
          Attrib[maTangent].Disable;
          Attrib[maBinormal].Disable;
          Attrib[maNormal].Disable;
          Attrib[maTexCoord0].Disable;
          Attrib[maTexCoord1].Disable;
          Attrib[maColor].Disable;
          Attrib[maWeight].Disable;
          Attrib[maJoint].Disable;
        end;
{
        gl.Disable(GL_LIGHTING);
        gl.Color3f(0, 1, 0);
        with Nodes[i].Mesh.BBox do
        begin
          gl.Beginp(GL_LINE_STRIP);
            gl.Vertex3f(Min.x, Min.y, Min.z);
            gl.Vertex3f(Max.x, Min.y, Min.z);
            gl.Vertex3f(Max.x, Min.y, Max.z);
            gl.Vertex3f(Min.x, Min.y, Max.z);
            gl.Vertex3f(Min.x, Min.y, Min.z);
            gl.Vertex3f(Min.x, Max.y, Min.z);
            gl.Vertex3f(Max.x, Max.y, Min.z);
            gl.Vertex3f(Max.x, Max.y, Max.z);
            gl.Vertex3f(Min.x, Max.y, Max.z);
            gl.Vertex3f(Min.x, Max.y, Min.z);
            gl.Vertex3f(Max.x, Max.y, Min.z);
            gl.Vertex3f(Max.x, Min.y, Min.z);
            gl.Vertex3f(Max.x, Min.y, Max.z);
            gl.Vertex3f(Max.x, Max.y, Max.z);
            gl.Vertex3f(Min.x, Max.y, Max.z);
            gl.Vertex3f(Min.x, Min.y, Max.z);
          gl.Endp;
        end;
}
      end;

{
  for i := Length(Nodes) - 1 downto 0 do
    if Nodes[i].MeshURL <> '' then
      with Nodes[i].Mesh do
      begin
        if Nodes[i].Material.Material.Params.Diffuse.w > 1 - EPS then
          continue;

        b.Min := Nodes[i].AMatrix * BBox.Min;
        b.Max := Nodes[i].AMatrix * BBox.Max;
        if not Visible(b) then
          continue;

        V := Buffer[btVertex].DataPtr;
        Buffer[btIndex].Bind;
        Buffer[btVertex].Bind;

        Render.ModelMatrix := Nodes[i].AMatrix;
        with Nodes[i].Material.Material do
        begin
          Bind;
          Attrib[maCoord].Value(SizeOf(TVertex), V^.Coord);
          Attrib[maTangent].Value(SizeOf(TVertex), V^.Tangent);
          Attrib[maBinormal].Value(SizeOf(TVertex), V^.Binormal);
          Attrib[maNormal].Value(SizeOf(TVertex), V^.Normal);
          Attrib[maTexCoord0].Value(SizeOf(TVertex), V^.TexCoord[0]);
        end;

        gl.DrawElements(GL_TRIANGLES, Length(Index), GL_UNSIGNED_SHORT, Buffer[btIndex].DataPtr);
      end;
         }
// Axis
  Render.ResetBind;
  Render.DepthWrite := False;
  gl.Beginp(GL_LINES);
  gl.Color3f(0, 0, 0);
  for i := -20 to 20 do
  begin
    gl.Vertex3f(-20 / 10, 0, i / 10);
    gl.Vertex3f(+20 / 10, 0, i / 10);
    gl.Vertex3f(i / 10, 0, -20 / 10);
    gl.Vertex3f(i / 10, 0, +20 / 10);
  end;
  gl.Endp;

  gl.Beginp(GL_LINES);
    gl.Color3f(1, 0, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(1, 0, 0);
    gl.Color3f(0, 1, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 1, 0);
    gl.Color3f(0, 0, 1); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 0, 1);
  gl.Endp;
  Render.DepthWrite := True;

  if Input.Hit[ikSpace] then
  begin
    for i := 0 to Length(Nodes) - 1 do
      if Nodes[i].MeshURL <> '' then
        Nodes[i].Material.Material.Free;
    for i := 0 to Length(Nodes) - 1 do
      if Nodes[i].MeshURL <> '' then
        Nodes[i].Material.Material := TMaterial.Load(Nodes[i].Material.Name);
  end;

end;
*)
{$ENDREGION}

end.
