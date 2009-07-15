program SpriteAnim;

{$APPTYPE CONSOLE}

uses
  CoreX;

{$R icon.res}

var
  Hero      : TSprite;
  Explosion : TSprite;

procedure onInit;
begin
  Display.VSync := False;

// Hero sprite
  Hero.Load('media/zero.spr');
  Hero.Pos := Math.Vec2f(400, 300);
// Explosion sprite
  Explosion.Load('media/explosion.spr');
end;

procedure onFree;
begin
  Explosion.Free;
  Hero.Free;
end;

procedure onRender;
begin
  Render.Clear(True, False);
  Render.Set2D(Display.Width, Display.Height);

  with Hero do
  begin
    if Input.Down[KK_RIGHT] xor Input.Down[KK_LEFT] then
    begin
      if Input.Down[KK_RIGHT] then
        Scale.x := +1
      else
        Scale.x := -1;
      Pos.x := Pos.x + Scale.x * Render.DeltaTime * 196;
      Play('run', True)
    end else
      Play('idle', True);
    Draw;
  end;

  if Input.Hit[KM_1] then
    with Explosion do
    begin
      with Input.Mouse.Pos do
        Pos := Math.Vec2f(X, Display.Height - Y);
      Stop;
      Play('boom', False);
    end;

  if Explosion.Playing then
    Explosion.Draw;

  if Input.Hit[KK_ESC] then
    CoreX.Quit;
end;

begin
//  ReportMemoryLeaksOnShutdown := True;
  CoreX.Start(@onInit, @onFree, @onRender);
end.
