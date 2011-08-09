program reaxtor;

{$APPTYPE CONSOLE}

uses
  Windows,
  Messages,
  CoreX,
  xmd,
  xmt,
  xfn,
  xctrl;

type
  TDisplayCtrl = class(TControl)
    constructor Create;
    destructor Destroy; override;
  public
    Camera : TCamera;
    CDrag  : (cdNone, cdPos, cdRot, cdZoom);
    LDrag  : (ldNone, ldPosXZ, ldPosY);
    MPos   : TPoint;
    MState : array [ikMouseL..ikMouseM] of Boolean;
    procedure OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: LongInt);
    procedure OnMouseUp;
    procedure OnMouseMove(Shift: TShiftState; X, Y: LongInt);
    procedure CameraCenter;
    procedure OnRender; override;
  end;

var
  AnimTrack : TAnimTrack;

procedure SaveModel(Model: TModelNode; const FileName: string);
var
  Stream : TStream;
  i, Count : LongInt;
  M : TMat4f;
begin
  Stream := TStream.Init(FileName, True);
  if Stream <> nil then
  begin
    Count := Model.Count;
    Stream.Write(Count, SizeOf(Count));
    for i := 0 to Model.Count - 1 do
      with TMeshNode(Model.Nodes[i]) do
      begin
        M := RMatrix;
        Stream.Write(M, SizeOf(M));
        Stream.WriteAnsi(AnsiString(DeleteExt(Copy(Mesh.Data.Name, 1, Pos('-', Mesh.Data.Name) - 1))));
        Stream.WriteAnsi(AnsiString(DeleteExt(Mesh.Material.Name)));
      end;
    Stream.Free;
  end;
end;

{$REGION 'TDisplayCtrl'}
procedure TDisplayCtrl.CameraCenter;
var
  b : TBox;
  i : LongInt;
begin
  b.Min := Vec3f(10000, 10000, 10000);
  b.Max := b.Min * -1;
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].MeshURL <> '' then
    begin
      b.Min := b.Min.Min(Nodes[i].Mesh.BBox.Min);
      b.Max := b.Max.Max(Nodes[i].Mesh.BBox.Max);
      Camera.Pos := (b.Min + b.Max) * 0.5;
      Camera.Dist := b.Min.Dist(b.Max);
    end;
end;

constructor TDisplayCtrl.Create;
var
  i : LongInt;
  Model : TModelNode;
  ModelName : string;
  Stream : TStream;
begin
  inherited Create(GUI);
//  Width := 256;
//  Align := alClient;

  Camera.Init(cmTarget);
  Camera.Pos   := Vec3f(0, 1.75 / 2, 0);
  Camera.Dist  := 1.5;
  Camera.FOV   := 45;
  Camera.ZNear := 0.1;
  Camera.ZFar  := 500;
  Camera.Angle.y := 0;

  i := Render.Time;
  if ParamStr(1) <> '' then
  begin
    if ExtractFileDir(ParamStr(1)) <> '' then
      FileSys.PathAdd(ExtractFileDir(ParamStr(1)));
    Convert(ParamStr(1));
    ModelName := DeleteExt(ExtractFileName(ParamStr(1)));
  end else
  begin
    ModelName := 'tanya';
//    Convert('Lamborghini_Gallardo.dae');
    Convert(ModelName + '.dae');
    Convert('room_cube.dae');
  end;

  CameraCenter;
  Writeln('Total time: ', Render.Time - i, ' ms');

  Render.Ambient := Vec3f(0.1, 0.1, 0.1);

  Render.Light[0].Pos    := Vec3f(2, 2.3, 1.3);
  Render.Light[0].Color  := Vec3f(0.7, 0.7, 0.7);
  Render.Light[0].Radius := 10;

  Render.Light[1].Color  := Vec3f(0.3, 0.3, 0.3);
  Render.Light[1].Radius := 10000;

  Render.Light[2].Pos    := Vec3f(-5, 2, -5);
  Render.Light[2].Color  := Vec3f(0.2, 0.2, 0.2);
  Render.Light[2].Radius := 10000;

  Model := TModelNode.Create(ExtractFileName(ParamStr(1)));
  for i := 0 to Length(Nodes) - 1 do
    if Nodes[i].Mesh.Mesh <> nil then
      Model.Add(TMeshNode.Create(Nodes[i].Mesh.Mesh, Nodes[i].AMatrix));

  Model.Skeleton := TSkeleton.Load(Modelname);
  Model.ResetSkeleton;
  Stream := TStream.Init(ModelName + EXT_XAN);
  if Stream <> nil then
  begin
    Model.Skeleton.AddAnim(ModelName).Play(1, 0, lmRepeat);;
    Stream.Free;
  end;

  SaveModel(Model, 'cache/' + ModelName + '.xmd');
  Scene.Node.Add(Model);
end;

destructor TDisplayCtrl.Destroy;
begin
  inherited;
end;

