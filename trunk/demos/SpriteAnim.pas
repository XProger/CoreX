unit SpriteAnim;
{===========================================}
{         Sprite Animation Demo             }
{-------------------------------------------}
{ Controls: Left, Right, Left Mouse Button  }
{===========================================}

interface

uses
  Demos, CoreX;

implementation

var
  Hero      : TSprite;
  Explosion : TSprite;
  Shot      : TSample;
  Engine    : TSample;

procedure onInit;
begin
// Hero sprite
  Hero.Load('media/zero.spr');
  Hero.Pos := Vec2f(0, 0);
// Explosion sprite
  Explosion.Load('media/explosion.spr');
  Shot.Load('media/explosion.wav');
  Engine.Load('media/engine.wav');
  Engine.Play(True);
end;

procedure onFree;
begin
  Engine.Free;
  Shot.Free;
  Explosion.Free;
  Hero.Free;
end;

procedure onRender;
begin
  Render.Clear(True, False);
  Render.Set2D(Screen.Width, Screen.Height);

  with Hero do
  begin
    if Input.Down[KK_RIGHT] xor Input.Down[KK_LEFT] then
    begin
      if Input.Down[KK_RIGHT] then
        Scale.x := +abs(Scale.x)
      else
        Scale.x := -abs(Scale.x);
      Pos.x := Pos.x + Scale.x * Render.DeltaTime * 196;
      Play('run', True)
    end else
      Play('idle', True);
    Draw;
  end;

  if Input.Hit[KM_L] then
    with Explosion do
    begin
      with Input.Mouse.Pos, Screen do
        Pos := Vec2f(X - Width div 2, Height - Y - Height div 2);
      Stop;
      Play('boom', False);
      Shot.Play;
    end;

  if Explosion.Playing then
    Explosion.Draw;

  if Input.Down[KK_UP] then
    Engine.Frequency := Clamp(Engine.Frequency + Trunc(Render.DeltaTime * 100000), 22000, 44100 * 10);
  if Input.Down[KK_DOWN] then
    Engine.Frequency := Clamp(Engine.Frequency - Trunc(Render.DeltaTime * 100000), 22000, 44100 * 10);
end;

initialization
  RegUnit(@onInit, @onFree, @onRender);

end.
