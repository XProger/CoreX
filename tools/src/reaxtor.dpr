program reaxtor;

{$APPTYPE CONSOLE}

{$R reaxtor.res}

uses
  CoreX, xmd, // CommCtrl,
  Windows, Messages;

procedure InitCommonControls; stdcall; external comctl32;

type
  TWndProc = function (Handle, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;

  TTCItem = record
    mask        : LongWord;
    dwState     : LongWord;
    dwStateMask : LongWord;
    pszText     : PAnsiChar;
    cchTextMax  : LongInt;
    iImage      : LongInt;
    lParam      : LongInt;
  end;

const
  TCIF_TEXT = $0001;
  TCM_INSERTITEMA = $1307;

type
  TColorVertex = record
    Position : TVec3f;
    Color    : TVec4f;
  end;

var
  HDialog : LongWord;
  HTC, HSB, HPN, HDS : LongWord;
  HPN_VS, HPN_G1, HPN_G2 : LongWord;
  HPN_G1_TV, HPN_G2_LV : LongWord;

{$REGION 'Dialog'}
procedure TabAdd(Caption: PAnsiChar);
var
  Item : TTCItem;
begin
  FillChar(Item, SizeOf(Item), 0);
  Item.iImage  := -1;
  Item.mask    := TCIF_TEXT;
  Item.pszText := Caption;
  SendMessage(HTC, TCM_INSERTITEMA, 0, LongInt(@Item));
end;
{
function LVAdd(Handle: LongWord; const Caption: string; SubItem: LongInt = -1): LongInt;
var
  LVItem : TLVItem;
begin
  FillChar(LVItem, SizeOf(LVItem), 0);
  LVItem.mask     := LVIF_TEXT;
  LVItem.pszText  := PChar(Caption);
  if SubItem >= 0 then
  begin
    LVItem.iSubItem := SubItem;
    SendMessage(Handle, LVM_SETITEM, 0, LongInt(@LVItem));
  end else
    SendMessage(Handle, LVM_INSERTITEM, 0, LongInt(@LVItem));
end;

procedure LVInitMaterial;
var
  LVColumn : TLVColumn;
  i : LongInt;
begin
  SendMessage(HPN_G2_LV, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_CHECKBOXES );

  FillChar(LVColumn, SizeOf(LVColumn), 0);
  LVColumn.mask := LVCF_WIDTH;
  LVColumn.cx := 100;
  SendMessage(HPN_G2_LV, LVM_INSERTCOLUMN, 0, Longint(@LVColumn));
  LVColumn.cx := 50;
  SendMessage(HPN_G2_LV, LVM_INSERTCOLUMN, 1, Longint(@LVColumn));

  i := LVAdd(HPN_G2_LV, 'Di');
  LVAdd(HPN_G2_LV, 'Ta', 1);

  LVAdd(HPN_G2_LV, 'Normal Map');
  LVAdd(HPN_G2_LV, 'Specular Map');
  LVAdd(HPN_G2_LV, 'Light Map');
end;
}
procedure DialogResize;
var
  Rect   : TRect;
  SBHeight : LongInt;
  PNWidth  : LongInt;
  TCHeight : LongInt;
  Width, Height : LongInt;
begin
  GetClientRect(HDialog, Rect);
  Width  := Rect.Right - Rect.Left;
  Height := Rect.Bottom - Rect.Top;
// StatusBar
  GetWindowRect(HSB, Rect);
  SBHeight := (Rect.Bottom - Rect.Top);
  MoveWindow(HSB, 0, Height - SBHeight, Width, SBHeight, False);
// Panel
  GetWindowRect(HPN, Rect);
  PNWidth := Rect.Right - Rect.Left;
  MoveWindow(HPN, Width - PNWidth, 0, PNWidth, Height - SBHeight, False);

// Groups
  GetClientRect(HPN, Rect);
// Vertical scroll
  MoveWindow(HPN_VS, Rect.Right - 16, 0, 16, Rect.Bottom, False);
  MoveWindow(HPN_G1, 8, 16, Rect.Right - 32, 256, False);
  MoveWindow(HPN_G2, 8, 16 + 256, Rect.Right - 32, 300, False);
// Nodes tree
  GetClientRect(HPN_G1, Rect);
  MoveWindow(HPN_G1_TV, 8, 16, Rect.Right - 16, Rect.Bottom - 24, False);
// Material params
  GetClientRect(HPN_G2, Rect);
  MoveWindow(HPN_G2_LV, 8, 16, Rect.Right - 16, Rect.Bottom - 24, False);

// Tab Contol
  GetWindowRect(HTC, Rect);
  TCHeight := Rect.Bottom - Rect.Top;
  MoveWindow(HTC, 0, 0, Width - PNWidth, TCHeight, False);
// Display
  MoveWindow(HDS, 0, TCHeight, Width - PNWidth, Height - TCHeight - SBHeight, False);
  if Screen.Handle <> 0 then
    Screen.Resize(Width - PNWidth, Height - TCHeight - SBHeight);

  RedrawWindow(HDialog, nil, 0, RDW_ALLCHILDREN or RDW_FRAME or RDW_UPDATENOW or RDW_INVALIDATE or RDW_NOERASE);
end;

function DefProc(Handle, Msg: LongWord; WParam, LParam: LongInt): LongInt;
begin
  Result := TWndProc(GetWindowLong(Handle, GWL_USERDATA))(Handle, Msg, WParam, LParam);
end;

procedure DialogSetProc(Handle: LongWord; Proc: TWndProc);
begin
  SetWindowLong(Handle, GWL_USERDATA, SetWindowLong(Handle, GWL_WNDPROC, LongInt(@Proc)));
end;

function LVProc(Handle, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
begin
  if Msg = WM_NOTIFY then
{    with PNMLISTVIEW(LParam)^.hdr do}
      Writeln(Msg);
  Result := DefProc(Handle, Msg, WParam, LParam);
end;

function MainProc(Handle, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
begin
  case Msg of
    WM_COMMAND :
      if LOWORD(WParam) = 2 then
      begin
        PostQuitMessage(0);
        CoreX.Quit;
      end;
    WM_SIZE :
      if WParam <> SIZE_MINIMIZED then
        DialogResize;
              {
    WM_NOTIFY :
      begin
        Result := SendMessage(GetDlgItem(HDialog, wParam), Msg, WParam, LParam);
        Exit;
      end;   }
{
    WM_PAINT, WM_ERASEBKGND : Exit;

    WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX :
      begin
        Result := COLOR_WINDOW + 1;
        Exit;
      end;}
  end;
  Result := DefProc(Handle, Msg, WParam, LParam);
end;

function MaterialDialogProc(HDlg, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
begin
  case Msg of
    WM_INITDIALOG :
    begin
    //  SetWindowLong(HDlg, DWL_DLGPROC, 0);
    end;
  end;
      Result := 0;
//  Result := DefDlgProc(HDlg, Msg, WParam, LParam);
end;

function DialogProc(HDlg, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
begin
  case Msg of
    WM_INITDIALOG :
      begin
        HDialog := HDlg;
        HTC := GetDlgItem(HDialog, 11);
        HSB := GetDlgItem(HDialog, 12);
        HPN := GetDlgItem(HDialog, 13);
        HDS := GetDlgItem(HDialog, 14);
        HPN_VS := GetDlgItem(HDialog, 131);
        HPN_G1 := GetDlgItem(HDialog, 132);
        HPN_G2 := GetDlgItem(HDialog, 133);
        HPN_G1_TV := GetDlgItem(HDialog, 1321);
//        HPN_G2_LV := GetDlgItem(HDialog, 1331);

        HPN_G2_LV := CreateDialog(HInstance, MakeIntresource(2), 0, @MaterialDialogProc);

        SetParent(HPN_VS, HPN);
        SetParent(HPN_G1, HPN);
        SetParent(HPN_G2, HPN);
        SetParent(HPN_G1_TV, HPN_G1);
        SetParent(HPN_G2_LV, HPN_G2);
//        ShowWindow(HPN_G2_LV, SW_SHOW);
        TabAdd('Model');
        TabAdd('Terrain');
        TabAdd('Font');
        TabAdd('Pack');
//        LVInitMaterial;
{
        HTV := GetDlgItem(HDialog, 1010);
        HEB := GetDlgItem(HDialog, 1014);
        HRE := GetDlgItem(HDialog, 1011);
        HIP := GetDlgItem(HDialog, 1025);
        HSH := GetDlgItem(HDialog, 1020);
        HSV := GetDlgItem(HDialog, 1021);
        HST := GetDlgItem(HDialog, 1022);
      // TreeView
        SendMessage(HTV, TVM_SETIMAGELIST, 0, HIconList);
        SendMessage(HTV, TVM_SETINDENT, 0, 0);
      // Main Window
        SendMessage(HDialog, WM_SETICON, 1, LoadIcon(HInstance, MakeIntresource(1)));
      // Set messages callback
        DialogSetProc(HTV, ProcList);
        DialogSetProc(HEB, ProcEdit);
        DialogSetProc(HSH, ProcSplitter);
        DialogSetProc(HSV, ProcSplitter);
        DialogSetProc(HST, ProcSplitter);
        DialogResize;
}
//        DialogSetProc(HPN_G2_LV, LVProc);
        SetWindowLong(HDialog, DWL_DLGPROC, 0);
        DialogSetProc(HDialog, MainProc);
        MoveWindow(HDialog, (GetSystemMetrics(SM_CXSCREEN) - 1024) div 2,
                            (GetSystemMetrics(SM_CYSCREEN) - 768) div 2, 1024, 768, False);
      end;
  end;
  Result := 0;
end;
{$ENDREGION}

procedure OnInit;
begin
  DialogResize;
  Input.Capture := False;
  Render.CullFace := True;
  xmd.OnInit;
end;

procedure OnFree;
begin
  xmd.OnFree;
end;

procedure OnRender;
const
  ColorT : TVec3f = (x: 0.05; y: 0.05; z: 0.05);
  ColorB : TVec3f = (x: 0.50; y: 0.50; z: 0.50);
var
  Rect : TRect;
  W, H : LongInt;
begin
  if Input.Down[KM_L] then
  begin
    SetFocus(Screen.Handle);
//    SetCapture(Screen.Handle);
  end else
  ;//  ReleaseCapture;
  Sleep(10);

// Display metrics
  GetWindowRect(HDS, Rect);
  W := Rect.Right - Rect.Left;
  H := Rect.Bottom - Rect.Top;
  gl.Viewport(0, 0, W, H);

// Background
  Render.Clear(False, True);
  Render.Set2D(2, 2);
  Render.DepthTest := False;
  Render.ResetBind;
  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.Color3fv(ColorT); gl.Vertex2f(-1, +1);
    gl.Color3fv(ColorB); gl.Vertex2f(-1, -1);
    gl.Color3fv(ColorT); gl.Vertex2f(+1, +1);
    gl.Color3fv(ColorB); gl.Vertex2f(+1, -1);
  gl.Endp;

  Render.DepthTest := True;
  xmd.OnRender;

// Axis
  Render.ResetBind;
  gl.Beginp(GL_LINES);
    gl.Color3f(1, 0, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(1, 0, 0);
    gl.Color3f(0, 1, 0); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 1, 0);
    gl.Color3f(0, 0, 1); gl.Vertex3f(0, 0, 0); gl.Vertex3f(0, 0, 1);
  gl.Endp;
end;

begin
  ReportMemoryLeaksOnShutdown := True;

  InitCommonControls;
  CreateDialog(HInstance, MakeIntresource(1), 0, @DialogProc);

  Screen.Handle := HDS;
  CoreX.Start(@OnInit, @OnFree, @OnRender);

  EndDialog(HDialog, 0);
end.
