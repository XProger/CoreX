program xmd;

{$APPTYPE CONSOLE}

uses
  CoreX, Windows, NvTriStrip;

//{$DEFINE DEBUG}

{$IFDEF DEBUG}
//  {$DEFINE DEBUG_NODE}
{$ENDIF}

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
const
// Format Flag
  FF_UNKNOWN   = $00;
  FF_COORD     = $01;
  FF_TBN       = $02;
  FF_NORMAL    = $04;
  FF_TEXCOORD0 = $08;
  FF_TEXCOORD1 = $10;
  FF_COLOR     = $20;
  FF_WEIGHT    = $40;
  FF_JOINT     = $80;

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
    Weight   : TVec3f;
    Joint    : TVec2f;
  end;
  TVertexArray = array of TVertex;

  TBBox = record
    Min, Max : TVec3f;
  end;

  TMesh = object
    Format : LongWord;
    Index  : TIndexArray;
    Vertex : TVertexArray;
    BBox   : TBBox;
  private
    Buffer : array [TBufferType] of TMeshBuffer;
    procedure CalculateTBN;
    procedure CalculateBBox;
    procedure Optimize;
  public
    procedure Init(Source: TSourceArray);
    procedure Free;
    procedure Save(const FileName: string);
  end;
{$ENDREGION}

{$REGION 'Material format'}
  TSamplerFlag = (sfDiffuse, sfNormal, sfSpecular, sfNormalSpecular, sfEmission, sfReflect, sfLighting, sfAmbient);

  TMaterial = record
    Sampler  : TSamplerFlag;
    Diffuse  : TVec4f;
    Specular : TVec4f;
    Ambient  : TVec3f;
    Texture  : array [TSamplerFlag] of string;
  end;
{$ENDREGION}

{$REGION 'Light format'}
  TLight = record
    Color : TVec3f;
  end;
{$ENDREGION}

{$REGION 'Node format'}
type
  TNode = record
    Parent   : LongInt;
    Matrix   : TMat4f;
    Joint    : Boolean;
    Mesh     : TMesh;
    Name     : string;
    MeshURL  : string;
    MatName  : string;
    MatURL   : string;
    SkinURL  : string;
    JointURL : string;
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
    MatName  : '';
    MatURL   : '';
    SkinURL  : '';
    JointURL : '';
  );
{$ENDREGION}

{$REGION 'Common functions'}
procedure Info(const Text: string);
begin
  Writeln(Text);
end;

procedure Error(const Text: string);
begin
  Writeln('Error: ', Text);
  Readln;
end;

procedure Warning(const Text: string);
begin
  Writeln('Warning: ', Text);
end;

procedure Hint(const Text: string);
begin
  Writeln('Hint: ', Text);
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

function ValidMatrix(const M: TMat4f): Boolean;
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
      Error('Invalid scale value: (' + Conv(x, 2) + ', ' + Conv(y, 2) + ', ' + Conv(z, 2) + ')');
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
{$ENDREGION}

{$REGION 'TMesh'}
procedure TMesh.CalculateTBN;
const
  NullVec : TVec3f = (x: 0; y: 0; z: 0);
var
  i  : Integer;
  v  : TVertex;
  e  : array [0..1] of TVec3f;
  st : array [0..1] of TVec2f;
  tn, bn : TVec3f;
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
  Vertex := ResVertex;

// Basis orthonormalization
  for i := 0 to Length(ResVertex) - 1 do
    with ResVertex[i] do
    begin
      tn := Tangent;
      bn := Binormal;
      Tangent := (tn - Normal * Normal.Dot(tn)).Normal;
      if bn.Dot(Normal.Cross(tn)) < 0 then
        Binormal := Tangent.Cross(Normal)
      else
        Binormal := Normal.Cross(Tangent);
      Binormal := Binormal.Normal;
    end;
end;

