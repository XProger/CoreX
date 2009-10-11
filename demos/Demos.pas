unit Demos;

interface

uses
  CoreX;

  procedure RegUnit(PInit, PFree, PRender: TCoreProc);
  procedure onInit;
  procedure onFree;
  procedure onRender;

implementation

var
  UnitReg : array of array [(upInit, upFree, upRender)] of TCoreProc;
  UnitIdx : Integer;

procedure RegUnit(PInit, PFree, PRender: TCoreProc);
var
  Count : Integer;
begin
  Count := Length(UnitReg);
  SetLength(UnitReg, Count + 1);
  UnitReg[Count][upInit]   := PInit;
  UnitReg[Count][upFree]   := PFree;
  UnitReg[Count][upRender] := PRender;
end;

procedure SetUnit(Idx: Integer);
begin
  Idx := Idx mod Length(UnitReg);
  UnitReg[UnitIdx][upFree];
  UnitIdx := Idx;
  UnitReg[UnitIdx][upInit];
end;

procedure onInit;
begin
  UnitReg[UnitIdx][upInit];
end;

procedure onFree;
begin
  UnitReg[UnitIdx][upFree];
end;

procedure onRender;
begin
  UnitReg[UnitIdx][upRender];
// Next demo
  if Input.Hit[KK_ENTER] then
    SetUnit(UnitIdx + 1);
// Close application
  if Input.Hit[KK_ESC] then
    CoreX.Quit;
end;

end.
