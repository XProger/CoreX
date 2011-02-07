unit xctrl;

interface

uses
  CoreX;

type
  TAnimTrack = class(TControl)
    FrameCount : LongInt;
    FrameIndex : LongInt;
    procedure OnRender; override;
  end;

implementation

procedure TAnimTrack.OnRender;
begin
  with Rect do
  begin
    gl.Beginp(GL_QUADS);
      gl.Color3f(1, 1, 1);
      gl.Vertex2f(Left, Top);
      gl.Vertex2f(Left, Bottom);
      gl.Vertex2f(Right, Bottom);
      gl.Vertex2f(Right, Top);
    gl.Endp;
  end;
end;

end.