procedure TMesh.CalculateBBox;
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

  with BBox do
    Info(' BBox: (' + Conv(Min.x, 2) + ', ' + Conv(Min.y, 2) + ', ' + Conv(Min.z, 2) + ') - (' +
                      Conv(Max.x, 2) + ', ' + Conv(Max.y, 2) + ', ' + Conv(Max.z, 2) + ')');
end;

procedure TMesh.Optimize;
var
  VertexRemap         : TVertexArray;
  Groups, GroupsRemap : PNVTSPrimitiveGroup;
  GroupCount          : Word;
  i                   : Integer;
begin
  nvtsSetCacheSize(24);
  nvtsSetStitchStrips(True);
  nvtsSetListOnly(True);

  nvtsGenerateStrips(@Index[0], Length(Index), Groups, GroupCount);
  nvtsRemapIndices(Groups, GroupCount, Length(Vertex), GroupsRemap);

  SetLength(VertexRemap, Length(Vertex));
  Move(Vertex[0], VertexRemap[0], Length(Vertex) * SizeOf(TVertex));

  for i := 0 to Groups^.numIndices - 1 do
  begin
    Index[i] := GroupsRemap^.indices[i];
    Vertex[Index[i]] := VertexRemap[Groups^.indices[i]];
  end;
end;

procedure TMesh.Init(Source: TSourceArray);
const
  FormatFlags : array [TSourceID] of LongWord = (
    FF_UNKNOWN, FF_UNKNOWN, FF_COORD, FF_TBN, FF_TBN, FF_NORMAL, FF_TEXCOORD0, FF_TEXCOORD1, FF_COLOR, FF_WEIGHT, FF_JOINT, FF_UNKNOWN
  );

  procedure GetValue(Idx: LongInt; S: TSourceID; out Value: TVec4f); overload;
  begin
    Value := NullVec4f;
    if Format and FormatFlags[S] > 0 then
      with Source[S] do
        Move(ValueF[Stride * ValueI[Idx]], Value, Stride * SizeOf(ValueF[0]));
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

var
  i : LongInt;
  S : TSourceID;
  v : TVertex;
  Count, Idx : LongInt;
begin
  Format := FF_UNKNOWN;
  for S := Low(S) to High(S) do
    if Source[S].SourceURL <> '' then
      Format := Format or FormatFlags[S];

  if (FF_TBN and Format > 0) and (FF_NORMAL and Format = 0) then
    Error('Mesh has no normals');

  if FF_COORD and Format = 0 then
    Error('Mesh has no vertex coordinates');

// Construct index & vertex
  SetLength(Index, Length(Source[SID_POSITION].ValueI));
  SetLength(Vertex, Length(Index));
  FillChar(Vertex[0], Length(Vertex) * SizeOf(TVertex), 0);
  FillChar(v, SizeOf(v), 0);

  Count := 0;
  for i := 0 to Length(Index) - 1 do
  begin
    GetValue(i, SID_POSITION, v.Coord);
    GetValue(i, SID_NORMAL, v.Normal);
    GetValue(i, SID_TEXCOORD0, v.TexCoord[0]);
    GetValue(i, SID_TEXCOORD1, v.TexCoord[1]);
    GetValue(i, SID_COLOR, v.Color);
{
    GetValue(i, SID_WEIGHT, v.Weight);
    GetValue(i, SID_JOINT, v.Joint);
}
    Idx := 0;
    while Idx < Count  do
      with Vertex[Idx] do
        if (Coord = v.Coord) and (Normal = v.Normal) and
           (TexCoord[0] = v.TexCoord[0]) and (TexCoord[1] = v.TexCoord[1]) and
           (Color = v.Color) and (Weight = v.Weight) and (Joint = v.Joint) then
          break
        else
          Inc(Idx);

    if Idx = Count then
    begin
      Vertex[Count] := v;
      Inc(Count);
    end;
    Index[i] := Idx;
  end;
  SetLength(Vertex, Count);