procedure TDisplayCtrl.OnMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: LongInt);
begin
// camera drag
  if ssAlt in Shift then
    if ((CDrag = cdRot) and (Button = mbMiddle)) or
       ((CDrag = cdPos) and (Button = mbLeft)) then
      CDrag := cdZoom
    else
      if ((CDrag = cdZoom) and (Button = mbLeft)) or
         ((CDrag = cdRot) and (Button = mbRight)) or
         (Button = mbMiddle) then
        CDrag := cdPos
      else
        if Button = mbRight then
          CDrag := cdZoom
        else
          CDrag := cdRot;

// light source drag
  if ssCtrl in Shift then
    if Button = mbLeft then
      LDrag := ldPosXZ
    else
      if Button = mbRight then
        LDrag := ldPosY;

  GetCursorPos(MPos);
end;

procedure TDisplayCtrl.OnMouseUp;
begin
  CDrag := cdNone;
  LDrag := ldNone;
end;

procedure TDisplayCtrl.OnMouseMove(Shift: TShiftState; X, Y: LongInt);
const
  SENS_POS  = 0.025;
  SENS_ROT  = 0.5 * deg2rad;
  SENS_ZOOM = 0.003;
var
  D, L, U, v : TVec3f;
  Pos : TPoint;
begin
  GetCursorPos(Pos);

  if (CDrag <> cdNone) or (LDrag <> ldNone) then
  begin
    D.x := sin(pi - Camera.Angle.y) * cos(Camera.Angle.x);
    D.y := -sin(Camera.Angle.x);
    D.z := cos(pi - Camera.Angle.y) * cos(Camera.Angle.x);

    D := D.Normal;
    L := D.Cross(Vec3f(0, 1, 0));
    L := L.Normal;
    U := L.Cross(D);
    U := U.Normal;
  end;

  case CDrag of
    cdPos :
      begin
        v := Vec3f(0, 0, 0);
        v := v - L * ((Pos.X - MPos.x) * SENS_POS * Camera.Dist / 10);
        v := v + U * ((Pos.Y - MPos.y) * SENS_POS * Camera.Dist / 10);
        Camera.Pos := Camera.Pos + v;
      end;
    cdRot :
      begin
        Camera.Angle.x := Camera.Angle.x + (Pos.Y - MPos.Y) * SENS_ROT;
        Camera.Angle.y := Camera.Angle.y + (Pos.X - MPos.X) * SENS_ROT;
        Camera.Angle.x := Clamp(Camera.Angle.x, 0.01 - pi/2, pi/2 - 0.01);
      end;
    cdZoom :
      Camera.Dist := Max(0.01, Min(300, Camera.Dist * (1 - ((Pos.X - MPos.X) + (Pos.Y - MPos.Y)) * SENS_ZOOM)));
  end;

  case LDrag of
    ldPosXZ  :
      begin
        Render.Light[0].Pos := Render.Light[0].Pos + L * (Pos.X - MPos.X) * SENS_POS * (Camera.Dist / 10);
        Render.Light[0].Pos := Render.Light[0].Pos + U * (MPos.Y - Pos.Y) * SENS_POS * (Camera.Dist / 10);
      end;
    ldPosY   : Render.Light[0].Pos := Render.Light[0].Pos + D * (MPos.Y - Pos.Y) * SENS_POS * (Camera.Dist / 10);
  end;

  MPos := Pos;
end;

procedure TDisplayCtrl.OnRender;
var
  i : LongInt;
const
  ColorT : TVec3f = (x: 0.05; y: 0.05; z: 0.05);
  ColorB : TVec3f = (x: 0.50; y: 0.50; z: 0.50);
  MouseButton : array [ikMouseL..ikMouseM] of TMouseButton =
    (mbLeft, mbRight, mbMiddle);
var
  k : TInputKey;
  sh : TShiftState;
  vp : TRect;
