unit CoreX;
{====================================================================}
{                 "CoreX" crossplatform game library                 }
{  Version : 0.01                                                    }
{  Mail    : xproger@list.ru                                         }
{  Site    : http://xproger.mentalx.org                              }
{====================================================================}
{ LICENSE:                                                           }
{ Copyright (c) 2009, Timur "XProger" Gagiev                         }
{ All rights reserved.                                               }
{                                                                    }
{ Redistribution and use in source and binary forms, with or without }
{ modification, are permitted under the terms of the BSD License.    }
{====================================================================}
interface

{$DEFINE DEBUG}

{$IFDEF WIN32}
  {$DEFINE WINDOWS}
{$ELSE}
  {$DEFINE LINUX}
{$ENDIF}
type
  TCoreProc = procedure;

// Math ------------------------------------------------------------------------
{$REGION 'Math'}
  TVec2f = record
    x, y : Single;
  end;

  TVec3f = record
    x, y, z : Single;
  end;

  TVec4f = record
    x, y, z, w : Single;
  end;

  TMath = object
    function Vec2f(x, y: Single): TVec2f; inline;
    function Vec3f(x, y, z: Single): TVec3f; inline;
    function Vec4f(x, y, z, w: Single): TVec4f; inline;
    function Max(x, y: Single): Single; overload;
    function Min(x, y: Single): Single; overload;
    function Max(x, y: Integer): Integer; overload;
    function Min(x, y: Integer): Integer; overload;
    function Sign(x: Single): Integer;
    function Ceil(const X: Extended): Integer;
    function Floor(const X: Extended): Integer;
  end;
{$ENDREGION}

// Utils -----------------------------------------------------------------------
{$REGION 'Utils'}
  TCharSet = set of AnsiChar;

  TUtils = object
    function IntToStr(Value: LongInt): string;
    function StrToInt(const Str: string; Def: LongInt = 0): LongInt;
    function FloatToStr(Value: Single; Digits: LongInt = 6): string;
    function StrToFloat(const Str: string; Def: Single = 0): Single;
    function BoolToStr(Value: Boolean): string;
    function StrToBool(const Str: string; Def: Boolean = False): Boolean;
    function LowerCase(const Str: string): string;
    function Trim(const Str: string): string;
    function DeleteChars(const Str: string; Chars: TCharSet): string;
    function ExtractFileDir(const Path: string): string;
  end;

  TResType = (rtTexture);

  TResData = record
    Ref  : LongInt;
    Name : string;
    case TResType of
      rtTexture : (
        ID     : LongWord;
        Width  : LongInt;
        Height : LongInt;
      );
  end;

  TResManager = object
    Items : array of TResData;
    Count : LongInt;
    procedure Init;
    function Add(const Name: string; out Idx: LongInt): Boolean;
    function Delete(Idx: LongInt): Boolean;
  end;

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
    procedure Load(const FileName: string);
    procedure Save(const FileName: string);
    procedure WriteStr(const Category, Name, Value: string);
    procedure WriteInt(const Category, Name: string; Value: LongInt);
    procedure WriteFloat(const Category, Name: string; Value: Single);
    procedure WriteBool(const Category, Name: string; Value: Boolean);
    function ReadStr(const Category, Name: string; const Default: string = ''): string;
    function ReadInt(const Category, Name: string; Default: LongInt = 0): LongInt;
    function ReadFloat(const Category, Name: string; Default: Single = 0): Single;
    function ReadBool(const Category, Name: string; Default: Boolean = False): Boolean;
    function CategoryName(Idx: LongInt): string;
  end;
{$ENDREGION}

// Display ---------------------------------------------------------------------
{$REGION 'Display'}
  TAAType = (aa0x, aa1x, aa2x, aa4x, aa8x, aa16x);

  TDisplay = object
  private
    FQuit   : Boolean;
    Handle  : LongWord;
    FWidth  : LongInt;
    FHeight : LongInt;
    FFullScreen   : Boolean;
    FAntiAliasing : TAAType;
    FVSync      : Boolean;
    FActive     : Boolean;
    FCaption    : string;
    FFPS        : LongInt;
    FFPSTime    : LongInt;
    FFPSIdx     : LongInt;
    procedure Init;
    procedure Free;
    procedure Update;
    procedure Restore;
    procedure SetFullScreen(Value: Boolean);
    procedure SetVSync(Value: Boolean);
    procedure SetCaption(const Value: string);
  public
    procedure Resize(W, H: LongInt);
    procedure Swap;
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
    property FullScreen: Boolean read FFullScreen write SetFullScreen;
    property AntiAliasing: TAAType read FAntiAliasing write FAntiAliasing;
    property VSync: Boolean read FVSync write SetVSync;
    property Active: Boolean read FActive;
    property Caption: string read FCaption write SetCaption;
    property FPS: LongInt read FFPS;
  end;
{$ENDREGION}

// Input -----------------------------------------------------------------------
{$REGION 'Input'}
  TInputKey = (
  // Keyboard
    KK_NONE, KK_PLUS, KK_MINUS, KK_TILDE,
    KK_0, KK_1, KK_2, KK_3, KK_4, KK_5, KK_6, KK_7, KK_8, KK_9,
    KK_A, KK_B, KK_C, KK_D, KK_E, KK_F, KK_G, KK_H, KK_I, KK_J, KK_K, KK_L, KK_M, 
    KK_N, KK_O, KK_P, KK_Q, KK_R, KK_S, KK_T, KK_U, KK_V, KK_W, KK_X, KK_Y, KK_Z,
    KK_F1, KK_F2, KK_F3, KK_F4, KK_F5, KK_F6, KK_F7, KK_F8, KK_F9, KK_F10, KK_F11, KK_F12,
    KK_ESC, KK_ENTER, KK_BACK, KK_TAB, KK_SHIFT, KK_CTRL, KK_ALT, KK_SPACE, 
    KK_PGUP, KK_PGDN, KK_END, KK_HOME, KK_LEFT, KK_UP, KK_RIGHT, KK_DOWN, KK_INS, KK_DEL,
  // Mouse
    KM_1, KM_2, KM_3, KM_WHUP, KM_WHDN,
  // Joystick
    KJ_1, KJ_2, KJ_3, KJ_4, KJ_5, KJ_6, KJ_7, KJ_8, KJ_9, KJ_10, KJ_11, KJ_12, KJ_13, KJ_14, KJ_15, KJ_16
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

  TInput = object
  private
    FCapture    : Boolean;
    FDown, FHit : array [TInputKey] of Boolean;
    FLastKey    : TInputKey;
    procedure Init;
    procedure Free;
    procedure Reset;
    procedure Update;
    function GetDown(InputKey: TInputKey): Boolean;
    function GetHit(InputKey: TInputKey): Boolean;
    procedure SetState(InputKey: TInputKey; Value: Boolean);
    procedure SetCapture(Value: Boolean);
  public
    Mouse : TMouse;
    Joy   : TJoy;
    property LastKey: TInputKey read FLastKey;
    property Down[InputKey: TInputKey]: Boolean read GetDown;
    property Hit[InputKey: TInputKey]: Boolean read GetHit;
    property Capture: Boolean read FCapture write SetCapture;
  end;
{$ENDREGION}

// Render ----------------------------------------------------------------------
{$REGION 'Render'}
  TBlendType = (btNone, btNormal, btAdd, btMult);

  TRender = object
  private
    FDeltaTime : Single;
    OldTime    : LongInt;
    ResManager : TResManager;
    procedure Init;
    procedure Free;
    function GeLongWord: LongInt;
    procedure SetBlend(Value: TBlendType);
    procedure SetDepthTest(Value: Boolean);
    procedure SetDepthWrite(Value: Boolean);
  public
    procedure Clear(Color, Depth: Boolean);
    procedure Set2D(Width, Height: LongInt);
    procedure Set3D(FOV: Single; zNear: Single = 0.1; zFar: Single = 1000);
    procedure Quad(x, y, w, h, s, t, sw, th: Single); inline;
    property Time: LongInt read GeLongWord;
    property DeltaTime: Single read FDeltaTime;
    property Blend: TBlendType write SetBlend;
    property DepthTest: Boolean write SetDepthTest;
    property DepthWrite: Boolean write SetDepthWrite;
  end;
{$ENDREGION}

// Texture ---------------------------------------------------------------------
{$REGION 'Texture'}
  TTexture = object
  private
    ResIdx : LongInt;
    Width  : LongInt;
    Height : LongInt;
  public
    procedure Load(const FileName: string);
    procedure Free;
    procedure Enable(Channel: LongInt = 0);
  end;
{$ENDREGION}

// Sprite ----------------------------------------------------------------------
{$REGION 'Sprite'}
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
    Blend     : TBlendType;
    CurIndex  : LongInt;
    StarLongWord : LongInt;
    function GetPlaying: Boolean;
  public
    Pos   : TVec2f;
    Scale : TVec2f;
    Angle : Single;
    procedure Load(const FileName: string);
    procedure Free;
    procedure Play(const AnimName: string; Loop: Boolean);
    procedure Stop;
    procedure Draw;
    property Playing: Boolean read GetPlaying;
    property Anim: TSpriteAnimList read FAnim;
  end;
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
    GL_FRONT = $0404, GL_BACK, GL_FRONT_AND_BACK,
  // Tests
    GL_DEPTH_TEST = $0B71, GL_STENCIL_TEST = $0B90, GL_ALPHA_TEST = $0BC0, GL_SCISSOR_TEST = $0C11,
  // GetTarget
    GL_CULL_FACE = $0B44, GL_BLEND = $0BE2,
  // Data Types
    GL_BYTE = $1400, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT, GL_INT, GL_UNSIGNED_INT, GL_FLOAT,
  // Matrix Mode
    GL_MODELVIEW = $1700, GL_PROJECTION, GL_TEXTURE,
  // Pixel Format
    GL_RGB = $1907, GL_RGBA, GL_RGB8 = $8051, GL_RGBA8 = $8058, GL_BGR = $80E0, GL_BGRA,
  // PolygonMode
    GL_POINT = $1B00, GL_LINE, GL_FILL,
  // List mode
    GL_COMPILE = $1300, GL_COMPILE_AND_EXECUTE,
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
    GL_TEXTURE_WRAP_S = $2802, GL_TEXTURE_WRAP_T, GL_REPEAT = $2901, GL_CLAMP_TO_EDGE = $812F, GL_TEXTURE_BASE_LEVEL = $813C, GL_TEXTURE_MAX_LEVEL,
  // Textures
    GL_TEXTURE_2D = $0DE1, GL_TEXTURE0 = $84C0, GL_TEXTURE_MAX_ANISOTROPY = $84FE, GL_MAX_TEXTURE_MAX_ANISOTROPY, GL_GENERATE_MIPMAP = $8191,
  // Compressed Textures
    GL_COMPRESSED_RGB_S3TC_DXT1 = $83F0, GL_COMPRESSED_RGBA_S3TC_DXT1, GL_COMPRESSED_RGBA_S3TC_DXT3, GL_COMPRESSED_RGBA_S3TC_DXT5,
  // AA
    WGL_SAMPLE_BUFFERS = $2041, WGL_SAMPLES, WGL_DRAW_TO_WINDOW = $2001, WGL_SUPPORT_OPENGL = $2010, WGL_DOUBLE_BUFFER, WGL_COLOR_BITS = $2014, WGL_DEPTH_BITS = $2022, WGL_STENCIL_BITS,
  // FBO
    GL_FRAMEBUFFER = $8D40, GL_RENDERBUFFER, GL_DEPTH_COMPONENT24 = $81A6, GL_COLOR_ATTACHMENT0 = $8CE0, GL_DEPTH_ATTACHMENT = $8D00, GL_FRAMEBUFFER_BINDING = $8CA6, GL_FRAMEBUFFER_COMPLETE = $8CD5,
  // Shaders
    GL_FRAGMENT_SHADER = $8B30, GL_VERTEX_SHADER, GL_COMPILE_STATUS = $8B81, GL_LINK_STATUS, GL_VALIDATE_STATUS, GL_INFO_LOG_LENGTH,
  // VBO
    GL_ARRAY_BUFFER = $8892, GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY = $88B9, GL_STATIC_DRAW = $88E4, GL_VERTEX_ARRAY = $8074, GL_NORMAL_ARRAY, GL_COLOR_ARRAY, GL_INDEX_ARRAY_EXT, GL_TEXTURE_COORD_ARRAY,
  // Queries
    GL_SAMPLES_PASSED = $8914, GL_QUERY_COUNTER_BITS = $8864, GL_CURRENT_QUERY, GL_QUERY_RESULT, GL_QUERY_RESULT_AVAILABLE,
    GL_MAX_CONST = High(LongInt)
  );

{$IFDEF LINUX}
  {$MACRO ON}
  {$DEFINE stdcall := cdecl}
{$ENDIF}
  TGL = object
  private
    Lib : LongWord;
    procedure Init;
    procedure Free;
  public
    GetProc        : function (ProcName: PAnsiChar): Pointer; stdcall;
    SwapInterval   : function (Interval: LongInt): LongInt; stdcall;
    GetString      : function (name: TGLConst): PAnsiChar; stdcall;
    PolygonMode    : procedure (face, mode: TGLConst); stdcall;
    GenTextures    : procedure (n: LongInt; textures: Pointer); stdcall;
    DeleteTextures : procedure (n: LongInt; textures: Pointer); stdcall;
    BindTexture    : procedure (target: TGLConst; texture: LongWord); stdcall;
    TexParameteri  : procedure (target, pname, param: TGLConst); stdcall;
    TexImage2D     : procedure (target: TGLConst; level: LongInt; internalformat: TGLConst; width, height, border: LongInt; format, _type: TGLConst; pixels: Pointer); stdcall;
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
    BlendFunc      : procedure (sfactor, dfactor: TGLConst); stdcall;
    StencilFunc    : procedure (func: TGLConst; ref: LongInt; mask: LongWord); stdcall;
    DepthFunc      : procedure (func: TGLConst); stdcall;
    StencilOp      : procedure (fail, zfail, zpass: TGLConst); stdcall;
    Viewport       : procedure (x, y, width, height: LongInt); stdcall;
    Beginp         : procedure (mode: TGLConst); stdcall;
    Endp           : procedure;
    Vertex2fv      : procedure (xyz: Pointer); stdcall;
    Vertex3fv      : procedure (xy: Pointer); stdcall;
    TexCoord2fv    : procedure (st: Pointer); stdcall;
    EnableClientState  : procedure (_array: TGLConst); stdcall;
    DisableClientState : procedure (_array: TGLConst); stdcall;
    DrawElements    : procedure (mode: TGLConst; count: LongInt; _type: TGLConst; const indices: Pointer); stdcall;
    DrawArrays      : procedure (mode: TGLConst; first, count: LongInt); stdcall;
    ColorPointer    : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    VertexPointer   : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    TexCoordPointer : procedure (size: LongInt; _type: TGLConst; stride: LongInt; const ptr: Pointer); stdcall;
    NormalPointer   : procedure (type_: TGLConst; stride: LongWord; const P: Pointer); stdcall;
    MatrixMode      : procedure (mode: TGLConst); stdcall;
    LoadIdentity    : procedure; stdcall;
    LoadMatrixf     : procedure (m: Pointer); stdcall;
    MultMatrixf     : procedure (m: Pointer); stdcall;
    PushMatrix      : procedure; stdcall;
    PopMatrix       : procedure; stdcall;
    Scalef          : procedure (x, y, z: Single); stdcall;
    Translatef      : procedure (x, y, z: Single); stdcall;
    Rotatef         : procedure (Angle, x, y, z: Single); stdcall;
    Ortho           : procedure (left, right, bottom, top, zNear, zFar: Double); stdcall;
    Frustum         : procedure (left, right, bottom, top, zNear, zFar: Double); stdcall;
  end;
{$IFDEF LINUX}
  {$MACRO OFF}
{$ENDIF}  
{$ENDREGION}

var
  gl      : TGL;
  Math    : TMath;
  Utils   : TUtils;
  Display : TDisplay;
  Input   : TInput;
  Render  : TRender;

  procedure Start(PInit, PFree, PRender: TCoreProc);
  procedure Quit;

implementation

// System API ==================================================================
{$REGION 'Windows System'}
{$IFDEF WINDOWS}
// Windows API -----------------------------------------------------------------
type
  TWndClassEx = packed record
    cbSize        : LongWord;
    style         : LongWord;
    lpfnWndProc   : Pointer;
    cbClsExtra    : LongInt;
    cbWndExtra    : LongInt;
    hInstance     : LongWord;
    hIcon         : LongInt;
    hCursor       : LongWord;
    hbrBackground : LongWord;
    lpszMenuName  : PAnsiChar;
    lpszClassName : PAnsiChar;
    hIconSm       : LongWord;
  end;

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

  TMsg = array [0..6] of LongWord;

  TPoint = packed record
    X, Y : LongInt;
  end;

  TRect = packed record
    Left, Top, Right, Bottom : LongInt;
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
    wXpos       : LongWord;
    wYpos       : LongWord;
    wZpos       : LongWord;
    wRpos       : LongWord;
    wUpos       : LongWord;
    wVpos       : LongWord;
    wButtons    : LongWord;
    dwButtonNum : LongWord;
    dwPOV       : LongWord;
    dwRes       : array [0..1] of LongWord;
  end;

const
  kernel32            = 'kernel32.dll';
  user32              = 'user32.dll';
  gdi32               = 'gdi32.dll';
  opengl32            = 'opengl32.dll';
  winmm               = 'winmm.dll';  
  WND_CLASS           = 'CCoreX';
  WS_CAPTION          = $C00000;
  WS_MINIMIZEBOX      = $20000;
  WS_SYSMENU          = $80000;
  WS_VISIBLE          = $10000000;
  WM_DESTROY          = $0002;
  WM_ACTIVATEAPP      = $001C;
  WM_SETICON          = $0080;
  WM_KEYDOWN          = $0100;
  WM_SYSKEYDOWN       = $0104;
  WM_LBUTTONDOWN      = $0201;
  WM_RBUTTONDOWN      = $0204;
  WM_MBUTTONDOWN      = $0207;
  WM_MOUSEWHEEL       = $020A;
  SW_SHOW             = 5;
  SW_MINIMIZE         = 6;
  GWL_STYLE           = -16;
  JOYCAPS_HASZ        = $0001;
  JOYCAPS_HASR        = $0002;
  JOYCAPS_HASU        = $0004;
  JOYCAPS_HASV        = $0008;
  JOYCAPS_HASPOV      = $0010;
  JOYCAPS_POVCTS      = $0040;
  JOY_RETURNPOVCTS    = $0200;

  function QueryPerformanceFrequency(out Freq: Int64): Boolean; stdcall; external kernel32;
  function QueryPerformanceCounter(out Count: Int64): Boolean; stdcall; external kernel32;
  function LoadLibraryA(Name: PAnsiChar): LongWord; stdcall; external kernel32;
  function FreeLibrary(LibHandle: LongWord): Boolean; stdcall; external kernel32;
  function GetProcAddress(LibHandle: LongWord; ProcName: PAnsiChar): Pointer; stdcall; external kernel32;
  function RegisterClassExA(const WndClass: TWndClassEx): Word; stdcall; external user32;
  function UnregisterClassA(lpClassName: PAnsiChar; hInstance: LongWord): Boolean; stdcall; external user32;
  function CreateWindowExA(dwExStyle: LongWord; lpClassName: PAnsiChar; lpWindowName: PAnsiChar; dwStyle: LongWord; X, Y, nWidth, nHeight: LongInt; hWndParent, hMenum, hInstance: LongWord; lpParam: Pointer): LongWord; stdcall; external user32;
  function DestroyWindow(hWnd: LongWord): Boolean; stdcall; external user32;
  function ShowWindow(hWnd: LongWord; nCmdShow: LongInt): Boolean; stdcall; external user32;
  function SetWindowLongA(hWnd: LongWord; nIndex, dwNewLong: LongInt): LongInt; stdcall; external user32;
  function AdjustWindowRect(var lpRect: TRect; dwStyle: LongWord; bMenu: Boolean): Boolean; stdcall; external user32;
  function SetWindowPos(hWnd, hWndInsertAfter: LongWord; X, Y, cx, cy: LongInt; uFlags: LongWord): Boolean; stdcall; external user32;
  function GetWindowRect(hWnd: LongWord; out lpRect: TRect): Boolean; stdcall; external user32;
  function GetCursorPos(out Point: TPoint): Boolean; stdcall; external user32;
  function SetCursorPos(X, Y: LongInt): Boolean; stdcall; external user32;
  function ShowCursor(bShow: Boolean): LongInt; stdcall; external user32;
  function ScreenToClient(hWnd: LongWord; var lpPoint: TPoint): Boolean; stdcall; external user32;
  function DefWindowProcA(hWnd, Msg: LongWord; wParam, lParam: LongInt): LongInt; stdcall; external user32;
  function PeekMessageA(out lpMsg: TMsg; hWnd, Min, Max, Remove: LongWord): Boolean; stdcall; external user32;
  function TranslateMessage(const lpMsg: TMsg): Boolean; stdcall; external user32;
  function DispatchMessageA(const lpMsg: TMsg): LongInt; stdcall; external user32;
  function SendMessageA(hWnd, Msg: LongWord; wParam, lParam: LongInt): LongInt; stdcall; external user32;
  function LoadIconA(hInstance: LongInt; lpIconName: PAnsiChar): LongWord; stdcall; external user32;
  function GetDC(hWnd: LongWord): LongWord; stdcall; external user32;
  function ReleaseDC(hWnd, hDC: LongWord): LongInt; stdcall; external user32;
  function SetWindowTextA(hWnd: LongWord; Text: PAnsiChar): Boolean; stdcall; external user32;
  function EnumDisplaySettingsA(lpszDeviceName: PAnsiChar; iModeNum: LongWord; lpDevMode: Pointer): Boolean; stdcall; external user32;
  function ChangeDisplaySettingsA(lpDevMode: Pointer; dwFlags: LongWord): LongInt; stdcall; external user32;
  function SetPixelFormat(DC: LongWord; PixelFormat: LongInt; FormatDef: Pointer): Boolean; stdcall; external gdi32;
  function ChoosePixelFormat(DC: LongWord; p2: Pointer): LongInt; stdcall; external gdi32;
  function SwapBuffers(DC: LongWord): Boolean; stdcall; external gdi32;
  function wglCreateContext(DC: LongWord): LongWord; stdcall; external opengl32;
  function wglMakeCurrent(DC, p2: LongWord): Boolean; stdcall; external opengl32;
  function wglDeleteContext(p1: LongWord): Boolean; stdcall; external opengl32;
  function wglGetProcAddress(ProcName: PAnsiChar): Pointer; stdcall; external opengl32;
  function joyGetNumDevs: LongWord; stdcall; external winmm;
  function joyGetDevCapsA(uJoyID: LongWord; lpCaps: Pointer; uSize: LongWord): LongWord; stdcall; external winmm;
  function joyGetPosEx(uJoyID: LongWord; lpInfo: Pointer): LongWord; stdcall; external winmm;

var
  DC, RC   : LongWord;
  TimeFreq : Int64;
  JoyCaps  : TJoyCaps;
  JoyInfo  : TJoyInfo;
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

  KeyPressMask       = 1 shl 0;
  KeyReleaseMask     = 1 shl 1;
  ButtonPressMask    = 1 shl 2;
  ButtonReleaseMask  = 1 shl 3;
  PointerMotionMask  = 1 shl 6;
  ButtonMotionMask   = 1 shl 13;
  FocusChangeMask    = 1 shl 21;

  CWOverrideRedirect = 1 shl 9;
  CWEventMask        = 1 shl 11;
  CWColormap         = 1 shl 13;
  CWCursor           = 1 shl 14;

  PPosition = 1 shl 2;
  PMinSize  = 1 shl 4;
  PMaxSize  = 1 shl 5;

  KeyPress        = 2;
  KeyRelease      = 3;
  ButtonPress     = 4;
  ButtonRelease   = 5;
  FocusIn         = 9;
  FocusOut        = 10; 
  ClientMessage   = 33;

  GLX_BUFFER_SIZE    = 2;
  GLX_RGBA           = 4;
  GLX_DOUBLEBUFFER   = 5;
  GLX_DEPTH_SIZE     = 12;
  GLX_STENCIL_SIZE   = 13;
  GLX_SAMPLES        = 100001;

  KEYBOARD_MASK = KeyPressMask or KeyReleaseMask;
  MOUSE_MASK = ButtonPressMask or ButtonReleaseMask or ButtonMotionMask or PointerMotionMask;

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

  TXColor = record
    pixel      : LongWord;
    r, g, b    : Word;     
    flags, pad : AnsiChar;
  end;

  PXSizeHints = ^TXSizeHints;
  TXSizeHints = record
    flags        : LongInt;
    x, y, w, h   : LongInt;
    min_w, min_h : LongInt;
    max_w, max_h : LongInt;
    SomeData1    : array [0..8] of LongInt;
  end;

  TXClientMessageEvent = record
    message_type: LongWord;
    format: LongInt;
    data: record l: array[0..4] of LongInt; end;
  end;

  TXKeyEvent = record
    Root, Subwindow: LongWord;
    Time : LongWord;
    x, y, XRoot, YRoot : Integer;
    State, KeyCode : LongWord;
    SameScreen : Boolean;
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
    tv_sec  : LongInt; 
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

  function glXChooseVisual(dpy: Pointer; screen: Integer; attribList: Pointer): PXVisualInfo; cdecl; external;
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

  WM_PROTOCOLS : LongWord;
  WM_DESTROY   : LongWord;
{$ENDIF}
{$ENDREGION}

// Math ========================================================================
{$REGION 'TMath'}
function TMath.Vec2f(x, y: Single): TVec2f;
begin
  Result.x := x;
  Result.y := y;
end;

function TMath.Vec3f(x, y, z: Single): TVec3f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function TMath.Vec4f(x, y, z, w: Single): TVec4f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
end;

function TMath.Max(x, y: Single): Single;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function TMath.Min(x, y: Single): Single;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function TMath.Max(x, y: LongInt): LongInt;
begin
  if x > y then
    Result := x
  else
    Result := y;
end;

function TMath.Min(x, y: LongInt): LongInt;
begin
  if x < y then
    Result := x
  else
    Result := y;
end;

function TMath.Sign(x: Single): LongInt;
begin
  if x > 0 then
    Result := 1
  else
    if x < 0 then
      Result := -1
    else
      Result := 0;
end;

function TMath.Ceil(const X: Extended): LongInt;
begin
  Result := LongInt(Trunc(X));
  if Frac(X) > 0 then
    Inc(Result);
end;

function TMath.Floor(const X: Extended): LongInt;
begin
  Result := LongInt(Trunc(X));
  if Frac(X) < 0 then
    Dec(Result);
end;
{$ENDREGION}

// Utils =======================================================================
{$REGION 'TUtils'}
function TUtils.IntToStr(Value: LongInt): string;
var
  Res : string[32];
begin
  Str(Value, Res);
  Result := string(Res);
end;

function TUtils.StrToInt(const Str: string; Def: LongInt): LongInt;
var
  Code : LongInt;
begin
  Val(Str, Result, Code);
  if Code <> 0 then
    Result := Def;
end;

function TUtils.FloatToStr(Value: Single; Digits: LongInt = 6): string;
var
  Res : string[32];
begin
  Str(Value:0:Digits, Res);
  Result := string(Res);
end;

function TUtils.StrToFloat(const Str: string; Def: Single): Single;
var
  Code : LongInt;
begin
  Val(Str, Result, Code);
  if Code <> 0 then
    Result := Def;
end;

function TUtils.BoolToStr(Value: Boolean): string;
begin
  if Value then
    Result := 'true'
  else
    Result := 'false';
end;

function TUtils.StrToBool(const Str: string; Def: Boolean = False): Boolean;
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

function TUtils.LowerCase(const Str: string): string;
begin
  Result := Str; // FIX!
end;

function TUtils.Trim(const Str: string): string;
var
  i, j: LongInt;
begin
  j := Length(Str);
  i := 1;
  while (i <= j) and (Str[i] <= ' ') do
    Inc(i);
  if i <= j then
  begin
    while Str[j] <= ' ' do
      Dec(j);
    Result := Copy(Str, i, j - i + 1);
  end else
    Result := '';
end;

function TUtils.DeleteChars(const Str: string; Chars: TCharSet): string;
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

function TUtils.ExtractFileDir(const Path: string): string;
var
  i : Integer;
begin
  for i := Length(Path) downto 1 do
    if (Path[i] = '\') or (Path[i] = '/') then
    begin
      Result := Copy(Path, 1, i);
      Exit;
    end;
  Result := '';
end;
{$ENDREGION}

{$REGION 'TResManager'}
procedure TResManager.Init;
begin
  Items := nil;
  Count := 0;
end;

function TResManager.Add(const Name: string; out Idx: LongInt): Boolean;
var
  i : LongInt;
begin
  Idx := -1;
// Resource in array?
  Result := False;
  for i := 0 to Count - 1 do
    if Items[i].Name = Name then
    begin
      Idx := i;
      Inc(Items[Idx].Ref);
      Exit;
    end;
// Get free slot
  Result := True;
  for i := 0 to Count - 1 do
    if Items[i].Ref <= 0 then
    begin
      Idx := i;
      Break;
    end;
// Init slot
  if Idx = -1 then
  begin
    Idx := Count;
    Inc(Count);
    SetLength(Items, Count);
  end;
  Items[Idx].Name := Name;
  Items[Idx].Ref  := 1;
end;

function TResManager.Delete(Idx: LongInt): Boolean;
begin
  Dec(Items[Idx].Ref);
  Result := Items[Idx].Ref <= 0;
end;
{$ENDREGION}

{$REGION 'TConfigFile'}
procedure TConfigFile.Load(const FileName: string);
var
  F : TextFile;
  Category, Line : string;
  CatId : LongInt;
begin
  Data := nil;
  CatId := -1;
  AssignFile(F, FileName);
  Reset(F);
  while not Eof(F) do
  begin
    Readln(F, Line);
    if Line <> '' then
      if Line[1] <> '[' then
      begin
        if (Line[1] <> ';') and (CatId >= 0) then
        begin
          SetLength(Data[CatId].Params, Length(Data[CatId].Params) + 1);
          with Data[CatId], Params[Length(Params) - 1] do
          begin
            Name  := Utils.Trim(Copy(Line, 1, Pos('=', Line) - 1));
            Value := Utils.Trim(Copy(Line, Pos('=', Line) + 1, Length(Line)));
          end;
        end;
      end else
      begin
        Category := Utils.Trim(Utils.DeleteChars(Line, ['[', ']']));
        CatId := Length(Data);
        SetLength(Data, CatId + 1);
        Data[CatId].Category := Category;
      end;
  end;
  CloseFile(F);
end;

procedure TConfigFile.Save(const FileName: string);
var
  F : TextFile;
  i, j : LongInt;
begin
  AssignFile(F, FileName);
  Rewrite(F);
  for i := 0 to Length(Data) - 1 do
  begin
    Writeln(F, '[', Data[i].Category, ']');
    for j := 0 to Length(Data[i].Params) - 1 do
      Writeln(F, Data[i].Params[j].Name, ' = ', Data[i].Params[j].Value);
    Writeln(F);
  end;
  CloseFile(F);
end;

procedure TConfigFile.WriteStr(const Category, Name, Value: string);
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

procedure TConfigFile.WriteInt(const Category, Name: string; Value: LongInt);
begin
  WriteStr(Category, Name, Utils.IntToStr(Value));
end;

procedure TConfigFile.WriteFloat(const Category, Name: string; Value: Single);
begin
  WriteStr(Category, Name, Utils.FloatToStr(Value, 4));
end;

procedure TConfigFile.WriteBool(const Category, Name: string; Value: Boolean);
begin
  WriteStr(Category, Name, Utils.BoolToStr(Value));
end;

function TConfigFile.ReadStr(const Category, Name: string; const Default: string = ''): string;
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

function TConfigFile.ReadInt(const Category, Name: string; Default: LongInt): LongInt;
begin
  Result := Utils.StrToInt(ReadStr(Category, Name, ''), Default);
end;

function TConfigFile.ReadFloat(const Category, Name: string; Default: Single): Single;
begin
  Result := Utils.StrToFloat(ReadStr(Category, Name, ''), Default);
end;

function TConfigFile.ReadBool(const Category, Name: string; Default: Boolean): Boolean;
begin
  Result := Utils.StrToBool(ReadStr(Category, Name, ''), Default);
end;

function TConfigFile.CategoryName(Idx: LongInt): string;
begin
  if (Idx >= 0) and (Idx < Length(Data)) then
    Result := Data[Idx].Category
  else
    Result := '';
end;
{$ENDREGION}

// Display =====================================================================
{$REGION 'TDisplay'}
{$IFDEF WINDOWS}
function WndProc(Hwnd, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;

  function ToInputKey(Value: LongInt): TInputKey;
  begin
    case Value of
      16..18   : // KK_SHIFT..KK_ALT
        Result := TInputKey(Ord(KK_SHIFT) + (Value - 16));
      32..40   : // KK_SPACE..KK_DOWN
        Result := TInputKey(Ord(KK_SPACE) + (Value - 32));
      48..57   : // numbers
        Result := TInputKey(Ord(KK_0) + (Value - 48));
      65..90   : // alphabet
        Result := TInputKey(Ord(KK_A) + (Value - 65));
      112..123 : // Functional Keys (F1..F12)
        Result := TInputKey(Ord(KK_F1) + (Value - 112));
      8   : Result := KK_BACK;
      9   : Result := KK_TAB;
      13  : Result := KK_ENTER;
      27  : Result := KK_ESC;
      45  : Result := KK_INS;
      46  : Result := KK_DEL;
      187 : Result := KK_PLUS;
      189 : Result := KK_MINUS;
      192 : Result := KK_TILDE;
    else
      Result := KK_NONE;
    end;
  end;

begin
  Result := 0;
  case Msg of
  // Close window
    WM_DESTROY :
      Quit;
  // Activation / Deactivation
    WM_ACTIVATEAPP :
      with Display do
      begin
        FActive := Word(wParam) = 1;
        if FullScreen then
        begin
          FullScreen := FActive;
          if FActive then
            ShowWindow(Handle, SW_SHOW)
          else
            ShowWindow(Handle, SW_MINIMIZE);
          FFullScreen := True;
        end;
        Input.Reset;
      end;
  // Keyboard
    WM_KEYDOWN, WM_KEYDOWN + 1, WM_SYSKEYDOWN, WM_SYSKEYDOWN + 1 :
    begin
      Input.SetState(ToInputKey(WParam), (Msg = WM_KEYDOWN) or (Msg = WM_SYSKEYDOWN));
      if (Msg = WM_SYSKEYDOWN) and (WParam = 13) then // Alt + Enter
        Display.FullScreen := not Display.FullScreen;
    end;
  // Mouse
    WM_LBUTTONDOWN, WM_LBUTTONDOWN + 1 : Input.SetState(KM_1, Msg = WM_LBUTTONDOWN);
    WM_RBUTTONDOWN, WM_RBUTTONDOWN + 1 : Input.SetState(KM_2, Msg = WM_RBUTTONDOWN);
    WM_MBUTTONDOWN, WM_MBUTTONDOWN + 1 : Input.SetState(KM_3, Msg = WM_MBUTTONDOWN);
    WM_MOUSEWHEEL :
      begin
        Inc(Input.Mouse.Delta.Wheel, SmallInt(wParam  shr 16) div 120);
        Input.SetState(KM_WHUP, SmallInt(wParam shr 16) > 0);
        Input.SetState(KM_WHDN, SmallInt(wParam shr 16) < 0);
      end
  else
    Result := DefWindowProcA(Hwnd, Msg, WParam, LParam);
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
procedure WndProc(var Event: TXEvent);

  function ToInputKey(Value: LongWord): TInputKey;
  const
    KeyCodes : array [KK_PLUS..KK_DEL] of Word =
      ($3D, $2D, $60,
       $30, $31, $32, $33, $34, $35, $36, $37, $38, $39,
       $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A,
       $FFBE, $FFBF, $FFC0, $FFC1, $FFC2, $FFC3, $FFC4, $FFC5, $FFC6, $FFC7, $FFC8, $FFC9,
       $FF1B, $FF0D, $FF08, $FF09, $FFE1, $FFE3, $FFE9, $20, $FF55, $FF56, $FF57, $FF50, $FF51, $FF52, $FF53, $FF54, $FF63, $FFFF);
  var
    Key : TInputKey;
  begin
    Result := KK_NONE;
    for Key := Low(KeyCodes) to High(KeyCodes) do
      if KeyCodes[Key] = Value then
      begin
        Result := Key;
        break;
      end
  end;

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
    FocusIn, FocusOut :
      with Display do 
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
    KeyPress, KeyRelease :
      with Event.xkey do
      begin
        Input.SetState(ToInputKey(XLookupKeysym(@Event, 0)), Event._type = KeyPress);
        if (state and 8 <> 0) and (KeyCode = 36) and (Event._type = KeyPress) then // Alt + Enter
          Display.FullScreen := not Display.FullScreen;
      end;
  // Mouse
    ButtonPress, ButtonRelease :  
      begin
        case Event.xkey.KeyCode of
          1 : Key := KM_1;
          2 : Key := KM_3;
          3 : Key := KM_2;
          4 : Key := KM_WHUP;
          5 : Key := KM_WHDN;
        else
          Key := KK_NONE;
        end;
        Input.SetState(Key, Event._type = ButtonPress);
        if Event._type = ButtonPress then
          case Key of
            KM_WHUP : Inc(Input.Mouse.Delta.Wheel);
            KM_WHDN : Dec(Input.Mouse.Delta.Wheel);
          end;        
      end;      
  end;
end;
{$ENDIF}

procedure TDisplay.Init;
{$IFDEF WINDOWS}
type
  TwglChoosePixelFormatARB = function (DC: LongWord; const piList, pfFList: Pointer; nMaxFormats: LongWord; piFormats, nNumFormats: Pointer): Boolean; stdcall;
const
  AttribF : array [0..1] of Single = (0, 0);
  AttribI : array [0..17] of TGLConst = (
    WGL_SAMPLES,        GL_ZERO,
    WGL_DRAW_TO_WINDOW, GL_TRUE,
    WGL_SUPPORT_OPENGL, GL_TRUE,
    WGL_SAMPLE_BUFFERS, GL_TRUE,
    WGL_DOUBLE_BUFFER,  GL_TRUE,
    WGL_COLOR_BITS,     TGLConst(32),
    WGL_DEPTH_BITS,     TGLConst(24),
    WGL_STENCIL_BITS,   TGLConst(8),
    GL_ZERO, GL_ZERO);
var
  WndClass : TWndClassEx;
  PFD      : TPixelFormatDescriptor;
  ChoisePF : TwglChoosePixelFormatARB;
  PFIdx    : LongInt;
  PFCount  : LongWord;
begin
  FWidth   := 800;
  FHeight  := 600;
  FCaption := 'CoreX';
// Init structures
  FillChar(WndClass, SizeOf(WndClass), 0);
  with WndClass do
  begin
    cbSize        := SizeOf(WndClass);
    lpfnWndProc   := @WndProc;
    hCursor       := 65553;
    hbrBackground := 9;
    lpszClassName := WND_CLASS;
  end;
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
    LongWord(Pointer(@AttribI[1])^) := 1 shl (Ord(FAntiAliasing) - 1); // Set num WGL_SAMPLES
  // Temp window
    Handle := CreateWindowExA(0, 'EDIT', nil, 0, 0, 0, 0, 0, 0, 0, 0, nil);
    DC := GetDC(Handle);
    SetPixelFormat(DC, ChoosePixelFormat(DC, @PFD), @PFD);
    RC := wglCreateContext(DC);
    wglMakeCurrent(DC, RC);
    ChoisePF := TwglChoosePixelFormatARB(wglGetProcAddress('wglChoosePixelFormatARB'));
    if @ChoisePF <> nil then
      ChoisePF(DC, @AttribI, @AttribF, 1, @PFIdx, @PFCount);
    wglMakeCurrent(0, 0);
    wglDeleteContext(RC);
    ReleaseDC(Handle, DC);
    DestroyWindow(Handle);
  end;
// Window
  RegisterClassExA(WndClass);
  Handle := CreateWindowExA(0, WND_CLASS, PAnsiChar(AnsiString(FCaption)), 0,
                            0, 0, 0, 0, 0, 0, HInstance, nil);
  SendMessageA(Handle, WM_SETICON, 1, LoadIconA(HInstance, 'MAINICON'));
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
const
  XGLAttr : array [0..11] of LongWord = (
    GLX_SAMPLES, 0,
    GLX_RGBA, 1,
    GLX_BUFFER_SIZE, 32,
    GLX_DOUBLEBUFFER,
    GLX_DEPTH_SIZE, 24,
    GLX_STENCIL_SIZE, 8,
    0);
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
  LongWord(Pointer(@XGLAttr[1])^) := 1 shl (Ord(FAntiAliasing) - 1); // Set num GLX_SAMPLES
  XVisual := glXChooseVisual(XDisp, XScr, @XGLAttr);
  XRoot   := XRootWindow(XDisp, XVisual^.screen);
  Pixmap  := XCreatePixmap(XDisp, XRoot, 1, 1, 1);
  FillChar(Color, SizeOf(Color), 0);
  XWndAttr.cursor := 0;//XCreatePixmapCursor(XDisp, Pixmap, Pixmap, @Color, @Color, 0, 0);
  XWndAttr.background_pixel := XBlackPixel(XDisp, XScr);
  XWndAttr.colormap   := XCreateColormap(XDisp, XRoot, XVisual^.visual, 0);
  XWndAttr.event_mask := KEYBOARD_MASK or MOUSE_MASK or FocusChangeMask;
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

procedure TDisplay.Free;
{$IFDEF WINDOWS}
begin
  Render.Free;
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  ReleaseDC(Handle, DC);
  DestroyWindow(Handle);
  UnregisterClassA(WND_CLASS, HInstance);
end;
{$ENDIF}
{$IFDEF LINUX}
begin
// Restore video mode
  if FullScreen then
    FullScreen := False;
  XRRFreeScreenConfigInfo(ScrConfig);
  Render.Free;
// OpenGL 
  glXMakeCurrent(XDisp, 0, nil);
  XFree(XVisual);
  glXDestroyContext(XDisp, XContext);
// Window
  XDestroyWindow(XDisp, Handle);
  XCloseDisplay(XDisp);
end;
{$ENDIF}

procedure TDisplay.Update;
{$IFDEF WINDOWS}
var
  Msg : TMsg;
begin
  while PeekMessageA(Msg, 0, 0, 0, 1) do
  begin
    TranslateMessage(Msg);
    DispatchMessageA(Msg);
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

procedure TDisplay.Restore;
{$IFDEF WINDOWS}
var
  Style : LongWord;
  Rect  : TRect;
begin
// Change main window style
  if FullScreen then
    Style := 0
  else
    Style := WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX;
  SetWindowLongA(Handle, GWL_STYLE, Style or WS_VISIBLE);
  Rect.Left   := 0;
  Rect.Top    := 0;
  Rect.Right  := Width;
  Rect.Bottom := Height;
  AdjustWindowRect(Rect, Style, False);
  with Rect do
    SetWindowPos(Handle, 0, 0, 0, Right - Left, Bottom - Top, $220);
  gl.Viewport(0, 0, Width, Height);
  VSync := FVSync;
  Swap;
  Swap;
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
  Mask := CWColormap or CWEventMask or CWCursor;
  if FFullScreen then
    Mask := Mask or CWOverrideRedirect; 
// Create new window
  Handle := XCreateWindow(XDisp, XRoot,
                          0, 0, Width, Height, 0,
                          XVisual^.depth, 1,
                          XVisual^.visual,
                          Mask, @XWndAttr);
// Change size
  XSizeHint.flags := PPosition or PMinSize or PMaxSize;
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
    XGrabPointer(XDisp, Handle, True, ButtonPressMask, 1, 1, Handle, 0, 0);
  end;
  gl.Viewport(0, 0, Width, Height);
  VSync := FVSync;
  Swap;
  Swap;
end;
{$ENDIF}

procedure TDisplay.SetFullScreen(Value: Boolean);
{$IFDEF WINDOWS}
var
  DevMode : TDeviceMode;
begin
  if Value then
  begin
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

procedure TDisplay.SetVSync(Value: Boolean);
begin
  FVSync := Value;
  if @gl.SwapInterval <> nil then
    gl.SwapInterval(Ord(FVSync));
end;

procedure TDisplay.SetCaption(const Value: string);
begin
  FCaption := Value;
{$IFDEF WINDOWS}
  SetWindowTextA(Handle, PAnsiChar(AnsiString(Value)));
{$ENDIF}
{$IFDEF LINUX}
  XStoreName(XDisp, Handle, PAnsiChar(Value));
{$ENDIF}
end;

procedure TDisplay.Resize(W, H: LongInt);
begin
  FWidth  := W;
  FHeight := H;
  FullScreen := FullScreen; // Resize screen
end;

procedure TDisplay.Swap;
begin
{$IFDEF WINDOWS}
  SwapBuffers(DC);
{$ENDIF}
{$IFDEF LINUX}
  glXSwapBuffers(XDisp, Handle);
{$ENDIF}
  Inc(FFPSIdx);
  if Render.Time - FFPSTime >= 1000 then
  begin
    FFPS     := FFPSIdx;
    FFPSIdx  := 0;
    FFPSTime := Render.Time;
    Caption := 'CoreX [FPS: ' + Utils.IntToStr(FPS) + ']';
  end;
end;
{$ENDREGION}

// Input =======================================================================
{$REGION 'TInput'}
procedure TInput.Init;
begin
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

procedure TInput.Update;
var
{$IFDEF WINDOWS}
  Rect  : TRect;
  Pos   : TPoint;
  CPos  : TPoint;
  i     : LongInt;
  JKey  : TInputKey;
  JDown : Boolean;

  function AxisValue(Value, Min, Max: LongWord): LongInt;
  begin
    Result := Round((Value + Min) / (Max - Min) * 200 - 100);
  end;
{$ENDIF}
{$IFDEF LINUX}
  WRoot, WChild, Mask : LongWord;
  X, Y, rX, rY        : longInt;
{$ENDIF}
begin
  FillChar(FHit, SizeOf(FHit), False);
  FLastKey := KK_NONE;
  Mouse.Delta.Wheel := 0;
  SetState(KM_WHUP, False);
  SetState(KM_WHDN, False);
{$IFDEF WINDOWS}
// Mouse
  GetWindowRect(Display.Handle, Rect);
  GetCursorPos(Pos);
  if not FCapture then
  begin
  // Calc mouse cursor pos (Client Space)
    ScreenToClient(Display.Handle, Pos);
    Mouse.Delta.X := Pos.X - Mouse.Pos.X;
    Mouse.Delta.Y := Pos.Y - Mouse.Pos.Y;
    Mouse.Pos.X := Pos.X;
    Mouse.Pos.Y := Pos.Y;
  end else
    if Display.Active then // Main window active?
    begin
    // Window Center Pos (Screen Space)
      CPos.X := (Rect.Right - Rect.Left) div 2;
      CPos.Y := (Rect.Bottom - Rect.Top) div 2;
    // Calc mouse cursor position delta
      Mouse.Delta.X := Pos.X - CPos.X;
      Mouse.Delta.Y := Pos.Y - CPos.Y;
    // Centering cursor
      if (Mouse.Delta.X <> 0) or (Mouse.Delta.Y <> 0) then
        SetCursorPos(Rect.Left + CPos.X, Rect.Top + CPos.Y);
      Inc(Mouse.Pos.X, Mouse.Delta.X);
      Inc(Mouse.Pos.Y, Mouse.Delta.Y);
    end else
    begin
    // No delta while window is not active
      Mouse.Delta.X := 0;
      Mouse.Delta.Y := 0;
    end;
// Joystick
  with Joy do
  begin
    FillChar(Axis, SizeOf(Axis), 0);
    POV := -1;
    if Ready and (joyGetPosEx(0, @JoyInfo) = 0) then
      with JoyCaps, JoyInfo, Axis do
      begin
      // Axis
        X := AxisValue(wXpos, wXmin, wXmax);
        Y := AxisValue(wYpos, wYmin, wYmax);
        if wCaps and JOYCAPS_HASZ > 0 then Z := AxisValue(wZpos, wZmin, wZmax);
        if wCaps and JOYCAPS_HASR > 0 then R := AxisValue(wRpos, wRmin, wRmax);
        if wCaps and JOYCAPS_HASU > 0 then U := AxisValue(wUpos, wUmin, wUmax);
        if wCaps and JOYCAPS_HASV > 0 then V := AxisValue(wVpos, wVmin, wVmax);
      // Point-Of-View
        if (wCaps and JOYCAPS_HASPOV > 0) and (dwPOV and $FFFF <> $FFFF) then
          POV := dwPOV and $FFFF / 100;
      // Buttons
        for i := 0 to wNumButtons - 1 do
        begin
          JKey  := TInputKey(Ord(KJ_1) + i);
          JDown := Input.Down[JKey];
          if (wButtons and (1 shl i) <> 0) xor JDown then
            Input.SetState(JKey, not JDown);
        end;
      end;
  end;
{$ENDIF}
{$IFDEF LINUX}
  with Display do
  begin
      XQueryPointer(XDisp, Handle, @WRoot, @WChild, @rX, @rY, @X, @Y, @Mask);
      if not FCapture then
      begin
        Mouse.Delta.X := X - Mouse.Pos.X;
        Mouse.Delta.Y := Y - Mouse.Pos.Y;
        Mouse.Pos.X := X;
        Mouse.Pos.Y := Y;
      end else
        if Active then
        begin
          Mouse.Delta.X := X - Width div 2;
          Mouse.Delta.Y := Y - Height div 2;
          XWarpPointer(XDisp, XScr, Handle, 0, 0, 0, 0,  Width div 2, Height div 2);
          Inc(Mouse.Pos.X, Mouse.Delta.X);
          Inc(Mouse.Pos.Y, Mouse.Delta.Y);
        end else
        begin
          Mouse.Delta.X := 0;
          Mouse.Delta.Y := 0;
        end;
  end;
{$ENDIF}
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
  FDown[InputKey] := Value;
  if not Value then
  begin
    FHit[InputKey] := True;
    FLastKey := InputKey;
  end;
end;

procedure TInput.SetCapture(Value: Boolean);
begin
  FCapture := Value;
{$IFDEF WINDOWS}
  while ShowCursor(not FCapture) = 0 do;
{$ENDIF}
end;
{$ENDREGION}

// Render ======================================================================
{$REGION 'TRender'}
procedure TRender.Init;
begin
  gl.Init;
{$IFDEF WINDOWS}
  QueryPerformanceFrequency(TimeFreq);
{$ENDIF}
  Display.Restore;
  Blend := btNormal;
  ResManager.Init;
  gl.Enable(GL_TEXTURE_2D);
  Writeln('GL_VENDOR   : ', gl.GetString(GL_VENDOR));
  Writeln('GL_RENDERER : ', gl.GetString(GL_RENDERER));
  Writeln('GL_VERSION  : ', gl.GetString(GL_VERSION));
end;

procedure TRender.Free;
begin
  gl.Free;
end;

function TRender.GeLongWord: LongInt;
{$IFDEF WINDOWS}
var
  Count : Int64;
begin
  QueryPerformanceCounter(Count);
  Result := Trunc(1000 * (Count / TimeFreq));
end;
{$ENDIF}
{$IFDEF LINUX}
var
  tv : TTimeVal;
begin
  gettimeofday(tv, nil);
  Result := 1000 * tv.tv_sec + tv.tv_usec div 1000;
end;
{$ENDIF}

procedure TRender.SetBlend(Value: TBlendType);
begin
  gl.Enable(GL_BLEND);
  case Value of
    btNormal : gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    btAdd    : gl.BlendFunc(GL_SRC_ALPHA, GL_ONE);
    btMult   : gl.BlendFunc(GL_ZERO, GL_SRC_COLOR);
  else
    gl.Disable(GL_BLEND);
  end;
end;

procedure TRender.SetDepthTest(Value: Boolean);
begin
  if Value then
    gl.Enable(GL_DEPTH_TEST)
  else
    gl.Disable(GL_DEPTH_TEST);
end;

procedure TRender.SetDepthWrite(Value: Boolean);
begin
  gl.DepthMask(Value);
end;

procedure TRender.Clear(Color, Depth: Boolean);
var
  Mask : LongWord;
begin
  Mask := 0;
  if Color then Mask := Mask or Ord(GL_COLOR_BUFFER_BIT);
  if Depth then Mask := Mask or Ord(GL_DEPTH_BUFFER_BIT);
  gl.Clear(TGLConst(Mask));
end;

procedure TRender.Set2D(Width, Height: LongInt);
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadIdentity;
  gl.Ortho(0, Width, 0, Height, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity;
end;

procedure TRender.Set3D(FOV, zNear, zFar: Single);
var
  x, y : Single;
begin
  x := FOV * pi / 180 * 0.5;
  y := zNear * Sin(x) / Cos(x);
  x := y * (Display.Width / Display.Height);
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadIdentity;
  gl.Frustum(-x, x, -y, y, zNear, zFar);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity;
end;

procedure TRender.Quad(x, y, w, h, s, t, sw, th: Single);
var
  v : array [0..3] of TVec4f;
begin
  v[0] := Math.Vec4f(x, y, s, t + th);
  v[1] := Math.Vec4f(x + w, y, s + sw, v[0].w);
  v[2] := Math.Vec4f(v[1].x, y + h, v[1].z, t);
  v[3] := Math.Vec4f(x, v[2].y, s, t);
  gl.Beginp(GL_QUADS);
    gl.TexCoord2fv(@v[0].z);
    gl.Vertex2fv(@v[0].x);
    gl.TexCoord2fv(@v[1].z);
    gl.Vertex2fv(@v[1].x);
    gl.TexCoord2fv(@v[2].z);
    gl.Vertex2fv(@v[2].x);
    gl.TexCoord2fv(@v[3].z);
    gl.Vertex2fv(@v[3].x);
  gl.Endp;
end;
{$ENDREGION}

// Texture =====================================================================
{$REGION 'TTexture'}
procedure TTexture.Load(const FileName: string);
const
  DDPF_ALPHAPIXELS = $01;
  DDPF_FOURCC      = $04;
var
  Stream  : File;
  i, w, h : LongInt;
  Size : LongInt;
  Data : Pointer;
  f, c : TGLConst;
  DDS  : record
    Magic       : LongWord;
    Size        : LongWord;
    Flags       : LongWord;
    Height      : LongInt;
    Width       : LongInt;
    POLSize     : LongInt;
    Depth       : LongInt;
    MipMapCount : LongInt;
    SomeData1   : array [0..11] of LongWord;
    pfFlags     : LongWord;
    pfFourCC    : array [0..3] of AnsiChar;
    pfRGBbpp    : LongInt;
    SomeData2   : array [0..8] of LongWord;
  end;
begin
  if Render.ResManager.Add(FileName, ResIdx) then
  begin
    AssignFile(Stream, FileName);
    Reset(Stream, 1);
    BlockRead(Stream, DDS, SizeOf(DDS));
    Data := GetMemory(DDS.POLSize);

    with Render.ResManager.Items[ResIdx] do
    begin
      Width  := DDS.Width;
      Height := DDS.Height;
      gl.GenTextures(1, @ID);
      gl.BindTexture(GL_TEXTURE_2D, ID);
    end;
    gl.TexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
  // Select OpenGL texture format
    DDS.pfRGBbpp := DDS.POLSize * 8 div (DDS.Width * DDS.Height);
    f := GL_RGB8;
    c := GL_BGR;
    if DDS.pfFlags and DDPF_FOURCC > 0 then
      case DDS.pfFourCC[3] of
        '1' : f := GL_COMPRESSED_RGBA_S3TC_DXT1;
        '3' : f := GL_COMPRESSED_RGBA_S3TC_DXT3;
        '5' : f := GL_COMPRESSED_RGBA_S3TC_DXT5;
      end
    else
      if DDS.pfFlags and DDPF_ALPHAPIXELS > 0 then
      begin
        f := GL_RGBA8;
        c := GL_BGRA;
      end;

    for i := 0 to Math.Max(DDS.MipMapCount, 1) - 1 do
    begin
      w := Math.Max(DDS.Width shr i, 1);
      h := Math.Max(DDS.Height shr i, 1);
      Size := (w * h * DDS.pfRGBbpp) div 8;
      BlockRead(Stream, Data^, Size);
      if (DDS.pfFlags and DDPF_FOURCC) > 0 then
      begin
        if (w < 4) or (h < 4) then
        begin
          DDS.MipMapCount := i;
          Break;
        end;
        gl.CompressedTexImage2D(GL_TEXTURE_2D, i, f, w, h, 0, Size, Data)
      end else
        gl.TexImage2D(GL_TEXTURE_2D, i, f, w, h, 0, c, GL_UNSIGNED_BYTE, Data);
    end;
    FreeMemory(Data);
    CloseFile(Stream);
  // Filter
    gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if DDS.MipMapCount > 0 then
    begin
      gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, TGLConst(DDS.MipMapCount - 1));
    end else
      gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  end;

  with Render.ResManager.Items[ResIdx] do
  begin
    Self.Width  := Width;
    Self.Height := Height;
  end;
end;

procedure TTexture.Free;
begin
  if Render.ResManager.Delete(ResIdx) then
    gl.DeleteTextures(1, @Render.ResManager.Items[ResIdx].ID);
end;

procedure TTexture.Enable(Channel: LongInt);
begin
  if @gl.ActiveTexture <> nil then
    gl.ActiveTexture(TGLConst(Ord(GL_TEXTURE0) + Channel));
  gl.BindTexture(GL_TEXTURE_2D, Render.ResManager.Items[ResIdx].ID);
end;
{$ENDREGION}

// Sprite ======================================================================
{$REGION 'TSpriteAnimList'}
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
{$ENDREGION}

{$REGION 'TSprite'}
function TSprite.GetPlaying: Boolean;
begin
  Result := False;
  if (CurIndex < 0) or (not FPlaying) then
    Exit;
  with Anim.Items[CurIndex] do
    FPlaying := FLoop or ((Render.Time - StarLongWord) div (1000 div FPS) < Frames);
  Result := FPlaying;
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
    Result := Cfg.ReadInt(Cat, Name, Def);
  end;

begin
  CurIndex := -1;
  FPlaying := False;
  Pos      := Math.Vec2f(0, 0);
  Scale    := Math.Vec2f(1, 1);
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
  Texture.Load(Cfg.ReadStr('sprite', 'Texture', ''));
  Blend := btNormal;
  Cat := Cfg.ReadStr('sprite', 'Blend', 'normal');
  for b := Low(b) to High(b) do
    if BlendStr[b] = Cat then
    begin
      Blend := b;
      break;
    end;
end;

procedure TSprite.Free;
begin
  Texture.Free;
end;

procedure TSprite.Play(const AnimName: string; Loop: Boolean);
var
  NewIndex : LongInt;
begin
  NewIndex := Anim.IndexOf(AnimName);
  if (NewIndex <> CurIndex) or (not FPlaying) then
  begin
    FLoop := Loop;
    StarLongWord := Render.Time;
    CurIndex := NewIndex;
  end;
  FPlaying := True;
end;

procedure TSprite.Stop;
begin
  FPlaying := False;
end;

procedure TSprite.Draw;
var
  CurFrame : LongInt;
  fw, fh   : Single;
begin
  if CurIndex < 0 then
    Exit;
  Texture.Enable;
  with Anim.Items[CurIndex] do
  begin
    if Playing then
      CurFrame := (Render.Time - StarLongWord) div (1000 div FPS) mod Frames
    else
      CurFrame := 0;
    fw := Width/Texture.Width;
    fh := Height/Texture.Height;
    Render.Blend := Blend;
    Render.Quad(Pos.X - CenterX * Scale.x, Pos.Y - CenterY * Scale.y,
                Width * Scale.x, Height * Scale.y,
                X/Texture.Width + CurFrame mod Cols * fw, CurFrame div Cols * fh, fw, fh);
  end;
end;
{$ENDREGION}

// GL ==========================================================================
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
  {$IFDEF MACOS}
    'aglGetProcAddress',
    'aglSetInteger',
  {$ENDIF}
    'glGetString',
    'glPolygonMode',
    'glGenTextures',
    'glDeleteTextures',
    'glBindTexture',
    'glTexParameteri',
    'glTexImage2D',
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
    'glBlendFunc',
    'glStencilFunc',
    'glDepthFunc',
    'glStencilOp',
    'glViewport',
    'glBegin',
    'glEnd',
    'glVertex2fv',
    'glVertex3fv',
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
    'glFrustum'
  );
var
  i    : LongInt;
  Proc : ^TProcArray;
begin
  Lib := LoadLibraryA(opengl32);
  if Lib <> 0 then
  begin
    Proc := @Self;
    Proc^[0] := GetProcAddress(Lib, ProcName[0]); // gl.GetProc
    for i := 1 to High(ProcName) do
    begin
      Proc^[i] := GetProc(ProcName[i]);
      if Proc^[i] = nil then
        Proc^[i] := GetProcAddress(Lib, ProcName[i]);
    {$IFDEF DEBUG}
      if Proc^[i] = nil then
        Writeln('- ', ProcName[i]);
    {$ENDIF}
    end;
  end;
end;

procedure TGL.Free;
begin
  FreeLibrary(Lib);
end;
{$ENDREGION}

// CoreX =======================================================================
{$REGION 'CoreX'}
procedure Start(PInit, PFree, PRender: TCoreProc);
begin
  chdir(Utils.ExtractFileDir(ParamStr(0)));
  Display.Init;
  Input.Init;

  PInit;
  while not Display.FQuit do
  begin
    Input.Update;
    Display.Update;
    Render.FDeltaTime := (Render.Time - Render.OldTime) / 1000;
    Render.OldTime := Render.Time;
    PRender;
    Display.Swap;
  end;
  PFree;

  Input.Free;
  Display.Free;
end;

procedure Quit;
begin
  Display.FQuit := True;
end;
{$ENDREGION}

end.