// Convert to Y-up axis
  for i := 0 to Length(Vertex) - 1 do
    with Vertex[i] do
    begin
      Coord := Coord * UnitScale;
      case UpAxis of
        uaX :
          begin
            Coord := Vec3f(-Coord.y, Coord.x, Coord.z);
            Normal := Vec3f(-Normal.y, Normal.x, Normal.z);
          end;
        uaZ :
          begin
            Coord := Vec3f(Coord.x, Coord.z, -Coord.y);
            Normal := Vec3f(Normal.x, Normal.z, -Normal.y);
          end;
      end;
    end;

  CalculateTBN;
  Info(' Format: (T: ' + Conv(Length(Index) div 3) + '; V: ' + Conv(Length(Vertex)) + ')');

  CalculateBBox;
  Optimize;

  Buffer[btIndex].Init(btIndex, Length(Index) * SizeOf(Index[0]), @Index[0]);
  Buffer[btVertex].Init(btVertex, Length(Vertex) * SizeOf(Vertex[0]), @Vertex[0]);
end;

procedure TMesh.Free;
begin
  Buffer[btIndex].Free;
  Buffer[btVertex].Free;
end;

procedure TMesh.Save(const FileName: string);
begin
  //
end;
{$ENDREGION}

{$REGION 'Get functions'}
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

function GetMesh(const XML: TXML; const URL, SkinURL: string; out Source : TSourceArray): Boolean;

  procedure GetInputs(const SourceXML, XML: TXML);

    function GetSourceID(const Semantic, SourceURL: string): TSourceID;
    var
      S : TSourceID;
    begin
      Result := SID_UNKNOWN;
      for S := Low(S) to High(S) do
        if (SourceName[S] = Semantic) and
           ((Source[S].SourceURL = '') or (Source[S].SourceURL = SourceURL)) then
        begin
          Result := S;
          Exit;
        end;
      if Result = SID_UNKNOWN then
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
              Source[S].Offset    := Conv(Params['offset'].Value, -1);
              if S = SID_VERTEX then
              begin
                for S := Low(S) to High(S) do
                  if Source[S].Offset = -1 then
                    Source[S].Offset := Source[SID_VERTEX].Offset;
              end else
              begin
                Source[S].SourceURL := ConvURL(Params['source'].Value);
                with SourceXML do
                  for j := 0 to Count - 1 do
                    with NodeI[j] do
                      if Tag = 'source' then
                        for S := Low(S) to High(S) do
                          if Params['id'].Value = Source[S].SourceURL then
                          begin
                            if Node['float_array'] <> nil then
                              Source[S].ValueF := ParseFloat(Node['float_array'].Content);
                            if Node['Name_array'] <> nil then
                              Source[S].ValueS := ParseString(Node['Name_array'].Content);
                            Source[S].Stride := Conv(Node['technique_common']['accessor'].Params['stride'].Value, 1);
                          end;
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
    with InputXML['triangles'] do
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
  i : LongInt;
  InputXML : TXML;
  SkinXML  : TXML;
begin
  Result := False;
  FillChar(Source, SizeOf(Source), 0);
  with XML['library_geometries'] do
    for i := 0 to Count - 1 do
      if NodeI[i].Params['id'].Value = URL then
        with NodeI[i] do
        begin
          InputXML := Node['mesh'];
          if InputXML = nil then
            Exit; // spline etc. is not supported
          if InputXML.Node['triangles'] = nil then
          begin
            Error('Non triangulated geometry "' + URL + '"');
            Exit;
          end;
        // Read inputs
          GetInputs(InputXML, InputXML['vertices']);
          GetInputs(InputXML, InputXML['triangles']);
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
          GetIndices(InputXML, SkinXML);
          Result := True;
          Exit;
        end;
end;

procedure GetMaterial(const XML: TXML; const URL: string; out Material: TMaterial);
begin
  //
end;