begin
  vp := Render.Viewport;
  Render.Viewport := Rect;//CoreX.Rect(Rect.Left, Rect.Top, Width, Height);

  Render.Set2D(0, 1, 1, 0);
  Render.DepthTest := False;
  Render.ResetBind;
  {
  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.Color3fv(ColorT); gl.Vertex2f(0, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(0, 0);
    gl.Color3fv(ColorT); gl.Vertex2f(1, 1);
    gl.Color3fv(ColorB); gl.Vertex2f(1, 0);
  gl.Endp;
}
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

  Render.Camera := Camera;

//  LightPos := Vec3f(-696.5, 108.839, 298.473);
  Render.Light[1].Pos := Render.ViewPos;
  Scene.OnRender;
{
// Axis
  Render.Camera.Setup;
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

  gl.Enable(GL_POINT_SMOOTH);
  gl.PointSize(16);
  gl.Beginp(GL_POINTS);
    gl.Color3fv(Render.Light[0].Color); gl.Vertex3fv(Render.Light[0].Pos);
    gl.Color3fv(Render.Light[2].Color); gl.Vertex3fv(Render.Light[2].Pos);
  gl.Endp;

  gl.Beginp(GL_LINES);
    gl.Color3f(1, 0, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(1, 0, 0);
    gl.Color3f(0, 1, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 1, 0);
    gl.Color3f(0, 0, 1); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 0, 1);
  gl.Endp;
  Render.DepthWrite := True;
}
  if Input.Hit[ikSpace] then
  begin
    for i := 0 to Length(Nodes) - 1 do
      if Nodes[i].Material.Material <> nil then
        Nodes[i].Material.Material.Free;

    for i := 0 to Length(Nodes) - 1 do
      if Nodes[i].Material.Material <> nil then
      begin
        Nodes[i].Material.FxSkin := not Nodes[i].Material.FxSkin;
        Nodes[i].Material.Save('cache/' + Nodes[i].Material.Name);
        Nodes[i].Material.Material := TMaterial.Load('cache/' + Nodes[i].Material.Name);
        Nodes[i].Mesh.Mesh.Material := Nodes[i].Material.Material;
      end;
  end;

  if Input.Hit[ikF] then
    CameraCenter;

  Render.Viewport := vp;
  Render.ResetBind;
  Render.Set2D(0, Screen.Height, Screen.Width, 0);
end;
{$ENDREGION}

var
  Font : TFont;

procedure OnInit;
var
  Ctrl, Panel : TControl;
begin
  Screen.Resizing := True;
//  Screen.Resize(1024, 768);



//  FileSys.PathAdd('H:\Projects\N4\bin\data\texture\');

  Input.Capture := False;

  GUI.Texture := TTexture.Load('skin');
{
  Panel := TControl.Create(100, 100, 75, 24);
  GUI.AddCtrl(Panel);

// left
  Ctrl := TImage.Create(0, 0, 6, 9);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1, 1, 1 + 6, 1 + 9);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(0, 9, 6, -1 - 9 - 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1, 1 + 9, 1 + 6, 1 + 9 + 7);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(0, -8, 6, 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1, 1 + 9 + 7, 1 + 6, 1 + 9 + 7 + 8);
  Panel.AddCtrl(Ctrl);

// right
  Ctrl := TImage.Create(-5, 0, 5, 9);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 8, 1, 1 + 5 + 8, 1 + 9);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(-5, 9, 5, -1 - 9 - 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 8, 1 + 9, 1 + 5 + 8, 1 + 9 + 7);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(-5, -8, 5, 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 8, 1 + 9 + 7, 1 + 5 + 8, 1 + 9 + 7 + 8);
  Panel.AddCtrl(Ctrl);

// middle
  Ctrl := TImage.Create(6, 0, -5 - 6 - 1, 9);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 6 + 1, 1, 1 + 1 + 6, 1 + 9);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(6, 9, -5 - 6 - 1, -1 - 9 - 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 6 + 1, 1 + 9, 1 + 1 + 6, 1 + 9 + 7);
  Panel.AddCtrl(Ctrl);


  Ctrl := TImage.Create(6, -8, -5 - 6 - 1, 8);
  TImage(Ctrl).Texture := GUI.Texture;
  TImage(Ctrl).TexRect := Vec4f(1 + 6 + 1, 1 + 9 + 7, 1 + 1 + 6, 1 + 9 + 7 + 8);
  Panel.AddCtrl(Ctrl);
}


  Ctrl := TDisplayCtrl.Create;
//  Ctrl.Move(0, 0, 800, 600);
//  Ctrl.Align := alClient;
  GUI.AddCtrl(Ctrl);
{
  AnimTrack := TAnimTrack.Create(0, 0, 0, 32);
  AnimTrack.Align := alBottom;
  GUI.AddCtrl(AnimTrack);
 }
  {

  Ctrl := TFontTab.Create;
  Ctrl.Align := alClient;
  GUI.AddCtrl(Ctrl);
   }
//  Screen.Resize(1024, 768);
  Font := TFont.Load('Trebuchet_10b');
end;

procedure OnFree;
begin
  Font.Free;
end;

procedure OnRender;
begin
//  Sleep(10);
//  Render.Mode := rmShadow;
  Render.Clear(True, True);
  Scene.Shadows := True;
  GUI.OnRender;

// Statistics
  Render.Viewport := CoreX.Rect(0, 0, Screen.Width, Screen.Height);
  Render.ResetBind;
  Render.Set2D(0, Screen.Height, Screen.Width, 0);
  Render.DepthTest := False;
  Font.Print('FPS: ' + Conv(Render.FPS), 8, 8, Vec4f(1, 1, 1, 1), 1, 1, Vec4f(0, 0, 0.5, 0.5));
end;

begin
  FileSys.PathAdd('');
  FileSys.PathAdd('cache/');
  FileSys.PathAdd('media/');
  FileSys.PathAdd('media/tanya/');
  FileSys.PathAdd('media/sponza/');
  FileSys.PathAdd('media/Lamborghini Gallardo/');
  FileSys.PathAdd('media/nano_suit/');
  FileSys.PathAdd('media/landscape/');

  ReportMemoryLeaksOnShutdown := True;
  Screen.AntiAliasing := aa4x;
  CoreX.Start(@OnInit, @OnFree, @OnRender);
end.
