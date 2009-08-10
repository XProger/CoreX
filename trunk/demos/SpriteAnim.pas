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

procedure onInit;
begin
// Hero sprite
  Hero.Load('media/zero.spr');
  Hero.Pos := Math.Vec2f(400, 300);
// Explosion sprite
  Explosion.Load('media/explosion.spr');
  Shot := Sound.Load('media/explosion.wav');
end;

procedure onFree;
begin
  Shot.Free;
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
        Scale.x := +abs(Scale.x)
      else
        Scale.x := -abs(Scale.x);
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
      Shot.Play;
    end;

  if Explosion.Playing then
    Explosion.Draw;
end;

initialization
  RegUnit(@onInit, @onFree, @onRender);

end.