procedure GetNodes(const MainXML: TXML; out Nodes: TNodeArray);

  procedure CollectNodes(const XML: TXML; Parent: LongInt);
  var
    i, j : LongInt;
    MatNode : TXML;
  begin
    with XML do
      for i := 0 to Count - 1 do
        with NodeI[i] do
          if Tag = 'node' then
          begin
            j := Length(Nodes);
            SetLength(Nodes, j + 1);
            Nodes[j] := ZeroNode;
            Nodes[j].Parent   := Parent;
            Nodes[j].Name     := Params['name'].Value;
            Nodes[j].Joint    := Params['type'].Value = 'JOINT';
            Nodes[j].JointURL := Params['sid'].Value;

            MatNode := nil;
          // Matrix
            if Node['matrix'] <> nil then
              Nodes[j].Matrix := ParseMatrix(Node['matrix'].Content);
            Nodes[j].Matrix := ConvMatrix(Nodes[j].Matrix);
          // Mesh
          // without skin
            if Node['instance_geometry'] <> nil then
              with Node['instance_geometry'] do
              begin
                Nodes[j].MeshURL := ConvURL(Params['url'].Value);
                MatNode := Node['bind_material'];
              end;
          // with skin
            if Node['instance_controller'] <> nil then
              with Node['instance_controller'] do
              begin
                Nodes[j].SkinURL := ConvURL(Params['url'].Value);
                MatNode := Node['bind_material'];
                Nodes[j].MeshURL := ConvURL(GetSkin(MainXML, Nodes[j].SkinURL).Params['source'].Value);
              end;
          // Material
            if MatNode <> nil then
              with MatNode['technique_common']['instance_material'] do
                begin
                  Nodes[j].MatURL  := ConvURL(Params['target'].Value);
                  Nodes[j].MatName := Params['symbol'].Value;
                end;

            {$IFDEF DEBUG_NODE}
              Writeln('Node ID : ', j);
              Writeln(' Parent   : ', Nodes[j].Parent);
              Writeln(' Name     : ', Nodes[j].Name);
              if Nodes[j].MeshURL <> '' then
                Writeln(' MeshURL  : ', Nodes[j].MeshURL);
              if Nodes[j].MatName <> '' then
                Writeln(' MatName  : ', Nodes[j].MatName);
              if Nodes[j].MatURL <> '' then
                Writeln(' MatURL   : ', Nodes[j].MatURL);
              if Nodes[j].SkinURL <> '' then
                Writeln(' SkinURL  : ', Nodes[j].SkinURL);
              if Nodes[j].JointURL <> '' then
                Writeln(' JointURL : ', Nodes[j].JointURL);
              WriteMat4f(Nodes[j].Matrix);
            {$ENDIF}
            CollectNodes(XML.NodeI[i], j);
          end;
  end;

begin
  CollectNodes(MainXML['library_visual_scenes']['visual_scene'], -1);
end;
{$ENDREGION}

var
  CamPos, CamAngle : TVec3f;
  Nodes  : TNodeArray;

procedure Convert(const FileName: string);
var
  i      : LongInt;
  XML    : TXML;
  Source : TSourceArray;
begin
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

  Writeln('Unit Scale : ', UnitScale:0:4);
  Writeln('Up Axis    : ', UpAxisName[UpAxis]);
  GetNodes(XML, Nodes);
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
      if GetMesh(XML, Nodes[i].MeshURL, Nodes[i].SkinURL, Source) then
      begin
        Writeln('Mesh: ' + Nodes[i].MeshURL);
        ValidMatrix(Nodes[i].Matrix);
        Nodes[i].Mesh.Init(Source);
      end;
  XML.Free;
end;

procedure OnInit;
begin
  Convert('H:\room_maya.dae');
//  Convert('H:\Projects\Pioner\PioModel\tanya_run.dae');
  if ParamStr(1) <> '' then
    Convert(ParamStr(1));

  Input.Capture := True;
  Render.DepthTest := True;
  Render.CullFace  := True;
  Screen.Resize(1280, 800);
end;

