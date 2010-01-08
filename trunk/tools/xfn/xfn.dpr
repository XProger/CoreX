program xfn;

{$APPTYPE CONSOLE}

uses
  CoreX, Windows;

var
  FontNames : TList;
  DC : LongWord;

  Texture : TTexture;

function FontNamesCompare(Item1, Item2: Pointer): LongInt;
begin
  if string(Item1) < string(Item2) then
    Result := -1
  else
    if string(Item1) > string(Item2) then
      Result := 1
    else
      Result := 0;
end;

procedure SortFontNames;
begin
  FontNames.Sort(@FontNamesCompare);
end;

function EnumFontsProc(var LFont: TLogFont; var TMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
var
  Name : string;
begin
  Name := LFont.lfFaceName;
  FontNames.Add(Pointer(Name));
  Pointer(Name) := nil; // dirty hack 8)
  Result := 1;
end;

procedure EnumFontNames;
begin
  FontNames.Init;
  EnumFontFamilies(DC, nil, @EnumFontsProc, 0);
end;

procedure FreeFontNames;
var
  i : LongInt;
  p : Pointer;
begin
  for i := 0 to FontNames.Count - 1 do
  begin
    p := FontNames.Items[i];
    string(p) := '';
  end;
end;

{
Procedure vidInit(Width, Height : Integer);
Var BInfo: tagBITMAPINFO;
Begin
  vidWidth:=Width;
  vidHeight:=Height;
  BInfo.bmiHeader.biSize:=SizeOf(tagBITMAPINFOHEADER);
  BInfo.bmiHeader.biWidth:=Width;
  BInfo.bmiHeader.biHeight:=-Height;
  BInfo.bmiHeader.biPlanes:=1;
  BInfo.bmiHeader.biBitCount:=32;
  BInfo.bmiHeader.biCompression:=BI_RGB;
  vidBitmap:=TBitmap.Create;
  vidBitmap.Handle:=CreateDIBSection(GetDC(MainForm.Handle), BInfo, DIB_RGB_COLORS, vidMemoryPointer, 0, 0);
  ZeroMemory(vidMemoryPointer, vidWidth*vidHeight*4);
End;

Procedure vidPutPixel(X, Y, Color : Integer);
Begin
  If (X>0) And (X<=vidWidth) And (Y>0) And (Y<=vidHeight) Then Buffer(vidMemoryPointer^)[(Y-1)*vidWidth+(X-1)]:=Color;
End;
}

procedure Generate(const Face: string; Size: LongInt; Bold, Italic: Boolean);
var
  Font : LongWord;
  Weight : LongInt;
  TM : TTextMetric;
  MDC : LongWord;
  BMP : LongWord;
  MaxWidth, MaxHeight : LongInt;
  Rect : TRect;
  BI   : TBitmapInfo;
  Data : Pointer;
  CSize : TSize;
begin
  if Bold then
    Weight := FW_BOLD
  else
    Weight := FW_NORMAL;

  Font := CreateFont(-MulDiv(Size, GetDeviceCaps(DC, LOGPIXELSY), 72), 0,
                     0, 0, Weight, 1, 0, 0, DEFAULT_CHARSET, 0, 0,
                     ANTIALIASED_QUALITY, 0, PChar(Face));
  if Font = 0 then
    Exit;

  MDC := CreateCompatibleDC(DC);
  SelectObject(MDC, Font);
  GetTextMetrics(MDC, TM);
  MaxWidth  := TM.tmMaxCharWidth;
  MaxHeight := TM.tmHeight;

  BMP := CreateCompatibleBitmap(DC, MaxWidth, MaxHeight);
// Fill Black
  SelectObject(MDC, BMP);
  SetRect(Rect, 0, 0, MaxWidth, MaxHeight);
  SetBkMode(MDC, TRANSPARENT);
  SetTextColor(MDC, $FFFFFF);
  Data := GetMemory(MaxWidth * MaxHeight * 3);
  ZeroMemory(@BI, SizeOf(BI));
  with BI.bmiHeader do
  begin
    biSize      := SizeOf(BI.bmiHeader);
    biWidth     := MaxWidth;
    biHeight    := MaxHeight;
    biPlanes    := 1;
    biBitCount  := 24;
    biSizeImage := biWidth * biHeight * biBitCount div 8;
  end;

  FillRect(MDC, Rect, GetStockObject(GRAY_BRUSH));

  GetTextExtentPoint(MDC, 'p', 1, CSize);
  TextOut(MDC, 0, 0, 'p', 1);

  GDIFlush;
  GetDIBits(MDC, BMP, 0, MaxHeight, Data, BI, DIB_RGB_COLORS);


  Texture.Init(MaxWidth, MaxHeight, Data, GL_RGB);
  FreeMemory(Data);

  DeleteObject(BMP);
  DeleteObject(Font);
  DeleteDC(MDC);
end;

procedure onInit;
var
  i : LongInt;
begin
  DC := GetDC(0);
  EnumFontNames;
  SortFontNames;
  Generate('Arial', 32, True, False);

  for i := 0 to FontNames.Count - 1 do
    Writeln(string(FontNames[i]));
end;

procedure onFree;
begin
  FreeFontNames;
  ReleaseDC(0, DC);
end;

procedure onRender;
begin
  Render.Clear(True, False);

  Render.Set2D(Screen.Width, Screen.Height);
  Texture.Enable;

  Render.Quad(-128, -128, Texture.Width, Texture.Height, 0, 0, 1, -1);

  Screen.Swap;
  Sleep(20);
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  CoreX.Start(@onInit, @onFree, @onRender);
end.
