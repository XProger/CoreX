unit GameRPG;
{===========================================}
{             JRPG Game Sample              }
{-------------------------------------------}
{ Controls: Left, Right, Up, Down, Enter    }
{===========================================}

interface

uses
  Demos, CoreX;

implementation

var
  Suzaku : TSprite;
  PlayerDir : Integer;

procedure onInit;
begin
  Suzaku.Load('media/xrpg/suzaku.spr');
  Suzaku.Pos := Vec2f(0, 0);
end;

procedure onFree;
begin
  Suzaku.Free;
end;

procedure onRender;
const
  SPEED = 64;
  SDir : array [0..3] of Char = ('s', 'w', 'n', 'e');
begin
  Render.Clear(True, False);
  Render.Set2D(Screen.Width, Screen.Height);

  with Suzaku, Input do
  begin
    if Down[KK_DOWN] xor Down[KK_LEFT] xor Down[KK_RIGHT] xor Down[KK_UP] then
    begin
      if Down[KK_DOWN] then
        PlayerDir := 0;
      if Down[KK_LEFT] then
        PlayerDir := 1;
      if Down[KK_UP] then
        PlayerDir := 2;
      if Down[KK_RIGHT] then
        PlayerDir := 3;
    // Position
      case PlayerDir of
        0 : Pos.y := Pos.y - SPEED * Render.DeltaTime;
        1 : Pos.x := Pos.x - SPEED * Render.DeltaTime;
        2 : Pos.y := Pos.y + SPEED * Render.DeltaTime;
        3 : Pos.x := Pos.x + SPEED * Render.DeltaTime;
      end;
    // Animation
      Play('walk_' + SDir[PlayerDir], True);
    end else
      Play('idle_' + SDir[PlayerDir], True);
    Draw;
  end;
end;

initialization
  RegUnit(@onInit, @onFree, @onRender);

end.
