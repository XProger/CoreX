program CoreX_Demos;

{$APPTYPE CONSOLE}

uses
  CoreX,
  Demos,
  SpriteAnim,
  GameRPG;

{$IF DEFINED(WINDOWS) or DEFINED(WIN32)}
  {$APPTYPE CONSOLE}
  {$R icon.res}
{$IFEND}

begin
  CoreX.Start(@Demos.onInit, @Demos.onFree, @Demos.onRender);
end.
