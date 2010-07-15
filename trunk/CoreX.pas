unit CoreX;
{====================================================================}
{                 "CoreX" crossplatform game library                 }
{  Version : 0.03                                                    }
{  Mail    : xproger@list.ru                                         }
{  Site    : http://xproger.mentalx.org                              }
{====================================================================}
{ LICENSE:                                                           }
{ Copyright (c) 2010, Timur "XProger" Gagiev                         }
{ All rights reserved.                                               }
{                                                                    }
{ Redistribution and use in source and binary forms, with or without }
{ modification, are permitted under the terms of the BSD License.    }
{====================================================================}
interface

//{$DEFINE FPS_CAPTION}

//{$DEFINE NO_SOUND}
//{$DEFINE NO_GUI}
//{$DEFINE NO_SCENE}
//{$DEFINE NO_FILESYS}
//{$DEFINE NO_MATERIAL}
//{$DEFINE NO_MESH}
{$DEFINE NO_SPRITE}
{$DEFINE NO_INPUT_JOY}

{$IFDEF WIN32}
  {$DEFINE WINDOWS}
  {$SETPEFlAGS 1} // IMAGE_FILE_RELOCS_STRIPPED
{$ENDIF}

{$IF DEFINED(LINUX) OR DEFINED(DARWIN)}
  {$MACRO ON}
  {$DEFINE stdcall := cdecl} // For TGL
{$IFEND}

// Math ------------------------------------------------------------------------
{$REGION 'Math'}
type
  TVec3b = record
    x, y, z : ShortInt;
  end;

  TVec2ub = record
    x, y : Byte;
  end;

  TVec3ub = record
    x, y, z : Byte;
  end;

  TVec4ub = record
    x, y, z, w : Byte;
  end;

  TVec2s = record
    x, y : SmallInt;
  end;

  TVec3s = record
    x, y, z : SmallInt;
  end;

  TVec4s = record
    x, y, z, w : SmallInt;
  end;

  TVec2f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    x, y : Single;
  {$IFNDEF FPC}
    class operator Equal(const a, b: TVec2f): Boolean;
    class operator Add(const a, b: TVec2f): TVec2f;
    class operator Subtract(const a, b: TVec2f): TVec2f;
    class operator Multiply(const a, b: TVec2f): TVec2f;
    class operator Multiply(const v: TVec2f; x: Single): TVec2f;
  {$ENDIF}
    function Dot(const v: TVec2f): Single;
    function Reflect(const n: TVec2f): TVec2f;
    function Refract(const n: TVec2f; Factor: Single): TVec2f;
    function Length: Single;
    function LengthQ: Single;
    function Normal: TVec2f;
    function Dist(const v: TVec2f): Single;
    function DistQ(const v: TVec2f): Single;
    function Lerp(const v: TVec2f; t: Single): TVec2f;
    function Min(const v: TVec2f): TVec2f;
    function Max(const v: TVec2f): TVec2f;
    function Clamp(const MinClamp, MaxClamp: TVec2f): TVec2f;
    function Rotate(Angle: Single): TVec2f;
    function Angle(const v: TVec2f): Single;
  end;

  TVec3f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    x, y, z : Single;
  {$IFNDEF FPC}
    class operator Equal(const a, b: TVec3f): Boolean;
    class operator Add(const a, b: TVec3f): TVec3f;
    class operator Subtract(const a, b: TVec3f): TVec3f;
    class operator Multiply(const a, b: TVec3f): TVec3f;
    class operator Multiply(const v: TVec3f; x: Single): TVec3f;
  {$ENDIF}
    function Dot(const v: TVec3f): Single;
    function Cross(const v: TVec3f): TVec3f;
    function Reflect(const n: TVec3f): TVec3f;
    function Refract(const n: TVec3f; Factor: Single): TVec3f;
    function Length: Single;
    function LengthQ: Single;
    function Normal: TVec3f;
    function Dist(const v: TVec3f): Single;
    function DistQ(const v: TVec3f): Single;
    function Lerp(const v: TVec3f; t: Single): TVec3f;
    function Min(const v: TVec3f): TVec3f;
    function Max(const v: TVec3f): TVec3f;
    function Clamp(const MinClamp, MaxClamp: TVec3f): TVec3f;
    function Rotate(Angle: Single; const Axis: TVec3f): TVec3f;
    function Angle(const v: TVec3f): Single;
    function MultiOp(out r: TVec3f; const v1, v2, op1, op2: TVec3f): Single;
  end;

  TVec4f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    x, y, z, w : Single;
  {$IFNDEF FPC}
    class operator Equal(const a, b: TVec4f): Boolean;
    class operator Add(const a, b: TVec4f): TVec4f;
    class operator Subtract(const a, b: TVec4f): TVec4f;
    class operator Multiply(const a, b: TVec4f): TVec4f;
    class operator Multiply(const v: TVec4f; x: Single): TVec4f;
  {$ENDIF}
    function Dot(const v: TVec3f): Single;
    function Lerp(const v: TVec4f; t: Single): TVec4f;
  end;

  TQuat = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    x, y, z, w : Single;
  {$IFNDEF FPC}
    class operator Equal(const q1, q2: TQuat): Boolean;
    class operator Add(const q1, q2: TQuat): TQuat;
    class operator Subtract(const q1, q2: TQuat): TQuat;
    class operator Multiply(const q: TQuat; x: Single): TQuat;
    class operator Multiply(const q1, q2: TQuat): TQuat;
    class operator Multiply(const q: TQuat; const v: TVec3f): TVec3f;
  {$ENDIF}
    function Invert: TQuat; inline;
    function Lerp(const q: TQuat; t: Single): TQuat;
    function Dot(const q: TQuat): Single; inline;
    function Normal: TQuat;
    function Euler: TVec3f;
  end;

  TDualQuat = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
  private
    function GetPos: TVec3f;
  public
    Real, Dual : TQuat;
  {$IFNDEF FPC}
    class operator Multiply(const dq1, dq2: TDualQuat): TDualQuat;
  {$ENDIF}
    function Lerp(const dq: TDualQuat; t: Single): TDualQuat;
    property Pos: TVec3f read GetPos;
    property Rot: TQuat read Real;
  end;

  TMat4f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
  private
    function  GetPos: TVec3f;
    procedure SetPos(const v: TVec3f);
    function  GetRot: TQuat;
    procedure SetRot(const q: TQuat);
  public
    e00, e10, e20, e30,
    e01, e11, e21, e31,
    e02, e12, e22, e32,
    e03, e13, e23, e33: Single;
  {$IFNDEF FPC}
    class operator Add(const a, b: TMat4f): TMat4f;
    class operator Multiply(const a, b: TMat4f): TMat4f;
    class operator Multiply(const m: TMat4f; const v: TVec3f): TVec3f;
    class operator Multiply(const m: TMat4f; const v: TVec4f): TVec4f;
    class operator Multiply(const m: TMat4f; x: Single): TMat4f;
  {$ENDIF}
    procedure Identity;
    function Det: Single;
    function Inverse: TMat4f;
    function Transpose: TMat4f;
    procedure Translate(const v: TVec3f);
    procedure Rotate(Angle: Single; const Axis: TVec3f);
    procedure Scale(const v: TVec3f);
    procedure LookAt(const Pos, Target, Up: TVec3f);
    procedure Ortho(Left, Right, Bottom, Top, ZNear, ZFar: Single);
    procedure Frustum(Left, Right, Bottom, Top, ZNear, ZFar: Single);
    procedure Perspective(FOV, Aspect, ZNear, ZFar: Single);
    property Pos: TVec3f read GetPos write SetPos;
    property Rot: TQuat read GetRot write SetRot;
  end;

{$IFDEF FPC}
// TVec2f
  operator = (const a, b: TVec2f): Boolean;
  operator + (const a, b: TVec2f): TVec2f;
  operator - (const a, b: TVec2f): TVec2f;
  operator * (const a, b: TVec2f): TVec2f;
  operator * (const v: TVec2f; x: Single): TVec2f;
// TVec3f
  operator = (const a, b: TVec3f): Boolean;
  operator + (const a, b: TVec3f): TVec3f;
  operator - (const a, b: TVec3f): TVec3f;
  operator * (const a, b: TVec3f): TVec3f;
  operator * (const v: TVec3f; x: Single): TVec3f;
// TVec4f
  operator = (const a, b: TVec4f): Boolean;
  operator + (const a, b: TVec4f): TVec4f;
  operator - (const a, b: TVec4f): TVec4f;
  operator * (const a, b: TVec4f): TVec4f;
  operator * (const v: TVec4f; x: Single): TVec4f;
// TQuat
  operator = (const q1, q2: TQuat): Boolean;
  operator + (const q1, q2: TQuat): TQuat;
  operator - (const q1, q2: TQuat): TQuat;
  operator * (const q: TQuat; x: Single): TQuat;
  operator * (const q1, q2: TQuat): TQuat;
  operator * (const q: TQuat; const v: TVec3f): TVec3f;
// TDualQuat
  operator * (const dq1, dq2: TDualQuat): TDualQuat;
// TMat4f
  operator + (const a, b: TMat4f): TMat4f;
  operator * (const a, b: TMat4f): TMat4f;
  operator * (const m: TMat4f; const v: TVec3f): TVec3f;
  operator * (const m: TMat4f; const v: TVec4f): TVec4f;
  operator * (const m: TMat4f; x: Single): TMat4f;
{$ENDIF}

type
// 2D primitives
  TRay2f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Pos, Dir : TVec2f;
  end;

  TCircle = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Center : TVec2f;
    Radius : Single;
  end;

  TQuad = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Min, Max : TVec2f;
  end;

// 3D primitives
  TRay3f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Pos, Dir : TVec3f;
  end;

  TSphere = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Center : TVec3f;
    Radius : Single;
    function Intersect(const v: TVec3f): Boolean; overload;
    function Intersect(const Ray: TRay3f; out tMin, tMax: Single): Boolean; overload;
  end;

  TBox = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    Min, Max : TVec3f;
    function Intersect(const v: TVec3f): Boolean; overload;
    function Intersect(const Ray: TRay3f; out tMin, tMax: Single): Boolean; overload;
  end;

  TTriangle = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    A, B, C : TVec3f;
    function Intersect(const Ray: TRay3f; out u, v, t: Single; TwoSide: Boolean = False): Boolean;
  end;

const
  ONE     : Single = 1.0;
  INF     = 1 / 0;
  NAN     = 0 / 0;
  EPS     = 1.E-05;
  deg2rad = pi / 180;
  rad2deg = 180 / pi;
  NullVec2f : TVec2f = (x: 0; y: 0);
  NullVec3f : TVec3f = (x: 0; y: 0; z: 0);
  NullVec4f : TVec4f = (x: 0; y: 0; z: 0; w: 0);
  InfBox : TBox = (
    Min: (x: +INF; y: +INF; z: +INF);
    Max: (x: -INF; y: -INF; z: -INF)
  );

  function Vec2f(x, y: Single): TVec2f; inline;
  function Vec3b(x, y, z: ShortInt): TVec3b; inline;
  function Vec3ub(x, y, z: Byte): TVec3ub; inline;
  function Vec3s(x, y, z: SmallInt): TVec3s; inline;
  function Vec3f(x, y, z: Single): TVec3f; inline;
  function Vec4ub(x, y, z, w: Byte): TVec4ub; inline;
  function Vec4s(x, y, z, w: SmallInt): TVec4s; inline;
  function Vec4f(x, y, z, w: Single): TVec4f; inline;
  function Quat(x, y, z, w: Single): TQuat; overload; inline;
  function Quat(Angle: Single; const Axis: TVec3f): TQuat; overload;
  function DualQuat(const qRot: TQuat; const qPos: TVec3f): TDualQuat; inline;
  function Mat4f(Angle: Single; const Axis: TVec3f): TMat4f;
  function Min(x, y: LongInt): LongInt; overload; inline;
  function Min(x, y: Single): Single; overload; inline;
  function Max(x, y: LongInt): LongInt; overload; inline;
  function Max(x, y: Single): Single; overload; inline;
  function Clamp(x, Min, Max: LongInt): LongInt; overload; inline;
  function Clamp(x, Min, Max: Single): Single; overload; inline;
  function ClampAngle(Angle: Single): Single; inline;
  function Lerp(x, y, t: Single): Single; inline;
  function Sign(x: Single): LongInt;
  function Ceil(const x: Single): LongInt;
  function Floor(const x: Single): LongInt;
  function Tan(x: Single): Single; assembler;
  procedure SinCos(Theta: Single; out Sin, Cos: Single); assembler;
  function ArcTan2(y, x: Single): Single; assembler;
  function ArcCos(x: Single): Single; assembler;
  function ArcSin(x: Single): Single; assembler;
  function Log2(const X: Single): Single;
  function Pow(x, y: Single): Single;
  function ToPow2(x: LongInt): LongInt;
{$ENDREGION}

// Utils -----------------------------------------------------------------------
{$REGION 'Utils'}
type
  TResType = (rtTexture, rtTexture1, rtTexture2, rtTexture3, rtTexture4, rtTexture5, rtTexture6,
              rtTexture7, rtTexture8, rtTexture9, rtTexture10, rtTexture11, rtTexture12,
	      rtTexture13, rtTexture14, rtTexture15, rtShader, rtMeshIndex, rtMeshVertex, rtSound);

  TCharSet = set of AnsiChar;

  PRect = ^TRect;
  TRect = record
    Left, Top, Right, Bottom : LongInt;
  end;

  PDataArray = ^TDataArray;
  TDataArray = array [0..1] of SmallInt;

  PByteArray = ^TByteArray;
  TByteArray = array [0..1] of Byte;

  TRGBA = record
    R, G, B, A : Byte;
  end;

{ Stream }
  TStream = class
    class function Init(Memory: Pointer; MemSize: LongInt): TStream; overload;
    class function Init(const FileName: string; RW: Boolean = False): TStream; overload;
    destructor Destroy; override;
  private
    SType  : (stMemory, stFile);
    FSize  : LongInt;
    FPos   : LongInt;
    FBPos  : LongInt;
    F      : File;
    Mem    : Pointer;
    procedure SetPos(Value: LongInt);
  {$IFNDEF NO_FILESYS}
    procedure SetBlock(BPos, BSize: LongInt);
  {$ENDIF}
  public
    procedure CopyFrom(const Stream: TStream);
    function Read(out Buf; BufSize: LongInt): LongInt;
    function Write(const Buf; BufSize: LongInt): LongInt;
    function ReadAnsi: AnsiString;
    procedure WriteAnsi(const Value: AnsiString);
    function ReadUnicode: WideString;
    procedure WriteUnicode(const Value: WideString);
    property Size: LongInt read FSize;
    property Pos: LongInt read FPos write SetPos;
  end;

{ ConfigFile }
  TConfigFile = object
  private
    Data : array of record
      Category : string;
      Params   : array of record
          Name  : string;
          Value : string;
        end;
      end;
  public
    procedure Clear;
    procedure Load(const FileName: string);
    procedure Save(const FileName: string);
    procedure Write(const Category, Name, Value: string); overload;
    procedure Write(const Category, Name: string; Value: LongInt); overload;
    procedure Write(const Category, Name: string; Value: Single); overload;
    procedure Write(const Category, Name: string; Value: Boolean); overload;
    function Read(const Category, Name: string; const Default: string = ''): string; overload;
    function Read(const Category, Name: string; Default: LongInt = 0): LongInt; overload;
    function Read(const Category, Name: string; Default: Single = 0): Single; overload;
    function Read(const Category, Name: string; Default: Boolean = False): Boolean; overload;
    function CategoryName(Idx: LongInt): string;
  end;

{ XML }
  TXMLParam = record
    Name  : string;
    Value : string;
  end;

  TXMLParams = class
    constructor Create(const Text: string);
  private
    FCount  : LongInt;
    FParams : array of TXMLParam;
    function GetParam(const Name: string): TXMLParam;
    function GetParamI(Idx: LongInt): TXMLParam;
  public
    property Count: LongInt read FCount;
    property Param[const Name: string]: TXMLParam read GetParam; default;
    property ParamI[Idx: LongInt]: TXMLParam read GetParamI;
  end;

  TXML = class
    class function Load(const FileName: string): TXML;
    constructor Create(const Text: string; BeginPos: LongInt);
    destructor Destroy; override;
  private
    FCount   : LongInt;
    FNode    : array of TXML;
    FTag     : string;
    FContent : string;
    FDataLen : LongInt;
    FParams  : TXMLParams;
    function GetNode(const TagName: string): TXML;
    function GetNodeI(Idx: LongInt): TXML;
  public
    property Count: LongInt read FCount;
    property Tag: string read FTag;
    property Content: string read FContent;
    property DataLen: LongInt read FDataLen;
    property Params: TXMLParams read FParams;
    property Node[const TagName: string]: TXML read GetNode; default;
    property NodeI[Idx: LongInt]: TXML read GetNodeI;
  end;

{ Thread }
  TThreadProc = procedure (Param: Pointer); stdcall;

  TThread = object
    procedure Init(Proc: TThreadProc; Param: Pointer; Activate: Boolean = True);
    procedure Free;
  private
    FActive : Boolean;
    FDone   : Boolean;
    FProc   : TThreadProc;
    FParam  : Pointer;
    FHandle : LongWord;
    procedure SetActive(Value: Boolean);
    procedure SetCPUMask(Value: LongInt);
  public
    procedure Wait(ms: LongWord = 0); // WTF! ???
    property CPUMask: LongInt write SetCPUMask;
    property Active: Boolean read FActive write SetActive;
    property Done: Boolean read FDone;
  end;

  TThreadInfo = record
    Thread : ^TThread;
    Proc   : TThreadProc;
    Param  : Pointer;
  end;

{ TList }
  TListCompareFunc = function (Item1, Item2: Pointer): LongInt;

  TList = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
    procedure Init(Capacity: LongInt = 1);
    procedure Free(FreeClass: Boolean = False);
  private
    FItems    : array of Pointer;
    FCount    : LongInt;
    FCapacity : LongInt;
    procedure BoundsCheck(Index: LongInt);
    function GetItem(Index: LongInt): Pointer; inline;
    procedure SetItem(Index: LongInt; Value: Pointer); inline;
  public
    function IndexOf(Item: Pointer): LongInt;
    function Add(Item: Pointer): LongInt;
    procedure Delete(Index: LongInt; FreeClass: Boolean = False);
    procedure Insert(Index: LongInt; Item: Pointer);
    procedure Sort(CompareFunc: TListCompareFunc);
    property Count: LongInt read FCount;
    property Items[Index: LongInt]: Pointer read GetItem write SetItem; default;
  end;

  TResObject = class
    constructor Create(const Name: string);
    procedure Free;
  public
    Name : string;
    Ref  : LongInt;
  end;

const
  CRLF = #13#10;
  NullRect : TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

  function Rect(Left, Top, Right, Bottom: LongInt): TRect; inline;
  function RGBA(R, G, B, A: Byte): TRGBA; inline;
  function Conv(const Str: string; Def: LongInt = 0): LongInt; overload;
  function Conv(const Str: string; Def: Single = 0): Single; overload;
  function Conv(const Str: string; Def: Boolean = False): Boolean; overload;
  function Conv(Value: LongInt): string; overload;
  function Conv(Value: Single; Digits: LongInt = 6): string; overload;
  function Conv(Value: Boolean): string; overload;
  function LowerCase(const Str: string): string;
  function TrimChars(const Str: string; Chars: TCharSet): string;
  function Trim(const Str: string): string;
  function DeleteChars(const Str: string; Chars: TCharSet): string;
  function ExtractFileDir(const Path: string): string;
  function MemCmp(p1, p2: Pointer; Size: LongInt): LongInt;
{$ENDREGION}

// FileSys ---------------------------------------------------------------------
{$REGION 'FileSys'}
{$IFNDEF NO_FILESYS}
type
  TFilePack = object
  private
    FName  : string;
    FTable : array of record
        Pos, Size : LongInt;
        FileName  : string;
      end;
    procedure Init(const PackName: string);
  public
    function Open(const FileName: string; out Stream: TStream): Boolean;
    property Name: string read FName;
  end;

  TFileSys = object
  private
    FPack : array of TFilePack;
    FPath : array of string;
    procedure Init;
    function Open(const FileName: string; RW: Boolean = False): TStream;
  public
    procedure Clear;
    procedure PackAdd(const PackName: string);
    procedure PackDel(const PackName: string);
    procedure PathAdd(const PathName: string);
    procedure PathDel(const PathName: string);
  end;
{$ENDIF}
{$ENDREGION}

// Screen ----------------------------------------------------------------------
{$REGION 'Screen'}
type
  TAAType = (aa0x, aa1x, aa2x, aa4x, aa8x, aa16x);

  TScreen = object
  private
    FQuit   : Boolean;
    FX, FY  : LongInt;
    FWidth  : LongInt;
    FHeight : LongInt;
    FCustom : Boolean;
    FFullScreen   : Boolean;
    FAntiAliasing : TAAType;
    FVSync      : Boolean;
    FActive     : Boolean;
    FCaption    : string;
    FResizing   : Boolean;
    FFPSTime    : LongInt;
    FFPSIdx     : LongInt;
    CursorNone  : LongWord;
    CursorArrow : LongWord;
    procedure Init;
    procedure Free;
    procedure Update;
    procedure Restore;
    procedure SetFullScreen(Value: Boolean);
    procedure SetVSync(Value: Boolean);
    procedure SetCaption(const Value: string);
    procedure SetResizing(const Value: Boolean);
  public
    Handle : LongWord;
    procedure Resize(W, H: LongInt);
    procedure Swap;
    procedure ShowCursor(Value: Boolean);
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
    property FullScreen: Boolean read FFullScreen write SetFullScreen;
    property AntiAliasing: TAAType read FAntiAliasing write FAntiAliasing;
    property VSync: Boolean read FVSync write SetVSync;
    property Active: Boolean read FActive;
    property Caption: string read FCaption write SetCaption;
    property Resizing: Boolean read FResizing write SetResizing;
  end;
{$ENDREGION}

// Input -----------------------------------------------------------------------
{$REGION 'Input'}
  TInputKey = (
  // Keyboard
    ikNone, ikPlus, ikMinus, ikTilde,
    ik0, ik1, ik2, ik3, ik4, ik5, ik6, ik7, ik8, ik9,
    ikA, ikB, ikC, ikD, ikE, ikF, ikG, ikH, ikI, ikJ, ikK, ikL, ikM,
    ikN, ikO, ikP, ikQ, ikR, ikS, ikT, ikU, ikV, ikW, ikX, ikY, ikZ,
    ikF1, ikF2, ikF3, ikF4, ikF5, ikF6, ikF7, ikF8, ikF9, ikF10, ikF11, ikF12,
    ikEsc, ikEnter, ikBack, ikTab, ikShift, ikCtrl, ikAlt, ikSpace,
    ikPgUp, ikPgDown, ikEnd, ikHome, ikLeft, ikUp, ikRight, ikDown, ikIns, ikDel,
  // Mouse
    ikMouseL, ikMouseR, ikMouseM, ikMouseWheelUp, ikMouseWheelDown
  // Joystick
  {$IFNDEF NO_INPUT_JOY}
    , ikJoy1, ikJoy2, ikJoy3, ikJoy4, ikJoy5, ikJoy6, ikJoy7, ikJoy8, ikJoy9, ikJoy10, ikJoy11, ikJoy12, ikJoy13, ikJoy14, ikJoy15, ikJoy16
  {$ENDIF}
  );

  TMouseDelta = record
    X, Y, Wheel : LongInt;
  end;

  TMousePos = record
    X, Y : LongInt;
  end;

  TMouse = object
    Pos   : TMousePos;
    Delta : TMouseDelta;
  end;
{$IFNDEF NO_INPUT_JOY}
  TJoyAxis = record
    X, Y, Z, R, U, V : LongInt;
  end;

  TJoy = object
  private
    FReady : Boolean;
  public
    POV  : Single;
    Axis : TJoyAxis;
    property Ready: Boolean read FReady;
  end;
{$ENDIF}

  TInput = object
  private
    FCapture    : Boolean;
    FDown, FHit : array [TInputKey] of Boolean;
    FLastKey    : TInputKey;
    FText       : WideString;
    procedure Init;
    procedure Free;
    procedure Reset;
    function Convert(KeyCode: Word): TInputKey;
    function GetDown(InputKey: TInputKey): Boolean;
    function GetHit(InputKey: TInputKey): Boolean;
    procedure SetState(InputKey: TInputKey; Value: Boolean);
    procedure SetCapture(Value: Boolean);
  public
    Mouse : TMouse;
  {$IFNDEF NO_INPUT_JOY}
    Joy   : TJoy;
  {$ENDIF}
    procedure Update;
    property LastKey: TInputKey read FLastKey;
    property Down[InputKey: TInputKey]: Boolean read GetDown;
    property Hit[InputKey: TInputKey]: Boolean read GetHit;
    property Capture: Boolean read FCapture write SetCapture;
    property Text: WideString read FText;
  end;
{$ENDREGION}

// Sound -----------------------------------------------------------------------
{$REGION 'Sound'}
{$IFNDEF NO_SOUND}
  TBufferData = record
    L, R : SmallInt;
  end;
  PBufferArray = ^TBufferArray;
  TBufferArray = array [0..1] of TBufferData;

  PSmallIntArray = ^TSmallIntArray;
  TSmallIntArray = array [0..1] of SmallInt;

  TSample = class(TResObject)
    constructor Create(Size: LongInt; Data: PSmallIntArray); overload;
    class function Load(const FileName: string): TSample;
    destructor Destroy; override;
  private
    FVolume : LongInt;
    DLength : LongInt;
    Data    : PSmallIntArray;
    constructor Create(const FileName: string); overload;
    procedure SetVolume(Value: LongInt);
  public
    Frequency : LongInt;
    procedure Play(Loop: Boolean = False);
    property Volume: LongInt read FVolume write SetVolume;
  end;

  TChannel = record
    Sample  : TSample;
    Volume  : LongInt;
    Offset  : LongInt;
    Loop    : Boolean;
    Playing : Boolean;
  end;

  TDevice = object
  private
    FActive : Boolean;
    WaveOut : LongInt;
    Data    : Pointer;
    procedure Init;
    procedure Free;
  public
    property Active: Boolean read FActive;
  end;

  TSound = object
    procedure Init;
    procedure Free;
  private
    Device    : TDevice;
    Channel   : array [0..63] of TChannel;
    ChCount   : LongInt;
    procedure Render(Data: PBufferArray);
    procedure FreeChannel(Index: LongInt);
    function AddChannel(const Ch: TChannel): Boolean;
  end;
{$ENDIF}
{$ENDREGION}

// OpenGL ----------------------------------------------------------------------
{$REGION 'OpenGL'}
type
  TGLConst = (
  // AttribMask
    GL_DEPTH_BUFFER_BIT = $0100, GL_STENCIL_BUFFER_BIT = $0400, GL_COLOR_BUFFER_BIT = $4000,
  // Boolean
    GL_FALSE = 0, GL_TRUE,
  // Begin Mode
    GL_POINTS = 0, GL_LINES, GL_LINE_LOOP, GL_LINE_STRIP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_QUADS, GL_QUAD_STRIP, GL_POLYGON,
  // Alpha Function
    GL_NEVER = $0200, GL_LESS, GL_EQUAL, GL_LEQUAL, GL_GREATER, GL_NOTEQUAL, GL_GEQUAL, GL_ALWAYS,
  // Blending Factor
    GL_ZERO = 0, GL_ONE, GL_SRC_COLOR = $0300, GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_DST_COLOR = $0306, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA_SATURATE,
  // DrawBuffer Mode
    GL_NONE = 0, GL_FRONT = $0404, GL_BACK, GL_FRONT_AND_BACK = $0408,
  // Pixel params
    GL_UNPACK_ALIGNMENT = $0CF5,
  // Tests
    GL_DEPTH_TEST = $0B71, GL_STENCIL_TEST = $0B90, GL_ALPHA_TEST = $0BC0, GL_SCISSOR_TEST = $0C11,
  // GetTarget
    GL_CULL_FACE = $0B44, GL_BLEND = $0BE2,
  // Data Types
    GL_BYTE = $1400, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT, GL_INT, GL_UNSIGNED_INT, GL_FLOAT, GL_HALF_FLOAT = $140B, GL_UNSIGNED_SHORT_5_6_5 = $8363, GL_UNSIGNED_SHORT_4_4_4_4_REV = $8365, GL_UNSIGNED_SHORT_1_5_5_5_REV,
  // Matrix Mode
    GL_MODELVIEW = $1700, GL_PROJECTION, GL_TEXTURE,
  // Pixel Format
    GL_DEPTH_COMPONENT = $1902, GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA, GL_RGB, GL_RGBA, GL_LUMINANCE, GL_LUMINANCE_ALPHA, GL_DEPTH_COMPONENT16 = $81A5, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT32, GL_ALPHA8 = $803C, GL_LUMINANCE8 = $8040, GL_LUMINANCE8_ALPHA8 = $8045, GL_RGB8 = $8051, GL_RGBA8 = $8058, GL_BGR = $80E0, GL_BGRA, GL_RGB5 = $8050, GL_RGBA4 = $8056, GL_RGB5_A1 = $8057, GL_RG = $8227, GL_R16F = $822D, GL_R32F, GL_RG16F, GL_RG32F, GL_RGBA32F = $8814, GL_RGBA16F = $881A,
  // PolygonMode
    GL_POINT = $1B00, GL_LINE, GL_FILL,
  // Smooth
    GL_POINT_SMOOTH = $0B10, GL_LINE_SMOOTH = $0B20, GL_POLYGON_SMOOTH = $0B41,
  // List mode
    GL_COMPILE = $1300, GL_COMPILE_AND_EXECUTE,
  // Lighting
    GL_LIGHTING = $0B50, GL_LIGHT0 = $4000, GL_AMBIENT = $1200, GL_DIFFUSE, GL_SPECULAR, GL_POSITION, GL_SPOT_DIRECTION, GL_SPOT_EXPONENT, GL_SPOT_CUTOFF, GL_CONSTANT_ATTENUATION, GL_LINEAR_ATTENUATION, GL_QUADRATIC_ATTENUATION,
  // Material
    GL_COLOR_MATERIAL = $0B57,
  // StencilOp
    GL_KEEP = $1E00, GL_REPLACE, GL_INCR, GL_DECR,
  // GetString Parameter
    GL_VENDOR = $1F00, GL_RENDERER, GL_VERSION, GL_EXTENSIONS,
  // TextureEnvParameter
    GL_TEXTURE_ENV_MODE = $2200, GL_TEXTURE_ENV_COLOR,
  // TextureEnvTarget
    GL_TEXTURE_ENV = $2300,
  // Texture Filter
    GL_NEAREST = $2600, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST = $2700, GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_LINEAR, GL_TEXTURE_MAG_FILTER = $2800, GL_TEXTURE_MIN_FILTER,
  // Texture Wrap Mode
    GL_TEXTURE_WRAP_S = $2802, GL_TEXTURE_WRAP_T, GL_TEXTURE_WRAP_R = $8072, GL_REPEAT = $2901, GL_CLAMP_TO_EDGE = $812F, GL_TEXTURE_BASE_LEVEL = $813C, GL_TEXTURE_MAX_LEVEL,
  // Textures
    GL_TEXTURE_2D = $0DE1, GL_TEXTURE0 = $84C0, GL_TEXTURE_MAX_ANISOTROPY = $84FE, GL_MAX_TEXTURE_MAX_ANISOTROPY, GL_GENERATE_MIPMAP = $8191,
    GL_TEXTURE_CUBE_MAP = $8513, GL_TEXTURE_CUBE_MAP_POSITIVE_X = $8515, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
  // Compressed Textures
    GL_COMPRESSED_RGB_S3TC_DXT1 = $83F0, GL_COMPRESSED_RGBA_S3TC_DXT1, GL_COMPRESSED_RGBA_S3TC_DXT3, GL_COMPRESSED_RGBA_S3TC_DXT5,
  // FBO
    GL_FRAMEBUFFER = $8D40, GL_RENDERBUFFER, GL_COLOR_ATTACHMENT0 = $8CE0, GL_DEPTH_ATTACHMENT = $8D00, GL_FRAMEBUFFER_BINDING = $8CA6, GL_FRAMEBUFFER_COMPLETE = $8CD5,
  // Shaders
    GL_FRAGMENT_SHADER = $8B30, GL_VERTEX_SHADER, GL_GEOMETRY_SHADER = $8DD9, GL_GEOMETRY_VERTICES_OUT = $8DDA, GL_GEOMETRY_INPUT_TYPE, GL_GEOMETRY_OUTPUT_TYPE, GL_MAX_GEOMETRY_OUTPUT_VERTICES = $8DE0, GL_COMPILE_STATUS = $8B81, GL_LINK_STATUS, GL_VALIDATE_STATUS, GL_INFO_LOG_LENGTH,
  // VBO
    GL_ARRAY_BUFFER = $8892, GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY = $88B9, GL_STATIC_DRAW = $88E4, GL_VERTEX_ARRAY = $8074, GL_NORMAL_ARRAY, GL_COLOR_ARRAY, GL_INDEX_ARRAY_EXT, GL_TEXTURE_COORD_ARRAY,
  // Queries
    GL_SAMPLES_PASSED = $8914, GL_QUERY_COUNTER_BITS = $8864, GL_CURRENT_QUERY, GL_QUERY_RESULT, GL_QUERY_RESULT_AVAILABLE,
    GL_MAX_CONST = High(LongInt)
  );

  TGL = object
  private
    Lib : LongWord;
    procedure Init;
    procedure Free;
  public
    GetProc        : function (ProcName: PAnsiChar): Pointer; stdcall;
    SwapInterval   : function (Interval: LongInt): LongInt; stdcall;
    GetIntegerv    : procedure (pname: TGLConst; params: Pointer); stdcall;
    GetFloatv      : procedure (pname: TGLConst; params: Pointer); stdcall;
    GetString      : function (name: TGLConst): PAnsiChar; stdcall;
    Flush          : procedure;
    PolygonMode    : procedure (face, mode: TGLConst); stdcall;
    PixelStorei    : procedure (pname: TGLConst; param: LongInt); stdcall;
    GenTextures    : procedure (n: LongInt; textures: Pointer); stdcall;
    DeleteTextures : procedure (n: LongInt; textures: Pointer); stdcall;
    BindTexture    : procedure (target: TGLConst; texture: LongWord); stdcall;
    TexParameteri  : procedure (target, pname, param: TGLConst); stdcall;
    TexImage2D     : procedure (target: TGLConst; level: LongInt; internalformat: TGLConst; width, height, border: LongInt; format, _type: TGLConst; data: Pointer); stdcall;
    TexSubImage2D  : procedure (target: TGLConst; level, x, y, width, height: LongInt; format, _type: TGLConst; data: Pointer); stdcall;
    GetTexImage    : procedure (target: TGLConst; level: LongInt; format, _type: TGLConst; data: Pointer); stdcall;
    GenerateMipmap : procedure (target: TGLConst); stdcall;
    CopyTexSubImage2D    : procedure (target: TGLConst; level, xoffset, yoffset, x, y, width, height: LongInt); stdcall;
    CompressedTexImage2D : procedure (target: TGLConst; level: LongInt; internalformat: TGLConst; width, height, border, imageSize: LongInt; data: Pointer); stdcall;
    ActiveTexture        : procedure (texture: TGLConst); stdcall;
    ClientActiveTexture  : procedure (texture: TGLConst); stdcall;
    Clear          : procedure (mask: TGLConst); stdcall;
    ClearColor     : procedure (red, green, blue, alpha: Single); stdcall;
    ColorMask      : procedure (red, green, blue, alpha: Boolean); stdcall;
    DepthMask      : procedure (flag: Boolean); stdcall;
    StencilMask    : procedure (mask: LongWord); stdcall;
    Enable         : procedure (cap: TGLConst); stdcall;
    Disable        : procedure (cap: TGLConst); stdcall;
    CullFace       : procedure (mode: TGLConst); stdcall;
    AlphaFunc      : procedure (func: TGLConst; factor: Single); stdcall;
    BlendFunc      : procedure (sfactor, dfactor: TGLConst); stdcall;
    StencilFunc    : procedure (func: TGLConst; ref: LongInt; mask: LongWord); stdcall;
    DepthFunc      : procedure (func: TGLConst); stdcall;
    StencilOp      : procedure (fail, zfail, zpass: TGLConst); stdcall;
    Lightfv        : procedure (light, pname: TGLConst; params: Pointer); stdcall;
    Materialfv     : procedure (face, pname: TGLConst; params: Pointer); stdcall;
    Viewport       : procedure (x, y, width, height: LongInt); stdcall;
    Scissor        : procedure (x, y, width, height: LongInt); stdcall;
    Beginp         : procedure (mode: TGLConst); stdcall;
    Endp           : procedure;
    PointSize      : procedure (size: Single); stdcall;
    LineWidth      : procedure (width: Single); stdcall;
    Color3f        : procedure (r, g, b: Single); stdcall;
    Color3fv       : procedure (const rgb: TVec3f); stdcall;
    Color4ub       : procedure (r, g, b, a: Byte); stdcall;
    Color4ubv      : procedure (var rgba: TRGBA); stdcall;
    Color4f        : procedure (r, g, b, a: Single); stdcall;
    Color4fv       : procedure (const rgba: TVec4f); stdcall;
    Vertex2f       : procedure (x, y: Single); stdcall;
    Vertex2fv      : procedure (const xy: TVec2f); stdcall;
    Vertex3f       : procedure (x, y, z: Single); stdcall;
    Vertex3fv      : procedure (const xyz: TVec3f); stdcall;
    Normal3f       : procedure (x, y, z: Single); stdcall;
    Normal3fv      : procedure (const xyz: TVec3f); stdcall;
    TexCoord2f     : procedure (s, t: Single); stdcall;
    TexCoord2fv    : procedure (const st: TVec2f); stdcall;
    EnableClientState  : procedure (_array: TGLConst); stdcall;
    DisableClientState : procedure (_array: TGLConst); stdcall;
    DrawElements    : procedure (mode: TGLConst; count: LongInt; _type: TGLConst; const indices: Pointer); stdcall;
    DrawArrays      : procedure (mode: TGLConst; first, count: LongInt); stdcall;
    ColorPointer    : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    VertexPointer   : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    TexCoordPointer : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    NormalPointer   : procedure (type_: TGLConst; stride: LongWord; const P: Pointer); stdcall;
    MatrixMode      : procedure (mode: TGLConst); stdcall;
    LoadIdentity    : procedure;
    LoadMatrixf     : procedure (const m: TMat4f); stdcall;
    MultMatrixf     : procedure (const m: TMat4f); stdcall;
    PushMatrix      : procedure;
    PopMatrix       : procedure;
    Scalef          : procedure (x, y, z: Single); stdcall;
    Translatef      : procedure (x, y, z: Single); stdcall;
    Rotatef         : procedure (Angle, x, y, z: Single); stdcall;
    Ortho           : procedure (left, right, bottom, top, zNear, zFar: Double); stdcall;
    Frustum         : procedure (left, right, bottom, top, zNear, zFar: Double); stdcall;
    ReadPixels      : procedure (x, y, width, height: LongInt; format, _type: TGLConst; pixels: Pointer); stdcall;
    DrawBuffer      : procedure (mode: TGLConst); stdcall;
    ReadBuffer      : procedure (mode: TGLConst); stdcall;
  // VBO
    GenBuffers      : procedure (n: LongInt; buffers: Pointer); stdcall;
    DeleteBuffers   : procedure (n: LongInt; const buffers: Pointer); stdcall;
    BindBuffer      : procedure (target: TGLConst; buffer: LongWord); stdcall;
    BufferData      : procedure (target: TGLConst; size: LongInt; const data: Pointer; usage: TGLConst); stdcall;
    BufferSubData   : procedure (target: TGLConst; offset, size: LongInt; const data: Pointer); stdcall;
    MapBuffer       : function  (target, access: TGLConst): Pointer; stdcall;
    UnmapBuffer     : function  (target: TGLConst): Boolean; stdcall;
  // GLSL Shaders
    GetProgramiv      : procedure (_program: LongWord; pname: TGLConst; params: Pointer); stdcall;
    CreateProgram     : function: LongWord;
    DeleteProgram     : procedure (_program: LongWord); stdcall;
    LinkProgram       : procedure (_program: LongWord); stdcall;
    UseProgram        : procedure (_program: LongWord); stdcall;
    ProgramParameteri : procedure (_program: LongWord; pname: TGLConst; Value: LongInt); stdcall;
    GetProgramInfoLog : procedure (_program: LongWord; maxLength: LongInt; var length: LongInt; infoLog: PAnsiChar); stdcall;
    GetShaderiv       : procedure (_shader: LongWord; pname: TGLConst; params: Pointer); stdcall;
    CreateShader      : function  (shaderType: TGLConst): LongWord; stdcall;
    DeleteShader      : procedure (_shader: LongWord); stdcall;
    ShaderSource      : procedure (_shader: LongWord; count: LongInt; src: Pointer; len: Pointer); stdcall;
    AttachShader      : procedure (_program, _shader: LongWord); stdcall;
    CompileShader     : function  (_shader: LongWord): Boolean; stdcall;
    GetShaderInfoLog  : procedure (_shader: LongWord; maxLength: LongInt; var length: LongInt; infoLog: PAnsiChar); stdcall;
    GetUniformLocation  : function  (_program: LongWord; const ch: PAnsiChar): LongInt; stdcall;
    Uniform1iv          : procedure (location, count: LongInt; value: Pointer); stdcall;
    Uniform1fv          : procedure (location, count: LongInt; value: Pointer); stdcall;
    Uniform2fv          : procedure (location, count: LongInt; value: Pointer); stdcall;
    Uniform3fv          : procedure (location, count: LongInt; value: Pointer); stdcall;
    Uniform4fv          : procedure (location, count: LongInt; value: Pointer); stdcall;
    UniformMatrix3fv    : procedure (location, count: LongInt; transpose: Boolean; value: Pointer); stdcall;
    UniformMatrix4fv    : procedure (location, count: LongInt; transpose: Boolean; value: Pointer); stdcall;
    GetAttribLocation        : function  (_program: LongWord; const ch: PAnsiChar): LongInt; stdcall;
    EnableVertexAttribArray  : procedure (index: LongWord); stdcall;
    DisableVertexAttribArray : procedure (index: LongWord); stdcall;
    VertexAttribPointer      : procedure (index: LongWord; size: LongInt; _type: TGLConst; normalized: Boolean; stride: LongInt; const ptr: Pointer); stdcall;
  // FBO
    DrawBuffers             : procedure (n: LongInt; bufs: Pointer); stdcall;
    GenFramebuffers         : procedure (n: LongInt; framebuffers: Pointer); stdcall;
    DeleteFramebuffers      : procedure (n: LongInt; framebuffers: Pointer); stdcall;
    BindFramebuffer         : procedure (target: TGLConst; framebuffer: LongWord); stdcall;
    FramebufferTexture2D    : procedure (target, attachment, textarget: TGLConst; texture: LongWord; level: LongInt); stdcall;
    FramebufferRenderbuffer : procedure (target, attachment, renderbuffertarget: TGLConst; renderbuffer: LongWord); stdcall;
    CheckFramebufferStatus  : function  (target: TGLConst): TGLConst; stdcall;
    GenRenderbuffers        : procedure (n: LongInt; renderbuffers: Pointer); stdcall;
    DeleteRenderbuffers     : procedure (n: LongInt; renderbuffers: Pointer); stdcall;
    BindRenderbuffer        : procedure (target: TGLConst; renderbuffer: LongWord); stdcall;
    RenderbufferStorage     : procedure (target, internalformat: TGLConst; width, height: LongInt); stdcall;
  // Multisample
    SampleCoverage          : procedure (value: Single; invert: Boolean); stdcall;
  end;
{$ENDREGION}

// Camera ----------------------------------------------------------------------
{$REGION 'TCamera'}
  TCameraMode = (cmFree, cmTarget, cmLookAt);
  TCameraProj = (cpPersp, cpOrtho);

  TCamera = object
    procedure Init(CameraMode: TCameraMode = cmFree; CameraProj: TCameraProj = cpPersp);
  public
    Mode   : TCameraMode;
    Proj   : TCameraProj;
    Pos    : TVec3f;
    Target : TVec3f;
    Angle  : TVec3f;
    Dist   : Single;
    FOV    : Single;
    ZNear  : Single;
    ZFar   : Single;
    Planes : array [0..5] of TVec4f;
    ViewMatrix : TMat4f;
    ProjMatrix : TMat4f;
    ViewProjMatrix : TMat4f;
    procedure UpdateMatrix;
    procedure UpdatePlanes;
    procedure Setup;
    function Visible(const Box: TBox): Boolean; overload;
    function Visible(const Sphere: TSphere): Boolean; overload;
  end;
{$ENDREGION}

// Render ----------------------------------------------------------------------
{$REGION 'Render'}
const
  MAX_LIGHTS = 3;

type
  TBlendType = (btNone, btNormal, btAdd, btMult);

  TCullFace = (cfNone, cfFront, cfBack);

  TRenderSupport = (rsMT, rsVBO, rsFBO, rsGLSL, rsOQ);

  TTexture = class;
  TTextureTarget = (ttTex2D, ttTexCubeXp, ttTexCubeXn, ttTexCubeYp, ttTexCubeYn, ttTexCubeZp, ttTexCubeZn);

  TLight = record
    ShadowMap : TTexture;
    Matrix    : TMat4f;
    Pos    : TVec3f;
    Color  : TVec3f;
    Radius : Single;
  end;

  TRenderMode = (rmOpaque, rmOpacity, rmShadow);

  TRenderTargetType = (rtColor, rtDepth);

  TRenderChannel = (rcDepth, rcColor0, rcColor1, rcColor2, rcColor3, rcColor4, rcColor5, rcColor6, rcColor7);

  TRenderTarget = class
    constructor Create(Width, Height: LongInt; DepthBuffer: Boolean = True);
    destructor Destroy; override;
  private
    FrameBuf : LongWord;
    DepthBuf : LongWord;
    ChannelCount : LongInt;
    ChannelList  : array [0..Ord(High(TRenderChannel)) - 1] of TGLConst;
  public
    Texture : array [TRenderChannel] of TTexture;
    procedure Attach(Channel: TRenderChannel; Texture: TTexture; Target: TTextureTarget = ttTex2D);
  end;

  TRender = object
  private
    FVendor   : string;
    FRenderer : string;
    FVersion  : string;
    FCPUCount  : LongInt;
    OldTime    : LongInt;
    FFPS       : LongInt;
    SBuffer    : array [TRenderSupport] of Boolean;
    FMaxAniso  : LongInt;
    FViewport  : TRect;
//    FScissor   : array of TRect;
  // states
    FBlendType  : TBlendType;
    FAlphaTest  : Byte;
    FDepthTest  : Boolean;
    FDepthWrite : Boolean;
    FCullFace   : TCullFace;
    FTarget     : TRenderTarget;
    procedure Init;
    procedure Free;
    function GetViewport: TRect;
    procedure SetViewport(const Value: TRect);
    procedure SetScissor(const Value: TRect);
    procedure SetBlendType(Value: TBlendType);
    procedure SetAlphaTest(Value: Byte);
    procedure SetDepthTest(Value: Boolean);
    procedure SetDepthWrite(Value: Boolean);
    procedure SetCullFace(Value: TCullFace);
    procedure SetTarget(Value: TRenderTarget);
  public
    Mode        : TRenderMode;
    ModelMatrix : TMat4f;
    Ambient     : TVec3f;
    ViewPos     : TVec3f;
    Camera      : TCamera;
    Light       : array [0..MAX_LIGHTS - 1] of TLight;
    TexOffset   : TVec2f;
    Time        : LongInt;
    DeltaTime   : Single;
    FrameFlag   : Boolean;
    function QueryTime: LongInt;
    function Support(RenderSupport: TRenderSupport): Boolean;
    procedure ResetBind;
    procedure Update;
    procedure Clear(ClearColor, ClearDepth: Boolean);
    procedure Set2D(Width, Height: Single); overload;
    procedure Set2D(X, Y, Width, Height: Single); overload;
    procedure Set3D(FOV, Aspect: Single; zNear: Single = 0.1; zFar: Single = 1000);
    procedure Quad(x, y, w, h, s, t, sw, th: Single);
    property Vendor: string read FVendor;
    property Renderer: string read FRenderer;
    property Version: string read FVersion;
    property CPUCount: LongInt read FCPUCount;
    property FPS: LongInt read FFPS;
    property MaxAniso: LongInt read FMaxAniso;
    property Viewport: TRect read GetViewport write SetViewport;
    property Scissor: TRect write SetScissor;
    property BlendType: TBlendType write SetBlendType;
    property AlphaTest: Byte write SetAlphaTest;
    property DepthTest: Boolean write SetDepthTest;
    property DepthWrite: Boolean write SetDepthWrite;
    property CullFace: TCullFace write SetCullFace;
    property Target: TRenderTarget read FTarget write SetTarget;
  end;
{$ENDREGION}

// Physic ----------------------------------------------------------------------
{$REGION 'Physic'}

{$ENDREGION}

// Texture ---------------------------------------------------------------------
{$REGION 'Texture'}
  TTextureFilter = (tfNone, tfBilinear, tfTrilinear, tfAniso);

  TTexture = class(TResObject)
    constructor Create(Width, Height: LongInt; Data: Pointer = nil; CFormat: TGLConst = GL_RGBA; IFormat: TGLConst = GL_RGBA8; DFormat: TGLConst = GL_UNSIGNED_BYTE); overload;
    class function Load(const FileName: string): TTexture;
    destructor Destroy; override;
  private
    FID     : LongWord;
    FWidth  : LongInt;
    FHeight : LongInt;
    FFilter : TTextureFilter;
    FClamp  : Boolean;
    FMipMap : Boolean;
    Sampler : TGLConst;
    constructor Create(const FileName: string); overload;
    procedure SetFilter(Value: TTextureFilter);
    procedure SetClamp(Value: Boolean);
  public
    procedure GenLevels;
    procedure DataGet(Data: Pointer; Level: LongInt = 0; CFormat: TGLConst = GL_RGBA; DFormat: TGLConst = GL_UNSIGNED_BYTE);
    procedure DataSet(X, Y, Width, Height: LongInt; Data: Pointer; Level: LongInt = 0; CFormat: TGLConst = GL_RGBA; DFormat: TGLConst = GL_UNSIGNED_BYTE);
    procedure DataCopy(XOffset, YOffset, X, Y, Width, Height: LongInt; Level: LongInt = 0);
    procedure Bind(Channel: LongInt = 0);
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
    property Filter: TTextureFilter read FFilter write SetFilter;
    property Clamp: Boolean read FClamp write SetClamp;
  end;
{$ENDREGION}

// Shader ----------------------------------------------------------------------
{$REGION 'Shader'}
  TShaderUniformType = (utInt, utVec1, utVec2, utVec3, utVec4, utMat3, utMat4);
  TShaderAttribType  = (atVec1b, atVec2b, atVec3b, atVec4b,
                        atVec1s, atVec2s, atVec3s, atVec4s,
                        atVec1f, atVec2f, atVec3f, atVec4f);

  TShaderUniform = object
  private
    FID    : LongInt;
    FType  : TShaderUniformType;
    FName  : string;
    FValue : array [0..11] of Single;
    procedure Init(ShaderID: LongWord; const UName: string; UniformType: TShaderUniformType);
  public
    procedure Value(const Data; Count: LongInt = 1);
    property Name: string read FName;
  end;

  TShaderAttrib = object
  private
    FID   : LongInt;
    FType : TShaderAttribType;
    DType : TGLConst;
    FNorm : Boolean;
    Size  : LongInt;
    FName : string;
    procedure Init(ShaderID: LongWord; const AName: string; AttribType: TShaderAttribType; Norm: Boolean = False);
  public
    procedure Value(Stride: LongInt; const Data);
    property Name: string read FName;
    procedure Enable;
    procedure Disable;
  end;

  TShader = class(TResObject)
    class function Load(const FileName: string; const Defines: array of string): TShader;
    destructor Destroy; override;
  private
    FID      : LongWord;
    FUniform : array of TShaderUniform;
    FAttrib  : array of TShaderAttrib;
    constructor Create(const FileName: string; const Defines: array of string);
  public
    function Uniform(const UName: string; UniformType: TShaderUniformType): TShaderUniform;
    function Attrib(const AName: string; AttribType: TShaderAttribType; Norm: Boolean = False): TShaderAttrib;
    procedure Bind;
  end;
{$ENDREGION}

// Material --------------------------------------------------------------------
{$REGION 'Material'}
  TMaterialSampler  = (msDiffuse, msNormal, msSpecular, msAmbient, msEmission, msAlphaMask, msReflect, msShadow, msMask, msMap0, msMap1, msMap2, msMap3);
  TMaterialAttrib   = (maCoord, maBinormal, maNormal, maTexCoord0, maTexCoord1, maColor, maJoint);
  TMaterialUniform  = (muModelMatrix, muLightMatrix, muViewPos, muJoint, muLightPos, muLightParam, muAmbient, muMaterial, muTexOffset);

  TMaterialSamplers = set of TMaterialSampler;

{$IFNDEF NO_MATERIAL}

const
  SamplerID : array [TMaterialSampler] of record
      ID   : LongInt;
      Name : string;
    end = (
      (ID: 0; Name: 'sDiffuse'),
      (ID: 1; Name: 'sNormal'),
      (ID: 2; Name: 'sSpecular'),
      (ID: 3; Name: 'sAmbient'),
      (ID: 4; Name: 'sEmission'),
      (ID: 5; Name: 'sAlphaMask'),
      (ID: 6; Name: 'sReflect'),
      (ID: 7; Name: 'sShadow'),
      (ID: 0; Name: 'sMask'),
      (ID: 1; Name: 'sMap0'),
      (ID: 2; Name: 'sMap1'),
      (ID: 3; Name: 'sMap2'),
      (ID: 4; Name: 'sMap3')
    );

  AttribID : array [TMaterialAttrib] of record
      AType : TShaderAttribType;
      Norm  : Boolean;
      Name  : string;
    end = (
      (AType: atVec3f; Norm: False; Name: 'aCoord'),
      (AType: atVec4b; Norm: True;  Name: 'aBinormal'),
      (AType: atVec4b; Norm: True;  Name: 'aNormal'),
      (AType: atVec2s; Norm: False; Name: 'aTexCoord0'),
      (AType: atVec2s; Norm: False; Name: 'aTexCoord1'),
      (AType: atVec4b; Norm: True;  Name: 'aColor'),
      (AType: atVec4b; Norm: False; Name: 'aJoint')
    );

  UniformID : array [TMaterialUniform] of record
      UType : TShaderUniformType;
      Name  : string;
    end = (
      (UType: utMat4; Name: 'uModelMatrix'),
      (UType: utMat4; Name: 'uLightMatrix'),
      (UType: utVec3; Name: 'uViewPos'),
      (UType: utVec4; Name: 'uJoint'),
      (UType: utVec3; Name: 'uLightPos'),
      (UType: utVec4; Name: 'uLightParam'),
      (UType: utVec3; Name: 'uAmbient'),
      (UType: utVec4; Name: 'uMaterial'),
      (UType: utVec2; Name: 'uTexOffset')
    );

type
  TMaterialParams = packed record
    Mode          : TRenderMode;
    DepthWrite    : Boolean;
    AlphaTest     : Byte;
    CullFace      : TCullFace;
    BlendType     : TBlendType;
    CastShadow    : Boolean;
    ReceiveShadow : Boolean;
    case Integer of
      0 : (
          Diffuse   : TVec4f;
          Emission  : TVec3f;
          Reflect   : Single;
          Specular  : TVec3f;
          Shininess : Single;
        );
      1 : (Uniform : array [0..2] of TVec4f);
  end;

  TMaterial = class(TResObject)
    class function Load(const FileName: string): TMaterial;
    destructor Destroy; override;
  private
    constructor Create; overload;
    constructor Create(const FileName: string); overload;
  public
    ModeMat  : array [TRenderMode] of TMaterial;
    Samplers : TMaterialSamplers;
    Shader   : TShader;
    Texture  : array [0..15] of TTexture;
    Attrib   : array [TMaterialAttrib] of TShaderAttrib;
    Uniform  : array [TMaterialUniform] of TShaderUniform;
    Params   : TMaterialParams;
    procedure Bind;
  end;
{$ENDIF}
{$ENDREGION}

// Sprite ----------------------------------------------------------------------
{$REGION 'Sprite'}
{$IFNDEF NO_SPRITE}
  TSpriteAnim = object
  private
    FName    : string;
    FFrames  : LongInt;
    FX, FY   : LongInt;
    FWidth   : LongInt;
    FHeight  : LongInt;
    FCols    : LongInt;
    FCX, FCY : LongInt;
    FFPS     : LongInt;
  public
    property Name: string read FName;
    property Frames: LongInt read FFrames;
    property X: LongInt read FX;
    property Y: LongInt read FY;
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
    property Cols: LongInt read FCols;
    property CenterX: LongInt read FCX;
    property CenterY: LongInt read FCY;
    property FPS: LongInt read FFPS;
  end;

  TSpriteAnimList = object
  private
    FCount : LongInt;
    FItems : array of TSpriteAnim;
    function GetItem(Idx: LongInt): TSpriteAnim;
  public
    procedure Add(const Name: string; Frames, X, Y, W, H, Cols, CX, CY, FPS: LongInt);
    function IndexOf(const Name: string): LongInt;
    property Count: LongInt read FCount;
    property Items[Idx: LongInt]: TSpriteAnim read GetItem; default;
  end;

  TSprite = object
  private
    FPlaying  : Boolean;
    FLoop     : Boolean;
    FAnim     : TSpriteAnimList;
    Texture   : TTexture;
    BlendType : TBlendType;
    CurIndex  : LongInt;
    StartTime : LongInt;
    FVertex   : array of TVec2f;
    FCols, FRows : LongInt;
    function GetWidth: LongInt;
    function GetHeight: LongInt;
    function GetPlaying: Boolean;
    function GetVertex(x, y: LongInt): TVec2f;
    procedure SetVertex(x, y: LongInt; const v: TVec2f);
  public
    Pos   : TVec2f;
    Scale : TVec2f;
    Angle : Single;
    procedure Load(const FileName: string);
    procedure Free;
    procedure Grid(GCols, GRows: LongInt);
    procedure Play(const AnimName: string; Loop: Boolean);
    procedure Stop;
    procedure Draw;
    property Width: LongInt read GetWidth;
    property Height: LongInt read GetHeight;
    property Playing: Boolean read GetPlaying;
    property Anim: TSpriteAnimList read FAnim;
    property Cols: LongInt read FCols;
    property Rows: LongInt read FRows;
    property Vertex[x, y: LongInt]: TVec2f read GetVertex write SetVertex;
  end;
{$ENDIF}
{$ENDREGION}

// Skeleton --------------------------------------------------------------------
{$REGION 'Skeleton'}
  TLoopMode = (lmNone, lmLast, lmRepeat, lmPingPong);

  TAnimData = class(TResObject)
    class function Load(const FileName: string): TAnimData;
    constructor Create(const FileName: string);
  public
    Frame  : array of array of TDualQuat; // [JointIndex][FrameIndex]
    FCount : LongInt;
    FPS    : LongInt;
    JCount : LongInt;
    JName  : array of AnsiString;
  end;

  TSkeleton = class;

  TAnim = class
    class function Load(const FileName: string; Skeleton: TSkeleton): TAnim;
    destructor Destroy; override;
  private
    BlendWeight : Single;
    BlendTime   : Single;
    LoopMode    : TLoopMode;
    StartWeight : Single;
    StartTime   : LongInt;
    FramePrev  : LongInt;
    FrameNext  : LongInt;
    FrameDelta : Single;
    State : array of Boolean;
  public
    Data   : TAnimData;
    Weight : Single;
    Speed  : Single;
    Joint  : array of TDualQuat;
    Map    : array of LongInt;
    procedure Update;
    procedure LerpJoint(Idx: LongInt);
    procedure Play(BlendWeight, BlendTime: Single; LoopMode: TLoopMode = lmNone);
    procedure Stop(BlendTime: Single);
  end;

  TJointIndex = SmallInt;

  TJoint = packed record
    Parent : TJointIndex;
    Bind   : TDualQuat;
    Frame  : TDualQuat;
  end;

  TSkeletonData = class(TResObject)
    class function Load(const FileName: string): TSkeletonData;
    constructor Create(const FileName: string);
  public
    JCount : LongInt;
    JName  : array of AnsiString;
    Base   : array of TJoint;
  end;

  TSkeleton = class
    class function Load(const FileName: string): TSkeleton;
    destructor Destroy; override;
  private
    Parent      : TSkeleton;
    ParentJoint : TJointIndex;
    State : array of Boolean;
  public
    Data  : TSkeletonData;
    Anim  : array of TAnim;
    Joint : array of TDualQuat;
    function AddAnim(const Name: string): TAnim;
    procedure Update;
    procedure SetParent(Skeleton: TSkeleton; JointIndex: TJointIndex);
    procedure UpdateJoint(Idx: TJointIndex);
    function JointIndex(const JName: AnsiString): TJointIndex;
  end;
{$ENDREGION}

// Mesh ------------------------------------------------------------------------
{$REGION 'Mesh'}
  TBufferType = (btIndex, btVertex);

  TMeshBuffer = class
    constructor Create(BufferType: TBufferType; Count, Stride: LongInt; Data: Pointer);
    class function Load(BufferType: TBufferType; Stream: TStream): TMeshBuffer;
    destructor Destroy; override;
  private
    RType  : TResType;
    DType  : TGLConst;
    ID     : LongWord;
    FData  : Pointer;
  public
    Count  : LongInt;
    Stride : LongInt;
    procedure SetData(Offset, Size: LongInt; Data: Pointer);
    procedure Bind;
    property DataPtr: Pointer read FData;
  end;

{$IFNDEF NO_MESH}
  TMeshAttribs = set of TMaterialAttrib;
  TMeshJointNames = array of AnsiString;

  TMeshMode = (mmTriList, mmTriStrip, mmLine);

  TMeshData = class(TResObject)
    class function Init: TMeshData;
    class function Load(const FileName: string): TMeshData;
    destructor Destroy; override;
  public
    BBox    : TBox;
    Mode    : TMeshMode;
    Attrib  : TMeshAttribs;
    JName   : TMeshJointNames;
    Buffer  : array [TBufferType] of TMeshBuffer;
  end;

  TMesh = class
    constructor Create(MeshData: TMeshData);
    class function Load(const FileName: string): TMesh;
    destructor Destroy; override;
  private
    JIndex : array of TJointIndex;
    JQuat  : array of TDualQuat;
    FSkeleton : TSkeleton;
    FMaterial : TMaterial;
    procedure SetMaterial(Value: TMaterial);
    procedure SetSkeleton(Value: TSkeleton);
  public
    Data : TMeshData;
    procedure OnRender;
    property Material: TMaterial read FMaterial write SetMaterial;
    property Skeleton: TSkeleton read FSkeleton write SetSkeleton;
  end;
{$ENDIF}
{$ENDREGION}

// Font ------------------------------------------------------------------------
{$REGION 'Font'}
type
  PCharData = ^TCharData;
  TCharData = record
    ID   : WideChar;
    py   : Word;
    w, h : Word;
    tx, ty, tw, th : Single;
  end;

  TFont = class(TResObject)
    constructor Create(const Name: string);
    class function Load(const FileName: string): TFont;
    destructor Destroy; override;
  public
    Texture  : TTexture;
    Table    : array [WideChar] of PCharData;
    CharData : array of TCharData;
    procedure Print(const Text: WideString); overload;
    procedure Print(const Text: WideString; x, y: LongInt; const Color: TVec4f); overload;
    procedure Print(const Text: WideString; x, y: LongInt; const Color: TVec4f; sx, sy: LongInt; const SColor: TVec4f); overload;
  end;
{$ENDREGION}

// GUI -------------------------------------------------------------------------
{$REGION 'GUI'}
{$IFNDEF NO_GUI}
type
  TAlign = (alNone, alLeft, alRight, alTop, alBottom, alClient);
  TAnchors = set of (akLeft, akRight, akTop, akBottom);
  TShiftState = set of (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble);
  TMouseButton = (mbLeft, mbRight, mbMiddle);

  TControlParams = record
    Align   : TAlign;
    Anchors : TAnchors;
    Left    : LongInt;
    Top     : LongInt;
    Width   : LongInt;
    Height  : LongInt;
  end;

  TEventType = (etMouseDClick, etMouseWheel, etMouseDown, etMouseUp, etMouseMove, etMouseEnter, etMouseLeave,
                etChar, etKeyDown, etKeyUp,
                etSize);

  TMouseEvent = record
    Button : TMouseButton;
    Shift  : TShiftState;
    Pos    : TVec3s;
  end;

  TKeyboardEvent = record
    Shift : TShiftState;
    case Integer of
      0 : (Key  : Word);
      1 : (Char : WideChar);
  end;

  TSizeEvent = record
    Rect : TRect;
  end;

  TControlEvent = record
    case ID: TEventType of
      etMouseDClick, etMouseWheel, etMouseDown, etMouseUp, etMouseMove, etMouseEnter, etMouseLeave :
        (Mouse : TMouseEvent);
      etChar, etKeyDown, etKeyUp :
        (Keyboard : TKeyboardEvent);
      etSize :
        (Size : TSizeEvent);
  end;

  TControl = class
    constructor Create(Left, Top, Width, Height: LongInt);
    destructor Destroy; override;
  private
    FParent : TControl;
    Params  : TControlParams;
    procedure Resize(Left, Top, Width, Height: LongInt); virtual;
    procedure Realign;
    procedure SetAlign(const Value: TAlign);
    procedure SetAnchors(const Value: TAnchors);
    procedure SetLeft(const Value: LongInt);
    procedure SetTop(const Value: LongInt);
    procedure SetWidth(const Value: LongInt);
    procedure SetHeight(const Value: LongInt);
    function GetRect: TRect;
  public
    Tag      : LongInt;
    Visible  : Boolean;
    Enabled  : Boolean;
    Color    : TVec4f;
    Caption  : string;
    Controls : array of TControl;
    function AddCtrl(const Ctrl: TControl): TControl;
    function DelCtrl(const Ctrl: TControl): Boolean;
    procedure BringToFront;
    procedure OnRender; virtual;
    function OnEvent(const Event: TControlEvent): Boolean; virtual;
    property Parent: TControl read FParent;
    property Align: TAlign read Params.Align write SetAlign;
    property Anchors: TAnchors read Params.Anchors write SetAnchors;
    property Left: LongInt read Params.Left write SetLeft;
    property Top: LongInt read Params.Top write SetTop;
    property Width: LongInt read Params.Width write SetWidth;
    property Height: LongInt read Params.Height write SetHeight;
    property Rect: TRect read GetRect;
  end;

  TPanel = class(TControl)
    //
  end;

  TGUI = class(TControl)
    constructor Create(Left, Top, Width, Height: LongInt);
    destructor Destroy; override;
  public
    Skin : TTexture;
    procedure OnRender; override;
  end;
{$ENDIF}
{$ENDREGION}

// Scene -----------------------------------------------------------------------
{$REGION 'Scene'}
  TNode = class
    constructor Create(const Name: string);
    destructor Destroy; override;
  private
    FParent  : TNode;
    FRBBox   : TBox;
    FRMatrix : TMat4f;
    FMatrix  : TMat4f;
    FBBox    : TBox;
    procedure SetParent(const Value: TNode);
    procedure SetRMatrix(const Value: TMat4f);
    procedure SetMatrix(const Value: TMat4f);
    procedure UpdateBounds;
  public
    Name  : string;
    Nodes : array of TNode;
    function Add(Node: TNode): TNode; virtual;
    function Remove(Node: TNode): Boolean; virtual;
    function Count: LongInt;
    procedure OnRender; virtual;
    property Parent: TNode read FParent write SetParent;
    property RMatrix: TMat4f read FRMatrix write SetRMatrix;
    property Matrix: TMat4f read FMatrix write SetMatrix;
    property BBox: TBox read FBBox;
  end;

{$IFNDEF NO_SCENE}
  TScene = object
  private
    ShadowTex  : TTexture;
    ShadowRT   : TRenderTarget;
  public
    Node : TNode;
    Shadows : Boolean;
    procedure Init;
    procedure Load(const FileName: string);
    procedure Free;
    procedure OnRender;
  end;
{$ENDIF}
{$ENDREGION}

// Model -----------------------------------------------------------------------
{$REGION 'Model'}
{$IFNDEF NO_MESH}
  TMeshNode = class(TNode)
    class function Load(const FileName: string): TMeshNode;
    constructor Create(Mesh: TMesh; Matrix: TMat4f); overload;
    destructor Destroy; override;
  public
    Mesh : TMesh;
    procedure OnRender; override;
  end;
{$ENDIF}

  TModelNode = class(TNode)
    class function Load(const FileName: string): TModelNode;
    destructor Destroy; override;
  public
    Skeleton : TSkeleton;
    procedure OnRender; override;
    procedure ResetSkeleton;
  end;
{$ENDREGION}

// Terrain ---------------------------------------------------------------------
{$REGION 'Terrain'}

{$ENDREGION}

const
  EXT_XTX = '.dds';
  EXT_XSH = '.xsh';
  EXT_XMT = '.xmt';
  EXT_XFN = '.xfn';
  EXT_XMS = '.xms';
  EXT_XMD = '.xmd';
  EXT_XAN = '.xan';
  EXT_XSK = '.xsk';
  EXT_WAV = '.wav';

type
  TCoreProc = procedure;

var
{$IFNDEF NO_FILESYS}
  FileSys : TFileSys;
{$ENDIF}
  gl      : TGL;
  Screen  : TScreen;
  Input   : TInput;
{$IFNDEF NO_SOUND}
  Sound   : TSound;
{$ENDIF}
  Render  : TRender;
{$IFNDEF NO_GUI}
  GUI     : TGUI;
{$ENDIF}
{$IFNDEF NO_SCENE}
  Scene   : TScene;
{$ENDIF}

  procedure Init;
  procedure Free;
  procedure Start(PInit, PFree, PRender: TCoreProc);
  procedure Quit;
  procedure MsgBox(const Caption, Text: string);
  function Assert(const Error: string; Flag: Boolean = True): Boolean;

implementation

// System API ==================================================================
{$REGION 'Windows System'}
{$IFDEF WINDOWS}
// Windows API -----------------------------------------------------------------
type
  TMsg = array [0..6] of LongWord;

  TPoint = packed record
    X, Y : LongInt;
  end;

  TMinMaxInfo = packed record
    ptReserved     : TPoint;
    ptMaxSize      : TPoint;
    ptMaxPosition  : TPoint;
    ptMinTrackSize : TPoint;
    ptMaxTrackSize : TPoint;
  end;
  PMinMaxInfo = ^TMinMaxInfo;

  TPixelFormatDescriptor = packed record
    nSize        : Word;
    nVersion     : Word;
    dwFlags      : LongWord;
    iPixelType   : Byte;
    cColorBits   : Byte;
    SomeData1    : array [0..12] of Byte;
    cDepthBits   : Byte;
    cStencilBits : Byte;
    SomeData2    : array [0..14] of Byte;
  end;

  TDeviceMode = packed record
    SomeData1     : array [0..35] of Byte;
    dmSize        : Word;
    dmDriverExtra : Word;
    dmFields      : LongWord;
    SomeData2     : array [0..59] of Byte;
    dmBitsPerPel  : LongWord;
    dmPelsWidth   : LongWord;
    dmPelsHeight  : LongWord;
    SomeData3     : array [0..39] of Byte;
  end;

  TJoyCaps = packed record
    wMid, wPid   : Word;
    szPname      : array [0..31] of AnsiChar;
    wXmin, wXmax : LongWord;
    wYmin, wYmax : LongWord;
    wZmin, wZmax : LongWord;
    wNumButtons  : LongWord;
    wPMin, wPMax : LongWord;
    wRmin, wRmax : LongWord;
    wUmin, wUmax : LongWord;
    wVmin, wVmax : LongWord;
    wCaps        : LongWord;
    wMaxAxes     : LongWord;
    wNumAxes     : LongWord;
    wMaxButtons  : LongWord;
    szRegKey     : array [0..31] of AnsiChar;
    szOEMVxD     : array [0..259] of AnsiChar;
  end;

  TJoyInfo = packed record
    dwSize      : LongWord;
    dwFlags     : LongWord;
    wX, wY, wZ  : LongWord;
    wR, wU, wV  : LongWord;
    wButtons    : LongWord;
    dwButtonNum : LongWord;
    dwPOV       : LongWord;
    dwRes       : array [0..1] of LongWord;
  end;

  TWaveFormatEx = packed record
    wFormatTag      : Word;
    nChannels       : Word;
    nSamplesPerSec  : LongWord;
    nAvgBytesPerSec : LongWord;
    nBlockAlign     : Word;
    wBitsPerSample  : Word;
    cbSize          : Word;
  end;

  PWaveHdr = ^TWaveHdr;
  TWaveHdr = record
    lpData         : Pointer;
    dwBufferLength : LongWord;
    SomeData       : array [0..5] of LongWord;
  end;

  TRTLCriticalSection = array [0..5] of LongWord;

  TWndProc = function (Handle, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;

const
  kernel32            = 'kernel32.dll';
  user32              = 'user32.dll';
  gdi32               = 'gdi32.dll';
  opengl32            = 'opengl32.dll';
  winmm               = 'winmm.dll';
  WS_VISIBLE          = $10000000;
  WM_DESTROY          = $0002;
  WM_SIZE             = $0005;
  WM_ACTIVATEAPP      = $001C;
  WM_GETMINMAXINFO    = $0024;
  WM_SETICON          = $0080;
  WM_GETDLGCODE       = $0087;
  WM_KEYDOWN          = $0100;
  WM_CHAR             = $0102;
  WM_SYSKEYDOWN       = $0104;
  WM_LBUTTONDOWN      = $0201;
  WM_RBUTTONDOWN      = $0204;
  WM_MBUTTONDOWN      = $0207;
  WM_MOUSEWHEEL       = $020A;
  DLGC_WANTALLKEYS    = 4;
  SW_SHOW             = 5;
  SW_MINIMIZE         = 6;
  GWL_WNDPROC         = -4;
  GWL_STYLE           = -16;
  GWL_USERDATA        = -21;
  GCL_HCURSOR         = -12;
  JOYCAPS_HASZ        = $0001;
  JOYCAPS_HASR        = $0002;
  JOYCAPS_HASU        = $0004;
  JOYCAPS_HASV        = $0008;
  JOYCAPS_HASPOV      = $0010;
  JOYCAPS_POVCTS      = $0040;
  JOY_RETURNPOVCTS    = $0200;
  WOM_DONE            = $3BD;

  function QueryPerformanceFrequency(out Freq: Int64): Boolean; stdcall; external kernel32;
  function QueryPerformanceCounter(out Count: Int64): Boolean; stdcall; external kernel32;
  function LoadLibraryA(Name: PAnsiChar): LongWord; stdcall; external kernel32;
  function FreeLibrary(LibHandle: LongWord): Boolean; stdcall; external kernel32;
  function GetProcAddress(LibHandle: LongWord; ProcName: PAnsiChar): Pointer; stdcall; external kernel32;
  function MessageBoxA(hWnd: LongWord; lpText, lpCaption: PAnsiChar; uType: LongWord): LongInt; stdcall; external user32;
  function CreateWindowExW(dwExStyle: LongWord; lpClassName: PWideChar; lpWindowName: PWideChar; dwStyle: LongWord; X, Y, nWidth, nHeight: LongInt; hWndParent, hMenum, hInstance: LongWord; lpParam: Pointer): LongWord; stdcall; external user32;
  function DestroyWindow(hWnd: LongWord): Boolean; stdcall; external user32;
  function ShowWindow(hWnd: LongWord; nCmdShow: LongInt): Boolean; stdcall; external user32;
  function SetWindowLongW(hWnd: LongWord; nIndex, dwNewLong: LongInt): LongInt; stdcall; external user32;
  function GetWindowLongW(hWnd: LongWord; nIndex: LongInt): LongInt; stdcall; external user32;
  function SetFocus(hWnd: LongWord): LongWord; stdcall; external user32;
  function SetClassLongW(hWnd: LongWord; nIndex: LongInt; dwNewLong: Longint): LongWord; stdcall; external user32;
  function GetClassLongW(hWnd: LongWord; nIndex: LongInt): LongWord; stdcall; external user32;
  function AdjustWindowRect(var lpRect: TRect; dwStyle: LongWord; bMenu: Boolean): Boolean; stdcall; external user32;
  function SetWindowPos(hWnd, hWndInsertAfter: LongWord; X, Y, cx, cy: LongInt; uFlags: LongWord): Boolean; stdcall; external user32;
  function GetWindowRect(hWnd: LongWord; out lpRect: TRect): Boolean; stdcall; external user32;
  function GetClientRect(hWnd: LongWord; out lpRect: TRect): Boolean; stdcall; external user32;
  function GetCursorPos(out Point: TPoint): Boolean; stdcall; external user32;
  function SetCursorPos(X, Y: LongInt): Boolean; stdcall; external user32;
  function CreateCursor(hInst: LongWord; xHotSpot, yHotSpot, nWidth, nHeight: LongInt; pvANDPlaneter, pvXORPlane: Pointer): LongWord; stdcall; external user32;
  function ScreenToClient(hWnd: LongWord; var lpPoint: TPoint): Boolean; stdcall; external user32;
  function DefWindowProcW(hWnd, Msg: LongWord; wParam, lParam: LongInt): LongInt; stdcall; external user32;
  function PeekMessageW(out lpMsg: TMsg; hWnd, Min, Max, Remove: LongWord): Boolean; stdcall; external user32;
  function TranslateMessage(const lpMsg: TMsg): Boolean; stdcall; external user32;
  function DispatchMessageW(const lpMsg: TMsg): LongInt; stdcall; external user32;
  function SendMessageA(hWnd, Msg: LongWord; wParam, lParam: LongInt): LongInt; stdcall; external user32;
  function LoadIconA(hInstance: LongInt; lpIconName: PAnsiChar): LongWord; stdcall; external user32;
  function GetDC(hWnd: LongWord): LongWord; stdcall; external user32;
  function ReleaseDC(hWnd, hDC: LongWord): LongInt; stdcall; external user32;
  function SetWindowTextA(hWnd: LongWord; Text: PAnsiChar): Boolean; stdcall; external user32;
  function EnumDisplaySettingsA(lpszDeviceName: PAnsiChar; iModeNum: LongWord; lpDevMode: Pointer): Boolean; stdcall; external user32;
  function ChangeDisplaySettingsA(lpDevMode: Pointer; dwFlags: LongWord): LongInt; stdcall; external user32;
  function SetCapture(hWnd: LongWord): LongWord; stdcall; external user32;
  function ReleaseCapture: Boolean; stdcall; external user32;
  function SetPixelFormat(DC: LongWord; PixelFormat: LongInt; FormatDef: Pointer): Boolean; stdcall; external gdi32;
  function ChoosePixelFormat(DC: LongWord; p2: Pointer): LongInt; stdcall; external gdi32;
  function SwapBuffers(DC: LongWord): Boolean; stdcall; external gdi32;
// WGL
  function wglCreateContext(DC: LongWord): LongWord; stdcall; external opengl32;
  function wglMakeCurrent(DC, p2: LongWord): Boolean; stdcall; external opengl32;
  function wglDeleteContext(p1: LongWord): Boolean; stdcall; external opengl32;
  function wglGetProcAddress(ProcName: PAnsiChar): Pointer; stdcall; external opengl32;
// Joystick
  function joyGetNumDevs: LongWord; stdcall; external winmm;
  function joyGetDevCapsA(uJoyID: LongWord; lpCaps: Pointer; uSize: LongWord): LongWord; stdcall; external winmm;
  function joyGetPosEx(uJoyID: LongWord; lpInfo: Pointer): LongWord; stdcall; external winmm;
// Threads
  procedure InitializeCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure EnterCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure LeaveCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure DeleteCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  function CreateThread(lpThreadAttributes: Pointer; dwStackSize: LongWord; lpStartAddress: Pointer; lpParameter: Pointer; dwCreationFlags: LongWord; lpThreadId: Pointer): LongWord; stdcall; external kernel32;
  function TerminateThread(hThread: LongWord; dwExitCode: LongWord): Boolean; stdcall; external kernel32;
  function SuspendThread(hThread: LongWord): LongWord; stdcall; external kernel32;
  function ResumeThread(hThread: LongWord): LongWord; stdcall; external kernel32;
  procedure Sleep(dwMilliseconds: LongWord); stdcall; external kernel32;
  function SetThreadAffinityMask(hThread: LongWord; dwThreadAffinityMask: LongWord): LongWord; stdcall; external kernel32;
  function GetProcessAffinityMask(hProcess: LongWord; out lpProcessAffinityMask, lpSystemAffinityMask: LongWord): Boolean; stdcall; external kernel32;
  function GetCurrentProcess: LongWord; stdcall; external kernel32;
// Audio
  function waveOutOpen(WaveOut: Pointer; DeviceID: LongWord; Fmt, dwCallback, dwInstance: Pointer; dwFlags: LongWord): LongWord; stdcall; external winmm;
  function waveOutClose(WaveOut: LongWord): LongWord; stdcall; external winmm;
  function waveOutPrepareHeader(WaveOut: LongWord; WaveHdr: Pointer; uSize: LongWord): LongWord; stdcall; external winmm;
  function waveOutUnprepareHeader(WaveOut: LongWord; WaveHdr: Pointer; uSize: LongWord): LongWord; stdcall; external winmm;
  function waveOutWrite(WaveOut: LongWord; WaveHdr: Pointer; uSize: LongWord): LongWord; stdcall; external winmm;
  function waveOutReset(WaveOut: LongWord): LongWord; stdcall; external winmm;

const
  PFDAttrib : array [0..17] of LongWord = (
    $2042,  0, // WGL_SAMPLES
    $2041,  1, // WGL_SAMPLE_BUFFERS
    $2001,  1, // WGL_DRAW_TO_WINDOW
    $2010,  1, // WGL_SUPPORT_OPENGL
    $2011,  1, // WGL_DOUBLE_BUFFER
    $2014, 32, // WGL_COLOR_BITS
    $2022, 24, // WGL_DEPTH_BITS
    $2023,  8, // WGL_STENCIL_BITS
    0, 0);

  KeyCodes : array [ikPlus..ikDel] of Word =
     ($BB, $BD, $C0,
      $30, $31, $32, $33, $34, $35, $36, $37, $38, $39,
      $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A,
      $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B,
      $1B, $0D, $08, $09, $10, $11, $12, $20, $21, $22, $23, $24, $25, $26, $27, $28, $2D, $2E);

  SND_FREQ     = 22050;
  SND_BPP      = 16;
  SND_BUF_SIZE = 50 * SND_FREQ * (SND_BPP div 8) * 2 div 1000; // 40 ms latency

var
  DC, RC   : LongWord;
  TimeFreq  : Int64;
  TimeStart : Int64;
{$IFNDEF NO_INPUT_JOY}
  JoyCaps  : TJoyCaps;
  JoyInfo  : TJoyInfo;
{$ENDIF}
{$IFNDEF NO_SOUND}
  SoundDF  : TWaveFormatEx;
  SoundDB  : array [0..1] of TWaveHdr;
  SoundCS  : TRTLCriticalSection;
{$ENDIF}
{$ENDIF}
{$ENDREGION}

{$REGION 'Linux System'}
{$IFDEF LINUX}
// Linux API -------------------------------------------------------------------
{$LINKLIB GL}
{$LINKLIB X11}
{$LINKLIB Xrandr}
{$LINKLIB dl}
const
  opengl32  = 'libGL.so';

  KeyPress        = 2;
  ButtonPress     = 4;
  FocusIn         = 9;
  ClientMessage   = 33;

type
  PXSeLongWordAttributes = ^TXSeLongWordAttributes;
  TXSeLongWordAttributes = record
    background_pixmap     : LongWord;
    background_pixel      : LongWord;
    SomeData1             : array [0..6] of LongInt;
    save_under            : Boolean;
    event_mask            : LongInt;
    do_not_propagate_mask : LongInt;
    override_redirect     : Boolean;
    colormap              : LongWord;
    cursor                : LongWord;
  end;

  PXVisualInfo = ^XVisualInfo;
  XVisualInfo = record
    visual        : Pointer;
    visualid      : LongWord;
    screen        : LongInt;
    depth         : LongInt;
    SomeData1     : array [0..5] of LongInt;
  end;

  TXColor = array [0..11] of Byte;

  PXSizeHints = ^TXSizeHints;
  TXSizeHints = record
    flags        : LongInt;
    x, y, w, h   : LongInt;
    min_w, min_h : LongInt;
    max_w, max_h : LongInt;
    SomeData1    : array [0..8] of LongInt;
  end;

  TXClientMessageEvent = record
    message_type : LongWord;
    format       : LongInt;
    data         : record l: array[0..4] of LongInt; end;
  end;

  TXKeyEvent = record
    Root, Subwindow, Time : LongWord;
    x, y, XRoot, YRoot    : LongInt;
    State, KeyCode        : LongWord;
    SameScreen            : Boolean;
  end;

  PXEvent = ^TXEvent;
  TXEvent = record
    _type      : LongInt;
    serial     : LongWord;
    send_event : Boolean;
    display    : Pointer;
    xwindow    : LongWord;
    case LongInt of
      0 : (pad     : array [0..18] of LongInt);
      1 : (xclient : TXClientMessageEvent);
      2 : (xkey    : TXKeyEvent);
  end;

  PXRRScreenSize = ^TXRRScreenSize;
  TXRRScreenSize = record
    width, height   : LongInt;
    mwidth, mheight : LongInt;
  end;

  TTimeVal = record
    tv_sec   : LongInt;
    tv_usec : LongInt;
  end;

  function XDefaultScreen(Display: Pointer): LongInt; cdecl; external;
  function XRootWindow(Display: Pointer; ScreenNumber: LongInt): LongWord; cdecl; external;
  function XOpenDisplay(DisplayName: PAnsiChar): Pointer; cdecl; external;
  function XCloseDisplay(Display: Pointer): Longint; cdecl; external;
  function XBlackPixel(Display: Pointer; ScreenNumber: LongInt): LongWord; cdecl; external;
  function XCreateColormap(Display: Pointer; W: LongWord; Visual: Pointer; Alloc: LongInt): LongWord; cdecl; external;
  function XCreateWindow(Display: Pointer; Parent: LongWord; X, Y: LongInt; Width, Height, BorderWidth: LongWord; Depth: LongInt; AClass: LongWord; Visual: Pointer; ValueMask: LongWord; Attributes: PXSeLongWordAttributes): LongWord; cdecl; external;
  function XDestroyWindow(Display: Pointer; W: LongWord): LongInt; cdecl; external;
  function XStoreName(Display: Pointer; Window: LongWord; _Xconst: PAnsiChar): LongInt; cdecl; external;
  function XInternAtom(Display: Pointer; Names: PAnsiChar; OnlyIfExists: Boolean): LongWord; cdecl; external;
  function XSetWMProtocols(Display: Pointer; W: LongWord; Protocols: Pointer; Count: LongInt): LongInt; cdecl; external;
  function XMapWindow(Display: Pointer; W: LongWord): LongInt; cdecl; external;
  function XFree(Data: Pointer): LongInt; cdecl; external;
  procedure XSetWMNormalHints(Display: Pointer; W: LongWord; Hints: PXSizeHints); cdecl; external;
  function XPending(Display: Pointer): LongInt; cdecl; external;
  function XNextEvent(Display: Pointer; EventReturn: PXEvent): Longint; cdecl; external;
  procedure glXWaitX; cdecl; external;
  function XCreatePixmap(Display: Pointer; W: LongWord; Width, Height, Depth: LongWord): LongWord; cdecl; external;
  function XCreatePixmapCursor(Display: Pointer; Source, Mask: LongWord; FColor, BColor: Pointer; X, Y: LongWord): LongWord; cdecl; external;
  function XLookupKeysym(para1: Pointer; para2: LongInt): LongWord; cdecl; external;
  function XDefineCursor(Display: Pointer; W: LongWord; Cursor: LongWord): Longint; cdecl; external;
  function XWarpPointer(Display: Pointer; SrcW, DestW: LongWord; SrcX, SrcY: LongInt; SrcWidth, SrcHeight: LongWord; DestX, DestY: LongInt): LongInt; cdecl; external;
  function XQueryPointer(Display: Pointer; W: LongWord; RootRetun, ChildReturn, RootXReturn, RootYReturn, WinXReturn, WinYReturn, MaskReturn: Pointer): Boolean; cdecl; external;
  function XGrabKeyboard(Display: Pointer; GrabWindow: LongWord; OwnerEvents: Boolean; PointerMode, KeyboardMode: LongInt; Time: LongWord): LongInt; cdecl; external;
  function XGrabPointer(Display: Pointer; GrabWindow: LongWord; OwnerEvents: Boolean; EventMask: LongWord; PointerMode, KeyboardMode: LongInt; ConfineTo, Cursor, Time: LongWord): LongInt; cdecl; external;
  function XUngrabKeyboard(Display: Pointer; Time: LongWord): LongInt; cdecl; external;
  function XUngrabPointer(Display: Pointer; Time: LongWord): LongInt; cdecl; external;
  procedure XRRFreeScreenConfigInfo(config: Pointer); cdecl; external;
  function XRRGetScreenInfo(dpy: Pointer; draw: LongWord): Pointer; cdecl; external;
  function XRRSetScreenConfigAndRate(dpy: Pointer; config: Pointer; draw: LongWord; size_index: LongInt; rotation: Word; rate: Word; timestamp: LongWord): LongInt; cdecl; external;
  function XRRConfigCurrentConfiguration(config: Pointer; rotation: Pointer): Word; cdecl; external;
  function XRRRootToScreen(dpy: Pointer; root: LongWord): LongInt; cdecl; external;
  function XRRSizes(dpy: Pointer; screen: LongInt; nsizes: PLongInt): PXRRScreenSize; cdecl; external;
  function gettimeofday(out timeval: TTimeVal; timezone: Pointer): LongInt; cdecl; external;

  function glXChooseVisual(dpy: Pointer; screen: LongInt; attribList: Pointer): PXVisualInfo; cdecl; external;
  function glXCreateContext(dpy: Pointer; vis: PXVisualInfo; shareList: Pointer; direct: Boolean): Pointer; cdecl; external;
  procedure glXDestroyContext(dpy: Pointer; ctx: Pointer); cdecl; external;
  function glXMakeCurrent(dpy: Pointer; drawable: LongWord; ctx: Pointer): Boolean; cdecl; external;
  procedure glXCopyContext(dpy: Pointer; src, dst: Pointer; mask: LongWord); cdecl; external;
  procedure glXSwapBuffers(dpy: Pointer; drawable: LongWord); cdecl; external;

  function dlopen(Name: PAnsiChar; Flags: LongInt): LongWord; cdecl; external;
  function dlsym(Lib: LongWord; Name: PAnsiChar): Pointer; cdecl; external;
  function dlclose(Lib: LongWord): LongInt; cdecl; external;

function LoadLibraryA(Name: PAnsiChar): LongWord;
begin
  Result := dlopen(Name, 1);
end;

function FreeLibrary(LibHandle: LongWord): Boolean;
begin
  Result := dlclose(LibHandle) = 0;
end;

function GetProcAddress(LibHandle: LongWord; ProcName: PAnsiChar): Pointer;
begin
  Result := dlsym(LibHandle, ProcName);
end;

const
  PFDAttrib : array [0..11] of LongWord = (
    $0186A1,  0, // GLX_SAMPLES
    $000005,     // GLX_DOUBLEBUFFER
    $000004,  1, // GLX_RGBA
    $000002, 32, // GLX_BUFFER_SIZE
    $00000C, 24, // GLX_DEPTH_SIZE
    $00000D,  8, // GLX_STENCIL_SIZE
    0);

  KeyCodes : array [ikPlus..ikDel] of Word =
    ($3D, $2D, $60,
     $30, $31, $32, $33, $34, $35, $36, $37, $38, $39,
     $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A,
     $FFBE, $FFBF, $FFC0, $FFC1, $FFC2, $FFC3, $FFC4, $FFC5, $FFC6, $FFC7, $FFC8, $FFC9,
     $FF1B, $FF0D, $FF08, $FF09, $FFE1, $FFE3, $FFE9, $20, $FF55, $FF56, $FF57, $FF50, $FF51, $FF52, $FF53, $FF54, $FF63, $FFFF);

var
  XDisp       : Pointer;
  XScr        : LongWord;
  XWndAttr    : TXSeLongWordAttributes;
  XContext    : Pointer;
  XVisual     : PXVisualInfo;
  XRoot       : LongWord;
// screen size params
  ScrConfig   : Pointer;
  ScrSizes    : PXRRScreenSize;
  SizesCount  : LongInt;
  DefSizeIdx  : LongInt;

  TimeStart   : LongInt;

  WM_PROTOCOLS : LongWord;
  WM_DESTROY   : LongWord;
{$ENDIF}
{$ENDREGION}

{$REGION 'MacOS System'}
{$IFDEF DARWIN}
  {$LINKFRAMEWORK Carbon}
  {$LINKFRAMEWORK AGL}
  {$LINKLIB dl}
const
  opengl32 = '/System/Library/Frameworks/OpenGL.framework/Libraries/libGL.dylib';
  kDocumentWindowClass        = 6;
  kWindowCloseBoxAttribute        = 1 shl 0;
  kWindowCollapseBoxAttribute     = 1 shl 3;
  kWindowStandardHandlerAttribute = 1 shl 25;

type
  TMacRect = record
    top, left, bottom, right : SmallInt;
  end;

  TMacPoint = record
    v, h : SmallInt;
  end;

  TMacEventRecord = record
    what      : Word;
    message   : LongWord;
    when      : LongWord;
    where     : TMacPoint;
    modifiers : Word;
  end;
  TMacTitle = string[255];

  TAGLPixelFormat = Pointer;
  TAGLContext = Pointer;

// Carbon
  function CreateNewWindow(windowClass, attributes: LongWord; const contentBounds: TMacRect; var outWindow: LongWord): LongInt; mwpascal; external name '_CreateNewWindow';
  function ReleaseWindow(window: LongWord): LongInt; mwpascal; external name '_ReleaseWindow';
  procedure SelectWindow(window: LongWord); mwpascal; external name '_SelectWindow';
  procedure ShowWindow(window: LongWord); mwpascal; external name '_ShowWindow';
  function GetWindowPort(window: LongWord): Pointer; mwpascal; external name '_GetWindowPort';
  function GetNextEvent(eventMask: Word; var Event: TMacEventRecord): Boolean; mwpascal; external name '_GetNextEvent';
  procedure SetWTitle(window: LongWord; const title: TMacTitle); mwpascal; external name '_SetWTitle';
  procedure Microseconds(var microTickCount: QWord); mwpascal; external name '_Microseconds';
// AGL
  function aglChoosePixelFormat(gdevs: Pointer; ndev: LongInt; attribs: Pointer): TAGLPixelFormat; cdecl; external;
  procedure aglDestroyPixelFormat(pix: TAGLPixelFormat); cdecl; external;
  function aglCreateContext(pix: TAGLPixelFormat; share: TAGLContext): TAGLContext; cdecl; external;
  function aglDestroyContext(ctx: TAGLContext): Boolean; cdecl; external;
  function aglSetCurrentContext(ctx: TAGLContext): Boolean; cdecl; external;
  function aglSetDrawable(ctx: TAGLContext; draw: Pointer): Boolean; cdecl; external;
  function aglSetFullScreen(ctx: TAGLContext; width, height, freq: LongInt; device: LongInt): Boolean; cdecl; external;
  procedure aglSwapBuffers(ctx: TAGLContext); cdecl; external;

  function dlopen(Name: PAnsiChar; Flags: LongInt): LongWord; cdecl; external;
  function dlsym(Lib: LongWord; Name: PAnsiChar): Pointer; cdecl; external;
  function dlclose(Lib: LongWord): LongInt; cdecl; external;

function LoadLibraryA(Name: PAnsiChar): LongWord;
begin
  Result := dlopen(Name, 1);
end;

function FreeLibrary(LibHandle: LongWord): Boolean;
begin
  Result := dlclose(LibHandle) = 0;
end;

function GetProcAddress(LibHandle: LongWord; ProcName: PAnsiChar): Pointer;
begin
  Result := dlsym(LibHandle, ProcName);
end;

const
  PFDAttrib : array [0..10] of LongWord = (
    $38,  0, // AGL_SAMPLES_ARB
    $05,     // AGL_DOUBLEBUFFER
    $04,     // AGL_RGBA
    $02, 32, // AGL_BUFFER_SIZE
    $0C, 24, // AGL_DEPTH_SIZE
    $0D,  8, // AGL_STENCIL_SIZE
    0);

  KeyCodes : array [ikPlus..ikDel] of Word =
    ($3D, $2D, $60,
     $30, $31, $32, $33, $34, $35, $36, $37, $38, $39,
     $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A,
     $FFBE, $FFBF, $FFC0, $FFC1, $FFC2, $FFC3, $FFC4, $FFC5, $FFC6, $FFC7, $FFC8, $FFC9,
     $FF1B, $FF0D, $FF08, $FF09, $FFE1, $FFE3, $FFE9, $20, $FF55, $FF56, $FF57, $FF50, $FF51, $FF52, $FF53, $FF54, $FF63, $FFFF);

var
  Context : TAGLContext;
  TimeStart : QWord;
{$ENDIF}
{$ENDREGION}

// Math ========================================================================
{$REGION 'TVec2f'}
{$IFDEF FPC}operator = {$ELSE}class operator TVec2f.Equal{$ENDIF}
  (const a, b: TVec2f): Boolean;
begin
  with b - a do
    Result := (abs(x) <= EPS) and (abs(y) <= EPS);
end;

{$IFDEF FPC}operator + {$ELSE}class operator TVec2f.Add{$ENDIF}
  (const a, b: TVec2f): TVec2f;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
end;

{$IFDEF FPC}operator - {$ELSE}class operator TVec2f.Subtract{$ENDIF}
  (const a, b: TVec2f): TVec2f;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec2f.Multiply{$ENDIF}
  (const a, b: TVec2f): TVec2f;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec2f.Multiply{$ENDIF}
  (const v: TVec2f; x: Single): TVec2f;
begin
  Result.x := v.x * x;
  Result.y := v.y * x;
end;

function TVec2f.Dot(const v: TVec2f): Single;
begin
  Result := x * v.x + y * v.y;
end;

function TVec2f.Reflect(const n: TVec2f): TVec2f;
begin
  Result := Self - n * (2 * Dot(n));
end;

function TVec2f.Refract(const n: TVec2f; Factor: Single): TVec2f;
var
  d, s : Single;
begin
  d := Dot(n);
  s := 1 - sqr(Factor) * (1 - sqr(d));
  if s < EPS then
    Result := Reflect(n)
  else
    Result := Self * Factor - n * (sqrt(s) + d * Factor);
end;

function TVec2f.Length: Single;
begin
  Result := sqrt(LengthQ);
end;

function TVec2f.LengthQ: Single;
begin
  Result := sqr(x) + sqr(y);
end;

function TVec2f.Normal: TVec2f;
var
  Len : Single;
begin
  Len := Length;
  if Len < EPS then
    Result := Vec2f(0, 0)
  else
    Result := Self * (1 / Len);
end;

function TVec2f.Dist(const v: TVec2f): Single;
var
  p : TVec2f;
begin
  p := v - Self;
  Result := p.Length;
end;

function TVec2f.DistQ(const v: TVec2f): Single;
var
  p : TVec2f;
begin
  p := v - Self;
  Result := p.LengthQ;
end;

function TVec2f.Lerp(const v: TVec2f; t: Single): TVec2f;
begin
  Result := Self + (v - Self) * t;
end;

function TVec2f.Min(const v: TVec2f): TVec2f;
begin
  Result.x := CoreX.Min(x, v.x);
  Result.y := CoreX.Min(y, v.y);
end;

function TVec2f.Max(const v: TVec2f): TVec2f;
begin
  Result.x := CoreX.Max(x, v.x);
  Result.y := CoreX.Max(y, v.y);
end;

function TVec2f.Clamp(const MinClamp, MaxClamp: TVec2f): TVec2f;
begin
  Result := Vec2f(CoreX.Clamp(x, MinClamp.x, MaxClamp.x), 
                  CoreX.Clamp(y, MinClamp.y, MaxClamp.y));
end;

function TVec2f.Rotate(Angle: Single): TVec2f;
var
  s, c : Single;
begin
  SinCos(Angle, s, c);
  Result := Vec2f(x * c - y * s, x * s + y * c);
end;

function TVec2f.Angle(const v: TVec2f): Single;
begin
  Result := ArcTan2(x * v.y - y * v.x, x * v.x + y * v.y);
end;
{$ENDREGION}

{$REGION 'TVec3f'}
{$IFDEF FPC}operator = {$ELSE}class operator TVec3f.Equal{$ENDIF}
  (const a, b: TVec3f): Boolean;
begin
  with b - a do
    Result := (abs(x) <= EPS) and (abs(y) <= EPS) and (abs(z) <= EPS);
end;

{$IFDEF FPC}operator + {$ELSE}class operator TVec3f.Add{$ENDIF}
  (const a, b: TVec3f): TVec3f;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
end;

{$IFDEF FPC}operator - {$ELSE}class operator TVec3f.Subtract{$ENDIF}
  (const a, b: TVec3f): TVec3f;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec3f.Multiply{$ENDIF}
  (const a, b: TVec3f): TVec3f;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec3f.Multiply{$ENDIF}
  (const v: TVec3f; x: Single): TVec3f;
begin
  Result.x := v.x * x;
  Result.y := v.y * x;
  Result.z := v.z * x;
end;

function TVec3f.Dot(const v: TVec3f): Single;
begin
  Result := x * v.x + y * v.y + z * v.z;
end;

function TVec3f.Cross(const v: TVec3f): TVec3f;
begin
  Result.x := y * v.z - z * v.y;
  Result.y := z * v.x - x * v.z;
  Result.z := x * v.y - y * v.x;
end;

function TVec3f.Reflect(const n: TVec3f): TVec3f;
begin
  Result := Self - n * (2 * Dot(n));
end;

function TVec3f.Refract(const n: TVec3f; Factor: Single): TVec3f;
var
  d, s : Single;
begin
  d := Dot(n);
  s := (1 - sqr(Factor)) * (1 - sqr(d));
  if s < EPS then
    Result := Reflect(n)
  else
    Result := Self * Factor - n * (sqrt(s) + d * Factor);
end;

function TVec3f.Length: Single;
begin
  Result := sqrt(LengthQ);
end;

function TVec3f.LengthQ: Single;
begin
  Result := sqr(x) + sqr(y) + sqr(z);
end;

function TVec3f.Normal: TVec3f;
var
  Len : Single;
begin
  Len := Length;
  if Len < EPS then
    Result := Vec3f(0, 0, 0)
  else
    Result := Self * (1 / Len);
end;

function TVec3f.Dist(const v: TVec3f): Single;
var
  p : TVec3f;
begin
  p := v - Self;
  Result := p.Length;
end;

function TVec3f.DistQ(const v: TVec3f): Single;
var
  p : TVec3f;
begin
  p := v - Self;
  Result := p.LengthQ;
end;

function TVec3f.Lerp(const v: TVec3f; t: Single): TVec3f;
begin
  Result := Self + (v - Self) * t;
end;

function TVec3f.Min(const v: TVec3f): TVec3f;
begin
  Result.x := CoreX.Min(x, v.x);
  Result.y := CoreX.Min(y, v.y);
  Result.z := CoreX.Min(z, v.z);
end;

function TVec3f.Max(const v: TVec3f): TVec3f;
begin
  Result.x := CoreX.Max(x, v.x);
  Result.y := CoreX.Max(y, v.y);
  Result.z := CoreX.Max(z, v.z);
end;

function TVec3f.Clamp(const MinClamp, MaxClamp: TVec3f): TVec3f;
begin
  Result := Vec3f(CoreX.Clamp(x, MinClamp.x, MaxClamp.x), 
                  CoreX.Clamp(y, MinClamp.y, MaxClamp.y), 
		  CoreX.Clamp(z, MinClamp.z, MaxClamp.z));
end;

function TVec3f.Rotate(Angle: Single; const Axis: TVec3f): TVec3f;
var
  s, c : Single;
  v0, v1, v2 : TVec3f;
begin
  SinCos(Angle, s, c);
  v0 := Axis * Dot(Axis);
  v1 := Self - v0;
  v2 := Axis.Cross(v1);
  Result.x := v0.x + v1.x * c + v2.x * s;
  Result.y := v0.y + v1.y * c + v2.y * s;
  Result.z := v0.z + v1.z * c + v2.z * s;
end;

function TVec3f.Angle(const v: TVec3f): Single;
begin
  Result := ArcCos(Dot(v) / sqrt(LengthQ * v.LengthQ))
end;

function TVec3f.MultiOp(out r: TVec3f; const v1, v2, op1, op2: TVec3f): Single;
begin
  r.x := v1.x * op1.x + v2.x * op2.x;
  r.y := v1.y * op1.y + v2.y * op2.y;
  r.z := v1.z * op1.z + v2.z * op2.z;
  Result := r.x + r.y + r.z;
  // add   = (v1, v2, 1, 1)
  // sub   = (v1, v2, 1, -1)
  // neg   = (v1, 0, -1, 0)
  // dot   = (v1, 0, v2, 0)
  // cross = (v1.yzx, v2.yzx, v2.zxy, -v1.zxy)
  // lenq  = (v1, 0, v1, 0)
  // lerp  = (v1, v2, 1 - t, t)
  // etc.
end;
{$ENDREGION}

{$REGION 'TVec4f'}
{$IFDEF FPC}operator = {$ELSE}class operator TVec4f.Equal{$ENDIF}
  (const a, b: TVec4f): Boolean;
begin
  with b - a do
    Result := (abs(x) <= EPS) and (abs(y) <= EPS) and (abs(z) <= EPS) and (abs(w) <= EPS);
end;

{$IFDEF FPC}operator + {$ELSE}class operator TVec4f.Add{$ENDIF}
  (const a, b: TVec4f): TVec4f;
begin
  Result.x := a.x + b.x;
  Result.y := a.y + b.y;
  Result.z := a.z + b.z;
  Result.w := a.w + b.w;
end;

{$IFDEF FPC}operator - {$ELSE}class operator TVec4f.Subtract{$ENDIF}
  (const a, b: TVec4f): TVec4f;
begin
  Result.x := a.x - b.x;
  Result.y := a.y - b.y;
  Result.z := a.z - b.z;
  Result.w := a.w - b.w;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec4f.Multiply{$ENDIF}
  (const a, b: TVec4f): TVec4f;
begin
  Result.x := a.x * b.x;
  Result.y := a.y * b.y;
  Result.z := a.z * b.z;
  Result.w := a.w * b.w;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TVec4f.Multiply{$ENDIF}
  (const v: TVec4f; x: Single): TVec4f;
begin
  Result.x := v.x * x;
  Result.y := v.y * x;
  Result.z := v.z * x;
  Result.w := v.w * x;
end;

function TVec4f.Dot(const v: TVec3f): Single;
begin
  Result := x * v.x + y * v.y + z * v.z + w;
end;

function TVec4f.Lerp(const v: TVec4f; t: Single): TVec4f;
begin
  Result := Self + (v - Self) * t;
end;
{$ENDREGION}

{$REGION 'TQuat'}
{$IFDEF FPC}operator = {$ELSE}class operator TQuat.Equal{$ENDIF}
  (const q1, q2: TQuat): Boolean;
begin
  Result := (abs(q1.x - q2.x) <= EPS) and
            (abs(q1.y - q2.y) <= EPS) and
            (abs(q1.z - q2.z) <= EPS) and
            (abs(q1.w - q2.w) <= EPS);
end;

{$IFDEF FPC}operator + {$ELSE}class operator TQuat.Add{$ENDIF}
  (const q1, q2: TQuat): TQuat;
begin
  Result.x := q1.x + q2.x;
  Result.y := q1.y + q2.y;
  Result.z := q1.z + q2.z;
  Result.w := q1.w + q2.w;
end;

{$IFDEF FPC}operator - {$ELSE}class operator TQuat.Subtract{$ENDIF}
  (const q1, q2: TQuat): TQuat;
begin
  Result.x := q1.x - q2.x;
  Result.y := q1.y - q2.y;
  Result.z := q1.z - q2.z;
  Result.w := q1.w - q2.w;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TQuat.Multiply{$ENDIF}
  (const q: TQuat; x: Single): TQuat;
begin
  Result.x := q.x * x;
  Result.y := q.y * x;
  Result.z := q.z * x;
  Result.w := q.w * x;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TQuat.Multiply{$ENDIF}
  (const q1, q2: TQuat): TQuat;
begin
  Result.x := q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
  Result.y := q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z;
  Result.z := q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x;
  Result.w := q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TQuat.Multiply{$ENDIF}
  (const q: TQuat; const v: TVec3f): TVec3f;
begin
  with q * Quat(v.x, v.y, v.z, 0) * q.Invert do
    Result := Vec3f(x, y, z);
end;

function TQuat.Invert: TQuat;
begin
  Result := Quat(-x, -y, -z, w);
end;

function TQuat.Lerp(const q: TQuat; t: Single): TQuat;
begin
  if Dot(q) < 0 then
    Result := Self - (q + Self) * t
  else
    Result := Self + (q - Self) * t;
end;

function TQuat.Dot(const q: TQuat): Single;
begin
  Result := x * q.x + y * q.y + z * q.z + w * q.w;
end;

function TQuat.Normal: TQuat;
var
  Len : Single;
begin
  Len := sqrt(sqr(x) + sqr(y) + sqr(z) + sqr(w));
  if Len > 0 then
  begin
    Len := 1 / Len;
    Result.x := x * Len;
    Result.y := y * Len;
    Result.z := z * Len;
    Result.w := w * Len;
  end;
end;

function TQuat.Euler: TVec3f;
var
  D : Single;
begin
  D := 2 * x * z + y * w;
  if abs(D) > 1 - EPS then
  begin
    Result.x := 0;
    if D > 0 then
      Result.y := -pi * 0.5
    else
      Result.y :=  pi * 0.5;
    Result.z := ArcTan2(-2 * (y * z - w * x), 2 * (w * w + y * y) - 1);
  end else
  begin
    Result.x := -ArcTan2(2 * (y * z + w * x), 2 * (w * w + z * z) - 1);
    Result.y := ArcSin(-d);
    Result.z := -ArcTan2(2 * (x * y + w * z), 2 * (w * w + x * x) - 1);
  end;
end;
{$ENDREGION}

{$REGION 'TDualQuat'}
{$IFDEF FPC}operator * {$ELSE}class operator TDualQuat.Multiply{$ENDIF}
  (const dq1, dq2: TDualQuat): TDualQuat;
begin
  Result.Real := dq1.Real * dq2.Real;
  Result.Dual := dq1.Real * dq2.Dual + dq1.Dual * dq2.Real;
end;

function TDualQuat.Lerp(const dq: TDualQuat; t: Single): TDualQuat;
begin
  if Real.Dot(dq.Real) < 0 then
  begin
    Result.Real := Real - (dq.Real + Real) * t;
    Result.Dual := Dual - (dq.Dual + Dual) * t;
  end else
  begin
    Result.Real := Real + (dq.Real - Real) * t;
    Result.Dual := Dual + (dq.Dual - Dual) * t;
  end;
end;

function TDualQuat.GetPos: TVec3f;
begin
  Result.x := (Dual.x * Real.w - Real.x * Dual.w + Real.y * Dual.z - Real.z * Dual.y) * 2;
  Result.y := (Dual.y * Real.w - Real.y * Dual.w + Real.z * Dual.x - Real.x * Dual.z) * 2;
  Result.z := (Dual.z * Real.w - Real.z * Dual.w + Real.x * Dual.y - Real.y * Dual.x) * 2;
end;
{$ENDREGION}

{$REGION 'TMat4f'}
function TMat4f.GetPos: TVec3f;
begin
  Result.x := e03;
  Result.y := e13;
  Result.z := e23;
end;

procedure TMat4f.SetPos(const v: TVec3f);
begin
  e03 := v.x;
  e13 := v.y;
  e23 := v.z;
end;

function TMat4f.GetRot: TQuat;
var
  t, s : Single;
begin
  t := e00 + e11 + e22 + 1;
  with Result do
    if t > EPS then
    begin
      s := 0.5 / sqrt(t);
      w := 0.25 / s;
      x := (e21 - e12) * s;
      y := (e02 - e20) * s;
      z := (e10 - e01) * s;
    end else
      if (e00 > e11) and (e00 > e22) then
      begin
        s := 2 * sqrt(1 + e00 - e11 - e22);
        w := (e21 - e12) / s;
        x := 0.25 * s;
        y := (e01 + e10) / s;
        z := (e02 + e20) / s;
      end else
        if e11 > e22 then
        begin
          s := 2 * sqrt(1 + e11 - e00 - e22);
          w := (e02 - e20) / s;
          x := (e01 + e10) / s;
          y := 0.25 * s;
          z := (e12 + e21) / s;
        end else
        begin
          s := 2 * sqrt(1 + e22 - e00 - e11);
          w := (e10 - e01) / s;
          x := (e02 + e20) / s;
          y := (e12 + e21) / s;
          z := 0.25 * s;
        end;
end;

procedure TMat4f.SetRot(const q: TQuat);
var
  sqw, sqx, sqy, sqz, invs : Single;
  tmp1, tmp2 : Single;
begin
  with q do
  begin
    sqw := w * w;
    sqx := x * x;
    sqy := y * y;
    sqz := z * z;

    invs := 1 / (sqx + sqy + sqz + sqw);
    e00 := ( sqx - sqy - sqz + sqw) * invs;
    e11 := (-sqx + sqy - sqz + sqw) * invs;
    e22 := (-sqx - sqy + sqz + sqw) * invs;

    tmp1 := x * y;
    tmp2 := z * w;
    e10 := 2 * (tmp1 + tmp2) * invs;
    e01 := 2 * (tmp1 - tmp2) * invs;

    tmp1 := x * z;
    tmp2 := y * w;
    e20 := 2 * (tmp1 - tmp2) * invs;
    e02 := 2 * (tmp1 + tmp2) * invs;

    tmp1 := y * z;
    tmp2 := x * w;
    e21 := 2 * (tmp1 + tmp2) * invs;
    e12 := 2 * (tmp1 - tmp2) * invs;
  end;
end;

{$IFDEF FPC}operator + {$ELSE}class operator TMat4f.Add{$ENDIF}
  (const a, b: TMat4f): TMat4f;
begin
  with Result do
  begin
    e00 := a.e00 + b.e00; e10 := a.e10 + b.e10; e20 := a.e20 + b.e20; e30 := a.e30 + b.e30;
    e01 := a.e01 + b.e01; e11 := a.e11 + b.e11; e21 := a.e21 + b.e21; e31 := a.e31 + b.e31;
    e02 := a.e02 + b.e02; e12 := a.e12 + b.e12; e22 := a.e22 + b.e22; e32 := a.e32 + b.e32;
    e03 := a.e03 + b.e03; e13 := a.e13 + b.e13; e23 := a.e23 + b.e23; e33 := a.e33 + b.e33;
  end;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TMat4f.Multiply{$ENDIF}
  (const a, b: TMat4f): TMat4f;
begin
  with Result do
  begin
    e00 := a.e00 * b.e00 + a.e01 * b.e10 + a.e02 * b.e20 + a.e03 * b.e30;
    e10 := a.e10 * b.e00 + a.e11 * b.e10 + a.e12 * b.e20 + a.e13 * b.e30;
    e20 := a.e20 * b.e00 + a.e21 * b.e10 + a.e22 * b.e20 + a.e23 * b.e30;
    e30 := a.e30 * b.e00 + a.e31 * b.e10 + a.e32 * b.e20 + a.e33 * b.e30;
    e01 := a.e00 * b.e01 + a.e01 * b.e11 + a.e02 * b.e21 + a.e03 * b.e31;
    e11 := a.e10 * b.e01 + a.e11 * b.e11 + a.e12 * b.e21 + a.e13 * b.e31;
    e21 := a.e20 * b.e01 + a.e21 * b.e11 + a.e22 * b.e21 + a.e23 * b.e31;
    e31 := a.e30 * b.e01 + a.e31 * b.e11 + a.e32 * b.e21 + a.e33 * b.e31;
    e02 := a.e00 * b.e02 + a.e01 * b.e12 + a.e02 * b.e22 + a.e03 * b.e32;
    e12 := a.e10 * b.e02 + a.e11 * b.e12 + a.e12 * b.e22 + a.e13 * b.e32;
    e22 := a.e20 * b.e02 + a.e21 * b.e12 + a.e22 * b.e22 + a.e23 * b.e32;
    e32 := a.e30 * b.e02 + a.e31 * b.e12 + a.e32 * b.e22 + a.e33 * b.e32;
    e03 := a.e00 * b.e03 + a.e01 * b.e13 + a.e02 * b.e23 + a.e03 * b.e33;
    e13 := a.e10 * b.e03 + a.e11 * b.e13 + a.e12 * b.e23 + a.e13 * b.e33;
    e23 := a.e20 * b.e03 + a.e21 * b.e13 + a.e22 * b.e23 + a.e23 * b.e33;
    e33 := a.e30 * b.e03 + a.e31 * b.e13 + a.e32 * b.e23 + a.e33 * b.e33;
  end;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TMat4f.Multiply{$ENDIF}
  (const m: TMat4f; const v: TVec3f): TVec3f;
begin
  with m do
  begin
    Result.x := e00 * v.x + e01 * v.y + e02 * v.z + e03;
    Result.y := e10 * v.x + e11 * v.y + e12 * v.z + e13;
    Result.z := e20 * v.x + e21 * v.y + e22 * v.z + e23;
  end;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TMat4f.Multiply{$ENDIF}
  (const m: TMat4f; const v: TVec4f): TVec4f;
begin
  with m do
  begin
    Result.x := e00 * v.x + e01 * v.y + e02 * v.z + e03 * v.w;
    Result.y := e10 * v.x + e11 * v.y + e12 * v.z + e13 * v.w;
    Result.z := e20 * v.x + e21 * v.y + e22 * v.z + e23 * v.w;
    Result.w := e30 * v.x + e31 * v.y + e32 * v.z + e33 * v.w;
  end;
end;

{$IFDEF FPC}operator * {$ELSE}class operator TMat4f.Multiply{$ENDIF}
  (const m: TMat4f; x: Single): TMat4f;
begin
  with Result do
  begin
    e00 := m.e00 * x; e10 := m.e10 * x; e20 := m.e20 * x; e30 := m.e30 * x;
    e01 := m.e01 * x; e11 := m.e11 * x; e21 := m.e21 * x; e31 := m.e31 * x;
    e02 := m.e02 * x; e12 := m.e12 * x; e22 := m.e22 * x; e32 := m.e32 * x;
    e03 := m.e03 * x; e13 := m.e13 * x; e23 := m.e23 * x; e33 := m.e33 * x;
  end;
end;

procedure TMat4f.Identity;
const
  IdentMat : TMat4f = (
    e00: 1; e10: 0; e20: 0; e30: 0;
    e01: 0; e11: 1; e21: 0; e31: 0;
    e02: 0; e12: 0; e22: 1; e32: 0;
    e03: 0; e13: 0; e23: 0; e33: 1;
  );
begin
  Self := IdentMat;
end;

function TMat4f.Det: Single;
begin
  Result := e00 * (e11 * (e22 * e33 - e32 * e23) - e21 * (e12 * e33 - e32 * e13) + e31 * (e12 * e23 - e22 * e13)) -
            e10 * (e01 * (e22 * e33 - e32 * e23) - e21 * (e02 * e33 - e32 * e03) + e31 * (e02 * e23 - e22 * e03)) +
            e20 * (e01 * (e12 * e33 - e32 * e13) - e11 * (e02 * e33 - e32 * e03) + e31 * (e02 * e13 - e12 * e03)) -
            e30 * (e01 * (e12 * e23 - e22 * e13) - e11 * (e02 * e23 - e22 * e03) + e21 * (e02 * e13 - e12 * e03));
end;

function TMat4f.Inverse: TMat4f;
var
  D : Single;
begin
  D := 1 / Det;
  Result.e00 :=  (e11 * (e22 * e33 - e32 * e23) - e21 * (e12 * e33 - e32 * e13) + e31 * (e12 * e23 - e22 * e13)) * D;
  Result.e01 := -(e01 * (e22 * e33 - e32 * e23) - e21 * (e02 * e33 - e32 * e03) + e31 * (e02 * e23 - e22 * e03)) * D;
  Result.e02 :=  (e01 * (e12 * e33 - e32 * e13) - e11 * (e02 * e33 - e32 * e03) + e31 * (e02 * e13 - e12 * e03)) * D;
  Result.e03 := -(e01 * (e12 * e23 - e22 * e13) - e11 * (e02 * e23 - e22 * e03) + e21 * (e02 * e13 - e12 * e03)) * D;
  Result.e10 := -(e10 * (e22 * e33 - e32 * e23) - e20 * (e12 * e33 - e32 * e13) + e30 * (e12 * e23 - e22 * e13)) * D;
  Result.e11 :=  (e00 * (e22 * e33 - e32 * e23) - e20 * (e02 * e33 - e32 * e03) + e30 * (e02 * e23 - e22 * e03)) * D;
  Result.e12 := -(e00 * (e12 * e33 - e32 * e13) - e10 * (e02 * e33 - e32 * e03) + e30 * (e02 * e13 - e12 * e03)) * D;
  Result.e13 :=  (e00 * (e12 * e23 - e22 * e13) - e10 * (e02 * e23 - e22 * e03) + e20 * (e02 * e13 - e12 * e03)) * D;
  Result.e20 :=  (e10 * (e21 * e33 - e31 * e23) - e20 * (e11 * e33 - e31 * e13) + e30 * (e11 * e23 - e21 * e13)) * D;
  Result.e21 := -(e00 * (e21 * e33 - e31 * e23) - e20 * (e01 * e33 - e31 * e03) + e30 * (e01 * e23 - e21 * e03)) * D;
  Result.e22 :=  (e00 * (e11 * e33 - e31 * e13) - e10 * (e01 * e33 - e31 * e03) + e30 * (e01 * e13 - e11 * e03)) * D;
  Result.e23 := -(e00 * (e11 * e23 - e21 * e13) - e10 * (e01 * e23 - e21 * e03) + e20 * (e01 * e13 - e11 * e03)) * D;
  Result.e30 := -(e10 * (e21 * e32 - e31 * e22) - e20 * (e11 * e32 - e31 * e12) + e30 * (e11 * e22 - e21 * e12)) * D;
  Result.e31 :=  (e00 * (e21 * e32 - e31 * e22) - e20 * (e01 * e32 - e31 * e02) + e30 * (e01 * e22 - e21 * e02)) * D;
  Result.e32 := -(e00 * (e11 * e32 - e31 * e12) - e10 * (e01 * e32 - e31 * e02) + e30 * (e01 * e12 - e11 * e02)) * D;
  Result.e33 :=  (e00 * (e11 * e22 - e21 * e12) - e10 * (e01 * e22 - e21 * e02) + e20 * (e01 * e12 - e11 * e02)) * D;
end;

function TMat4f.Transpose: TMat4f;
begin
  Result.e00 := e00; Result.e10 := e01; Result.e20 := e02; Result.e30 := e03;
  Result.e01 := e10; Result.e11 := e11; Result.e21 := e12; Result.e31 := e13;
  Result.e02 := e20; Result.e12 := e21; Result.e22 := e22; Result.e32 := e23;
  Result.e03 := e30; Result.e13 := e31; Result.e23 := e32; Result.e33 := e33;
end;

procedure TMat4f.Translate(const v: TVec3f);
var
  m : TMat4f;
begin
  m.Identity;
  m.Pos := v;
  Self := Self * m;
end;

procedure TMat4f.Rotate(Angle: Single; const Axis: TVec3f);
var
  m : TMat4f;
begin
  m := Mat4f(Angle, Axis);
  Self := Self * m;
end;

procedure TMat4f.Scale(const v: TVec3f);
var
  m : TMat4f;
begin
  m.Identity;
  m.e00 := v.x;
  m.e11 := v.y;
  m.e22 := v.z;
  Self := Self * m;
end;

procedure TMat4f.LookAt(const Pos, Target, Up: TVec3f);
var
  R, U, D : TVec3f;
begin
  D := (Pos - Target);
  D := D.Normal;
  R := Up.Cross(D);
  R := R.Normal;
  U := D.Cross(R);

  e00 := R.x; e01 := R.y; e02 := R.z; e03 := -Pos.Dot(R);
  e10 := U.x; e11 := U.y; e12 := U.z; e13 := -Pos.Dot(U);
  e20 := D.x; e21 := D.y; e22 := D.z; e23 := -Pos.Dot(D);
  e30 := 0;   e31 := 0;   e32 := 0;   e33 := 1;
end;

procedure TMat4f.Ortho(Left, Right, Bottom, Top, ZNear, ZFar: Single);
begin
  e00 := 2 / (Right - Left);
  e10 := 0;
  e20 := 0;
  e30 := 0;

  e01 := 0;
  e11 := 2 / (Top - Bottom);
  e21 := 0;
  e31 := 0;

  e02 := 0;
  e12 := 0;
  e22 := -2 / (ZFar - ZNear);
  e32 := 0;

  e03 := -(Right + Left) / (Right - Left);
  e13 := -(Top + Bottom) / (Top - Bottom);
  e23 := -(ZFar + ZNear) / (ZFar - ZNear);
  e33 := 1;
end;

procedure TMat4f.Frustum(Left, Right, Bottom, Top, ZNear, ZFar: Single);
begin
  e00 := 2 * ZNear / (Right - Left);
  e10 := 0;
  e20 := 0;
  e30 := 0;

  e01 := 0;
  e11 := 2 * ZNear / (Top - Bottom);
  e21 := 0;
  e31 := 0;

  e02 := (Right + Left) / (Right - Left);
  e12 := (Top + Bottom) / (Top - Bottom);
  e22 := -(ZFar + ZNear) / (ZFar - ZNear);
  e32 := -1;

  e03 := 0;
  e13 := 0;
  e23 := -2 * ZFar * ZNear / (ZFar - ZNear);
  e33 := 0;
end;

procedure TMat4f.Perspective(FOV, Aspect, ZNear, ZFar: Single);
var
  x, y : Single;
begin
  y := ZNear * Tan(FOV * 0.5 * deg2rad);
  x := y * Aspect;
  Frustum(-x, x, -y, y, ZNear, ZFar);
end;
{$ENDREGION}

{$REGION 'TSphere'}
function TSphere.Intersect(const v: TVec3f): Boolean;
begin
  Result := Center.DistQ(v) < sqr(Radius);
end;

function TSphere.Intersect(const Ray: TRay3f; out tMin, tMax: Single): Boolean;
var
  p, d : Single;
  v : TVec3f;
begin
  v := Ray.Pos - Center;
  p := -v.Dot(Ray.Dir);
  d := sqr(p) + sqr(Radius) - v.LengthQ;
  if d > 0 then
  begin
    d := sqrt(d);
    tMin := p - d;
    tMax := p + d;
    if tMax > 0 then
    begin
      if tMin < 0 then tMin := 0;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{$ENDREGION}

{$REGION 'TBox'}
function TBox.Intersect(const v: TVec3f): Boolean;
begin
  Result := (v.x >= Min.x) and (v.y >= Min.y) and (v.z >= Min.z) and
            (v.x <= Max.x) and (v.y <= Max.y) and (v.z <= Max.z);
end;

function TBox.Intersect(const Ray: TRay3f; out tMin, tMax: Single): Boolean;

  function Intersect1D(Pos, Dir, Min, Max: Single; var tMin, tMax: Single): Boolean;
  var
    t0, t1 : Single;
  begin
    if (Dir > -EPS) and (Dir < +EPS) then
    begin
      Result := (Pos >= Min) and (Pos <= Max);
      Exit;
    end else
      Dir := 1 / Dir;

    if Dir > 0 then
    begin
      t0 := (Min - Pos) * Dir;
      t1 := (Max - Pos) * Dir;
    end else
    begin
      t0 := (Max - Pos) * Dir;
      t1 := (Min - Pos) * Dir;
    end;

    if t0 > tMin then tMin := t0;
    if t1 < tMax then tMax := t1;

    Result := (tMax > tMin) and (tMax > 0);
  end;

begin
  tMin := -INF;
  tMax := +INF;

  Result := (Intersect1D(Ray.Pos.x, Ray.Dir.x, Min.x, Max.x, tMin, tMax)) and
            (Intersect1D(Ray.Pos.y, Ray.Dir.y, Min.y, Max.y, tMin, tMax)) and
            (Intersect1D(Ray.Pos.z, Ray.Dir.z, Min.z, Max.z, tMin, tMax));
end;
{$ENDREGION}

{$REGION 'TTriangle'}
function TTriangle.Intersect(const Ray: TRay3f; out u, v, t: Single; TwoSide: Boolean): Boolean;
label
  tada;
var
  e1, e2, p, q, r : TVec3f;
  d : Single;
begin
  e1 := B - A;
  e2 := C - A;
  p  := Ray.Dir.Cross(e2);
  d  := p.Dot(e1);

  if d > EPS then
  begin
    r := Ray.Pos - A;
    u := p.Dot(r);
    if (u >= 0) and (u <= d) then
    begin
      q := r.Cross(e1);
      v := Ray.Dir.Dot(q);
      if (v >= 0) and (u + v <= d) then
        goto tada;
    end;
  end;

  if (d < -EPS) and TwoSide then
  begin
    r := Ray.Pos - A;
    u := p.Dot(r);
    if (u <= 0) and (u >= d) then
    begin
      q := r.Cross(e1);
      v := Ray.Dir.Dot(q);
      if (v <= 0) and (u + v >= d) then
        goto tada;
    end;
  end;

  Result := False;
  Exit;  
tada:
  d := 1 / d;
  t := q.Dot(e2);
  if t > EPS then
  begin
    t := t * d;  
    u := u * d;
    v := v * d;
    Result := True;
  end else
    Result := False;
end;

{$ENDREGION}

{$REGION 'Math'}
function Vec2f(x, y: Single): TVec2f;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec3b(x, y, z: ShortInt): TVec3b;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec3ub(x, y, z: Byte): TVec3ub;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec3s(x, y, z: SmallInt): TVec3s;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec3f(x, y, z: Single): TVec3f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec4ub(x, y, z, w: Byte): TVec4ub;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Vec4s(x, y, z, w: SmallInt): TVec4s;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Vec4f(x, y, z, w: Single): TVec4f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Quat(x, y, z, w: Single): TQuat;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function Quat(Angle: Single; const Axis: TVec3f): TQuat;
var
  s, c : Single;
begin
  SinCos(Angle * 0.5, s, c);
  Result.x := Axis.x * s;
  Result.y := Axis.y * s;
  Result.z := Axis.z * s;
  Result.w := c;
end;

function DualQuat(const qRot: TQuat; const qPos: TVec3f): TDualQuat;
begin
  with Result do
  begin
    Real := qRot;
    Dual := Quat(qPos.x, qPos.y, qPos.z, 0) * (qRot * 0.5);
  end;
end;

function Mat4f(Angle: Single; const Axis: TVec3f): TMat4f;
var
  s, c  : Single;
  ic : Single;
  xy, yz, zx, xs, ys, zs, icxy, icyz, iczx : Single;
begin
  SinCos(Angle, s, c);
  ic := 1 - c;

  with Result, Axis do
  begin
    xy := x * y;  yz := y * z;  zx := z * x;
    xs := x * s;  ys := y * s;  zs := z * s;
    icxy := ic * xy;  icyz := ic * yz;  iczx := ic * zx;
    e00 := ic * x * x + c;  e01 := icxy - zs;       e02 := iczx + ys;       e03 := 0.0;
    e10 := icxy + zs;       e11 := ic * y * y + c;  e12 := icyz - xs;       e13 := 0.0;
    e20 := iczx - ys;       e21 := icyz + xs;       e22 := ic * z * z + c;  e23 := 0.0;
    e30 := 0.0;             e31 := 0.0;             e32 := 0.0;             e33 := 1.0;
  end;
end;

function Min(x, y: LongInt): LongInt;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function Min(x, y: Single): Single;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function Max(x, y: LongInt): LongInt;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function Max(x, y: Single): Single;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function Clamp(x, Min, Max: LongInt): LongInt;
begin
  if x < min then
    Result := min
  else
    if x > max then
      Result := max
    else
      Result := x;
end;

function Clamp(x, Min, Max: Single): Single;
begin
  if x < min then
    Result := min
  else
    if x > max then
      Result := max
    else
      Result := x;
end;

function ClampAngle(Angle: Single): Single;
begin
  if Angle > pi then
    Result := (Frac(Angle / pi) - 1) * pi
  else
    if Angle < -pi then
      Result := (Frac(Angle / pi) + 1) * pi
    else
      Result := Angle;
end;

function Lerp(x, y, t: Single): Single;
begin
  Result := x + (y - x) * t;
end;

function Sign(x: Single): LongInt;
begin
  if x > 0 then
    Result := 1
  else
    if x < 0 then
      Result := -1
    else
      Result := 0;
end;

function Ceil(const x: Single): LongInt;
begin
  Result := LongInt(Trunc(x));
  if Frac(x) > 0 then
    Inc(Result);
end;

function Floor(const x: Single): LongInt;
begin
  Result := LongInt(Trunc(x));
  if Frac(x) < 0 then
    Dec(Result);
end;

function Tan(x: Single): Single; assembler;
asm
  fld x
  fptan
  fstp st(0)
  fwait
end;

procedure SinCos(Theta: Single; out Sin, Cos: Single); assembler;
asm
  fld Theta
  fsincos
  fstp dword ptr [edx]
  fstp dword ptr [eax]
  fwait
end;

function ArcTan2(y, x: Single): Single; assembler;
asm
  fld y
  fld x
  fpatan
  fwait
end;

function ArcCos(x: Single): Single; assembler;
asm
{
  fld x
  fmul st, st
  fsubr ONE
  fsqrt
  fld x
  fpatan
}
  fld1
  fld    x
  fst    st(2)
  fmul   st(0), st(0)
  fsubp
  fsqrt
  fxch
  fpatan
end;

function ArcSin(x: Single): Single; assembler;
asm
{
  fld x
  fld st
  fmul st, st
  fsubr ONE
  fsqrt
  fpatan
}
  fld1
  fld    X
  fst    st(2)
  fmul   st(0), st(0)
  fsubp
  fsqrt
  fpatan
end;

function Log2(const X: Single): Single; assembler;
asm
  fld1
  fld X
  fyl2x
  fwait
end;

function Pow(x, y: Single): Single;
begin
  Result := exp(ln(x) * y);
end;

function ToPow2(x: LongInt): LongInt;
begin
  Result := x - 1;
  Result := Result or (Result shr 1);
  Result := Result or (Result shr 2);
  Result := Result or (Result shr 4);
  Result := Result or (Result shr 8);
  Result := Result or (Result shr 16);
  Result := Result + 1;
end;
{$ENDREGION}

// Utils =======================================================================
{$REGION 'TResManager'}
type
  TResManager = object
    Items  : array of TResObject;
    Count  : LongInt;
  // 0..15  - Texture
  // 16     - Shader
  // 17, 18 - Index, Vertex buffer
    Active : array [TResType] of TObject;
    procedure Init;
    procedure Free;
    function GetRef(const Name: string): TResObject;
    function Add(const Res: TResObject): LongInt;
    function Delete(Res: TResObject): Boolean;
  end;

var
  ResManager : TResManager;

procedure TResManager.Init;
begin
  Items := nil;
  Count := 0;
  FillChar(Active, SizeOf(Active), 0);
end;

procedure TResManager.Free;
var
  i : LongInt;
  Str : string;
begin
  if ResManager.Count > 0 then
  begin
    Str := 'Resource leak has occurred:';
    for i := 0 to Count - 1 do
    begin
      Str := Str + #13;
      Str := Str + Items[i].ClassName;
      if Items[i].Name <> '' then
        Str := Str + ' "' + Items[i].Name + '"';
    end;
    MsgBox('Leaks', Str);
  end;
end;

function TResManager.GetRef(const Name: string): TResObject;
var
  i : LongInt;
begin
  Result := nil;
  if Name <> '' then
    for i := 0 to Count - 1 do
      if Items[i].Name = Name then
      begin
        Result := Items[i];
        Inc(Items[i].Ref);
        Exit;
      end;
end;

function TResManager.Add(const Res: TResObject): LongInt;
begin
  if Res <> nil then
  begin
    if Count = Length(Items) then
      SetLength(Items, Count + 32);
    Items[Count] := Res;
    Result := Count;
    Inc(Count);
  end else
    Result := -1;
end;

function TResManager.Delete(Res: TResObject): Boolean;
var
  i  : LongInt;
  rt : TResType;
begin
  Dec(Res.Ref);
  Result := Res.Ref <= 0;
  if Result then
    for i := 0 to Count - 1 do
      if Items[i] = Res then
      begin
        Dec(Count);
        Items[i] := Items[Count];
        Items[Count] := nil;
        for rt := Low(Active) to High(Active) do
          if Active[rt] = Res then
            Active[rt] := nil;
        Exit;
      end;
end;
{$ENDREGION}

{$REGION 'TResObject'}
constructor TResObject.Create(const Name: string);
begin
  Self.Ref  := 1;
  Self.Name := Name;
  ResManager.Add(Self);
end;

procedure TResObject.Free;
begin
  if ResManager.Delete(Self) then
    Destroy;
end;
{$ENDREGION}

{$REGION 'TStream'}
class function TStream.Init(Memory: Pointer; MemSize: LongInt): TStream;
begin
  Result := TStream.Create;
  with Result do
  begin
    SType := stMemory;
    Mem   := Memory;
    FSize := MemSize;
    FPos  := 0;
    FBPos := 0;
  end;
end;

class function TStream.Init(const FileName: string; RW: Boolean): TStream;
begin
{$IFNDEF NO_FILESYS}
  Result := FileSys.Open(FileName, RW);
{$ELSE}
  Result := nil;
{$ENDIF}
end;

destructor TStream.Destroy;
begin
  if SType = stFile then
    CloseFile(F);
end;

procedure TStream.SetPos(Value: LongInt);
begin
  FPos := Value;
  if SType = stFile then
    Seek(F, FBPos + FPos);
end;

{$IFNDEF NO_FILESYS}
procedure TStream.SetBlock(BPos, BSize: LongInt);
begin
  FSize := BSize;
  FBPos := BPos;
  Pos := 0;
end;
{$ENDIF}

procedure TStream.CopyFrom(const Stream: TStream);
var
  p : Pointer;
  CPos : LongInt;
begin
  p := GetMemory(Stream.Size);
  CPos := Stream.Pos;
  Stream.Pos := 0;
  Stream.Read(p^, Stream.Size);
  Stream.Pos := CPos;
  Write(p^, Stream.Size);
  FreeMemory(p);
end;

function TStream.Read(out Buf; BufSize: LongInt): LongInt;
begin
  if SType = stMemory then
  begin
    Result := Min(FPos + BufSize, FSize) - FPos;
    Move(Mem^, Buf, Result);
  end else
    BlockRead(F, Buf, BufSize, Result);
  Inc(FPos, Result);
end;

function TStream.Write(const Buf; BufSize: LongInt): LongInt;
begin
  if SType = stMemory then
  begin
    Result := Min(FPos + BufSize, FSize) - FPos;
    Move(Buf, Mem^, Result);
  end else
    BlockWrite(F, Buf, BufSize, Result);
  Inc(FPos, Result);
  Inc(FSize, Max(0, FPos - FSize));
end;

function TStream.ReadAnsi: AnsiString;
var
  Len : Word;
begin
  Read(Len, SizeOf(Len));
  if Len > 0 then
  begin
    SetLength(Result, Len);
    Read(Result[1], Len);
  end else
    Result := '';
end;

procedure TStream.WriteAnsi(const Value: AnsiString);
var
  Len : Word;
begin
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  if Len > 0 then
    Write(Value[1], Len);
end;

function TStream.ReadUnicode: WideString;
var
  Len : Word;
begin
  Read(Len, SizeOf(Len));
  SetLength(Result, Len);
  Read(Result[1], Len * 2);
end;

procedure TStream.WriteUnicode(const Value: WideString);
var
  Len : Word;
begin
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  Write(Value[1], Len * 2);
end;
{$ENDREGION}

{$REGION 'TConfigFile'}
procedure TConfigFile.Clear;
begin
  Data := nil;
end;

procedure TConfigFile.Load(const FileName: string);
var
  AnsiText : AnsiString;
  Text, Category, Line : string;
  CatId : LongInt;
  Stream : TStream;
  i, BeginPos : LongInt;
begin
  Data := nil;
  CatId := -1;
  Stream := TStream.Init(FileName);
  SetLength(AnsiText, Stream.Size);
  Stream.Read(AnsiText[1], Length(AnsiText));
  Stream.Free;
  Text := string(AnsiText);
  BeginPos := 1;
  while BeginPos < Length(Text) do
  begin
    for i := BeginPos to Length(Text) do
      if (Text[i] = #13) or (i = Length(Text)) then
      begin
        Line := Copy(Text, BeginPos, i - BeginPos + 1);
        BeginPos := i + 1;
        break;
      end;
    Line := Trim(Line);

    if Line <> '' then
      if Line[1] <> '[' then
      begin
        if (Line[1] <> ';') and (CatId >= 0) then
        begin
          SetLength(Data[CatId].Params, Length(Data[CatId].Params) + 1);
          with Data[CatId], Params[Length(Params) - 1] do
          begin
            Name  := Trim(Copy(Line, 1, Pos('=', Line) - 1));
            Value := Trim(Copy(Line, Pos('=', Line) + 1, Length(Line)));
          end;
        end;
      end else
      begin
        Category := Trim(DeleteChars(Line, ['[', ']']));
        CatId := Length(Data);
        SetLength(Data, CatId + 1);
        Data[CatId].Category := Category;
      end;
  end;
end;

procedure TConfigFile.Save(const FileName: string);
var
  Stream : TStream;
  Text   : string;
  i, j : LongInt;
begin
  Text := '';
  for i := 0 to Length(Data) - 1 do
  begin
    Text := Text + '[' + Data[i].Category + ']' + CRLF;
    for j := 0 to Length(Data[i].Params) - 1 do
      Text := Text + Data[i].Params[j].Name + ' = ' + Data[i].Params[j].Value + CRLF;
    Text := Text + CRLF;
  end;
  Stream := TStream.Init(FileName, True);
  Stream.Write(AnsiString(Text)[1], Length(Text));
  Stream.Free;
end;

procedure TConfigFile.Write(const Category, Name, Value: string);
var
  i, j : LongInt;
begin
  for i := 0 to Length(Data) - 1 do
    if Category = Data[i].Category then
      with Data[i] do
      begin
        for j := 0 to Length(Params) - 1 do
          if Params[j].Name = Name then
          begin
            Params[j].Value := Value;
            Exit;
          end;
      // Add new param
        SetLength(Params, Length(Params) + 1);
        Params[Length(Params) - 1].Name  := Name;
        Params[Length(Params) - 1].Value := Value;
        Exit;
      end;
// Add new category
  SetLength(Data, Length(Data) + 1);
  with Data[Length(Data) - 1] do
  begin
    SetLength(Params, 1);
    Params[0].Name  := Name;
    Params[0].Value := Value;
  end;
end;

procedure TConfigFile.Write(const Category, Name: string; Value: LongInt);
begin
  Write(Category, Name, Conv(Value));
end;

procedure TConfigFile.Write(const Category, Name: string; Value: Single);
begin
  Write(Category, Name, Conv(Value, 4));
end;

procedure TConfigFile.Write(const Category, Name: string; Value: Boolean);
begin
  Write(Category, Name, Conv(Value));
end;

function TConfigFile.Read(const Category, Name: string; const Default: string = ''): string;
var
  i, j : LongInt;
begin
  Result := Default;
  for i := 0 to Length(Data) - 1 do
    if Category = Data[i].Category then
      for j := 0 to Length(Data[i].Params) - 1 do
        if Data[i].Params[j].Name = Name then
        begin
          Result := Data[i].Params[j].Value;
          Exit;
        end;
end;

function TConfigFile.Read(const Category, Name: string; Default: LongInt): LongInt;
begin
  Result := Conv(Read(Category, Name, ''), Default);
end;

function TConfigFile.Read(const Category, Name: string; Default: Single): Single;
begin
  Result := Conv(Read(Category, Name, ''), Default);
end;

function TConfigFile.Read(const Category, Name: string; Default: Boolean): Boolean;
begin
  Result := Conv(Read(Category, Name, ''), Default);
end;

function TConfigFile.CategoryName(Idx: LongInt): string;
begin
  if (Idx >= 0) and (Idx < Length(Data)) then
    Result := Data[Idx].Category
  else
    Result := '';
end;
{$ENDREGION}

{$REGION 'TXMLParam'}
constructor TXMLParams.Create(const Text: string);
var
  i          : LongInt;
  Flag       : (F_BEGIN, F_NAME, F_VALUE);
  ParamIdx   : LongInt;
  IndexBegin : LongInt;
  ReadValue  : Boolean;
  TextFlag   : Boolean;
begin
  Flag       := F_BEGIN;
  ParamIdx   := -1;
  IndexBegin := 1;
  ReadValue  := False;
  TextFlag   := False;
  for i := 1 to Length(Text) do
    case Flag of
      F_BEGIN :
        if Text[i] <> ' ' then
        begin
          ParamIdx := Length(FParams);
          SetLength(FParams, ParamIdx + 1);
          FParams[ParamIdx].Name  := '';
          FParams[ParamIdx].Value := '';
          Flag := F_NAME;
          IndexBegin := i;
        end;
      F_NAME :
        if Text[i] = '=' then
        begin
          FParams[ParamIdx].Name := Trim(Copy(Text, IndexBegin, i - IndexBegin));
          Flag := F_VALUE;
          IndexBegin := i + 1;
        end;
      F_VALUE :
        begin
          if Text[i] = '"' then
            TextFlag := not TextFlag;
          if (Text[i] <> ' ') and (not TextFlag) then
            ReadValue := True
          else
            if ReadValue then
            begin
              FParams[ParamIdx].Value := TrimChars(Trim(Copy(Text, IndexBegin, i - IndexBegin)), ['"']);
              Flag := F_BEGIN;
              ReadValue := False;
              ParamIdx := -1;
            end else
              continue;
        end;
    end;
  if ParamIdx <> -1 then
    FParams[ParamIdx].Value := TrimChars(Trim(Copy(Text, IndexBegin, Length(Text) - IndexBegin + 1)), ['"']);
  FCount := Length(FParams);
end;

function TXMLParams.GetParam(const Name: string): TXMLParam;
const
  NullParam : TXMLParam = (Name: ''; Value: '');
var
  i : LongInt;
begin
  for i := 0 to Count - 1 do
    if FParams[i].Name = Name then
    begin
      Result.Name  := FParams[i].Name;
      Result.Value := FParams[i].Value;
      Exit;
    end;
  Result := NullParam;
end;

function TXMLParams.GetParamI(Idx: LongInt): TXMLParam;
begin
  Result.Name  := FParams[Idx].Name;
  Result.Value := FParams[Idx].Value;
end;
{$ENDREGION}

{$REGION 'TXML'}
class function TXML.Load(const FileName: string): TXML;
var
  Stream   : TStream;
  Text     : string;
  Size     : LongInt;
  UTF8Text : UTF8String;
begin
  Stream := TStream.Init(FileName);
  if Stream <> nil then
  begin
    Size := Stream.Size;
    SetLength(UTF8Text, Size);
    Stream.Read(UTF8Text[1], Size);
    Text := UTF8ToString(UTF8Text);
    Result := Create(Text, 1);
    Stream.Free;
  end else
    Result := nil;
end;

constructor TXML.Create(const Text: string; BeginPos: LongInt);
var
  i, j : LongInt;
  Flag : (F_BEGIN, F_TAG, F_PARAMS, F_CONTENT, F_END);
  BeginIndex : LongInt;
  TextFlag   : Boolean;
begin
  TextFlag := False;
  Flag     := F_BEGIN;
  i := BeginPos - 1;

  BeginIndex := BeginPos;
  FContent := '';
  while i <= Length(Text) do
  begin
    Inc(i);
    case Flag of
    // waiting for new tag '<...'
      F_BEGIN :
        if Text[i] = '<' then
        begin
          Flag := F_TAG;
          BeginIndex := i + 1;
        end;
    // waiting for tag name '... ' or '.../' or '...>'
      F_TAG :
        begin
          case Text[i] of
            '>' : Flag := F_CONTENT;
            '/' : Flag := F_END;
            ' ' : Flag := F_PARAMS;
            '?', '!' :
              begin
                Flag := F_BEGIN;
                continue;
              end
          else
            continue;
          end;
          FTag := Trim(Copy(Text, BeginIndex, i - BeginIndex));
          BeginIndex := i + 1;
        end;
    // parse tag parameters
      F_PARAMS :
        begin
          if Text[i] = '"' then
            TextFlag := not TextFlag;
          if not TextFlag then
          begin
            case Text[i] of
              '>' : Flag := F_CONTENT;
              '/' : Flag := F_END;
            else
              continue;
            end;
            FParams := TXMLParams.Create(Trim(Copy(Text, BeginIndex, i - BeginIndex)));
            BeginIndex := i + 1;
          end;
        end;
    // parse tag content
      F_CONTENT :
        begin
          case Text[i] of
            '"' : TextFlag := not TextFlag;
            '<' :
              if not TextFlag then
              begin
                FContent := FContent + Trim(Copy(Text, BeginIndex, i - BeginIndex));
              // is new tag or my tag closing?
                for j := i to Length(Text) do
                  if Text[j] = '>' then
                  begin
                    if Trim(Copy(Text, i + 1, j - i - 1)) <> '/' + FTag then
                    begin
                      SetLength(FNode, Length(FNode) + 1);
                      FNode[Length(FNode) - 1] := TXML.Create(Text, i - 1);
                      i := i + FNode[Length(FNode) - 1].DataLen;
                      BeginIndex := i + 1;
                    end else
                      Flag := F_END;
                    break;
                  end;
              end
          end;
        end;
    // waiting for close tag
      F_END :
        if Text[i] = '>' then
        begin
          FDataLen := i - BeginPos;
          break;
        end;
    end;
  end;
  FCount := Length(FNode);
end;

destructor TXML.Destroy;
var
  i : LongInt;
begin
  for i := 0 to Count - 1 do
    NodeI[i].Free;
  Params.Free;
end;

function TXML.GetNode(const TagName: string): TXML;
var
  i : LongInt;
begin
  for i := 0 to Count - 1 do
    if FNode[i].Tag = TagName then
    begin
      Result := FNode[i];
      Exit;
    end;
  Result := nil;
end;

function TXML.GetNodeI(Idx: LongInt): TXML;
begin
  Result := FNode[Idx];
end;
{$ENDREGION}

{$REGION 'TThread'}
procedure ThreadProc(var Thread: TThread); stdcall;
begin
  Thread.FProc(Thread.FParam);
  Thread.FDone := True;
end;

procedure TThread.Init(Proc: TThreadProc; Param: Pointer; Activate: Boolean);
var
  Flag : LongWord;
begin
  FActive := Activate;
{$IFDEF WINDOWS}
  if FActive then
    Flag := 0
  else
    Flag := 4; // CREATE_SUSPENDED;
  FDone  := False;
  FProc  := Proc;
  FParam := Param;
  FHandle := CreateThread(nil, 0, @ThreadProc, @Self, Flag, nil);
{$ENDIF}
end;

procedure TThread.Free;
begin
{$IFDEF WINDOWS}
  TerminateThread(FHandle, 0);
{$ENDIF}
end;

procedure TThread.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
  {$IFDEF WINDOWS}
    if Value then
      ResumeThread(FHandle)
    else
      SuspendThread(FHandle);
  {$ENDIF}
  end;
end;

procedure TThread.SetCPUMask(Value: LongInt);
begin
{$IFDEF WINDOWS}
  FDone := True;
  SetThreadAffinityMask(FHandle, Value);
{$ENDIF}
end;

procedure TThread.Wait(ms: LongWord);
begin
{$IFDEF WINDOWS}
  Sleep(ms);
{$ENDIF}
end;
{$ENDREGION}

{$REGION 'TList'}
procedure TList.Init(Capacity: LongInt);
begin
  FItems := nil;
  FCount := 0;
  FCapacity := Capacity;
end;

procedure TList.Free(FreeClass: Boolean);
var
  i : LongInt;
begin
  if FreeClass then
    for i := 0 to Count - 1 do
      TObject(FItems[i]).Free;
  FItems := nil;
  FCount := 0;
end;

procedure TList.BoundsCheck(Index: LongInt);
begin
  if (Index < 0) or (Index >= FCount) then
    Assert('List index out of bounds (' + Conv(Index) + ')');
end;

function TList.GetItem(Index: LongInt): Pointer;
begin
  BoundsCheck(Index);
  Result := FItems[Index];
end;

procedure TList.SetItem(Index: LongInt; Value: Pointer);
begin
  BoundsCheck(Index);
  FItems[Index] := Value;
end;

function TList.IndexOf(Item: Pointer): LongInt;
var
  i : LongInt;
begin
  for i := 0 to FCount - 1 do
    if FItems[i] = Item then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TList.Add(Item: Pointer): LongInt;
begin
  if FCount mod FCapacity = 0 then
    SetLength(FItems, Length(FItems) + FCapacity);
  FItems[FCount] := Item;
  Result := FCount;
  Inc(FCount);
end;

procedure TList.Delete(Index: LongInt; FreeClass: Boolean);
begin
  BoundsCheck(Index);
  if FreeClass then
    TObject(FItems[Index]).Free;
  Move(FItems[Index + 1], FItems[Index], (FCount - Index - 1) * SizeOf(FItems[0]));
  Dec(FCount);
  if Length(FItems) - FCount + 1 > FCapacity then
    SetLength(FItems, Length(FItems) - FCapacity);
end;

procedure TList.Insert(Index: LongInt; Item: Pointer);
begin
  BoundsCheck(Index);
  Add(nil);
  Move(FItems[Index], FItems[Index + 1], (FCount - Index - 1) * SizeOf(FItems[0]));
  FItems[Index] := Item;
end;

procedure TList.Sort(CompareFunc: TListCompareFunc);

  procedure SortFragment(L, R: LongInt);
  var
    i, j : Integer;
    P, T : Pointer;
  begin
    repeat
      i := L;
      j := R;
      P := FItems[(L + R) div 2];
      repeat
        while CompareFunc(FItems[i], P) < 0 do
          Inc(i);
        while CompareFunc(FItems[j], P) > 0 do
          Dec(j);
        if i <= j then
        begin
          T := FItems[i];
          FItems[i] := FItems[j];
          FItems[j] := T;
          Inc(i);
          Dec(j);
        end;
      until i > j;
      if L < j then
        SortFragment(L, j);
      L := i;
    until i >= R;
  end;

begin
  if FCount > 1 then
    SortFragment(0, FCount - 1);
end;
{$ENDREGION}

{$REGION 'Utils'}
function Rect(Left, Top, Right, Bottom: LongInt): TRect;
begin
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Right  := Right;
  Result.Bottom := Bottom;
end;

function RGBA(R, G, B, A: Byte): TRGBA;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := A;
end;

function Conv(const Str: string; Def: LongInt): LongInt;
var
  Code : LongInt;
begin
  Val(Str, Result, Code);
  if Code <> 0 then
    Result := Def;
end;

function Conv(const Str: string; Def: Single): Single;
var
  Code : LongInt;
begin
  Val(Str, Result, Code);
  if Code <> 0 then
    Result := Def;
end;

function Conv(const Str: string; Def: Boolean = False): Boolean;
var
  LStr : string;
begin
  LStr := LowerCase(Str);
  if LStr = 'true' then
    Result := True
  else
    if LStr = 'false' then
      Result := False
    else
      Result := Def;
end;

function Conv(Value: LongInt): string;
var
  Res : string[32];
begin
  Str(Value, Res);
  Result := string(Res);
end;

function Conv(Value: Single; Digits: LongInt = 6): string;
var
  Res : string[32];
begin
  Str(Value:0:Digits, Res);
  Result := string(Res);
end;

function Conv(Value: Boolean): string;
begin
  if Value then
    Result := 'true'
  else
    Result := 'false';
end;

function LowerCase(const Str: string): string;
var
  i : LongInt;
begin
  Result := Str;
  for i := 1 to Length(Str) do
    if AnsiChar(Result[i]) in ['A'..'Z', 'À'..'ß'] then
      Result[i] := Chr(Ord(Result[i]) + 32);
end;

function TrimChars(const Str: string; Chars: TCharSet): string;
var
  i, j : LongInt;
begin
  j := Length(Str);
  i := 1;
  while (i <= j) and (AnsiChar(Str[i]) in Chars) do
    Inc(i);
  if i <= j then
  begin
    while AnsiChar(Str[j]) in Chars do
      Dec(j);
    Result := Copy(Str, i, j - i + 1);
  end else
    Result := '';
end;

function Trim(const Str: string): string;
begin
  Result := TrimChars(Str, [#9, #10, #13, #32]);
end;

function DeleteChars(const Str: string; Chars: TCharSet): string;
var
  i, j : LongInt;
begin
  j := 0;
  SetLength(Result, Length(Str));
  for i := 1 to Length(Str) do
    if not (AnsiChar(Str[i]) in Chars) then
    begin
      Inc(j);
      Result[j] := Str[i];
    end;
  SetLength(Result, j);
end;

function ExtractFileDir(const Path: string): string;
var
  i : LongInt;
begin
  for i := Length(Path) downto 1 do
    if (Path[i] = '\') or (Path[i] = '/') then
    begin
      Result := Copy(Path, 1, i);
      Exit;
    end;
  Result := '';
end;

function MemCmp(p1, p2: Pointer; Size: LongInt): LongInt;
asm
       PUSH    ESI
       PUSH    EDI
       MOV     ESI,P1
       MOV     EDI,P2
       XOR     EAX,EAX
       REPE    CMPSB
       JE      @@1
       MOVZX   EAX,BYTE PTR [ESI-1]
       MOVZX   EDX,BYTE PTR [EDI-1]
       SUB     EAX,EDX
@@1:   POP     EDI
       POP     ESI
end;
{$ENDREGION}

// FileSys =====================================================================
{$REGION 'TFilePack'}
{$IFNDEF NO_FILESYS}
procedure TFilePack.Init(const PackName: string);
var
  Stream   : TStream;
  AName    : AnsiString;
  Len      : Byte;
  i, Count : LongInt;
begin
  FName := PackName;
  Stream := TStream.Init(PackName);
  Stream.Read(Count, SizeOf(Count));
  SetLength(FTable, Count);
  for i := 0 to Length(FTable) - 1 do
    with FTable[i] do
    begin
      Stream.Read(Len, SizeOf(Len));
      SetLength(AName, Len);
      Stream.Read(AName[1], Len);
      FileName := string(AName);
      Stream.Read(Pos, SizeOf(Pos));
      Stream.Read(Size, SizeOf(Size));
    end;
  Stream.Free;
end;

function TFilePack.Open(const FileName: string; out Stream: TStream): Boolean;
var
  i : LongInt;
begin
  for i := 0 to Length(FTable) - 1 do
    if FTable[i].FileName = FileName then
    begin
      Stream := TStream.Init(FName);
      Stream.SetBlock(FTable[i].Pos, FTable[i].Size);
      Result := True;
      Exit;
    end;
  Result := False;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TFileSys'}
{$IFNDEF NO_FILESYS}
procedure TFileSys.Init;
begin
  chdir(ExtractFileDir(ParamStr(0)));
end;

function TFileSys.Open(const FileName: string; RW: Boolean): TStream;
var
  i, io : LongInt;
begin
  Result := nil;
  if not RW then
    for i := 0 to Length(FPack) - 1 do
      if FPack[i].Open(FileName, Result) then
        Exit;

  io := 1;
  Result := TStream.Create;
  {$I-}
  for i := 0 to Length(FPath) - 1 do
  begin
    FileMode := 2;
    AssignFile(Result.F, FPath[i] + FileName);
    if RW then
    begin
      FileMode := 1;
      Rewrite(Result.F, 1)
    end else
    begin
      FileMode := 0;
      Reset(Result.F, 1);
    end;
    io := IOResult;
    if io = 0 then
    begin
      Result.SType := stFile;
      Result.FSize := FileSize(Result.F);
      Result.FPos  := 0;
      Result.FBPos := 0;
      break;
    end;
  end;

  if io <> 0 then
  begin
//    Assert('Can''t open "' + FileName + '"');
    Result.Free;
    Result := nil;
  end;
  {$I+}
end;

procedure TFileSys.Clear;
begin
  FPack := nil;
  SetLength(FPath, 1);
  FPath[0] := '';
end;

procedure TFileSys.PackAdd(const PackName: string);
begin
  SetLength(FPack, Length(FPack) + 1);
  FPack[Length(FPack) - 1].Init(PackName);
end;

procedure TFileSys.PackDel(const PackName: string);
var
  i : LongInt;
begin
  for i := 0 to Length(FPack) - 1 do
    if FPack[i].Name = PackName then
    begin
      FPack[i] := FPack[Length(FPack) - 1];
      SetLength(FPack, Length(FPack) - 1);
    end;
end;

procedure TFileSys.PathAdd(const PathName: string);
begin
  SetLength(FPath, Length(FPath) + 1);
  FPath[Length(FPath) - 1] := PathName;
end;

procedure TFileSys.PathDel(const PathName: string);
var
  i : LongInt;
begin
  for i := 0 to Length(FPath) - 1 do
    if FPath[i] = PathName then
    begin
      FPath[i] := FPath[Length(FPath) - 1];
      SetLength(FPath, Length(FPath) - 1);
    end;
end;
{$ENDIF}
{$ENDREGION}

// Screen ======================================================================
{$REGION 'TScreen'}
{$IFDEF WINDOWS}
function WndProc(Hwnd, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
const
  MaxPoint : TPoint = (X: 10000; Y: 10000);
var
  Rect : TRect;
begin
  Result := 0;
  case Msg of
  // Close window
    WM_DESTROY :
      Quit;
  // Activation / Deactivation
    WM_ACTIVATEAPP :
      with Screen do
      begin
        FActive := Word(WParam) = 1;
        if FullScreen then
        begin
          if FActive then
            ShowWindow(Handle, SW_SHOW)
          else
            ShowWindow(Handle, SW_MINIMIZE);
          FullScreen := FActive;
          FFullScreen := True;
        end;
        Input.Reset;
      end;

    WM_SIZE :
      begin
        {$IFNDEF NO_GUI}
        GetClientRect(Screen.Handle, Rect);
        Screen.FWidth  := Rect.Right - Rect.Left;
        Screen.FHeight := Rect.Bottom - Rect.Top;
        if GUI <> nil then
        begin
          GUI.Resize(0, 0, Screen.Width, Screen.Height);
          GUI.Realign;
        end;
        {$ENDIF}
      //  Screen.Resize(Word(LParam), Word(LParam shr 16));
      end;
  // Set max window size
    WM_GETMINMAXINFO :
      TMinMaxInfo(Pointer(LParam)^).ptMaxTrackSize := MaxPoint;
  // Keyboard
    WM_KEYDOWN, WM_KEYDOWN + 1, WM_SYSKEYDOWN, WM_SYSKEYDOWN + 1 :
      begin
        Input.SetState(Input.Convert(WParam), (Msg = WM_KEYDOWN) or (Msg = WM_SYSKEYDOWN));
        if (Msg = WM_SYSKEYDOWN) and (WParam = 13) and (not Screen.FCustom) then // Alt + Enter
          Screen.FullScreen := not Screen.FullScreen;
      end;
    WM_CHAR :
      if (WParam > 31) then
        Input.FText := Input.FText + WideChar(WParam);
  // Mouse
    WM_LBUTTONDOWN..WM_LBUTTONDOWN + 2 : Input.SetState(ikMouseL, (Msg <> WM_LBUTTONDOWN + 1));
    WM_RBUTTONDOWN..WM_RBUTTONDOWN + 2 : Input.SetState(ikMouseR, (Msg <> WM_RBUTTONDOWN + 1));
    WM_MBUTTONDOWN..WM_MBUTTONDOWN + 2 : Input.SetState(ikMouseM, (Msg <> WM_MBUTTONDOWN + 1));
    WM_MOUSEWHEEL :
      begin
        Inc(Input.Mouse.Delta.Wheel, SmallInt(wParam  shr 16) div 120);
        Input.SetState(ikMouseWheelUp, SmallInt(wParam shr 16) > 0);
        Input.SetState(ikMouseWheelDown, SmallInt(wParam shr 16) < 0);
      end;
    else
      if Screen.FCustom then
        Result := TWndProc(GetWindowLongW(Hwnd, GWL_USERDATA))(Hwnd, Msg, WParam, LParam)
      else
        Result := DefWindowProcW(Hwnd, Msg, WParam, LParam);
  end;
  
// set/release mouse capture
  if (Msg = WM_LBUTTONDOWN) or (Msg = WM_RBUTTONDOWN) or (Msg = WM_MBUTTONDOWN) then
    SetCapture(Screen.Handle);

  if ((Msg = WM_LBUTTONDOWN + 1) or (Msg = WM_RBUTTONDOWN + 1) or (Msg = WM_MBUTTONDOWN + 1)) and
      not (Input.Down[ikMouseL] and Input.Down[ikMouseR] and Input.Down[ikMouseM]) then
    ReleaseCapture;
end;
{$ENDIF}
{$IFDEF LINUX}
procedure WndProc(var Event: TXEvent);
var
  Key : TInputKey;
begin
  case Event._type of
  // Close window
    ClientMessage :
      if (Event.xclient.message_type = WM_PROTOCOLS) and
         (LongWord(Event.xclient.data.l[0]) = WM_DESTROY) then
        Quit;
  // Activation / Deactivation
    FocusIn, FocusIn + 1 :
      with Screen do
        if (Event.xwindow = Handle) and (Active <> (Event._type = FocusIn)) then
        begin
          FActive := Event._type = FocusIn;
          if FullScreen then
          begin
            FullScreen := FActive;
            FFullScreen := True;
          end;
          Input.Reset;
        end;
  // Keyboard
    KeyPress, KeyPress + 1 :
      with Event.xkey do
      begin
        Input.SetState(Input.Convert(XLookupKeysym(@Event, 0)), Event._type = KeyPress);
        if (state and 8 <> 0) and (KeyCode = 36) and (Event._type = KeyPress) then // Alt + Enter
          Screen.FullScreen := not Screen.FullScreen;
      end;
  // Mouse
    ButtonPress, ButtonPress + 1 :
      begin
        case Event.xkey.KeyCode of
          1 : Key := ikMouseL;
          2 : Key := ikMouseR;
          3 : Key := ikMouseM;
          4 : Key := ikMouseWheelUp;
          5 : Key := ikMouseWheelDown;
        else
          Key := KK_NONE;
        end;
        Input.SetState(Key, Event._type = ButtonPress);
        if Event._type = ButtonPress then
          case Key of
            ikMouseWheelUp   : Inc(Input.Mouse.Delta.Wheel);
            ikMouseWheelDown : Dec(Input.Mouse.Delta.Wheel);
          end;
      end;
  end;
end;
{$ENDIF}
{$IFDEF DARWIN}
function WndProc(inHandlerCallRef, inEvent, inUserData: Pointer): LongInt; cdecl;
var
  EventClass, EventKind, Key : LongWord;
  Button : Word;
begin
  EventClass := GetEventClass(inEvent);
  EventKind  := GetEventKind(inEvent);
  case EventClass of
    kEventClassWindow :
      case EventKind of
        kEventWindowClosed :
          Quit;
        kEventWindowActivated, kEventWindowDeactivated :
          with Screen do
          begin
            FActive := EventKind = kEventWindowActivated;
            if FullScreen then
            begin
            {
              if FActive then
                ShowWindow(Handle, SW_SHOW)
              else
                ShowWindow(Handle, SW_MINIMIZE);
            }
              FullScreen := FActive;
              FFullScreen := True;
            end;
            Input.Reset;
          end;
      end;
    kEventClassKeyboard :
      begin
        GetEventParameter(inEvent, kEventParamKeyCode, LongWord('magn'), nil, SizeOf(Key), nil, @Key);
        Input.SetState(Input.Convert(Key), EventKind <> kEventRawKeyUp);
      end;
    kEventClassMouse :
      if EventKind = kEventMouseWheelMoved then
      begin
        GetEventParameter(inEvent, kEventParamMouseWheelDelta, LongWord('long'), nil, SizeOf(Wheel), nil, @Wheel);
        Inc(Input.Mouse.Delta.Wheel, Wheel);
        Input.SetState(ikMouseWheelUp, Wheel > 0);
        Input.SetState(ikMouseWheelDown, Wheel < 0);
      end else
      begin
        GetEventParameter(inEvent, kEventParamMouseButton, LongWord('mbtn'), nil, SizeOf(Button), nil, @Button);
        Input.SetState(TInputKey(Ord(ikMouseL) + Button - kEventMouseButtonPrimary), EventKind = kEventMouseDown);
      end;
  end;
  Result := CallNextEventHandler(inHandlerCallRef, inEvent);
end;
{$ENDIF}

procedure TScreen.Init;
{$IFDEF WINDOWS}
type
  TwglChoosePixelFormatARB = function (DC: LongWord; const piList, pfFList: Pointer; nMaxFormats: LongWord; piFormats, nNumFormats: Pointer): Boolean; stdcall;
const
  AttribF : array [0..1] of Single = (0, 0);
var
  PFD      : TPixelFormatDescriptor;
  ChoisePF : TwglChoosePixelFormatARB;
  PFIdx    : LongInt;
  PFCount  : LongWord;
  PHandle  : LongWord;
  CursorMaskA, CursorMaskX : array [0..127] of Byte;
begin
  FWidth   := 800;
  FHeight  := 600;
  FCaption := 'CoreX';
// Init structures
  FillChar(PFD, SizeOf(PFD), 0);
  with PFD do
  begin
    nSize        := SizeOf(PFD);
    nVersion     := 1;
    dwFlags      := $25;
    cColorBits   := 32;
    cDepthBits   := 24;
    cStencilBits := 8;
  end;
  PFIdx := -1;
// Choise multisample format (OpenGL AntiAliasing)
  if FAntiAliasing <> aa0x then
  begin
    LongWord(Pointer(@PFDAttrib[1])^) := 1 shl (Ord(FAntiAliasing) - 1); // Set num WGL_SAMPLES
  // Temp window
    PHandle := CreateWindowExW(0, 'EDIT', nil, 0, 0, 0, 0, 0, 0, 0, 0, nil);
    DC := GetDC(PHandle);
    SetPixelFormat(DC, ChoosePixelFormat(DC, @PFD), @PFD);
    RC := wglCreateContext(DC);
    wglMakeCurrent(DC, RC);
    ChoisePF := TwglChoosePixelFormatARB(wglGetProcAddress('wglChoosePixelFormatARB'));
    if @ChoisePF <> nil then
      ChoisePF(DC, @PFDAttrib, @AttribF, 1, @PFIdx, @PFCount);
    wglMakeCurrent(0, 0);
    wglDeleteContext(RC);
    ReleaseDC(PHandle, DC);
    DestroyWindow(PHandle);
  end;
  FCustom := Handle <> 0;
// Window
  if not FCustom then
  begin
    Handle := CreateWindowExW(0, 'STATIC', PWideChar(WideString(FCaption)), 0,
                              0, 0, 0, 0, 0, 0, HInstance, nil);
    SendMessageA(Handle, WM_SETICON, 1, LoadIconA(HInstance, 'MAINICON'));
    SetWindowLongW(Handle, GWL_WNDPROC, LongInt(@WndProc));
  end else
  begin
    SetWindowLongW(Handle, GWL_USERDATA, SetWindowLongW(Handle, GWL_WNDPROC, LongInt(@WndProc)));
    SetFocus(Handle);
  end;

  FillChar(CursorMaskA, SizeOf(CursorMaskA), $FF);
  FillChar(CursorMaskX, SizeOf(CursorMaskX), $00);
  CursorArrow := GetClassLongW(Handle, GCL_HCURSOR);
  CursorNone  := CreateCursor(hInstance, 0, 0, 32, 32, @CursorMaskA, @CursorMaskX);

// OpenGL
  DC := GetDC(Handle);
  if PFIdx = -1 then
    SetPixelFormat(DC, ChoosePixelFormat(DC, @PFD), @PFD)
  else
    SetPixelFormat(DC, PFIdx, @PFD);
  RC := wglCreateContext(DC);
  wglMakeCurrent(DC, RC);
  Render.Init;
  FFPSTime := Render.Time;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Rot    : Word;
  Pixmap : LongWord;
  Color  : TXColor;
begin
  FWidth   := 800;
  FHeight  := 600;
  FCaption := 'CoreX';
// Init objects
  XDisp := XOpenDisplay(nil);
  XScr  := XDefaultScreen(XDisp);
  LongWord(Pointer(@PFDAttrib[1])^) := 1 shl (Ord(FAntiAliasing) - 1); // Set num GLX_SAMPLES
  XVisual := glXChooseVisual(XDisp, XScr, @PFDAttrib);
  XRoot   := XRootWindow(XDisp, XVisual^.screen);
  Pixmap  := XCreatePixmap(XDisp, XRoot, 1, 1, 1);
  FillChar(Color, SizeOf(Color), 0);
  XWndAttr.cursor := 0;//XCreatePixmapCursor(XDisp, Pixmap, Pixmap, @Color, @Color, 0, 0);
  XWndAttr.background_pixel := XBlackPixel(XDisp, XScr);
  XWndAttr.colormap   := XCreateColormap(XDisp, XRoot, XVisual^.visual, 0);
  XWndAttr.event_mask := $20204F; // Key | Button | Pointer | Focus
// Set client messages
  WM_DESTROY   := XInternAtom(XDisp, 'WM_DELETE_WINDOW', True);
  WM_PROTOCOLS := XInternAtom(XDisp, 'WM_PROTOCOLS', True);
// OpenGL Init
  XContext := glXCreateContext(XDisp, XVisual, nil, True);
// Screen Settings
  ScrSizes   := XRRSizes(XDisp, XRRRootToScreen(XDisp, XRoot), @SizesCount);
  ScrConfig  := XRRGetScreenInfo(XDisp, XRoot);
  DefSizeIdx := XRRConfigCurrentConfiguration(ScrConfig, @Rot);

  Render.Init;
  FFPSTime := Render.Time;
end;
{$ENDIF}
{$IFDEF DARWIN}
const
  Events : array [0..8, 0..1] of LongWord = (
    (kEventClassWindow, kEventWindowClosed),
    (kEventClassWindow, kEventWindowActivated),
    (kEventClassWindow, kEventWindowDeactivated),
    (kEventClassKeyboard, kEventRawKeyDown),
    (kEventClassKeyboard, kEventRawKeyUp),
    (kEventClassKeyboard, kEventRawKeyRepeat),
    (kEventClassMouse, kEventMouseDown),
    (kEventClassMouse, kEventMouseUp),
    (kEventClassMouse, kEventMouseWheelMoved)
  );
var
  Size   : TMacRect;
  Format : TAGLPixelFormat;
begin
  FWidth   := 800;
  FHeight  := 600;
  FCaption := 'CoreX';

  Format  := aglChoosePixelFormat(nil, 0, @PFDAttrib);
  Context := aglCreateContext(Format, nil);
  aglDestroyPixelFormat(Format);

  Size.Left := 0;
  Size.Top  := 0;
  Size.Right  := Size.Left + FWidth;
  Size.Bottom := Size.Top + FHeight;

  CreateNewWindow(kDocumentWindowClass, kWindowCloseBoxAttribute or kWindowCollapseBoxAttribute or kWindowStandardHandlerAttribute, Size, Handle);
  SelectWindow(Handle);
  ShowWindow(Handle);
  aglSetDrawable(Context, GetWindowPort(Handle));
  aglSetCurrentContext(Context);

  InstallEventHandler(GetApplicationEventTarget, NewEventHandlerUPP(@WndProc), Length(Events), @Events, nil, nil);

  Render.Init;
  FFPSTime := Render.Time;
end;
{$ENDIF}

procedure TScreen.Free;
begin
// Restore video mode
  FullScreen := False;
  Render.Free;
{$IFDEF WINDOWS}
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  ReleaseDC(Handle, DC);
  if not FCustom then
    DestroyWindow(Handle);
{$ENDIF}
{$IFDEF LINUX}
  XRRFreeScreenConfigInfo(ScrConfig);
  glXMakeCurrent(XDisp, 0, nil);
  XFree(XVisual);
  glXDestroyContext(XDisp, XContext);
  if not FCustom then
    XDestroyWindow(XDisp, Handle);
  XCloseDisplay(XDisp);
{$ENDIF}
{$IFDEF DARWIN}
  aglSetCurrentContext(nil);
  aglDestroyContext(Context);
  if not FCustom then
    ReleaseWindow(Handle);
{$ENDIF}
end;

procedure TScreen.Update;
{$IFDEF WINDOWS}
var
  Msg : TMsg;
begin
  while PeekMessageW(Msg, 0, 0, 0, 1) do
  begin
    TranslateMessage(Msg);
    DispatchMessageW(Msg);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Event : TXEvent;
begin
  while XPending(XDisp) <> 0 do
  begin
    XNextEvent(XDisp, @Event);
    WndProc(Event);
  end;
end;
{$ENDIF}
{$IFDEF DARWIN}
var
  Event : TMacEventRecord;
begin
  while GetNextEvent($FFFF, Event) do;
end;
{$ENDIF}

procedure TScreen.Restore;
{$IFDEF WINDOWS}
var
  Style : LongWord;
  Rect  : TRect;
begin
  if FCustom then
    Exit;
// Change main window style
  if not FFullScreen then
  begin
    if FResizing then
      Style := $CF0000    // WS_OVERLAPPEDWINDOW
    else
      Style := $CA0000;   // WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX
  end else
    Style := $80000000; // WS_POPUP
  SetWindowLongW(Handle, GWL_STYLE, Style or WS_VISIBLE);

  Rect.Left   := 0;
  Rect.Top    := 0;
  Rect.Right  := Width;
  Rect.Bottom := Height;
  AdjustWindowRect(Rect, Style, False);
  with Rect do
    if FFullScreen then
      SetWindowPos(Handle, LongWord(-2 + Ord(FFullScreen)), 0, 0, Right - Left, Bottom - Top, $20)
    else
      SetWindowPos(Handle, LongWord(-2 + Ord(FFullScreen)), FX, FY, Right - Left, Bottom - Top, $20);
  Render.Viewport := CoreX.Rect(0, 0, Width, Height);
  Render.Clear(True, False);
  Swap;
  VSync := FVSync;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Mask      : LongWord;
  XSizeHint : TXSizeHints;
begin
// Recreate window
  XUngrabKeyboard(XDisp, 0);
  XUngrabPointer(XDisp, 0);
  glXMakeCurrent(XDisp, 0, nil);
  if Handle <> 0 then
    XDestroyWindow(XDisp, Handle);
  glXWaitX;

  XWndAttr.override_redirect := FFullScreen;
  if FFullScreen then
    Mask := $6A00 // CWColormap or CWEventMask or CWCursor or CWOverrideRedirect
  else
    Mask := $6800; // without CWOverrideRedirect
// Create new window
  Handle := XCreateWindow(XDisp, XRoot,
                          0, 0, Width, Height, 0,
                          XVisual^.depth, 1,
                          XVisual^.visual,
                          Mask, @XWndAttr);
// Change size
  XSizeHint.flags := $34; // PPosition or PMinSize or PMaxSize;
  XSizeHint.x := 0;
  XSizeHint.y := 0;
  XSizeHint.min_w := Width;
  XSizeHint.min_h := Height;
  XSizeHint.max_w := Width;
  XSizeHint.max_h := Height;
  XSetWMNormalHints(XDisp, Handle, @XSizeHint);
  XSetWMProtocols(XDisp, Handle, @WM_DESTROY, 1);
  Caption := FCaption;

  glXMakeCurrent(XDisp, Handle, XContext);

  XMapWindow(XDisp, Handle);
  glXWaitX;
  if FFullScreen Then
  begin
    XGrabKeyboard(XDisp, Handle, True, 1, 1, 0);
    XGrabPointer(XDisp, Handle, True, 4, 1, 1, Handle, 0, 0);
  end;
  Render.Viewport := CoreX.Rect(0, 0, Width, Height);
  VSync := FVSync;
  Swap;
  Swap;
  VSync := FVSync;
end;
{$ENDIF}
{$IFDEF DARWIN}
//var
//  Size : TMacRect;
begin                {
  if FFullScreen then
  begin
    Size.Left := 0;
    Size.Top  := 0;
  end else
  begin
    Size.Left := FX;
    Size.Top  := FY;
  end;
  Size.Right  := Size.Left + FWidth;
  Size.Bottom := Size.Top + FHeight;

  if Handle <> 0 then
  begin
    aglSetCurrentContext(nil);
    ReleaseWindow(Handle);
  end;

  CreateNewWindow(kDocumentWindowClass, kWindowCloseBoxAttribute or kWindowCollapseBoxAttribute or kWindowStandardHandlerAttribute, Size, Handle);
  SelectWindow(Handle);
  ShowWindow(Handle);
  aglSetDrawable(Context, GetWindowPort(Handle));
  aglSetCurrentContext(Context);
}
  gl.Viewport(0, 0, Width, Height);
end;
{$ENDIF}

procedure TScreen.SetFullScreen(Value: Boolean);
{$IFDEF WINDOWS}
var
  DevMode : TDeviceMode;
  Rect    : TRect;
begin
  if Value then
  begin
    GetWindowRect(Handle, Rect);
    if FFullScreen <> Value then
    begin
      FX := Rect.Left;
      FY := Rect.Top;
    end;
    FillChar(DevMode, SizeOf(DevMode), 0);
    DevMode.dmSize := SizeOf(DevMode);
    EnumDisplaySettingsA(nil, 0, @DevMode);
    with DevMode do
    begin
      dmPelsWidth  := Width;
      dmPelsHeight := Height;
      dmBitsPerPel := 32;
      dmFields     := $1C0000; // DM_BITSPERPEL or DM_PELSWIDTH  or DM_PELSHEIGHT;
    end;
    ChangeDisplaySettingsA(@DevMode, $04); // CDS_FULLSCREEN
  end else
    if FFullScreen <> Value then
      ChangeDisplaySettingsA(nil, 0);
  FFullScreen := Value;
  Restore;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  i, SizeIdx : LongInt;
begin
  if Value then
  begin
  // mode search
    SizeIdx := -1;
    for i := 0 to SizesCount - 1 do
      if (ScrSizes[i].Width = Width) and (ScrSizes[i].Height = Height) then
      begin
        SizeIdx := i;
        break;
      end;
  end else
    SizeIdx := DefSizeIdx;
// set current video mode
  if SizeIdx <> -1 then
    XRRSetScreenConfigAndRate(XDisp, ScrConfig, XRoot, SizeIdx, 1, 0, 0);
  FFullScreen := Value;
  Restore;
end;
{$ENDIF}
{$IFDEF DARWIN}
begin
end;
{$ENDIF}

procedure TScreen.SetVSync(Value: Boolean);
begin
  FVSync := Value;
  if @gl.SwapInterval <> nil then
    if FFullScreen then
      gl.SwapInterval(Ord(FVSync))
    else
      gl.SwapInterval(0);
end;

procedure TScreen.SetCaption(const Value: string);
begin
  FCaption := Value;
{$IFDEF WINDOWS}
  SetWindowTextA(Handle, PAnsiChar(AnsiString(Value)));
{$ENDIF}
{$IFDEF LINUX}
  XStoreName(XDisp, Handle, PAnsiChar(Value));
{$ENDIF}
{$IFDEF DARWIN}
  SetWTitle(Handle, Value);
{$ENDIF}
end;

procedure TScreen.SetResizing(const Value: Boolean);
begin
  FResizing := Value;
  Restore;
end;

procedure TScreen.ShowCursor(Value: Boolean);
begin
{$IFDEF WINDOWS}
  if Value then
    SetClassLongW(Handle, GCL_HCURSOR, CursorArrow)
  else
    SetClassLongW(Handle, GCL_HCURSOR, CursorNone);
{$ENDIF}
end;

procedure TScreen.Resize(W, H: LongInt);
begin
  FWidth  := W;
  FHeight := H;
  FullScreen := FullScreen; // Resize screen
end;

procedure TScreen.Swap;
begin
{$IFDEF WINDOWS}
  SwapBuffers(DC);
{$ENDIF}
{$IFDEF LINUX}
  glXSwapBuffers(XDisp, Handle);
{$ENDIF}
{$IFDEF DARWIN}
  aglSwapBuffers(Context);
{$ENDIF}
  Inc(FFPSIdx);
  if Render.Time - FFPSTime >= 1000 then
  begin
    Render.FFPS := FFPSIdx;
    FFPSIdx  := 0;
    FFPSTime := Render.Time;
  {$IFDEF FPS_CAPTION}
    Caption := 'CoreX [FPS: ' + Conv(Render.FPS) + ']';
  {$ENDIF}
  end;
end;
{$ENDREGION}

// Input =======================================================================
{$REGION 'TInput'}
procedure TInput.Init;
begin
{$IFNDEF NO_INPUT_JOY}
  {$IFDEF WINDOWS}
  // Initialize Joystick
    Joy.FReady := False;
    if (joyGetNumDevs <> 0) and (joyGetDevCapsA(0, @JoyCaps, SizeOf(JoyCaps)) = 0) then
      with JoyCaps, JoyInfo do
      begin
        dwSize  := SizeOf(JoyInfo);
        dwFlags := $08FF; // JOY_RETURNALL or JOY_USEDEADZONE;
        if wCaps and JOYCAPS_POVCTS > 0 then
          dwFlags := dwFlags or JOY_RETURNPOVCTS;
        Joy.FReady := joyGetPosEx(0, @JoyInfo) = 0;
      end;
  {$ENDIF}
{$ENDIF}
// Reset key states
  Reset;
end;

procedure TInput.Free;
begin
  //
end;

procedure TInput.Reset;
begin
  FillChar(FDown, SizeOf(FDown), False);
  Update;
end;

function TInput.Convert(KeyCode: Word): TInputKey;
var
  Key : TInputKey;
begin
  for Key := Low(KeyCodes) to High(KeyCodes) do
    if KeyCodes[Key] = KeyCode then
    begin
      Result := Key;
      Exit;
    end;
  Result := ikNone;
end;

function TInput.GetDown(InputKey: TInputKey): Boolean;
begin
  Result := FDown[InputKey];
end;

function TInput.GetHit(InputKey: TInputKey): Boolean;
begin
  Result := FHit[InputKey];
end;

procedure TInput.SetState(InputKey: TInputKey; Value: Boolean);
begin
  if FDown[InputKey] and (not Value) then
  begin
    FHit[InputKey] := True;
    FLastKey := InputKey;
  end;
  FDown[InputKey] := Value;
end;

procedure TInput.SetCapture(Value: Boolean);
begin
  FCapture := Value;
  Screen.ShowCursor(not Value);
end;

procedure TInput.Update;
{$IFDEF WINDOWS}
var
  Rect  : TRect;
  Pos   : TPoint;
  CPos  : TPoint;
  {$IFNDEF NO_INPUT_JOY}
    i     : LongInt;
    JKey  : TInputKey;
    JDown : Boolean;

    function AxisValue(Value, Min, Max: LongWord): LongInt;
    begin
      if Max - Min <> 0 then
        Result := Round((Value + Min) / (Max - Min) * 200 - 100)
      else
        Result := 0;
    end;
  {$ENDIF}
{$ENDIF}
{$IFDEF LINUX}
var
  WRoot, WChild, Mask : LongWord;
  X, Y, rX, rY        : longInt;
{$ENDIF}
begin
  FillChar(FHit, SizeOf(FHit), False);
  FText    := '';
  FLastKey := ikNone;
  Mouse.Delta.Wheel := 0;
  SetState(ikMouseWheelUp, False);
  SetState(ikMouseWheelDown, False);

// Mouse
  {$IFDEF WINDOWS}
    GetWindowRect(Screen.Handle, Rect);
    GetCursorPos(Pos);
  {$ENDIF}
  {$IFDEF LINUX}
    Rect := CoreX.Rect(0, 0, Width div 2, Height div 2);
    XQueryPointer(XDisp, Handle, @WRoot, @WChild, @rX, @rY, @X, @Y, @Mask);
  {$ENDIF}
  {$IFDEF DARWIN}
    Rect := CoreX.Rect(FX, FY, FX + Width div 2, FY + Height div 2);
    GetGlobalMouse(Pos);
  {$ENDIF}
  if not FCapture then
  begin
  // Calc mouse cursor pos (Client Space)
  {$IFDEF WINDOWS}
    ScreenToClient(Screen.Handle, Pos);
  {$ENDIF}
    Mouse.Delta.X := Pos.X - Mouse.Pos.X;
    Mouse.Delta.Y := Pos.Y - Mouse.Pos.Y;
    Mouse.Pos.X := Pos.X;
    Mouse.Pos.Y := Pos.Y;
  end else
    if Screen.Active then // Main window active?
    begin
    // Window Center Pos (Screen Space)
      CPos.X := (Rect.Right + Rect.Left) div 2;
      CPos.Y := (Rect.Bottom + Rect.Top) div 2;
    // Calc mouse cursor position delta
      Mouse.Delta.X := Pos.X - CPos.X;
      Mouse.Delta.Y := Pos.Y - CPos.Y;
    // Centering cursor
      if (Mouse.Delta.X <> 0) or (Mouse.Delta.Y <> 0) then
      {$IFDEF WINDOWS}
        SetCursorPos(CPos.X, CPos.Y);
      {$ENDIF}
      {$IFDEF LINUX}
        XWarpPointer(XDisp, XScr, Handle, 0, 0, 0, 0, CPos.X, CPos.Y);
      {$ENDIF}
      {$IFDEF DARWIN}
        CGWarpMouseCursorPosition(CPos.X, CPos.Y);
      {$ENDIF}
      Inc(Mouse.Pos.X, Mouse.Delta.X);
      Inc(Mouse.Pos.Y, Mouse.Delta.Y);
    end else
    begin
    // No delta while window is not active
      Mouse.Delta.X := 0;
      Mouse.Delta.Y := 0;
    end;

{$IFNDEF NO_INPUT_JOY}
{$IFDEF WINDOWS}
// Joystick
  with Joy do
  begin
    FillChar(Axis, SizeOf(Axis), 0);
    POV := -1;
    if Ready and (joyGetPosEx(0, @JoyInfo) = 0) then
      with JoyCaps, JoyInfo, Axis do
      begin
      // Axis
        X := AxisValue(wX, wXmin, wXmax);
        Y := AxisValue(wY, wYmin, wYmax);
        if wCaps and JOYCAPS_HASZ > 0 then Z := AxisValue(wZ, wZmin, wZmax);
        if wCaps and JOYCAPS_HASR > 0 then R := AxisValue(wR, wRmin, wRmax);
        if wCaps and JOYCAPS_HASU > 0 then U := AxisValue(wU, wUmin, wUmax);
        if wCaps and JOYCAPS_HASV > 0 then V := AxisValue(wV, wVmin, wVmax);
      // Point-Of-View
        if (wCaps and JOYCAPS_HASPOV > 0) and (dwPOV and $FFFF <> $FFFF) then
          POV := dwPOV and $FFFF / 100;
      // Buttons
        for i := 0 to wNumButtons - 1 do
        begin
          JKey  := TInputKey(Ord(ikJoy1) + i);
          JDown := Input.Down[JKey];
          if (wButtons and (1 shl i) <> 0) xor JDown then
            Input.SetState(JKey, not JDown);
        end;
      end;
  end;
{$ENDIF}
{$ENDIF}
end;
{$ENDREGION}

// Sound =======================================================================
{$REGION 'TSample'}
{$IFNDEF NO_SOUND}
{ TSample }
constructor TSample.Create(Size: LongInt; Data: PSmallIntArray);
begin
  inherited Create(Conv(LongInt(Self)));
  Self.DLength := Size div 2;
  Self.Data := GetMemory(Size);
  Move(Data^, Self.Data^, Size);
  Frequency := SND_FREQ;
  Volume    := 100;
end;

class function TSample.Load(const FileName: string): TSample;
begin
  Result := TSample(ResManager.GetRef(FileName + EXT_WAV));
  if Result = nil then
    Result := TSample.Create(FileName + EXT_WAV);
end;

constructor TSample.Create(const FileName: string);
var
  Stream : TStream;
  Header : record
    Some1 : array [0..4] of LongWord;
    Fmt   : TWaveFormatEx;
    Some2 : Word;
    DLen  : LongWord;
  end;
begin
  inherited Create(FileName);

  Stream := TStream.Init(FileName);
  if Stream <> nil then
  begin
    Stream.Read(Header, SizeOf(Header));
    with Header, Fmt do
      if (wBitsPerSample = 16) and (nChannels = 1) and (nSamplesPerSec = SND_FREQ) then
      begin
        DLength := Header.DLen div nBlockAlign;
        Data    := GetMemory(DLen);
        Stream.Read(Data^, DLen);
      end;
    Stream.Free;
  end;

  Frequency := SND_FREQ;
  Volume    := 100;
end;

destructor TSample.Destroy;
var
  i : LongInt;
begin
  i := 0;
  while i < Sound.ChCount do
    if Sound.Channel[i].Sample = Self then
      Sound.FreeChannel(i)
    else
      Inc(i);
  FreeMemory(Data);
end;

procedure TSample.Play(Loop: Boolean);
var
  Channel : TChannel;
begin
  Channel.Sample  := Self;
  Channel.Volume  := Volume;
  Channel.Offset  := 0;
  Channel.Loop    := Loop;
  Channel.Playing := True;
  Sound.AddChannel(Channel);
end;

procedure TSample.SetVolume(Value: LongInt);
begin
  FVolume := Min(100, Max(0, Value));
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TDevice'}
{$IFNDEF NO_SOUND}
{ TDevice }
procedure FillProc(WaveOut, Msg, Inst: LongWord; WaveHdr: PWaveHdr; Param2: LongWord); stdcall;
begin
  if Sound.Device.Active then
    if Msg = WOM_DONE then
    begin
      waveOutUnPrepareHeader(WaveOut, WaveHdr, SizeOf(TWaveHdr));
      Sound.Render(WaveHdr^.lpData);
      waveOutPrepareHeader(WaveOut, WaveHdr, SizeOf(TWaveHdr));
      waveOutWrite(WaveOut, WaveHdr, SizeOf(TWaveHdr));
    end;
end;

procedure TDevice.Init;
begin
  with SoundDF do
  begin
    wFormatTag      := 1;
    nChannels       := 2;
    nSamplesPerSec  := SND_FREQ;
    wBitsPerSample  := SND_BPP;
    cbSize          := SizeOf(SoundDF);
    nBlockAlign     := wBitsPerSample div 8 * nChannels;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign * nChannels;
  end;

  if waveOutOpen(@WaveOut, $FFFFFFFF, @SoundDF, @FillProc, @Self, $30000) = 0 then
  begin
    FActive := True;
    FillChar(SoundDB, SizeOf(SoundDB), 0);
    Data := GetMemory(SND_BUF_SIZE * 2);
  // Buffer 0
    SoundDB[0].dwBufferLength := SND_BUF_SIZE;
    SoundDB[0].lpData         := Data;
    FillProc(WaveOut, WOM_DONE, 0, @SoundDB[0], 0);
  // Buffer 1
    SoundDB[1].dwBufferLength := SND_BUF_SIZE;
    SoundDB[1].lpData         := Pointer(LongWord(Data) + SND_BUF_SIZE);
    FillProc(WaveOut, WOM_DONE, 0, @SoundDB[1], 0);
  end else
    FActive := False;
end;

procedure TDevice.Free;
begin
  if FActive then
  begin
    FActive := False;
    waveOutUnPrepareHeader(WaveOut, @SoundDB[0], SizeOf(TWaveHdr));
    waveOutUnPrepareHeader(WaveOut, @SoundDB[1], SizeOf(TWaveHdr));
    waveOutReset(WaveOut);
    waveOutClose(WaveOut);
    FreeMemory(Data);
  end;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TSound'}
{$IFNDEF NO_SOUND}
{ TSound }
procedure TSound.Init;
begin
  InitializeCriticalSection(SoundCS);
  Device.Init;
end;

procedure TSound.Free;
begin
  Device.Free;
  DeleteCriticalSection(SoundCS);
  inherited;
end;

procedure TSound.Render(Data: PBufferArray);
const
  SAMPLE_COUNT = SND_BUF_SIZE div 4;
var
  i, j, sidx : LongInt;
  Amp : LongInt;
  AmpData : array [0..SAMPLE_COUNT - 1] of record
    L, R : LongInt;
  end;
begin
  EnterCriticalSection(SoundCS);
  if ChCount > 0 then
  begin
    FillChar(AmpData, SizeOf(AmpData), 0);
  // Mix channels sample
    for j := 0 to ChCount - 1 do
      with Channel[j] do
      begin
        for i := 0 to SAMPLE_COUNT - 1 do
        begin
          sidx := Offset + Trunc(i * Sample.Frequency / SND_FREQ);
          if sidx >= Sample.DLength then
            if Loop then
            begin
              Offset := Offset - sidx;
              sidx := 0;
            end else
            begin
              Playing := False;
              break;
            end;
          Amp := Volume * Sample.Data^[sidx] div 100;
          AmpData[i].L := AmpData[i].L + Amp;
          AmpData[i].R := AmpData[i].R + Amp;
        end;
        Offset := sidx;
      end;
  // Normalize
    for i := 0 to SAMPLE_COUNT - 1 do
    begin
      Data^[i].L := Clamp(AmpData[i].L, Low(SmallInt), High(SmallInt));
      Data^[i].R := Clamp(AmpData[i].R, Low(SmallInt), High(SmallInt));
    end;
  end else
    FillChar(Data^, SND_BUF_SIZE, 0);
  LeaveCriticalSection(SoundCS);

  i := 0;
  while i < ChCount do
    if not Channel[i].Playing then
      FreeChannel(i)
    else
      Inc(i);
end;

procedure TSound.FreeChannel(Index: LongInt);
begin
  EnterCriticalSection(SoundCS);
  ChCount := ChCount - 1;
  Channel[Index] := Channel[ChCount];
  LeaveCriticalSection(SoundCS);
end;

function TSound.AddChannel(const Ch: TChannel): Boolean;
begin
  Result := ChCount < Length(Channel);
  if Result then
  begin
    EnterCriticalSection(SoundCS);
    Channel[ChCount] := Ch;
    Inc(ChCount);
    LeaveCriticalSection(SoundCS);
  end;
end;
{$ENDIF}
{$ENDREGION}

// Camera ======================================================================
{$REGION 'TCamera'}
procedure TCamera.Init(CameraMode: TCameraMode; CameraProj: TCameraProj);
begin
  FillChar(Self, SizeOf(Self), 0);
  Mode := CameraMode;
  Proj := CameraProj;
  FOV   := 45;
  ZNear := 0.1;
  ZFar  := 100;
  Pos   := NullVec3f;
  Angle := NullVec3f;
  Dist  := 0;
end;

procedure TCamera.UpdateMatrix;
begin
  ViewMatrix.Identity;
  case Mode of
    cmFree :
      begin
        ViewMatrix.Rotate(Angle.z, Vec3f(0, 0, 1));
        ViewMatrix.Rotate(Angle.x, Vec3f(1, 0, 0));
        ViewMatrix.Rotate(Angle.y, Vec3f(0, 1, 0));
        ViewMatrix.Translate(Pos * -1);
      end;
    cmTarget :
      begin
        ViewMatrix.Pos := Vec3f(0, 0, -Dist);
        ViewMatrix.Rotate(Angle.x, Vec3f(1, 0, 0));
        ViewMatrix.Rotate(Angle.y, Vec3f(0, 1, 0));
        ViewMatrix.Rotate(Angle.z, Vec3f(0, 0, 1));
        ViewMatrix.Translate(Pos * -1);
      end;
    cmLookAt :
      ViewMatrix.LookAt(Pos, Target, Vec3f(0, 1, 0));
  end;

  with Render.Viewport do
    case Proj of
      cpPersp : ProjMatrix.Perspective(FOV, (Right - Left) / (Bottom - Top), zNear, zFar);
      cpOrtho : ProjMatrix.Ortho(-1, 1, -1, 1, zNear, zFar);
      //ProjMatrix.Ortho((Left - Right) * 0.5, (Right - Left) * 0.5, (Top - Bottom) * 0.5, (Bottom - Top) * 0.5, zNear, zFar);
    end;
  ViewProjMatrix := ProjMatrix * ViewMatrix;
end;

procedure TCamera.UpdatePlanes;

  procedure Plane(out p: TVec4f; x, y, z, w: Single); inline;
  var
    Len : Single;
  begin
    Len := 1 / sqrt(sqr(x) + sqr(y) + sqr(z));
    p.x := x * Len;
    p.y := y * Len;
    p.z := z * Len;
    p.w := w * Len;
  end;

begin
  with ViewProjMatrix do
  begin
    Plane(Planes[0], e30 - e00, e31 - e01, e32 - e02, e33 - e03); // right
    Plane(Planes[1], e30 + e00, e31 + e01, e32 + e02, e33 + e03); // left
    Plane(Planes[2], e30 - e10, e31 - e11, e32 - e12, e33 - e13); // top
    Plane(Planes[3], e30 + e10, e31 + e11, e32 + e12, e33 + e13); // bottom
    Plane(Planes[4], e30 - e20, e31 - e21, e32 - e22, e33 - e23); // near
    Plane(Planes[5], e30 + e20, e31 + e21, e32 + e22, e33 + e23); // far
  end;
end;

procedure TCamera.Setup;
var
  M : TMat4f;
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadMatrixf(ProjMatrix);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadMatrixf(ViewMatrix);

  M := ViewMatrix.Inverse;
  Render.ViewPos := M.Pos;
end;

function TCamera.Visible(const Box: TBox): Boolean;
var
  i : LongInt;
begin
  with Box do
    for i := Low(Planes) to High(Planes) do
      with Planes[i] do
        if (Dot(Max) < 0) and
           (Dot(Vec3f(Min.x, Max.y, Max.z)) < 0) and
           (Dot(Vec3f(Max.x, Min.y, Max.z)) < 0) and
           (Dot(Vec3f(Min.x, Min.y, Max.z)) < 0) and
           (Dot(Vec3f(Max.x, Max.y, Min.z)) < 0) and
           (Dot(Vec3f(Min.x, Max.y, Min.z)) < 0) and
           (Dot(Vec3f(Max.x, Min.y, Min.z)) < 0) and
           (Dot(Min) < 0) then
        begin
          Result := False;
          Exit;
        end;
  Result := True;
end;

function TCamera.Visible(const Sphere: TSphere): Boolean;
var
  i : LongInt;
begin
  with Sphere do
    for i := Low(Planes) to High(Planes) do
      if Planes[i].Dot(Center) < -Radius then
      begin
        Result := False;
        Exit;
      end;
  Result := True;
end;
{$ENDREGION}

// Render ======================================================================
{$REGION 'TRenderTarget'}
constructor TRenderTarget.Create(Width, Height: LongInt; DepthBuffer: Boolean);
begin
  gl.GenFramebuffers(1, @FrameBuf);
  gl.BindFramebuffer(GL_FRAMEBUFFER, FrameBuf);
  if DepthBuffer then
  begin
    gl.GenRenderbuffers(1, @DepthBuf);
    gl.BindRenderbuffer(GL_RENDERBUFFER, DepthBuf);
    gl.RenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, Width, Height);
    gl.FramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, DepthBuf);
  end;
//  Assert('Invalid frame buffer object', gl.CheckFramebufferStatus(GL_FRAMEBUFFER) <> GL_FRAMEBUFFER_COMPLETE);
  gl.BindFramebuffer(GL_FRAMEBUFFER, 0);
end;

destructor TRenderTarget.Destroy;
begin
  if DepthBuf <> 0 then
    gl.DeleteRenderbuffers(1, @DepthBuf);
  gl.DeleteFramebuffers(1, @FrameBuf);
end;

procedure TRenderTarget.Attach(Channel: TRenderChannel; Texture: TTexture; Target: TTextureTarget);
var
  TargetID  : TGLConst;
  TextureID : LongWord;
begin
  if Target = ttTex2D then
    TargetID := GL_TEXTURE_2D
  else
    TargetID := TGLConst(Ord(GL_TEXTURE_CUBE_MAP_POSITIVE_X) + Ord(Target) - 1);

  if Texture <> nil then
    TextureID := Texture.FID
  else
    TextureID := 0;

  gl.BindFramebuffer(GL_FRAMEBUFFER, FrameBuf);
  if Channel = rcDepth then
    gl.FramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, TargetID, TextureID, 0)
  else
    gl.FramebufferTexture2D(GL_FRAMEBUFFER, TGLConst(Ord(GL_COLOR_ATTACHMENT0) + Ord(Channel) - 1), TargetID, TextureID, 0);

  Self.Texture[Channel] := Texture;
  ChannelCount := 0;
  for Channel := rcColor0 to High(Self.Texture) do
    if Self.Texture[Channel] <> nil then
    begin
      ChannelList[ChannelCount] := TGLConst(Ord(GL_COLOR_ATTACHMENT0) + Ord(Channel) - 1);
      Inc(ChannelCount);
    end;
  gl.BindFramebuffer(GL_FRAMEBUFFER, 0);
end;
{$ENDREGION}

{$REGION 'TRender'}
procedure TRender.Init;
var
  pm, sm : LongWord;
begin
  gl.Init;
// Get start time
{$IFDEF WINDOWS}
  QueryPerformanceFrequency(TimeFreq);
  QueryPerformanceCounter(TimeStart);
{$ENDIF}
{$IFDEF LINUX}
  TimeStart := Time;
{$ENDIF}
{$IFDEF DARWIN}
  Microseconds(TimeStart);
{$ENDIF}
  Screen.Restore;
  Mode := rmOpaque;
  BlendType := btNormal;

  gl.PixelStorei(GL_UNPACK_ALIGNMENT, 1);
  gl.Enable(GL_TEXTURE_2D);
  gl.Disable(GL_DEPTH_TEST);

  FVendor   := string(gl.GetString(GL_VENDOR));
  FRenderer := string(gl.GetString(GL_RENDERER));
  FVersion  := string(gl.GetString(GL_VERSION));

  gl.GetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY, @FMaxAniso);
  FMaxAniso := Min(FMaxAniso, 8);

  Assert('Update your video card driver!', FRenderer = 'GDI Generic');

  SBuffer[rsMT]   := @gl.ActiveTexture <> nil;
  SBuffer[rsVBO]  := @gl.BindBuffer <> nil;
  SBuffer[rsFBO]  := @gl.GenFramebuffers <> nil;
  SBuffer[rsGLSL] := @gl.CreateProgram <> nil;

// Get number of processors
  pm := 1;
{$IFDEF WINDOWS}
  GetProcessAffinityMask(GetCurrentProcess, pm, sm);
{$ENDIF}
  FCPUCount := 0;
  while pm > 0 do
  begin
    pm := pm shr 1;
    Inc(FCPUCount);
  end;

  OldTime := Time;
end;

procedure TRender.Free;
begin
  gl.Free;
end;

function TRender.GetViewport: TRect;
begin
  Result := FViewport;
end;

procedure TRender.SetViewport(const Value: TRect);
begin
  FViewport := Value;
  gl.Viewport(Value.Left, Value.Top, Value.Right - Value.Left, Value.Bottom - Value.Top);
end;

procedure TRender.SetScissor(const Value: TRect);
begin
  gl.Scissor(Value.Left, Value.Top, Value.Right - Value.Left, Value.Bottom - Value.Top);
end;

procedure TRender.SetBlendType(Value: TBlendType);
begin
  if FBlendType <> Value then
  begin
    if FBlendType = btNone then
      gl.Enable(GL_BLEND);
    FBlendType := Value;
    case Value of
      btNormal : gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      btAdd    : gl.BlendFunc(GL_SRC_ALPHA, GL_ONE);
      btMult   : gl.BlendFunc(GL_ZERO, GL_SRC_COLOR);
    else
      gl.Disable(GL_BLEND);
    end;
  end;
end;

procedure TRender.SetAlphaTest(Value: Byte);
begin
  if FAlphaTest <> Value then
  begin
    FAlphaTest := Value;
    if Value > 0 then
    begin
      gl.Enable(GL_ALPHA_TEST);
      gl.AlphaFunc(GL_GREATER, Value / 255);
    end else
      gl.Disable(GL_ALPHA_TEST);
  end;
end;

procedure TRender.SetDepthTest(Value: Boolean);
begin
  if FDepthTest <> Value then
  begin
    FDepthTest := Value;
    if Value then
      gl.Enable(GL_DEPTH_TEST)
    else
      gl.Disable(GL_DEPTH_TEST);
  end;
end;

procedure TRender.SetDepthWrite(Value: Boolean);
begin
  if FDepthWrite <> Value then
  begin
    FDepthWrite := Value;
    gl.DepthMask(Value);
  end;
end;

procedure TRender.SetCullFace(Value: TCullFace);
begin
  if FCullFace <> Value then
  begin
    if FCullFace = cfNone then
      gl.Enable(GL_CULL_FACE);
    FCullFace := Value;
    case Value of
      cfFront : gl.CullFace(GL_FRONT);
      cfBack  : gl.CullFace(GL_BACK);
    else
      gl.Disable(GL_CULL_FACE);
    end;
  end;
end;

procedure TRender.SetTarget(Value: TRenderTarget);
begin
  FTarget := Value;
  if Value <> nil then
  begin
    gl.BindFramebuffer(GL_FRAMEBUFFER, Value.FrameBuf);
    if Value.ChannelCount = 0 then
    begin
      gl.DrawBuffer(GL_NONE);
      gl.ReadBuffer(GL_NONE);
    end else
    begin
      gl.DrawBuffer(GL_BACK);
      gl.ReadBuffer(GL_BACK);
    end;
    gl.DrawBuffers(Value.ChannelCount, @Value.ChannelList);
  end else
    gl.BindFramebuffer(GL_FRAMEBUFFER, 0);
end;

function TRender.QueryTime: LongInt;
{$IFDEF WINDOWS}
var
  Count : Int64;
begin
  QueryPerformanceCounter(Count);
  Result := Trunc(1000 * ((Count - TimeStart) / TimeFreq));
end;
{$ENDIF}
{$IFDEF LINUX}
var
  tv : TTimeVal;
begin
  gettimeofday(tv, nil);
  Result := tv.tv_sec * 1000 + tv.tv_usec div 1000 - TimeStart; // FIX! Add TimeStart
end;
{$ENDIF}
{$IFDEF DARWIN}
var
  T : QWord;
begin
  Microseconds(T);
  Result := (T - TimeStart) div 1000;
end;
{$ENDIF}

function TRender.Support(RenderSupport: TRenderSupport): Boolean;
begin
  Result := SBuffer[RenderSupport];
end;

procedure TRender.ResetBind;
var
  i : LongInt;
begin
  FillChar(ResManager.Active, SizeOf(ResManager.Active), 0);
  if not Render.Support(rsMT) then
  begin
    gl.BindTexture(GL_TEXTURE_2D, 0);
    gl.BindTexture(GL_TEXTURE_CUBE_MAP, 0);
  end else
    for i := 0 to 15 do
    begin
      gl.ActiveTexture(TGLConst(Ord(GL_TEXTURE0) + i));
      gl.BindTexture(GL_TEXTURE_2D, 0);
      gl.BindTexture(GL_TEXTURE_CUBE_MAP, 0);
    end;
  gl.UseProgram(0);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);
end;

procedure TRender.Update;
begin
  FrameFlag := not FrameFlag;
  Time      := QueryTime;
  DeltaTime := (Time - OldTime) / 1000;
  OldTime   := Time;
end;

procedure TRender.Clear(ClearColor, ClearDepth: Boolean);
var
  Mask : LongWord;
begin
  DepthWrite := True;
  Mask := 0;
  if ClearColor then Mask := Mask or Ord(GL_COLOR_BUFFER_BIT);
  if ClearDepth then Mask := Mask or Ord(GL_DEPTH_BUFFER_BIT);
  gl.Clear(TGLConst(Mask));
end;

procedure TRender.Set2D(Width, Height: Single);
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadIdentity;
  gl.Ortho(-Width/2, Width/2, -Height/2, Height/2, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity;
end;

procedure TRender.Set2D(X, Y, Width, Height: Single);
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadIdentity;
  gl.Ortho(X, Width, Y, Height, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity;
end;

procedure TRender.Set3D(FOV, Aspect, zNear, zFar: Single);
var
  PM : TMat4f;
begin
  PM.Perspective(FOV, Aspect, zNear, zFar);
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadMatrixf(PM);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity;
end;

procedure TRender.Quad(x, y, w, h, s, t, sw, th: Single);
var
  v : array [0..3] of TVec4f;
begin
  v[3] := Vec4f(x, y, s, t + th);
  v[2] := Vec4f(x + w, y, s + sw, t + th);
  v[1] := Vec4f(x + w, y + h, s + sw, t);
  v[0] := Vec4f(x, y + h, s, t);

  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.TexCoord2f(v[0].z, v[0].w);
    gl.Vertex2f(v[0].x, v[0].y);
    gl.TexCoord2f(v[1].z, v[1].w);
    gl.Vertex2f(v[1].x, v[1].y);
    gl.TexCoord2f(v[3].z, v[3].w);
    gl.Vertex2f(v[3].x, v[3].y);
    gl.TexCoord2f(v[2].z, v[2].w);
    gl.Vertex2f(v[2].x, v[2].y);
  gl.Endp;
end;
{$ENDREGION}

// Texture =====================================================================
{$REGION 'TTexture'}
class function TTexture.Load(const FileName: string): TTexture;
begin
  Result := TTexture(ResManager.GetRef(FileName + EXT_XTX));
  if Result = nil then
    Result := TTexture.Create(FileName + EXT_XTX);
end;

constructor TTexture.Create(Width, Height: LongInt; Data: Pointer; CFormat, IFormat, DFormat: TGLConst);
begin
  inherited Create(Conv(LongInt(Self)));
  FWidth  := Width;
  FHeight := Height;
  gl.GenTextures(1, @FID);
  gl.BindTexture(GL_TEXTURE_2D, FID);
  gl.TexImage2D(GL_TEXTURE_2D, 0, IFormat, Width, Height, 0, CFormat, DFormat, Data);
  Sampler := GL_TEXTURE_2D;
  FMipMap := False;
  FFilter := tfBilinear;
  Filter := tfNone;
end;

constructor TTexture.Create(const FileName: string);
type
  TLoadFormat = (lfNULL, lfDXT1c, lfDXT1a, lfDXT3, lfDXT5, lfA8, lfL8, lfAL8, lfBGRA8, lfBGR8, lfBGR5A1, lfBGR565, lfBGRA4, lfR16F, lfR32F, lfGR16F, lfGR32F, lfBGRA16F, lfBGRA32F);
  TDDS = record
    dwMagic       : LongWord;
    dwSize        : LongInt;
    dwFlags       : LongWord;
    dwHeight      : LongWord;
    dwWidth       : LongWord;
    dwPOLSize     : LongWord;
    dwDepth       : LongWord;
    dwMipMapCount : LongInt;
    SomeData1   : array [0..11] of LongWord;
    pfFlags     : LongWord;
    pfFourCC    : LongWord;
    pfRGBbpp    : LongWord;
    pfRMask     : LongWord;
    pfGMask     : LongWord;
    pfBMask     : LongWord;
    pfAMask     : LongWord;
    dwCaps1     : LongWord;
    dwCaps2     : LongWord;
    SomeData3   : array [0..2] of LongWord;
  end;

const
  FOURCC_DXT1          = $31545844;
  FOURCC_DXT3          = $33545844;
  FOURCC_DXT5          = $35545844;
  FOURCC_R16F          = $0000006F;
  FOURCC_G16R16F       = $00000070;
  FOURCC_A16B16G16R16F = $00000071;
  FOURCC_R32F          = $00000072;
  FOURCC_G32R32F       = $00000073;
  FOURCC_A32B32G32R32F = $00000074;

  DDPF_ALPHAPIXELS = $01;
  DDPF_ALPHA       = $02;
  DDPF_FOURCC      = $04;
  DDPF_RGB         = $40;
  DDPF_LUMINANCE   = $020000;
  DDSD_MIPMAPCOUNT = $020000;
  DDSCAPS2_CUBEMAP = $0200;

  LoadFormat : array [TLoadFormat] of record
      Compressed : Boolean;
      DivSize    : Byte;
      Bytes      : Byte;
      IFormat    : TGLConst;
      EFormat    : TGLConst;
      DataType   : TGLConst;
    end = (
    (Compressed: False; DivSize: 1; Bytes:  1; IFormat: GL_FALSE; EFormat: GL_FALSE; DataType: GL_FALSE),
    (Compressed: True;  DivSize: 4; Bytes:  8; IFormat: GL_COMPRESSED_RGB_S3TC_DXT1; EFormat: GL_FALSE; DataType: GL_FALSE),
    (Compressed: True;  DivSize: 4; Bytes:  8; IFormat: GL_COMPRESSED_RGBA_S3TC_DXT1; EFormat: GL_FALSE; DataType: GL_FALSE),
    (Compressed: True;  DivSize: 4; Bytes: 16; IFormat: GL_COMPRESSED_RGBA_S3TC_DXT3; EFormat: GL_FALSE; DataType: GL_FALSE),
    (Compressed: True;  DivSize: 4; Bytes: 16; IFormat: GL_COMPRESSED_RGBA_S3TC_DXT5; EFormat: GL_FALSE; DataType: GL_FALSE),
    (Compressed: False; DivSize: 1; Bytes:  1; IFormat: GL_ALPHA8; EFormat: GL_ALPHA; DataType: GL_UNSIGNED_BYTE),
    (Compressed: False; DivSize: 1; Bytes:  1; IFormat: GL_LUMINANCE8; EFormat: GL_LUMINANCE; DataType: GL_UNSIGNED_BYTE),
    (Compressed: False; DivSize: 1; Bytes:  2; IFormat: GL_LUMINANCE8_ALPHA8; EFormat: GL_LUMINANCE_ALPHA; DataType: GL_UNSIGNED_BYTE),
    (Compressed: False; DivSize: 1; Bytes:  4; IFormat: GL_RGBA8; EFormat: GL_BGRA; DataType: GL_UNSIGNED_BYTE),
    (Compressed: False; DivSize: 1; Bytes:  3; IFormat: GL_RGB8; EFormat: GL_BGR; DataType: GL_UNSIGNED_BYTE),
    (Compressed: False; DivSize: 1; Bytes:  2; IFormat: GL_RGB5_A1; EFormat: GL_BGRA; DataType: GL_UNSIGNED_SHORT_1_5_5_5_REV),
    (Compressed: False; DivSize: 1; Bytes:  2; IFormat: GL_RGB5; EFormat: GL_RGB; DataType: GL_UNSIGNED_SHORT_5_6_5),
    (Compressed: False; DivSize: 1; Bytes:  2; IFormat: GL_RGBA4; EFormat: GL_BGRA; DataType: GL_UNSIGNED_SHORT_4_4_4_4_REV),
    (Compressed: False; DivSize: 1; Bytes:  2; IFormat: GL_R16F; EFormat: GL_RED; DataType: GL_HALF_FLOAT),
    (Compressed: False; DivSize: 1; Bytes:  4; IFormat: GL_R32F; EFormat: GL_RED; DataType: GL_FLOAT),
    (Compressed: False; DivSize: 1; Bytes:  4; IFormat: GL_RG16F; EFormat: GL_RG; DataType: GL_HALF_FLOAT),
    (Compressed: False; DivSize: 1; Bytes:  8; IFormat: GL_RG32F; EFormat: GL_RG; DataType: GL_FLOAT),
    (Compressed: False; DivSize: 1; Bytes:  8; IFormat: GL_RGBA16F; EFormat: GL_RGBA; DataType: GL_HALF_FLOAT),
    (Compressed: False; DivSize: 1; Bytes: 16; IFormat: GL_RGBA32F; EFormat: GL_RGBA; DataType: GL_FLOAT)
  );

var
  Stream  : TStream;
  i, w, h : LongInt;
  Data    : Pointer;
  LF      : TLoadFormat;
  Samples : LongInt;
  st      : TGLConst;
  s       : LongInt;
  RMips   : LongInt;
  DDS     : TDDS;

  function GetLoadFormat(const DDS: TDDS): TLoadFormat;
  begin
    Result := lfNULL;
    with DDS do
      if pfFlags and DDPF_FOURCC = DDPF_FOURCC then
      begin
        case pfFourCC of
        // Compressed
          FOURCC_DXT1 :
           if pfFlags xor DDPF_ALPHAPIXELS > 0 then
             Result := lfDXT1a
           else
             Result := lfDXT1c;
          FOURCC_DXT3 : Result := lfDXT3;
          FOURCC_DXT5 : Result := lfDXT5;
        // Float
          FOURCC_R16F          : Result := lfR16F;
          FOURCC_G16R16F       : Result := lfGR16F;
          FOURCC_A16B16G16R16F : Result := lfBGRA16F;
          FOURCC_R32F          : Result := lfR32F;
          FOURCC_G32R32F       : Result := lfGR32F;
          FOURCC_A32B32G32R32F : Result := lfBGRA32F;
        end
      end else
        case pfRGBbpp of
           8 :
            if (pfFlags and DDPF_LUMINANCE > 0) and (pfRMask xor $FF = 0) then
              Result := lfL8
            else
              if (pfFlags and DDPF_ALPHA > 0) and (pfAMask xor $FF = 0) then
                Result := lfA8;
          16 :
              if pfFlags and DDPF_ALPHAPIXELS > 0 then
              begin
                if (pfFlags and DDPF_LUMINANCE > 0) and (pfRMask xor $FF + pfAMask xor $FF00 = 0) then
                  Result := lfAL8
                else
                  if pfFlags and DDPF_RGB > 0 then
                    if pfRMask xor $0F00 + pfGMask xor $00F0 + pfBMask xor $0F + pfAMask xor $F000 = 0 then
                      Result := lfBGRA4
                    else
                      if pfRMask xor $7C00 + pfGMask xor $03E0 + pfBMask xor $1F + pfAMask xor $8000 = 0 then
                        Result := lfBGR5A1;
              end else
                if pfFlags and DDPF_RGB > 0 then
                  if pfRMask xor $F800 + pfGMask xor $07E0 + pfBMask xor $1F = 0 then
                    Result := lfBGR565;
          24 :
            if pfRMask xor $FF0000 + pfGMask xor $FF00 + pfBMask xor $FF = 0 then
              Result := lfBGR8;
          32 :
            if pfRMask xor $FF0000 + pfGMask xor $FF00 + pfBMask xor $FF + pfAMask xor $FF000000 = 0 then
              Result := lfBGRA8;
        end;
  end;

begin
  inherited Create(FileName);
  Stream := TStream.Init(FileName);
  if Stream = nil then
  begin
    FWidth  := 1;
    FHeight := 1;
    Exit;
  end;
  Stream.Read(DDS, SizeOf(DDS));
  FWidth  := DDS.dwWidth;
  FHeight := DDS.dwHeight;
// Select OpenGL texture format
  LF := GetLoadFormat(DDS);
  if LF = lfNULL then
  begin
    Assert('Not supported format: "' + FileName + '"');
    Stream.Free;
    Exit;
  end;

  with DDS, LoadFormat[LF] do
  begin
    if dwFlags and DDSD_MIPMAPCOUNT = 0 then
       dwMipMapCount := 1;
    RMips := dwMipMapCount;
    for i := 0 to dwMipMapCount - 1 do
      if Min(Width shr i, Height shr i) < 4 then
      begin
        RMips := i;
        break;
      end;

  // 2D image
    Sampler := GL_TEXTURE_2D;
    Samples := 1;
  // CubeMap image
    if dwCaps2 and DDSCAPS2_CUBEMAP > 0 then
    begin
      Sampler := GL_TEXTURE_CUBE_MAP;
      Samples := 6;
    end;
    // 3D image
    ///...

    Data := GetMemory((FWidth div DivSize) * (FHeight div DivSize) * Bytes);

    gl.GenTextures(1, @FID);
    gl.BindTexture(Sampler, FID);

    for s := 0 to Samples - 1 do
    begin
      case Sampler of
        GL_TEXTURE_CUBE_MAP :
          st := TGLConst(Ord(GL_TEXTURE_CUBE_MAP_POSITIVE_X) + s)
      else
        st := Sampler;
      end;

      for i := 0 to dwMipMapCount - 1 do
      begin
        w := FWidth shr i;
        h := FHeight shr i;
        dwSize := ((w div DivSize) * (h div DivSize) * Bytes);
        if i >= RMips then
        begin
          Stream.Pos := Stream.Pos + dwSize;
          continue;
        end;

        Stream.Read(Data^, dwSize);
        if Compressed then
          gl.CompressedTexImage2D(st, i, IFormat, w, h, 0, dwSize, Data)
        else
          gl.TexImage2D(st, i, IFormat, w, h, 0, EFormat, DataType, Data);
      end;
    end;
    FreeMemory(Data);

    FMipMap := dwMipMapCount > 1;
    if FMipMap then
      gl.TexParameteri(Sampler, GL_TEXTURE_MAX_LEVEL, TGLConst(RMips - 1));
  end;
  Stream.Free;
  Filter := tfAniso;
end;

destructor TTexture.Destroy;
begin
  gl.DeleteTextures(1, @FID);
  inherited;
end;

procedure TTexture.SetFilter(Value: TTextureFilter);
const
  FilterMode : array [Boolean, TTextureFilter, 0..1] of TGLConst =
    (((GL_NEAREST, GL_NEAREST), (GL_LINEAR, GL_LINEAR), (GL_LINEAR, GL_LINEAR), (GL_LINEAR, GL_LINEAR)),
     ((GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST), (GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR), (GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR), (GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR)));
begin
  if FFilter <> Value then
  begin
    FFilter := Value;
    Bind(0);
    gl.TexParameteri(Sampler, GL_TEXTURE_MIN_FILTER, FilterMode[FMipMap, FFilter, 0]);
    gl.TexParameteri(Sampler, GL_TEXTURE_MAG_FILTER, FilterMode[FMipMap, FFilter, 1]);
    if Render.MaxAniso > 0 then
      if FFilter = tfAniso then
        gl.TexParameteri(Sampler, GL_TEXTURE_MAX_ANISOTROPY, TGLConst(Render.MaxAniso))
      else
        gl.TexParameteri(Sampler, GL_TEXTURE_MAX_ANISOTROPY, TGLConst(1));
  end;
end;

procedure TTexture.SetClamp(Value: Boolean);
const
  ClampMode : array [Boolean] of TGLConst = (GL_REPEAT, GL_CLAMP_TO_EDGE);
begin
  if FClamp <> Value then
  begin
    FClamp := Value;
    Bind;
    gl.TexParameteri(Sampler, GL_TEXTURE_WRAP_S, ClampMode[Clamp]);
    gl.TexParameteri(Sampler, GL_TEXTURE_WRAP_T, ClampMode[Clamp]);
    gl.TexParameteri(Sampler, GL_TEXTURE_WRAP_R, ClampMode[Clamp]);
  end;
end;

procedure TTexture.GenLevels;
var
  f : TTextureFilter;
begin
  Bind;
  gl.GenerateMipmap(Sampler);
// reset filtering
  if not FMipMap then
  begin
    f := Filter;
    FFilter := TTextureFilter(-1);
    Filter := f;
  end;
end;

procedure TTexture.DataGet(Data: Pointer; Level: LongInt; CFormat, DFormat: TGLConst);
begin
  Bind;
  gl.GetTexImage(Sampler, Level, CFormat, DFormat, Data);
end;

procedure TTexture.DataSet(X, Y, Width, Height: LongInt; Data: Pointer; Level: LongInt; CFormat, DFormat: TGLConst);
begin
  Bind;
  gl.TexSubImage2D(Sampler, Level, X, Y, Width, Height, CFormat, DFormat, Data);
end;

procedure TTexture.DataCopy(XOffset, YOffset, X, Y, Width, Height, Level: LongInt);
begin
  Bind;
  gl.CopyTexSubImage2D(Sampler, Level, XOffset, YOffset, X, Y, Width, Height);
end;

procedure TTexture.Bind(Channel: LongInt);
begin
  if ResManager.Active[TResType(Channel + Ord(rtTexture))] <> Self then
  begin
    if Render.Support(rsMT) then
      gl.ActiveTexture(TGLConst(Ord(GL_TEXTURE0) + Channel));
    gl.BindTexture(Sampler, FID);
    ResManager.Active[TResType(Channel + Ord(rtTexture))] := Self;
  end;
end;
{$ENDREGION}

// Shader ======================================================================
{$REGION 'TShaderUniform'}
procedure TShaderUniform.Init(ShaderID: LongWord; const UName: string; UniformType: TShaderUniformType);
var
  i : LongInt;
begin
  FID   := gl.GetUniformLocation(ShaderID, PAnsiChar(AnsiString(UName)));
  FName := UName;
  FType := UniformType;
  for i := 0 to Length(FValue) - 1 do
    FValue[i] := NAN;
end;

procedure TShaderUniform.Value(const Data; Count: LongInt);
const
  USize : array [TShaderUniformType] of LongInt = (4, 4, 8, 12, 16, 36, 64);
begin
  if FID <> -1 then
  begin
    if Count * USize[FType] <= SizeOf(FValue) then
      if MemCmp(@FValue, @Data, Count * USize[FType]) <> 0 then
        Move(Data, FValue, Count * USize[FType])
      else
        Exit;

    case FType of
      utInt  : gl.Uniform1iv(FID, Count, @Data);
      utVec1 : gl.Uniform1fv(FID, Count, @Data);
      utVec2 : gl.Uniform2fv(FID, Count, @Data);
      utVec3 : gl.Uniform3fv(FID, Count, @Data);
      utVec4 : gl.Uniform4fv(FID, Count, @Data);
      utMat3 : gl.UniformMatrix3fv(FID, Count, False, @Data);
      utMat4 : gl.UniformMatrix4fv(FID, Count, False, @Data);
    end;
  end;
end;
{$ENDREGION}

{$REGION 'TShaderAttrib'}
procedure TShaderAttrib.Init(ShaderID: LongWord; const AName: string; AttribType: TShaderAttribType; Norm: Boolean);
begin
  FID   := gl.GetAttribLocation(ShaderID, PAnsiChar(AnsiString(AName)));
  FName := AName;
  FType := AttribType;
  Size  := Byte(FType) mod 4 + 1;
  FNorm := Norm;
  case FType of
    atVec1b..atVec4b : DType := GL_UNSIGNED_BYTE;
    atVec1s..atVec4s : DType := GL_SHORT;
    atVec1f..atVec4f : DType := GL_FLOAT;
  end;
end;

procedure TShaderAttrib.Value(Stride: LongInt; const Data);
begin
  if FID <> -1 then
    gl.VertexAttribPointer(FID, Size, DType, FNorm, Stride, @Data);
end;

procedure TShaderAttrib.Enable;
begin
  if FID <> -1 then
    gl.EnableVertexAttribArray(FID);
end;

procedure TShaderAttrib.Disable;
begin
  if FID <> -1 then
    gl.DisableVertexAttribArray(FID);
end;
{$ENDREGION}

{$REGION 'TShader'}
class function TShader.Load(const FileName: string; const Defines: array of string): TShader;
var
  i : LongInt;
  DefinesStr : string;
begin
  DefinesStr := '';
  for i := 0 to Length(Defines) - 1 do
    DefinesStr := DefinesStr + '*' + Defines[i];
  Result := TShader(ResManager.GetRef(FileName + EXT_XSH + DefinesStr));
  if Result = nil then
    Result := TShader.Create(FileName + EXT_XSH, Defines);
end;

constructor TShader.Create(const FileName: string; const Defines: array of string);

  procedure InfoLog(Obj: LongWord; IsProgram: Boolean);
  var
    LogBuf : AnsiString;
    LogLen : LongInt;
  begin
    if IsProgram then
      gl.GetProgramiv(Obj, GL_INFO_LOG_LENGTH, @LogLen)
    else
      gl.GetShaderiv(Obj, GL_INFO_LOG_LENGTH, @LogLen);

    SetLength(LogBuf, LogLen);

    if IsProgram then
      gl.GetProgramInfoLog(Obj, LogLen, LogLen, PAnsiChar(LogBuf))
    else
      gl.GetShaderInfoLog(Obj, LogLen, LogLen, PAnsiChar(LogBuf));
    Assert(FileName + CRLF + string(LogBuf));
  end;

  procedure Attach(ShaderType: TGLConst; const CSource: AnsiString);
  var
    Obj : LongWord;
    SourcePtr  : PAnsiChar;
    SourceSize : LongInt;
    Status : LongInt;
  begin
    Obj := gl.CreateShader(ShaderType);

    SourcePtr  := PAnsiChar(CSource);
    SourceSize := Length(CSource);

    gl.ShaderSource(Obj, 1, @SourcePtr, @SourceSize);
    gl.CompileShader(Obj);
    gl.GetShaderiv(Obj, GL_COMPILE_STATUS, @Status);
    if Status <> 1 then
      InfoLog(Obj, False);
    gl.AttachShader(FID, Obj);
    gl.DeleteShader(Obj);
  end;

const
  DEFINE = '#define';
var
  i : LongInt;
  Status : LongInt;
  Stream : TStream;
  Source  : AnsiString;
  CSource : AnsiString;
  DefinesStr : string;
begin
  inherited Create(FileName);

  if not Render.Support(rsGLSL) then
    Assert('GLSL shaders are not supported');

// Defines string assembly
  DefinesStr := DEFINE;
  for i := 0 to Length(Defines) - 1 do
    DefinesStr := DefinesStr + ' ' + Defines[i] + CRLF + DEFINE;

  FID := gl.CreateProgram();
// Reading
  Stream := TStream.Init(FileName);
  if Stream <> nil then
  begin
    SetLength(Source, Stream.Size);
    Stream.Read(Source[1], Stream.Size);
    Stream.Free;
  // Compiling
//    DefinesStr := '#version 120' + CRLF + DefinesStr; // not necessary
    CSource := AnsiString(DefinesStr + ' VERTEX' + CRLF) + Source;
    Attach(GL_VERTEX_SHADER, CSource);
    CSource := AnsiString(DefinesStr + ' FRAGMENT' + CRLF) + Source;
    Attach(GL_FRAGMENT_SHADER, CSource);
    if Pos(AnsiString('#ifdef GEOMETRY'), Source) > 0 then
    begin
      CSource := AnsiString(DefinesStr + ' GEOMETRY' + CRLF) + Source;
      Attach(GL_GEOMETRY_SHADER, CSource);
  //    gl.GetIntegerv(GL_MAX_GEOMETRY_OUTPUT_VERTICES, @i);
      gl.ProgramParameteri(FID, GL_GEOMETRY_VERTICES_OUT, 3);
      gl.ProgramParameteri(FID, GL_GEOMETRY_INPUT_TYPE, Ord(GL_TRIANGLES));
      gl.ProgramParameteri(FID, GL_GEOMETRY_OUTPUT_TYPE, Ord(GL_TRIANGLE_STRIP));
    end;
  // Linking
    gl.LinkProgram(FID);
    gl.GetProgramiv(FID, GL_LINK_STATUS, @Status);
    if Status <> 1 then
      InfoLog(FID, True);
  end else
    Assert('Can''t open shader "' + FileName + '"');
end;

destructor TShader.Destroy;
begin
  gl.DeleteProgram(FID);
end;

function TShader.Uniform(const UName: string; UniformType: TShaderUniformType): TShaderUniform;
var
  i : LongInt;
begin
  for i := 0 to Length(FUniform) - 1 do
    if FUniform[i].Name = UName then
    begin
      Result := FUniform[i];
      Exit;
    end;
  Result.Init(FID, UName, UniformType);
  SetLength(FUniform, Length(FUniform) + 1);
  FUniform[Length(FUniform) - 1] := Result;
end;

function TShader.Attrib(const AName: string; AttribType: TShaderAttribType; Norm: Boolean = False): TShaderAttrib;
var
  i : LongInt;
begin
  for i := 0 to Length(FAttrib) - 1 do
    if FAttrib[i].Name = AName then
    begin
      Result := FAttrib[i];
      Exit;
    end;
  Result.Init(FID, AName, AttribType, Norm);
  SetLength(FAttrib, Length(FAttrib) + 1);
  FAttrib[Length(FAttrib) - 1] := Result;
end;

procedure TShader.Bind;
begin
  if ResManager.Active[rtShader] <> Self then
  begin
    gl.UseProgram(FID);
    ResManager.Active[rtShader] := Self;
  end;
end;
{$ENDREGION}

// Material ====================================================================
{$REGION 'TMaterial'}
{$IFNDEF NO_MATERIAL}
class function TMaterial.Load(const FileName: string): TMaterial;
begin
  Result := TMaterial(ResManager.GetRef(FileName + EXT_XMT));
  if Result = nil then
    Result := TMaterial.Create(FileName + EXT_XMT);
end;

constructor TMaterial.Create;
begin
end;

constructor TMaterial.Create(const FileName: string);
var
  i, DCount : LongInt;
  ma : TMaterialAttrib;
  ms : TMaterialSampler;
  mu : TMaterialUniform;
  Stream : TStream;
  ShaderName  : string;
  SamplerName : string;
  Defines : array of string;
  rm      : TRenderMode;
begin
  inherited Create(FileName);

  Stream := TStream.Init(FileName);
  Stream.Read(Params, SizeOf(Params));

  ShaderName := string(Stream.ReadAnsi);
  Stream.Read(DCount, SizeOf(DCount));
  SetLength(Defines, DCount + 1);
  for i := 0 to DCount - 1 do
    Defines[i] := string(Stream.ReadAnsi);
  Defines[DCount] := 'MODE_NORMAL';
  Shader := TShader.Load(ShaderName, Defines);

  Stream.Read(Samplers, SizeOf(Samplers));
  for ms in Samplers do
  begin
    SamplerName := string(Stream.ReadAnsi);
    if SamplerName <> '' then
      Texture[SamplerID[ms].ID] := TTexture.Load(SamplerName);
  end;
  Stream.Free;

  if Params.ReceiveShadow then
    Samplers := Samplers + [msShadow];

// normal mode
  ModeMat[rmOpaque]  := Self;
  ModeMat[rmOpacity] := Self;
// shadow mode
  if Params.CastShadow then
  begin
    Defines[DCount] := 'MODE_SHADOW';
    ModeMat[rmShadow] := TMaterial.Create; // unmanaged
    ModeMat[rmShadow].Samplers := Samplers;
    ModeMat[rmShadow].Params   := Params;
    ModeMat[rmShadow].Params.Mode := rmShadow;
  // shader
    ModeMat[rmShadow].Shader   := TShader.Load(ShaderName, Defines);
  // texture
    ModeMat[rmShadow].Texture[SamplerID[msDiffuse].ID] := Texture[SamplerID[msDiffuse].ID];
    if Texture[SamplerID[msDiffuse].ID] <> nil then
      Inc(Texture[SamplerID[msDiffuse].ID].Ref);
  end;

  for rm := Low(rm) to High(rm) do
    if ModeMat[rm] <> nil then
      with ModeMat[rm] do
      begin
        Shader.Bind;
        for ms in Samplers do
          with SamplerID[ms] do
            Shader.Uniform(Name, utInt).Value(ID);
        for ma := Low(ma) to High(ma) do
          with AttribID[ma] do
            Attrib[ma] := Shader.Attrib(Name, AType, Norm);
        for mu := Low(mu) to High(mu) do
          with UniformID[mu] do
            Uniform[mu] := Shader.Uniform(Name, UType);
      end;
end;

destructor TMaterial.Destroy;
var
  i : LongInt;
  rm : TRenderMode;
begin
  Shader.Free;

  Texture[SamplerID[msShadow].ID] := nil; // shadow map is not material managed sampler
  for i := 0 to Length(Texture) - 1 do
    if Texture[i] <> nil then
      Texture[i].Free;

  for rm := Low(rm) to High(rm) do
    if (ModeMat[rm] <> nil) and (ModeMat[rm] <> Self) then
      ModeMat[rm].Free;
end;

procedure TMaterial.Bind;
var
  i : LongInt;
  LightPos   : array [0..MAX_LIGHTS - 1] of TVec3f;
  LightParam : array [0..MAX_LIGHTS - 1] of TVec4f;
begin
  if ModeMat[Render.Mode] <> nil then
    with ModeMat[Render.Mode] do
    begin
      Render.CullFace   := Params.CullFace;
      Render.BlendType  := Params.BlendType;
      Render.DepthWrite := Params.DepthWrite;
      Render.AlphaTest  := Params.AlphaTest;

      if Shader <> nil then
      begin
        Shader.Bind;
        Uniform[muModelMatrix].Value(Render.ModelMatrix);
        case Render.Mode of
          rmOpaque, rmOpacity :
            begin
              for i := 0 to MAX_LIGHTS - 1 do
              begin
                LightPos[i]     := Render.Light[i].Pos;
                LightParam[i].x := Render.Light[i].Color.x;
                LightParam[i].y := Render.Light[i].Color.y;
                LightParam[i].z := Render.Light[i].Color.z;
                LightParam[i].w := sqr(Render.Light[i].Radius);
              end;
              Uniform[muViewPos].Value(Render.ViewPos);
              Uniform[muAmbient].Value(Render.Ambient);
              Uniform[muLightPos].Value(LightPos, MAX_LIGHTS);
              Uniform[muLightParam].Value(LightParam, MAX_LIGHTS);
              Uniform[muMaterial].Value(Params.Uniform, 3);
              Uniform[muTexOffset].Value(Render.TexOffset);
              if Params.ReceiveShadow then
              begin
                Uniform[muLightMatrix].Value(Render.Light[0].Matrix);
                Texture[SamplerID[msShadow].ID] := Render.Light[0].ShadowMap;
              end;
            end;
          rmShadow :
            begin
              LightPos[0] := Render.Light[0].Pos;
              Uniform[muLightPos].Value(LightPos, 1);
              Uniform[muMaterial].Value(Params.Uniform, 1);
            end;
        end;
      end;

      for i := 0 to Length(Texture) - 1 do
        if Texture[i] <> nil then
          Texture[i].Bind(i);
  end;
end;
{$ENDIF}
{$ENDREGION}

// Sprite ======================================================================
{$REGION 'TSpriteAnimList'}
{$IFNDEF NO_SPRITE}
function TSpriteAnimList.GetItem(Idx: LongInt): TSpriteAnim;
const
  NullAnim : TSpriteAnim = (FName: ''; FFrames: 1; FX: 0; FY: 0; FWidth: 1; FHeight: 1; FCX: 0; FCY: 0; FFPS: 1);
begin
  if (Idx >= 0) and (Idx < Count) then
    Result := FItems[Idx]
  else
    Result := NullAnim;
end;

procedure TSpriteAnimList.Add(const Name: string; Frames, X, Y, W, H, Cols, CX, CY, FPS: LongInt);
begin
  SetLength(FItems, FCount + 1);
  FItems[FCount].FName   := Name;
  FItems[FCount].FFrames := Frames;
  FItems[FCount].FX      := X;
  FItems[FCount].FY      := Y;
  FItems[FCount].FWidth  := W;
  FItems[FCount].FHeight := H;
  FItems[FCount].FCols   := Cols;
  FItems[FCount].FCX     := CX;
  FItems[FCount].FCY     := CY;
  FItems[FCount].FFPS    := FPS;
  Inc(FCount);
end;

function TSpriteAnimList.IndexOf(const Name: string): LongInt;
var
  i : LongInt;
begin
  for i := 0 to Count - 1 do
    if FItems[i].Name = Name then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TSprite'}
{$IFNDEF NO_SPRITE}
function TSprite.GetWidth: LongInt;
begin
  if (CurIndex >= 0) then
    Result := Anim.Items[CurIndex].Width
  else
    Result := 1;
end;

function TSprite.GetHeight: LongInt;
begin
  if (CurIndex >= 0) then
    Result := Anim.Items[CurIndex].Height
  else
    Result := 1;
end;

function TSprite.GetPlaying: Boolean;
begin
  Result := False;
  if (CurIndex < 0) or (not FPlaying) then
    Exit;
  with Anim.Items[CurIndex] do
    FPlaying := FLoop or ((Render.Time - StartTime) div (1000 div FPS) < Frames);
  Result := FPlaying;
end;

function TSprite.GetVertex(x, y: LongInt): TVec2f;
begin
  Result := FVertex[y * FCols + x];
end;

procedure TSprite.SetVertex(x, y: LongInt; const v: TVec2f);
begin
  FVertex[y * FCols + x] := v;
end;

procedure TSprite.Load(const FileName: string);
const
  BlendStr : array [TBlendType] of string =
    ('none', 'normal', 'add', 'mult');
var
  Cfg : TConfigFile;
  i   : Integer;
  b   : TBlendType;
  Cat : string;

  function Param(const Name: string; Def: Integer): Integer;
  begin
    Result := Cfg.Read(Cat, Name, Def);
  end;

begin
  CurIndex := -1;
  FPlaying := False;
  Pos      := Vec2f(0, 0);
  Scale    := Vec2f(1, 1);
  Angle    := 0;

  Cfg.Load(FileName);
  i := 0;
  while Cfg.CategoryName(i) <> '' do
  begin
    Cat := Cfg.CategoryName(i);
    if Cat <> 'sprite' then
      Anim.Add(Cat, Param('Frames', 1), Param('FramesX', 0), Param('FramesY', 0),
               Param('FramesWidth', 1), Param('FramesHeight', 1), Param('Cols', Param('Frames', 1)),
               Param('CenterX', 0), Param('CenterY', 0), Param('FPS', 1));
    Inc(i);
  end;
  Texture := TTexture.Create(Cfg.Read('sprite', 'Texture', ''));
  BlendType := btNormal;
  Cat := Cfg.Read('sprite', 'Blend', 'normal');
  for b := Low(b) to High(b) do
    if BlendStr[b] = Cat then
    begin
      BlendType := b;
      break;
    end;
  Play(Cfg.Read('sprite', 'Anim', 'default'), True);
  Grid(2, 2);
end;

procedure TSprite.Free;
begin
  Texture.Free;
end;

procedure TSprite.Grid(GCols, GRows: LongInt);
var
  i : LongInt;
begin
  FCols := Clamp(GCols, 2, 32);
  FRows := Clamp(GRows, 2, 32);
  SetLength(FVertex, Cols * Rows);
  for i := 0 to Cols * Rows - 1 do
    FVertex[i] := Vec2f(i mod Cols / (Cols - 1), i div Cols / (Rows - 1));
end;

procedure TSprite.Play(const AnimName: string; Loop: Boolean);
var
  NewIndex : LongInt;
begin
  NewIndex := Anim.IndexOf(AnimName);
  if (NewIndex > -1) and ((NewIndex <> CurIndex) or (not FPlaying)) then
  begin
    FLoop := Loop;
    StartTime := Render.Time;
    CurIndex := NewIndex;
    FPlaying := True;
  end;
end;

procedure TSprite.Stop;
begin
  FPlaying := False;
end;

procedure TSprite.Draw;
var
  x, y, CurFrame : LongInt;
  vs, vc, ts, tc : TVec2f;
  v, t : array [0..31, 0..31] of TVec2f;
begin
  if CurIndex < 0 then
    Exit;
  Texture.Bind;
  with Anim.Items[CurIndex] do
  begin
    if Playing then
      CurFrame := (Render.Time - StartTime) div (1000 div FPS) mod Frames
    else
      CurFrame := 0;
    Render.BlendType := BlendType;

    vs := Vec2f(Width, Height) * Scale;
    vc := Vec2f(CenterX, CenterY) * Scale;
    ts := Vec2f(Width / Texture.Width, Height / Texture.Height);
    tc := Vec2f(X / Texture.Width, Y / Texture.Height) + Vec2f(CurFrame mod Cols, CurFrame div Cols) * ts;
  end;

  gl.PushMatrix;
  gl.Translatef(Pos.x, Pos.y, 0);
  gl.Rotatef(Angle * rad2deg, 0, 0, 1);
  gl.Translatef(-vc.x, -vc.y, 0);
  gl.Scalef(vs.x, vs.y, 1);

  for y := 0 to FRows - 1 do
    for x := 0 to FCols - 1 do
    begin
      v[x, y] := Vertex[x, y];
      t[x, y] := Vec2f(x / (FCols - 1), 1 - y / (FRows - 1)) * ts + tc;
    end;

  gl.Beginp(GL_QUADS);
    for y := 0 to FRows - 2 do
      for x := 0 to FCols - 2 do
      begin
        gl.TexCoord2fv(t[x, y]);         gl.Vertex2fv(v[x, y]);
        gl.TexCoord2fv(t[x + 1, y]);     gl.Vertex2fv(v[x + 1, y]);
        gl.TexCoord2fv(t[x + 1, y + 1]); gl.Vertex2fv(v[x + 1, y + 1]);
        gl.TexCoord2fv(t[x, y + 1]);     gl.Vertex2fv(v[x, y + 1]);
      end;
  gl.Endp;

  gl.PopMatrix;
end;
{$ENDIF}
{$ENDREGION}

// Skeleton ====================================================================
{$REGION 'TAnimData'}
class function TAnimData.Load(const FileName: string): TAnimData;
begin
  Result := TAnimData(ResManager.GetRef(FileName + EXT_XAN));
  if Result = nil then
    Result := TAnimData.Create(FileName + EXT_XAN);
end;

constructor TAnimData.Create(const FileName: string);
type
  TFrameFlag = (ffRotX, ffRotY, ffRotZ, ffPosX, ffPosY, ffPosZ);
const
  CSCALE = 1 / High(SmallInt);
var
  i, j : LongInt;
  Stream : TStream;
  Rot : TQuat;
  Pos : TVec3f;
  Len : Single;
  Flag  : array of set of TFrameFlag;
  SData  : array of Single;
  SCount : LongInt;

  function GetNext: Single;
  begin
    Result := SData[SCount];
    Inc(SCount);
  end;

begin
  inherited Create(FileName);
  Stream := TStream.Init(FileName);
  if Stream <> nil then
  begin
    Stream.Read(JCount, SizeOf(JCount));
    SetLength(JName, JCount);
    SetLength(Frame, JCount);
    for i := 0 to JCount - 1 do
      JName[i] := Stream.ReadAnsi;
    Stream.Read(FPS, SizeOf(FPS));
    Stream.Read(FCount, SizeOf(FCount));

    SetLength(Flag, FCount);
    SetLength(SData, FCount * 6); // maximum data elements (6 = Rot + Pos)

    for i := 0 to JCount - 1 do
    begin
      SetLength(Frame[i], FCount);

      Stream.Read(Flag[0], FCount * SizeOf(Flag[0]));
      Stream.Read(SCount, SizeOf(SCount));
      Stream.Read(SData[0], SCount * SizeOf(SData[0]));
      SCount := 0;

      Rot := Quat(0, 0, 0, 1);
      Pos := Vec3f(0, 0, 0);
      for j := 0 to FCount - 1 do
      begin
        if ffRotX in Flag[j] then Rot.x := GetNext;
        if ffRotY in Flag[j] then Rot.y := GetNext;
        if ffRotZ in Flag[j] then Rot.z := GetNext;
        if ffPosX in Flag[j] then Pos.x := GetNext;
        if ffPosY in Flag[j] then Pos.y := GetNext;
        if ffPosZ in Flag[j] then Pos.z := GetNext;

      // w component reconstruction
        if (ffRotX in Flag[j]) or (ffRotY in Flag[j]) or (ffRotZ in Flag[j]) then
        begin
          Len := 1 - sqr(Rot.x) - sqr(Rot.y) - sqr(Rot.z);
          if Len < EPS  then
            Rot.w := 0
          else
            Rot.w := sqrt(Len);
        end;

        Frame[i][j] := DualQuat(Rot, Pos);
      end;
    end;
    Stream.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TAnim'}
class function TAnim.Load(const FileName: string; Skeleton: TSkeleton): TAnim;
var
  i, j : LongInt;
begin
  Result := TAnim.Create;
  with Result do
  begin
    Data := TAnimData.Load(FileName);
    SetLength(State, Data.JCount);
    SetLength(Joint, Data.JCount);
    SetLength(Map, Skeleton.Data.JCount);
  // joint indices remapping
    for i := 0 to Skeleton.Data.JCount - 1 do
      Map[i] := -1; // non animated
    for i := 0 to Data.JCount - 1 do
    begin
      j := Skeleton.JointIndex(Data.JName[i]);
      if j > -1 then
        Map[j] := i; // animated joint
    end;
  end;
end;

destructor TAnim.Destroy;
begin
  Data.Free;
  inherited;
end;

procedure TAnim.Update;
begin
  if (Weight + EPS < BlendWeight) and (BlendTime > EPS) then
    Weight := Lerp(StartWeight, BlendWeight, Min(1, (Render.Time - StartTime) * 0.001 / BlendTime))
  else
    Weight := BlendWeight;

  // StartTime .... RESET
  FrameDelta := Frac((Render.Time - StartTime) * Data.FPS / 1000);
  FramePrev  := (Render.Time - StartTime) * Data.FPS div 1000;
  case LoopMode of
    lmNone :
      if FramePrev >= Data.FCount then
      begin
        FrameNext  := 0;
        FrameDelta := 0;
      end else
        FrameNext := FramePrev + 1;
    lmRepeat :
      FrameNext := (FramePrev + 1) mod Data.FCount;
    lmLast :
      FrameNext := Min(FramePrev + 1, Data.FCount);
    lmPingPong :
      if FramePrev div Data.FCount mod 2 = 0 then
        FrameNext := Min(FramePrev mod Data.FCount + 1, Data.FCount)
      else
        FrameNext := Max(FramePrev mod Data.FCount - 1, 0);
  end;
  FramePrev := FramePrev mod Data.FCount;
end;

procedure TAnim.LerpJoint(Idx: LongInt);
begin
  if State[Idx] <> Render.FrameFlag then
  begin
    Joint[Idx] := Data.Frame[Idx][FramePrev].Lerp(Data.Frame[Idx][FrameNext], FrameDelta);
    State[Idx] := Render.FrameFlag;
  end;
end;

procedure TAnim.Play(BlendWeight, BlendTime: Single; LoopMode: TLoopMode = lmNone);
begin
  Self.BlendWeight := BlendWeight;
  Self.BlendTime   := BlendTime;
  Self.LoopMode    := LoopMode;
  StartWeight := Weight;
  StartTime   := Render.Time;
end;

procedure TAnim.Stop(BlendTime: Single);
begin
  Play(0, BlendTime, LoopMode);
end;
{$ENDREGION}

{$REGION 'TSkeletonData'}
class function TSkeletonData.Load(const FileName: string): TSkeletonData;
begin
  Result := TSkeletonData(ResManager.GetRef(FileName + EXT_XSK));
  if Result = nil then
    Result := TSkeletonData.Create(FileName + EXT_XSK);
end;

constructor TSkeletonData.Create(const FileName: string);
var
  i : LongInt;
  Stream : TStream;
begin
  inherited Create(FileName);
  Stream := TStream.Init(FileName);
  if Stream <> nil then
  begin
    Stream.Read(JCount, SizeOf(JCount));
    SetLength(Base, JCount);
    SetLength(JName, JCount);
    for i := 0 to JCount - 1 do
      JName[i] := Stream.ReadAnsi;
    Stream.Read(Base[0], JCount * SizeOf(TJoint));
    Stream.Free;
  end;
end;
{$ENDREGION}

{$REGION 'TSkeleton'}
class function TSkeleton.Load(const FileName: string): TSkeleton;
begin
  Result := TSkeleton.Create;
  with Result do
  begin
    Data := TSkeletonData.Load(FileName);
    SetLength(State, Data.JCount);
    SetLength(Joint, Data.JCount);
  end;
end;

destructor TSkeleton.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(Anim) - 1 do
    Anim[i].Free;
  Data.Free;
  inherited;
end;

function TSkeleton.AddAnim(const Name: string): TAnim;
begin
  Result := TAnim.Load(Name, Self);
  SetLength(Anim, Length(Anim) + 1);
  Anim[Length(Anim) - 1] := Result;
end;

procedure TSkeleton.Update;
var
  i : LongInt;
begin
  for i := 0 to Length(Anim) - 1 do
    Anim[i].Update;
end;

procedure TSkeleton.SetParent(Skeleton: TSkeleton; JointIndex: TJointIndex);
begin
  Parent := Skeleton;
  ParentJoint := JointIndex;
end;

procedure TSkeleton.UpdateJoint(Idx: TJointIndex);
var
  CJoint : TDualQuat;
  i : LongInt;
  w : Single;
begin
  if State[Idx] = Render.FrameFlag then
    Exit;

  w := 1;
  CJoint := Data.Base[Idx].Frame;

  for i := Length(Anim) - 1 downto 0 do
    with Anim[i] do
      if (Map[Idx] > -1) and (Weight > EPS) then
      begin
        LerpJoint(Map[Idx]);
        CJoint := CJoint.Lerp(Joint[Map[Idx]], w);
        break;
        w := w - Weight;
        if w < EPS then
          break;
      end;

  if Data.Base[Idx].Parent > -1 then
  begin
    UpdateJoint(Data.Base[Idx].Parent);
    Joint[Idx] := Joint[Data.Base[Idx].Parent] * CJoint;
  end else
    if Parent <> nil then
    begin
      Parent.UpdateJoint(ParentJoint);
      Joint[Idx] := Parent.Joint[ParentJoint] * CJoint;
    end else
      Joint[Idx] := CJoint;

  State[Idx] := Render.FrameFlag;
end;

function TSkeleton.JointIndex(const JName: AnsiString): TJointIndex;
var
  i : LongInt;
begin
  Result := -1;
  for i := 0 to Data.JCount - 1 do
    if Data.JName[i] = JName then
    begin
      Result := i;
      Exit;
    end;
end;
{$ENDREGION}

// Mesh ========================================================================
{$REGION 'TMeshBuffer'}
constructor TMeshBuffer.Create(BufferType: TBufferType; Count, Stride: LongInt; Data: Pointer);
begin
  Self.Count  := Count;
  Self.Stride := Stride;
  if BufferType = btIndex then
  begin
    DType := GL_ELEMENT_ARRAY_BUFFER;
    RType := rtMeshIndex;
  end else
  begin
    DType := GL_ARRAY_BUFFER;
    RType := rtMeshVertex;
  end;

  if Render.Support(rsVBO) then
  begin
    gl.GenBuffers(1, @ID);
    gl.BindBuffer(DType, ID);
    gl.BufferData(DType, Count * Stride, Data, GL_STATIC_DRAW);
    FData := nil;
  end else
  begin
    FData := GetMemory(Count * Stride);
    if Data <> nil then
      Move(Data^, FData^, Count * Stride);
  end;
end;

class function TMeshBuffer.Load(BufferType: TBufferType; Stream: TStream): TMeshBuffer;
var
  Count  : LongInt;
  Stride : LongInt;
  Data   : Pointer;
begin
  Stream.Read(Count, SizeOf(Count));
  if Count > 0 then
  begin
    Stream.Read(Stride, SizeOf(Stride));
    Data := GetMemory(Count * Stride);
    Stream.Read(Data^, Count * Stride);
    Result := TMeshBuffer.Create(BufferType, Count, Stride, Data);
    FreeMemory(Data);
  end else
    Result := nil;
end;

destructor TMeshBuffer.Destroy;
begin
  if FData <> nil then
    FreeMemory(FData)
  else
    gl.DeleteBuffers(1, @ID);
  inherited;
end;

procedure TMeshBuffer.SetData(Offset, Size: LongInt; Data: Pointer);
var
  p : PByteArray;
begin
  if FData = nil then
  begin
    Bind;
    P := gl.MapBuffer(DType, GL_WRITE_ONLY);
  end else
    P := FData;
  Move(Data^, P[Offset], Size);
  if FData = nil then
    gl.UnmapBuffer(DType);
end;

procedure TMeshBuffer.Bind;
begin
  if ResManager.Active[RType] <> Self then
  begin
    if FData = nil then
      gl.BindBuffer(DType, ID);
    ResManager.Active[RType] := Self;
  end;
end;
{$ENDREGION}

{$REGION 'TMeshData'}
{$IFNDEF NO_MESH}
class function TMeshData.Init: TMeshData;
begin
  Result := TMeshData.Create(Conv(LongInt(Self)));
end;

class function TMeshData.Load(const FileName: string): TMeshData;
var
  Stream : TStream;
  i, Count : LongInt;
begin
  Result := TMeshData(ResManager.GetRef(FileName + EXT_XMS));
  if Result = nil then
  begin
    Stream := TStream.Init(FileName + EXT_XMS);
    if Stream <> nil then
    begin
      Result := TMeshData.Create(FileName + EXT_XMS);
      with Result do
      begin
        Stream.Read(BBox, SizeOf(BBox));
        Stream.Read(Mode, SizeOf(Mode));
        Stream.Read(Attrib, SizeOf(Attrib));
      // buffers
        Buffer[btIndex]  := TMeshBuffer.Load(btIndex, Stream);
        Buffer[btVertex] := TMeshBuffer.Load(btVertex, Stream);
      // joint names
        Stream.Read(Count, SizeOf(Count));
        if Count > 0 then
        begin
          SetLength(JName, Count);
          for i := 0 to Count - 1 do
            JName[i] := Stream.ReadAnsi;
        end;
      end;
      Stream.Free;
    end;
  end;
end;

destructor TMeshData.Destroy;
var
  bt : TBufferType;
begin
  for bt := Low(bt) to High(bt) do
    if Buffer[bt] <> nil then
      Buffer[bt].Free;
  inherited;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TMesh'}
{$IFNDEF NO_MESH}
constructor TMesh.Create(MeshData: TMeshData);
begin
  Data := MeshData;
  SetLength(JIndex, Length(Data.JName));
  SetLength(JQuat, Length(Data.JName));
end;

class function TMesh.Load(const FileName: string): TMesh;
var
  Data : TMeshData;
begin
  Data := TMeshData.Load(FileName);
  if Data <> nil then
    Result := TMesh.Create(Data)
  else
    Result := nil;
end;

destructor TMesh.Destroy;
begin
  Data.Free;
  if Material <> nil then
    Material.Free;
  inherited;
end;

procedure TMesh.SetMaterial(Value: TMaterial);
begin
  if FMaterial <> Value then
    FMaterial := Value;
end;

procedure TMesh.SetSkeleton(Value: TSkeleton);
var
  i : LongInt;
begin
  if FSkeleton <> Value then
  begin
    FSkeleton := Value;
    if FSkeleton <> nil then
      for i := 0 to Length(JIndex) - 1 do
        JIndex[i] := FSkeleton.JointIndex(Data.JName[i]);
  end;
end;

procedure TMesh.onRender;
const
  AttribSize : array [TMaterialAttrib] of LongInt = (12, 4, 4, 4, 4, 4, 4);
  IndexType  : array [1..4] of TGLConst = (GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, GL_FALSE, GL_UNSIGNED_INT);
  MeshMode   : array [TMeshMode] of TGLConst = (GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_LINES);
var
  ma : TMaterialAttrib;
  p  : Pointer;
  i  : LongInt;
begin
  if (Material = nil) or
     (Material.ModeMat[Render.Mode] = nil) or
     (Material.Params.Mode <> Render.Mode) then
    Exit;
  Material.Bind;
// collect skin joints
  if (maJoint in Data.Attrib) and (Skeleton <> nil) then
  begin
    for i := 0 to Length(JIndex) - 1 do
      if JIndex[i] > -1 then
      begin
        Skeleton.UpdateJoint(JIndex[i]);
        JQuat[i] := Skeleton.Joint[JIndex[i]] * Skeleton.Data.Base[JIndex[i]].Bind;
      end;
    Material.Uniform[muJoint].Value(JQuat[0], Length(JQuat) * 2);
  end;

  with Data do
  begin
  // set vertex attributes
    Buffer[btVertex].Bind;
    p := Buffer[btVertex].DataPtr;
    for ma in Attrib do
    begin
      Material.ModeMat[Render.Mode].Attrib[ma].Enable;
      Material.ModeMat[Render.Mode].Attrib[ma].Value(Buffer[btVertex].Stride, p^);
      Inc(LongInt(p), AttribSize[ma]);
    end;
  // set indices & call DIP
    if Buffer[btIndex] <> nil then
    begin
      Buffer[btIndex].Bind;
      gl.DrawElements(MeshMode[Mode], Buffer[btIndex].Count, IndexType[Buffer[btIndex].Stride], Buffer[btIndex].DataPtr);
    end else
      gl.DrawArrays(MeshMode[Mode], 0, Buffer[btIndex].Count);
{
    for ma in Attrib do
      Material.Attrib[ma].Disable;
}
  end;
end;
{$ENDIF}
{$ENDREGION}

// Font ========================================================================
{$REGION 'Font'}
class function TFont.Load(const FileName: string): TFont;
begin
  Result := TFont(ResManager.GetRef(FileName + EXT_XFN));
  if Result = nil then
    Result := TFont.Create(FileName);
end;

constructor TFont.Create(const Name: string);
const
  XFN_MAGIC = $2B6E6678;
var
  Stream : TStream;
  i : LongInt;
  Header : record
    Magic  : LongWord;
    Offset : LongWord;
  end;
begin
  inherited Create(Name + EXT_XFN);
  Texture := TTexture.Load(Name);
  Stream := TStream.Init(Name + EXT_XTX);
  if Stream <> nil then
  begin
    Stream.Pos := 32; // reserved dds header part
    Stream.Read(Header, SizeOf(Header));
    if not Assert('Invalid font "' + Name + '"', Header.Magic <> XFN_MAGIC) then
    begin
      Stream.Pos := Header.Offset;
      Stream.Read(i, SizeOf(i));
      SetLength(CharData, i);
      Stream.Read(CharData[0], Length(CharData) * SizeOf(CharData[0]));
      for i := 0 to Length(CharData) - 1 do
        Table[CharData[i].ID] := @CharData[i];
    end;
    Stream.Free;
  end;
end;

destructor TFont.Destroy;
begin
  if Texture <> nil then
    Texture.Free;
  inherited;
end;

procedure TFont.Print(const Text: WideString);
var
  i, px : LongInt;
begin
  Texture.Bind;
  gl.Beginp(GL_QUADS);
    px := 0;
    for i := 1 to Length(Text) do
      if Table[Text[i]] <> nil then
        with Table[Text[i]]^ do
        begin
          gl.TexCoord2f(tx, ty);           gl.Vertex2f(px, py);
          gl.TexCoord2f(tx, ty + th);      gl.Vertex2f(px, py + h);
          gl.TexCoord2f(tx + tw, ty + th); gl.Vertex2f(px + w, py + h);
          gl.TexCoord2f(tx + tw, ty);      gl.Vertex2f(px + w, py);
          Inc(px, w + 1);
        end;
  gl.Endp;
end;

procedure TFont.Print(const Text: WideString; x, y: LongInt; const Color: TVec4f);
begin
  gl.PushMatrix;
  gl.Translatef(x, y, 0);
  gl.Color4fv(Color);
  Print(Text);
  gl.PopMatrix;
end;

procedure TFont.Print(const Text: WideString; x, y: LongInt; const Color: TVec4f; sx, sy: LongInt; const SColor: TVec4f);
begin
  gl.PushMatrix;
  gl.Translatef(x + sx, y + sy, 0);
  gl.Color4fv(SColor);
  Print(Text);
  gl.Translatef(-sx, -sy, 0);
  gl.Color4fv(Color);
  Print(Text);
  gl.PopMatrix;
end;
{$ENDREGION}

// GUI =========================================================================
{$REGION 'TControl'}
{$IFNDEF NO_GUI}
constructor TControl.Create(Left, Top, Width, Height: LongInt);
begin
  Resize(Left, Top, Width, Height);
  Align   := alNone;
  Visible := True;
  Enabled := True;
  Color   := Vec4f(0.5, 0.5, 0.5, 1.0);
end;

destructor TControl.Destroy;
begin
  while Length(Controls) > 0 do
    DelCtrl(Controls[0]);
  inherited;
end;

procedure TControl.Resize(Left, Top, Width, Height: LongInt);
begin
  Params.Left   := Left;
  Params.Top    := Top;
  Params.Width  := Width;
  Params.Height := Height;
end;

procedure TControl.Realign;
var
  CtrlSize : array [alLeft..alBottom] of LongInt;

  procedure DoAlign(CurAlign: TAlign);
  var
    i : LongInt;
  begin
    for i := 0 to Length(Controls) - 1 do
      with Controls[i] do
        if Visible and (Align = CurAlign) then
          case Align of
            alLeft   :
              begin
                Resize(CtrlSize[alLeft], CtrlSize[alTop], Width, CtrlSize[alBottom] - CtrlSize[alTop]);
                Inc(CtrlSize[alLeft], Width);
              end;
            alRight  :
              begin
                Dec(CtrlSize[alRight], Width);
                Resize(CtrlSize[alRight], CtrlSize[alTop], Width, CtrlSize[alBottom] - CtrlSize[alTop]);
              end;
            alTop    :
              begin
                Resize(CtrlSize[alLeft], CtrlSize[alTop], CtrlSize[alRight] - CtrlSize[alLeft], Height);
                Inc(CtrlSize[alTop], Height);
              end;
            alBottom :
              begin
                Dec(CtrlSize[alBottom], Height);
                Resize(CtrlSize[alLeft], CtrlSize[alBottom], CtrlSize[alRight] - CtrlSize[alLeft], Height);
              end;
            alClient : Resize(CtrlSize[alLeft], CtrlSize[alTop], CtrlSize[alRight] - CtrlSize[alLeft], CtrlSize[alBottom] - CtrlSize[alTop]);
          else
            Resize(Left, Top, Width, Height);
          end;
  end;

var
  i  : LongInt;
begin
  if Length(Controls) > 0 then
  begin
    CtrlSize[alLeft]   := 0;
    CtrlSize[alTop]    := 0;
    CtrlSize[alRight]  := Width;
    CtrlSize[alBottom] := Height;
    DoAlign(alTop);
    DoAlign(alBottom);
    DoAlign(alLeft);
    DoAlign(alRight);
    DoAlign(alClient);
    for i := 0 to Length(Controls) - 1 do
      Controls[i].Realign;
  end;
end;

procedure TControl.SetAlign(const Value: TAlign);
const
  AnchorAlign : array [TAlign] of TAnchors = (
    [akLeft, akTop],
    [akLeft, akTop, akRight],
    [akLeft, akRight, akBottom],
    [akLeft, akTop, akBottom],
    [akRight, akTop, akBottom],
    [akLeft, akTop, akRight, akBottom]
  );
begin
  Params.Align := Value;
  Anchors := AnchorAlign[Value];
  if Parent <> nil then
    Parent.Realign
  else
    Realign;
end;

procedure TControl.SetAnchors(const Value: TAnchors);
begin
  Params.Anchors := Value;
  Realign;
end;

procedure TControl.SetLeft(const Value: LongInt);
begin
  Params.Left := Value;
  Realign;
end;

procedure TControl.SetTop(const Value: LongInt);
begin
  Params.Top := Value;
  Realign;
end;

procedure TControl.SetWidth(const Value: LongInt);
begin
  Params.Width := Value;
  Realign;
end;

procedure TControl.SetHeight(const Value: LongInt);
begin
  Params.Height := Value;
  Realign;
end;

function TControl.GetRect: TRect;
begin
  Result.Left   := Left;
  Result.Top    := Top;
  Result.Right  := Left + Width;
  Result.Bottom := Top + Height;

  if Parent <> nil then
    with Parent.Rect do
    begin
      Result.Left   := Result.Left + Left;
      Result.Top    := Result.Top + Top;
      Result.Right  := Result.Right + Left;
      Result.Bottom := Result.Bottom + Top;
    end;
end;

function TControl.AddCtrl(const Ctrl: TControl): TControl;
begin
  Result := Ctrl;
  SetLength(Controls, Length(Controls) + 1);
  Controls[Length(Controls) - 1] := Ctrl;
  Ctrl.FParent := Self;
  Realign;
end;

function TControl.DelCtrl(const Ctrl: TControl): Boolean;
var
  i, j : LongInt;
begin
  for i := 0 to Length(Controls) - 1 do
    if Controls[i] = Ctrl then
    begin
      Controls[i].Free;
      for j := i to Length(Controls) - 2 do
        Controls[j] := Controls[j + 1];
      SetLength(Controls, Length(Controls) - 1);
      Result := True;
      Exit;
    end;
  Result := False;
end;

procedure TControl.BringToFront;
var
  i  : LongInt;
  tc : TControl;
begin
  if Parent <> nil then
    with Parent do
      for i := 0 to Length(Controls) - 1 do
        if Controls[i] = Self then
        begin
          tc := Controls[i];
          Controls[i] := Controls[Length(Controls) - 1];
          Controls[Length(Controls) - 1] := tc;
          Realign;
          break;
        end;
end;

procedure TControl.OnRender;
var
  i : LongInt;
begin
  if Color.w > EPS then
    with Rect do
    begin
      gl.Beginp(GL_TRIANGLE_STRIP);
        gl.Color4fv(Color);
        gl.Vertex2f(Left, Top);
        gl.Vertex2f(Right, Top);
        gl.Vertex2f(Left, Bottom);
        gl.Vertex2f(Right, Bottom);
      gl.Endp;
    end;

  for i := 0 to Length(Controls) - 1 do
    if Controls[i].Visible then
      Controls[i].OnRender;
end;

function TControl.OnEvent(const Event: TControlEvent): Boolean;
begin
  Result := False;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TGUI'}
{$IFNDEF NO_GUI}
constructor TGUI.Create(Left, Top, Width, Height: LongInt);
begin
  inherited;
  Color.w := 0;
  // Skin blablabla
end;

destructor TGUI.Destroy;
begin
  if Skin <> nil then
    Skin.Free;
  inherited;
end;

procedure TGUI.OnRender;
begin
  Render.DepthTest := False;
  Render.CullFace  := cfNone;
  Render.ResetBind;
  Render.Viewport := CoreX.Rect(0, 0, Screen.Width, Screen.Height);
  Render.Set2D(0, Screen.Height, Screen.Width, 0);
  inherited;
end;
{$ENDIF}
{$ENDREGION}

// Node ========================================================================
{$REGION 'TNode'}
constructor TNode.Create(const Name: string);
begin
  FRBBox := InfBox;
  Self.Name := Name;
end;

destructor TNode.Destroy;
begin
  Parent := nil;
  while Length(Nodes) > 0 do
    Nodes[0].Free;
  inherited;
end;

procedure TNode.SetParent(const Value: TNode);
var
  i : LongInt;
begin
// delete self from parent node list
  if FParent <> nil then
    with FParent do
      for i := 0 to Length(Nodes) - 1 do
        if Nodes[i] = Self then
        begin
          Nodes[i] := Nodes[Length(Nodes) - 1];
          SetLength(Nodes, Length(Nodes) - 1);
          UpdateBounds;
          break;
        end;
// add self to new parent node list
  if Value <> nil then
    with Value do
    begin
      SetLength(Nodes, Length(Nodes) + 1);
      Nodes[Length(Nodes) - 1] := Self;
    end;
  FParent := Value;
// recalc matrices
{
  if FParent <> nil then
  begin
    FRMatrix := Matrix * FParent.Matrix.Inverse;
    FParent.UpdateBounds;
  end else
    FRMatrix := Matrix;
}
end;

procedure TNode.SetRMatrix(const Value: TMat4f);
begin
  FRMatrix := Value;
  if FParent <> nil then
  begin
    Matrix := FParent.Matrix * FRMatrix;
    FParent.UpdateBounds;
  end else
    Matrix := FRMatrix;
end;

procedure TNode.SetMatrix(const Value: TMat4f);
var
  v : array [0..7] of TVec3f;
  i : LongInt;
begin
  FMatrix := Value;

  for i := 0 to Length(Nodes) - 1 do
    Nodes[i].Matrix := FMatrix * Nodes[i].FRMatrix;

// Calculate BoundingBox
  with FRBBox do
  begin
    v[0] := FMatrix * Vec3f(Min.x, Max.y, Max.z);
    v[1] := FMatrix * Vec3f(Max.x, Min.y, Max.z);
    v[2] := FMatrix * Vec3f(Min.x, Min.y, Max.z);
    v[3] := FMatrix * Vec3f(Max.x, Max.y, Min.z);
    v[4] := FMatrix * Vec3f(Min.x, Max.y, Min.z);
    v[5] := FMatrix * Vec3f(Max.x, Min.y, Min.z);
    v[6] := FMatrix * Min;
    v[7] := FMatrix * Max;
    with FBBox do
    begin
      Min := v[0];
      Max := v[0];
      for i := Low(v) + 1 to High(v) do
      begin
        Min := v[i].Min(Min);
        Max := v[i].Min(Max);
      end;
    end;
  end;

  if Parent <> nil then
    Parent.UpdateBounds;
end;

procedure TNode.UpdateBounds;
var
  i : LongInt;
  b : TBox;
begin
  b := FBBox;
  for i := 0 to Length(Nodes) - 1 do
    with Nodes[i].BBox do
    begin
      b.Min := b.Min.Min(Min);
      b.Max := b.Max.Max(Max);
    end;

  if (b.Min = FBBox.Min) and (b.Max = FBBox.Max) then
    Exit;

  FBBox := b;
  if FParent <> nil then
    FParent.UpdateBounds;
end;

function TNode.Add(Node: TNode): TNode;
begin
  Node.Parent := Self;
  Result := Node;
end;

function TNode.Remove(Node: TNode): Boolean;
begin
  Node.Parent := nil;
  Result := True;
end;

function TNode.Count: LongInt;
begin
  Result := Length(Nodes);
end;

procedure TNode.OnRender;
var
  i : LongInt;
begin
  for i := 0 to Length(Nodes) - 1 do
    Nodes[i].OnRender;
end;
{$ENDREGION}

// Model =======================================================================
{$REGION 'TMeshNode'}
{$IFNDEF NO_MESH}
class function TMeshNode.Load(const FileName: string): TMeshNode;
begin
  Result := nil;
end;

constructor TMeshNode.Create(Mesh: TMesh; Matrix: TMat4f);
begin
  Self.Mesh     := Mesh;
  Self.Name     := Mesh.Data.Name;
  Self.FRBBox   := Mesh.Data.BBox;
  Self.FRMatrix := Matrix;
  Self.FMatrix  := Matrix;
end;

destructor TMeshNode.Destroy;
begin
  if Mesh <> nil then
    Mesh.Free;
  inherited;
end;

procedure TMeshNode.OnRender;
begin
{
  b.Min := Nodes[i].AMatrix * Mesh.Data.BBox.Min;
  b.Max := Nodes[i].AMatrix * Mesh.Data.BBox.Max;
  if not Visible(b) then
    continue;
}
  Render.ModelMatrix := FMatrix;
  Mesh.OnRender;
{
  Render.ResetBind;
  gl.Color3f(0, 1, 0);
  gl.Disable(GL_TEXTURE_2D);
  with FRBBox do
  begin
    gl.Beginp(GL_LINE_STRIP);
      gl.Vertex3f(Min.x, Min.y, Min.z);
      gl.Vertex3f(Max.x, Min.y, Min.z);
      gl.Vertex3f(Max.x, Min.y, Max.z);
      gl.Vertex3f(Min.x, Min.y, Max.z);
      gl.Vertex3f(Min.x, Min.y, Min.z);
      gl.Vertex3f(Min.x, Max.y, Min.z);
      gl.Vertex3f(Max.x, Max.y, Min.z);
      gl.Vertex3f(Max.x, Max.y, Max.z);
      gl.Vertex3f(Min.x, Max.y, Max.z);
      gl.Vertex3f(Min.x, Max.y, Min.z);
      gl.Vertex3f(Max.x, Max.y, Min.z);
      gl.Vertex3f(Max.x, Min.y, Min.z);
      gl.Vertex3f(Max.x, Min.y, Max.z);
      gl.Vertex3f(Max.x, Max.y, Max.z);
      gl.Vertex3f(Min.x, Max.y, Max.z);
      gl.Vertex3f(Min.x, Min.y, Max.z);
    gl.Endp;
  end;
}
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TModelNode'}
class function TModelNode.Load(const FileName: string): TModelNode;
var
  Stream : TStream;
  i, Count : LongInt;
  M : TMat4f;
  Mesh : TMesh;
begin
  Stream := TStream.Init(FileName + EXT_XMD);
  if Stream <> nil then
  begin
    Result := TModelNode.Create(FileName  + EXT_XMD);
    Stream.Read(Count, SizeOf(Count));
    for i := 0 to Count - 1 do
    begin
      Stream.Read(M, SizeOf(M));
      Mesh          := TMesh.Load(string(Stream.ReadAnsi));
      Mesh.Material := TMaterial.Load(string(Stream.ReadAnsi));
      Result.Add(TMeshNode.Create(Mesh, M));
    end;
    Stream.Free;
  end else
    Result := nil;
end;

destructor TModelNode.Destroy;
begin
  if Skeleton <> nil then
    Skeleton.Free;
  inherited;
end;

procedure TModelNode.OnRender;
begin
  if Skeleton <> nil then
    Skeleton.Update;
  inherited;
end;

procedure TModelNode.ResetSkeleton;
var
  i : LongInt;
begin
  for i := 0 to Count - 1 do
    if Nodes[i] is TMeshNode then
      with TMeshNode(Nodes[i]) do
        if Mesh <> nil then
          Mesh.Skeleton := Skeleton;
end;
{$ENDREGION}

// Scene =======================================================================
{$REGION 'TScene'}
{$IFNDEF NO_SCENE}
const
  SHADOW_SIZE = 512;

procedure TScene.Init;
const
  GL_TEXTURE_COMPARE_MODE = TGLConst($884C);
  GL_TEXTURE_COMPARE_FUNC = TGLConst($884D);
  GL_COMPARE_R_TO_TEXTURE = TGLConst($884E);
  GL_DEPTH_TEXTURE_MODE = TGLConst($884B);
begin
  Node := TNode.Create('main');
//    ShadowTex[i] := TTexture.Create(SHADOW_SIZE, SHADOW_SIZE, nil, GL_RGBA, GL_RGBA8);
  ShadowTex := TTexture.Create(SHADOW_SIZE, SHADOW_SIZE, nil, GL_DEPTH_COMPONENT, GL_DEPTH_COMPONENT24);
  ShadowTex.Bind();
  gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE);
  ShadowTex.Clamp := True;
  ShadowTex.Filter := tfBilinear;

  ShadowRT := TRenderTarget.Create(SHADOW_SIZE, SHADOW_SIZE, False);
  ShadowRT.Attach(rcDepth, ShadowTex);
end;

procedure TScene.Load(const FileName: string);
begin
  //
end;

procedure TScene.Free;
begin
  ShadowRT.Free;
  ShadowTex.Free;
  Node.Free;
end;

procedure TScene.OnRender;
const
  GL_SAMPLE_ALPHA_TO_MASK = TGLConst($809E);
  GL_SAMPLE_MASK          = TGLConst($80A0);
var
  MainCamera  : TCamera;
  LightCamera : TCamera;
  OldRT : TRenderTarget;
begin
  MainCamera := Render.Camera;
  MainCamera.UpdateMatrix;
  MainCamera.UpdatePlanes;

  if Shadows then
  begin
  // create light camera
    LightCamera.Init(cmLookAt, cpPersp);
    LightCamera.ZNear  := 0.1;
    LightCamera.ZFar   := Render.Light[0].Radius;
    LightCamera.FOV    := 90;
    LightCamera.Pos    := Render.Light[0].Pos;
    LightCamera.Target := Vec3f(0, 1, 0);

    LightCamera.UpdateMatrix;
    LightCamera.UpdatePlanes;
    with Render.Light[0] do
    begin
      Matrix.Identity;
      Matrix.e03 := 0.5;
      Matrix.e13 := 0.5;
      Matrix.e23 := 0.5;
      Matrix.e00 := 0.5;
      Matrix.e11 := 0.5;
      Matrix.e22 := 0.5;
      Matrix := Matrix * LightCamera.ProjMatrix * LightCamera.ViewMatrix;
    end;

    Render.DepthTest := True;

  // render shadow map
    Render.Mode := rmShadow;
    OldRT := Render.Target;
    Render.Target := ShadowRT;
    Render.Viewport := Rect(0, 0, SHADOW_SIZE, SHADOW_SIZE);
    Render.Camera := LightCamera;
    Render.Camera.Setup;
    Render.Clear(False, True);
    Node.OnRender;
    Render.Target := OldRT;

    Render.DepthTest := True;
    Render.Light[0].ShadowMap := ShadowTex;
  end;

// main render
{
  gl.Enable(GL_SAMPLE_ALPHA_TO_MASK);
  gl.Enable(GL_SAMPLE_MASK);
  gl.SampleCoverage(0.75, False);
}
  Render.DepthTest := True;
  Render.Viewport := Rect(0, 0, Screen.Width, Screen.Height);
  Render.Camera := MainCamera;
  Render.Camera.Setup;
  Render.Mode := rmOpaque;
  Node.OnRender;
  Render.Mode := rmOpacity;
  Node.OnRender;
  Render.Light[0].ShadowMap := nil;
{
  if Shadows then
  begin
  // show shadow map
    Render.ResetBind;
    Render.Set2D(0, 0, Screen.Width, Screen.Height);
    Render.DepthTest := False;
    Render.CullFace := cfNone;
    Render.BlendType := btNone;
    ShadowTex.Bind;
    gl.Color3f(1, 1, 1);
    gl.Beginp(GL_QUADS);
      gl.TexCoord2f(0, 0); gl.Vertex2f(0, 0);
      gl.TexCoord2f(0, 1); gl.Vertex2f(0, 256);
      gl.TexCoord2f(1, 1); gl.Vertex2f(256, 256);
      gl.TexCoord2f(1, 0); gl.Vertex2f(256, 0);
    gl.Endp;
    Render.DepthTest := True;
  end;
}
end;
{$ENDIF}
{$ENDREGION}

// OpenGL ======================================================================
{$REGION 'TGL'}
procedure TGL.Init;
type
  TProcArray = array [-1..0] of Pointer;
const
  ProcName : array [0..(SizeOf(TGL) - SizeOf(Lib)) div 4 - 1] of PAnsiChar = (
  {$IFDEF WINDOWS}
    'wglGetProcAddress',
    'wglSwapIntervalEXT',
  {$ENDIF}
  {$IFDEF LINUX}
    'glXGetProcAddress',
    'glXSwapIntervalSGI',
  {$ENDIF}
  {$IFDEF DARWIN}
    '',
    '',
  {$ENDIF}
    'glGetIntegerv',
    'glGetFloatv',
    'glGetString',
    'glFlush',
    'glPolygonMode',
    'glPixelStorei',
    'glGenTextures',
    'glDeleteTextures',
    'glBindTexture',
    'glTexParameteri',
    'glTexImage2D',
    'glTexSubImage2D',
    'glGetTexImage',
    'glGenerateMipmapEXT',
    'glCopyTexSubImage2D',
    'glCompressedTexImage2DARB',
    'glActiveTextureARB',
    'glClientActiveTextureARB',
    'glClear',
    'glClearColor',
    'glColorMask',
    'glDepthMask',
    'glStencilMask',
    'glEnable',
    'glDisable',
    'glCullFace',
    'glAlphaFunc',
    'glBlendFunc',
    'glStencilFunc',
    'glDepthFunc',
    'glStencilOp',
    'glLightfv',
    'glMaterialfv',
    'glViewport',
    'glScissor',
    'glBegin',
    'glEnd',
    'glPointSize',
    'glLineWidth',
    'glColor3f',
    'glColor3fv',
    'glColor4ub',
    'glColor4ubv',
    'glColor4f',
    'glColor4fv',
    'glVertex2f',
    'glVertex2fv',
    'glVertex3f',
    'glVertex3fv',
    'glNormal3f',
    'glNormal3fv',
    'glTexCoord2f',
    'glTexCoord2fv',
    'glEnableClientState',
    'glDisableClientState',
    'glDrawElements',
    'glDrawArrays',
    'glColorPointer',
    'glVertexPointer',
    'glTexCoordPointer',
    'glNormalPointer',
    'glMatrixMode',
    'glLoadIdentity',
    'glLoadMatrixf',
    'glMultMatrixf',
    'glPushMatrix',
    'glPopMatrix',
    'glScalef',
    'glTranslatef',
    'glRotatef',
    'glOrtho',
    'glFrustum',
    'glReadPixels',
    'glDrawBuffer',
    'glReadBuffer',
    'glGenBuffersARB',
    'glDeleteBuffersARB',
    'glBindBufferARB',
    'glBufferDataARB',
    'glBufferSubDataARB',
    'glMapBufferARB',
    'glUnmapBufferARB',
    'glGetProgramiv',
    'glCreateProgram',
    'glDeleteProgram',
    'glLinkProgram',
    'glUseProgram',
    'glProgramParameteriEXT',
    'glGetProgramInfoLog',
    'glGetShaderiv',
    'glCreateShader',
    'glDeleteShader',
    'glShaderSource',
    'glAttachShader',
    'glCompileShader',
    'glGetShaderInfoLog',
    'glGetUniformLocation',
    'glUniform1iv',
    'glUniform1fv',
    'glUniform2fv',
    'glUniform3fv',
    'glUniform4fv',
    'glUniformMatrix3fv',
    'glUniformMatrix4fv',
    'glGetAttribLocation',
    'glEnableVertexAttribArray',
    'glDisableVertexAttribArray',
    'glVertexAttribPointer',
    'glDrawBuffers',
    'glGenFramebuffersEXT',
    'glDeleteFramebuffersEXT',
    'glBindFramebufferEXT',
    'glFramebufferTexture2DEXT',
    'glFramebufferRenderbufferEXT',
    'glCheckFramebufferStatusEXT',
    'glGenRenderbuffersEXT',
    'glDeleteRenderbuffersEXT',
    'glBindRenderbufferEXT',
    'glRenderbufferStorageEXT',
    'glSampleCoverage'
  );
var
  i    : LongInt;
  Proc : ^TProcArray;
begin
  Lib := LoadLibraryA(opengl32);
  if Lib <> 0 then
  begin
    Proc := @Self;
    {$IFNDEF DARWIN}
    Proc^[0] := GetProcAddress(Lib, ProcName[0]); // gl.GetProc
    {$ENDIF}
    for i := {$IFDEF DARWIN}2{$ELSE}1{$ENDIF} to High(ProcName) do
    begin
      {$IFNDEF DARWIN}
      Proc^[i] := GetProc(ProcName[i]);
      if Proc^[i] = nil then
      {$ENDIF}
        Proc^[i] := GetProcAddress(Lib, ProcName[i]);
{
      if Proc^[i] = nil then
        Writeln('Error: ', ProcName[i]);
}
    end;
  end;
{$IFDEF WINDOWS}
  Set8087CW($133F);
{$ELSE}
  {$IF DEFINED(cpui386) OR DEFINED(cpux86_64)}
  //  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  {$IFEND}
{$ENDIF}
end;

procedure TGL.Free;
begin
  FreeLibrary(Lib);
end;
{$ENDREGION}

// CoreX =======================================================================
{$REGION 'CoreX'}
procedure Init;
begin
  ResManager.Init;
{$IFNDEF NO_FILESYS}
  FileSys.Init;
{$ENDIF}
  Screen.Init;
  Input.Init;
{$IFNDEF NO_SOUND}
  Sound.Init;
{$ENDIF}
{$IFNDEF NO_GUI}
  GUI := TGUI.Create(0, 0, Screen.Width, Screen.Height);
{$ENDIF}
{$IFNDEF NO_SCENE}
  Scene.Init;
{$ENDIF}
end;

procedure Free;
begin
{$IFNDEF NO_SCENE}
  Scene.Free;
{$ENDIF}
{$IFNDEF NO_GUI}
  GUI.Free;
  GUI := nil;
{$ENDIF}
{$IFNDEF NO_SOUND}
  Sound.Free;
{$ENDIF}
  Input.Free;
  Screen.Free;
  ResManager.Free;
end;

procedure Start(PInit, PFree, PRender: TCoreProc);
begin
  Init;
  PInit;
  Input.Update;
  while not Screen.FQuit do
  begin
    Input.Update;
    Screen.Update;
    Render.Update;
    PRender;
    Screen.Swap;
  end;
  PFree;
  Free;
end;
procedure Quit;
begin
  Screen.FQuit := True;
end;

procedure MsgBox(const Caption, Text: string);
begin
  {$IFDEF WINDOWS}
    MessageBoxA(0, PAnsiChar(AnsiString(Text)), PAnsiChar(AnsiString(Caption)), 16);
  {$ENDIF}
end;

function Assert(const Error: string; Flag: Boolean): Boolean;
begin
  Result := Flag;
  if Flag then
  begin
    MsgBox('Fatal Error', Error);
    Halt;
  end;
end;
{$ENDREGION}

end.
