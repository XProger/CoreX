unit xmt;

interface

uses
  CoreX;

{$REGION 'Material format'}
type
  TNodeMaterial = record
    ShaderName : string;
    URL       : string;
    Name      : string;
    ShadeType : (stLambert, stPhong, stBlinn);
    Params    : TMaterialParams;
    Defines   : array of string;
    SamplerName : array [TMaterialSampler] of string;
    Material  : TMaterial;
    Skin      : Boolean;
    FxSkin    : Boolean;
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

var
  NodeMatList : TNodeMaterialArray;

  procedure GetMaterial(const XML: TXML; const URL: string; out NodeMaterial: TNodeMaterial);

implementation

uses
  xmd;

{$REGION 'TNodeMaterial'}
procedure TNodeMaterial.Save;
const
  SamplerDefine : array [TMaterialSampler] of string = (
    'MAP_DIFFUSE', 'MAP_NORMAL', 'MAP_SPECULAR', 'MAP_AMBIENT', 'MAP_EMISSION', 'MAP_ALPHAMASK', 'MAP_REFLECT', 'MAP_SHADOW',
    'MAP_MASK', 'MAP_MAP0', 'MAP_MAP1', 'MAP_MAP2', 'MAP_MAP3'
  );

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
  ms : TMaterialSampler;
  Stream : TStream;
  i, DCount : LongInt;
  Samplers : TMaterialSamplers;
begin
  Defines := nil;
// Set defines
  if Skin then
    AddDefine('SKIN');

  Samplers := [];
//  Writeln(Ord(ms));
  for ms := Low(ms) to High(ms) do
    if (SamplerName[ms] <> '') or ((ms = msShadow) and Params.ReceiveShadow) then
    begin
      AddDefine(SamplerDefine[ms]);
      Samplers := Samplers + [ms];
    end;
  Samplers := Samplers - [msShadow];

  if SamplerName[msReflect] <> '' then
    AddDefine('FX_REFLECT');

  if (SamplerName[msEmission] <> '') or (Params.Emission.LengthQ > EPS) then
    AddDefine('FX_EMISSION');

//  if ShadeType in [stPhong, stBlinn] then
    AddDefine('FX_SHADE');
//  AddDefine('FX_PLASTIC');

  case ShadeType of
    stPhong : AddDefine('FX_PHONG');
    stBlinn : AddDefine('FX_BLINN');
  end;

  if FxSkin then
    AddDefine('FX_SKIN');
//  AddDefine('FX_COLOR');

// Saving
  Stream := TStream.Init(FileName + EXT_XMT, True);
  if Stream <> nil then
  begin
    Stream.Write(Params, SizeOf(Params));
    Stream.WriteAnsi(AnsiString(ShaderName));
    DCount := Length(Defines);
    Stream.Write(DCount, SizeOf(DCount)); // Defines count
    for i := 0 to DCount - 1 do
      Stream.WriteAnsi(AnsiString(Defines[i]));
    Stream.Write(Samplers, SizeOf(Samplers));
    for ms := Low(ms) to High(ms) do
      if ms in Samplers then
        Stream.WriteAnsi(AnsiString(SamplerName[ms]));
    Stream.Free;
  end;
end;
{$ENDREGION}

{$REGION 'GetMaterial'}
procedure GetMaterial(const XML: TXML; const URL: string; out NodeMaterial: TNodeMaterial);

  function GetSampler(const XMLfx, XMLtex: TXML; var Sampler: TSamplerParams): string;
  var
    i : LongInt;
    s : string;
    Stream : TStream;
  begin
    Result := '';
    if XMLtex = nil then
      Exit;

    s := XMLtex.Params['texture'];
    with XMLfx['profile_COMMON'] do
    begin
      for i := 0 to Count - 1 do
        if (NodeI[i].Tag = 'newparam') and (NodeI[i].Params['sid'] = s) then
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
        if (NodeI[i].Tag = 'newparam') and (NodeI[i].Params['sid'] = s) then
        begin
          s := NodeI[i]['surface']['init_from'].Content;
          break;
        end;
    end;

  // sampler params
    if (XMLtex['extra'] <> nil) and (XMLtex['extra']['technique'] <> nil) then
      with XMLtex['extra']['technique'] do
      begin
        Sampler.OffsetUV.x := 0.0;
        Sampler.OffsetUV.y := 0.0;
        Sampler.RepeatUV.x := 1.0;
        Sampler.RepeatUV.y := 1.0;
        Sampler.RotateUV   := 0.0;
            {
        Sampler.OffsetUV.x := Conv(Node['offsetU'].Content, 0.0);
        Sampler.OffsetUV.y := Conv(Node['offsetV'].Content, 0.0);
        Sampler.RepeatUV.x := Conv(Node['repeatU'].Content, 1.0);
        Sampler.RepeatUV.y := Conv(Node['repeatV'].Content, 1.0);
        Sampler.RotateUV   := Conv(Node['rotateUV'].Content, 0.0);
        }
      end;
      
    with XML['library_images'] do
      for i := 0 to Count - 1 do
        if NodeI[i].Params['id'] = s then
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
  ms : TMaterialSampler;
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
        if Params['id'] = URL then
        begin
          NodeMaterial.Name := Params['name'];
          MatFX := ConvURL(Node['instance_effect'].Params['url']);
          break;
        end;
