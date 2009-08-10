unit GameRPG;
{===========================================}
{             JRPG Game Sample              }
{-------------------------------------------}
{ Controls: Left, Right, Up, Down, Enter    }
{===========================================}

interface

uses
  Demos, CoreX, Windows, Messages;

implementation

var
  Suzaku : TSprite;
  PlayerDir : Integer;

procedure onInit;
begin
  Suzaku.Load('media/xrpg/suzaku.spr');
  Suzaku.Pos := CoreX.Math.Vec2f(400, 300);
end;

procedure onFree;
begin
  Suzaku.Free;
end;

procedure onRender;
const
  SPEED = 64;
begin
  Render.Clear(True, False);
  Render.Set2D(Display.Width, Display.Height);

  with Suzaku, Input do
  begin
    if Down[KK_DOWN] xor Down[KK_LEFT] xor Down[KK_RIGHT] xor Down[KK_UP] then
    begin
      if Down[KK_DOWN] then
        PlayerDir := 0;
      if Down[KK_LEFT] then
        PlayerDir := 1;
      if Down[KK_RIGHT] then
        PlayerDir := 2;
      if Down[KK_UP] then
        PlayerDir := 3;
    // Position
      case PlayerDir of
        0 : Pos.y := Pos.y - SPEED * Render.DeltaTime;
        1 : Pos.x := Pos.x - SPEED * Render.DeltaTime;
        2 : Pos.x := Pos.x + SPEED * Render.DeltaTime;
        3 : Pos.y := Pos.y + SPEED * Render.DeltaTime;
      end;
    // Animation
      case PlayerDir of
        0 : Play('walk_s', True);
        1 : Play('walk_w', True);
        2 : Play('walk_e', True);
        3 : Play('walk_n', True);
      end;
    end else
      case PlayerDir of
        0 : Play('idle_s', True);
        1 : Play('idle_w', True);
        2 : Play('idle_e', True);
        3 : Play('idle_n', True);
      end;
    Draw;
  end;
end;

initialization
  RegUnit(@onInit, @onFree, @onRender);

end.
