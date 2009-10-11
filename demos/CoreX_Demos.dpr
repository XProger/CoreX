program CoreX_Demos;

uses
  CoreX in '..\CoreX.pas',
  Demos in 'Demos.pas',
  SpriteAnim in 'SpriteAnim.pas',
  GameRPG in 'GameRPG.pas',
  Raytrace in 'Raytrace.pas';

{$IF DEFINED(WINDOWS) or DEFINED(WIN32)}
  {$APPTYPE CONSOLE}
  {$R icon.res}
{$IFEND}

begin
  CoreX.Start(@Demos.onInit, @Demos.onFree, @Demos.onRender);
end.