// read MatFX
  if MatFX <> '' then
    with XML['library_effects'] do
      for i := 0 to Count - 1 do
        if NodeI[i].Params['id'] = MatFX then
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

            with NodeMaterial do
            begin
              with Params do
              begin
                Mode       := rmOpaque;
                DepthWrite := True;
                AlphaTest  := 1;
                CullFace   := cfBack;
                BlendType  := btNormal;
                Diffuse    := Vec4f(1, 1, 1, 1);
                Emission   := Vec3f(0, 0, 0);
                Reflect    := 0.2;
                Specular   := Vec3f(1, 1, 1);
                Shininess  := 10;
              end;

              for ms := Low(Params.Sampler) to High(Params.Sampler) do
              begin
                SamplerName[ms] := '';
                with Params.Sampler[ms] do
                begin
                  RepeatUV := Vec2f(1, 1);
                  OffsetUV := Vec2f(0, 0);
                  RotateUV := 0;
                end;
              end;
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
                Str := GetSampler(XML['library_effects'].NodeI[i], Node['diffuse']['texture'], Params.Sampler[msDiffuse]);
                if Str <> '' then
                  SamplerName[msDiffuse] := Str;
                if Node['diffuse']['color'] <> nil then
                  Diffuse := TVec4f(Pointer(@ParseFloat(Node['diffuse']['color'].Content)[0])^);
              end;
            // Specular
              if Node['specular'] <> nil then
              begin
                SamplerName[msSpecular] := GetSampler(XML['library_effects'].NodeI[i], Node['specular']['texture'], Params.Sampler[msSpecular]);
                if (Node['specular'] <> nil) and (Node['specular']['color'] <> nil) then
                  Specular := TVec3f(Pointer(@ParseFloat(Node['specular']['color'].Content)[0])^)
                else
                  Specular := Vec3f(1, 1, 1);
              end;
            // Ambient
              if Node['ambient'] <> nil then
                SamplerName[msAmbient] := GetSampler(XML['library_effects'].NodeI[i], Node['ambient']['texture'], Params.Sampler[msAmbient]);
            // Emission
              if Node['emission'] <> nil then
              begin
                SamplerName[msEmission] := GetSampler(XML['library_effects'].NodeI[i], Node['emission']['texture'], Params.Sampler[msEmission]);
                if Node['emission']['color'] <> nil then
                  Emission := TVec3f(Pointer(@ParseFloat(Node['emission']['color'].Content)[0])^)
                else
                  Emission := Vec3f(1, 1, 1);
              end;
            // Reflect
              if Node['reflective'] <> nil then
                SamplerName[msReflect]  := GetSampler(XML['library_effects'].NodeI[i], Node['reflective']['texture'], Params.Sampler[msReflect]);
            // Transparent
              if (Node['transparency'] <> nil) and (Node['transparency']['float'] <> nil) then
                Diffuse.w := Diffuse.w * ParseFloat(Node['transparency']['float'].Content)[0];

              if Node['transparent'] <> nil then
              begin
                str := GetSampler(XML['library_effects'].NodeI[i], Node['transparent']['texture'],  Params.Sampler[msMask]);
                SamplerName[msMask] := str;
                if str <> '' then
                  Params.Mode := rmOpacity;
              end;
            end;
            if (Node['extra'] <> nil) and (Node['extra']['technique'] <> nil) then
              with Node['extra']['technique'] do
              begin
              // normal bump
                if (Node['bump'] <> nil) and (Node['bump']['texture'] <> nil) then
                  NodeMaterial.SamplerName[msNormal] := GetSampler(XML['library_effects'].NodeI[i], Node['bump']['texture'], NodeMaterial.Params.Sampler[msNormal]);
              // specular
                if (Node['spec_level'] <> nil) then
                begin
                  if Node['spec_level']['texture'] <> nil then
                    NodeMaterial.SamplerName[msSpecular] := GetSampler(XML['library_effects'].NodeI[i], Node['spec_level']['texture'], NodeMaterial.Params.Sampler[msSpecular]);
                  if Node['spec_level']['float'] <> nil then
                    NodeMaterial.Params.Specular := NodeMaterial.Params.Specular * ParseFloat(Node['spec_level']['float'].Content)[0];
                end;
              // emission
                if (Node['emission_level'] <> nil) and (Node['emission_level']['float'] <> nil) then
                  NodeMaterial.Params.Emission := NodeMaterial.Params.Emission * ParseFloat(Node['emission_level']['float'].Content)[0];
              end;
            break;
          end;

  NodeMaterial.SamplerName[msMask] := ''; // FIX!

  if NodeMaterial.Params.Diffuse.w < 1 - EPS then
    NodeMaterial.Params.Mode := rmOpacity;

  if (NodeMaterial.Params.Mode = rmOpacity) and (NodeMaterial.SamplerName[msMask] = '') then
  begin
    NodeMaterial.Params.BlendType := btNone;
    NodeMaterial.SamplerName[msAlphaMask] := 'amask';
  end;

  NodeMaterial.FxSkin := True;
  NodeMaterial.ShaderName := 'xshader';

  NodeMaterial.Params.CastShadow    := True;
  NodeMaterial.Params.ReceiveShadow := True;

// Add material to list
  SetLength(NodeMatList, Length(NodeMatList) + 1);
  NodeMatList[Length(NodeMatList) - 1] := NodeMaterial;
end;
{$ENDREGION}

end.