procedure OnFree;
var
  i : LongInt;
begin
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
      Nodes[i].Mesh.Free;
end;

procedure OnRender;
var
  i : LongInt;

  procedure UpdateCamera;
  const
    CAM_SPEED = 5;
  var
    Dir    : TVec3f;
    VSpeed : TVec3f;
    PM, MM : TMat4f;
  begin
    CamAngle.x := CamAngle.x + Input.Mouse.Delta.Y * 0.01;
    CamAngle.y := CamAngle.y + Input.Mouse.Delta.X * 0.01;
    CamAngle.x := Clamp(CamAngle.x, -pi/2 + EPS, pi/2 - EPS);

    Dir.x := sin(pi - CamAngle.y) * cos(CamAngle.x);
    Dir.y := -sin(CamAngle.x);
    Dir.z := cos(pi - CamAngle.y) * cos(CamAngle.x);
    VSpeed := Vec3f(0, 0, 0);
    with Input do
    begin
      if Down[KK_W] then VSpeed := VSpeed + Dir;
      if Down[KK_S] then VSpeed := VSpeed - Dir;
      if Down[KK_D] then VSpeed := VSpeed + Dir.Cross(Vec3f(0, 1, 0));
      if Down[KK_A] then VSpeed := VSpeed - Dir.Cross(Vec3f(0, 1, 0));
    end;
    CamPos := CamPos + VSpeed.Normal * (Render.DeltaTime * CAM_SPEED);

    MM.Identity;
    MM.Rotate(CamAngle.x, Vec3f(1, 0, 0));
    MM.Rotate(CamAngle.y, Vec3f(0, 1, 0));
    MM.Translate(CamPos * -1);
    PM.Perspective(90, Screen.Width/Screen.Height, 0.01, 100);

    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(PM);
    gl.MatrixMode(GL_MODELVIEW);
    gl.LoadMatrixf(MM);
  end;

  function GetNodeMatrix(Idx: LongInt): TMat4f;
  begin
    if Nodes[Idx].Parent <> -1 then
      Result := Nodes[Idx].Matrix * GetNodeMatrix(Nodes[Idx].Parent)
    else
      Result := Nodes[Idx].Matrix;
  end;

var
  lp : TVec4f;
  V  : ^TVertex;
begin
//  Sleep(5);

  Render.Clear(True, True);
  UpdateCamera;

  with CamPos do
    lp := Vec4f(x, y, z, 1);
  gl.Enable(GL_COLOR_MATERIAL);
  gl.Enable(GL_LIGHT0);
  gl.Lightfv(GL_LIGHT0, GL_POSITION, @lp);

  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
      with Nodes[i].Mesh do
      begin
        gl.PushMatrix;
        gl.MultMatrixf(GetNodeMatrix(i));

        gl.Enable(GL_LIGHTING);

        gl.Color3f(1, 1, 1);

        V := Buffer[btVertex].DataPtr;

        Buffer[btIndex].Enable;
        Buffer[btVertex].Enable;

        gl.EnableClientState(GL_VERTEX_ARRAY);
        gl.EnableClientState(GL_NORMAL_ARRAY);

        gl.NormalPointer(GL_FLOAT, SizeOf(TVertex), @(V^.Normal));
        gl.VertexPointer(3, GL_FLOAT, SizeOf(TVertex), @(V^.Coord));
        gl.DrawElements(GL_TRIANGLES, Length(Index), GL_UNSIGNED_SHORT,  Buffer[btIndex].DataPtr);

        gl.DisableClientState(GL_VERTEX_ARRAY);
        gl.DisableClientState(GL_NORMAL_ARRAY);

        Buffer[btIndex].Disable;
        Buffer[btVertex].Disable;

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

        gl.PopMatrix;
      end;
  if Input.Hit[KK_ESC] then
    CoreX.Quit;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
//  Screen.AntiAliasing := aa8x;
  CoreX.Start(@OnInit, @OnFree, @OnRender);
end.
