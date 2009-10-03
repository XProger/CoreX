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

{$IFDEF WIN32}
  {$DEFINE WINDOWS}
{$ENDIF}

{$IFDEF LINUX}
  {$MACRO ON}
  {$DEFINE stdcall := cdecl} // For TGL
{$ENDIF}

// Math ------------------------------------------------------------------------
{$REGION 'Math'}
type
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
    function Lerp(const v: TVec2f; t: Single): TVec2f;
    function Clamp(const Min, Max: TVec2f): TVec2f;
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
    function Lerp(const v: TVec3f; t: Single): TVec3f;
    function Clamp(const Min, Max: TVec3f): TVec3f;
    function Rotate(Angle: Single; const Axis: TVec3f): TVec3f;
    function Angle(const v: TVec3f): Single;
  end;

  TVec4f = record
    x, y, z, w : Single;
  end;

  TMat4f = {$IFDEF FPC} object {$ELSE} record {$ENDIF}
  private
    function  GetPos: TVec3f;
    procedure SetPos(const v: TVec3f);
  public
    e00, e10, e20, e30,
    e01, e11, e21, e31,
    e02, e12, e22, e32,
    e03, e13, e23, e33: Single;
  {$IFNDEF FPC}
    class operator Add(const a, b: TMat4f): TMat4f;
    class operator Multiply(const a, b: TMat4f): TMat4f;
    class operator Multiply(const m: TMat4f; const v: TVec3f): TVec3f;
    class operator Multiply(const m: TMat4f; x: Single): TMat4f;
  {$ENDIF}
    procedure Identity;
    function Det: Single;
    function Inverse: TMat4f;
    function Transpose: TMat4f;
    function FromAxisAngle(Angle: Single; const Axis: TVec3f): TMat4f;
    procedure Translate(const v: TVec3f);
    procedure Rotate(Angle: Single; const Axis: TVec3f);
    procedure Scale(const v: TVec3f);
    procedure Ortho(Left, Right, Bottom, Top, ZNear, ZFar: Single);
    procedure Frustum(Left, Right, Bottom, Top, ZNear, ZFar: Single);
    procedure Perspective(FOV, Aspect, ZNear, ZFar: Single);
    property Pos: TVec3f read GetPos write SetPos;
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
// TMat4f
  operator + (const a, b: TMat4f): TMat4f;
  operator * (const a, b: TMat4f): TMat4f;
  operator * (const m: TMat4f; const v: TVec3f): TVec3f;
  operator * (const m: TMat4f; x: Single): TMat4f;
{$ENDIF}

const
  ONE     : Single = 1.0;
  EPS     = 1.E-05;
  deg2rad = pi / 180;
  rad2deg = 180 / pi;

  function Vec2f(x, y: Single): TVec2f; inline;
  function Vec3f(x, y, z: Single): TVec3f; inline;
  function Vec4f(x, y, z, w: Single): TVec4f; inline;
  function Min(x, y: LongInt): LongInt; overload; inline;
  function Min(x, y: Single): Single; overload; inline;
  function Max(x, y: LongInt): LongInt; overload; inline;
  function Max(x, y: Single): Single; overload; inline;
  function Clamp(x, Min, Max: LongInt): LongInt; overload; inline;
  function Clamp(x, Min, Max: Single): Single; overload; inline;
  function Lerp(x, y, t: Single): Single; inline;
  function Sign(x: Single): LongInt;
  function Ceil(const x: Extended): LongInt;
  function Floor(const x: Extended): LongInt;
  function Tan(x: Single): Single; assembler;
  procedure SinCos(Theta: Single; out Sin, Cos: Single); assembler;
  function ArcTan2(y, x: Single): Single; assembler;
  function ArcCos(x: Single): Single; assembler;
  function ArcSin(x: Single): Single; assembler;
  function Pow(x, y: Single): Single;
{$ENDREGION}

// Utils -----------------------------------------------------------------------
{$REGION 'Utils'}
const
  CRLF = #13#10;

type
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
  TStream = object
    procedure Init(Memory: Pointer; MemSize: LongInt); overload;
    procedure Init(const FileName: string; RW: Boolean = False); overload;
    procedure Free;
  private
    SType  : (stFile, stMemory);
    FSize  : LongInt;
    FPos   : LongInt;
    FBPos  : LongInt;
    F      : File;
    Mem    : Pointer;
    procedure SetPos(Value: LongInt);
    procedure SetBlock(BPos, BSize: LongInt);
  public
    procedure CopyFrom(const Stream: TStream);
    function Read(out Buf; BufSize: LongInt): LongInt;
    function Write(const Buf; BufSize: LongInt): LongInt;
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
    constructor Create(const FileName: string); overload;
    constructor Create(const Text: string; BeginPos: LongInt); overload;
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
  TThreadProc = procedure (Param: LongInt); stdcall;

  TThread = object
    procedure Init(Proc: TThreadProc; Param: Pointer; Activate: Boolean = True);
    procedure Free;
  private
    FActive : Boolean;
    FHandle : LongWord;
    procedure SetActive(Value: Boolean);
    procedure SetCPUMask(Value: LongInt);
  public
    procedure Wait(ms: LongWord = 0); // WTF! ???
    property Active: Boolean read FActive write SetActive;
    property CPUMask: LongInt write SetCPUMask;
  end;

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
  function Rect(Left, Top, Right, Bottom: LongInt): TRect; inline;
  function RGBA(R, G, B, A: Byte): TRGBA; inline;
{$ENDREGION}

// FileSys ---------------------------------------------------------------------
{$REGION 'FileSys'}
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
    procedure Init;
  public
    procedure Clear;
    procedure Add(const PackName: string);
    procedure Del(const PackName: string);
    function Open(const FileName: string; RW: Boolean = False): TStream;
  end;
{$ENDREGION}

// Screen ----------------------------------------------------------------------
{$REGION 'Screen'}
type
  TAAType = (aa0x, aa1x, aa2x, aa4x, aa8x, aa16x);

  TScreen = object
  private
    FQuit   : Boolean;
    FWidth  : LongInt;
    FHeight : LongInt;
    FCustom : Boolean;
    FFullScreen   : Boolean;
    FAntiAliasing : TAAType;
    FVSync      : Boolean;
    FActive     : Boolean;
    FCaption    : string;
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
    Handle : LongWord;
    procedure Resize(W, H: LongInt);
    procedure Swap;
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
    property FullScreen: Boolean read FFullScreen write SetFullScreen;
    property AntiAliasing: TAAType read FAntiAliasing write FAntiAliasing;
    property VSync: Boolean read FVSync write SetVSync;
    property Active: Boolean read FActive;
    property Caption: string read FCaption write SetCaption;
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
    KM_L, KM_R, KM_M, KM_WHUP, KM_WHDN,
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
    FText       : string;
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
    Joy   : TJoy;
    procedure Update;
    property LastKey: TInputKey read FLastKey;
    property Down[InputKey: TInputKey]: Boolean read GetDown;
    property Hit[InputKey: TInputKey]: Boolean read GetHit;
    property Capture: Boolean read FCapture write SetCapture;
    property Text: string read FText;
  end;
{$ENDREGION}

// Sound -----------------------------------------------------------------------
{$REGION 'Sound'}
  TBufferData = record
    L, R : SmallInt;
  end;
  PBufferArray = ^TBufferArray;
  TBufferArray = array [0..1] of TBufferData;

  PSample = ^TSample;
  TSample = object
  private
    ResIdx  : LongInt;
    FVolume : LongInt;
    procedure SetVolume(Value: LongInt);
  public
    Frequency : LongInt;
    procedure Load(const FileName: string);
    procedure Free;
    procedure Play(Loop: Boolean = False);
    property Volume: LongInt read FVolume write SetVolume;
  end;

  TChannel = record
    Sample  : PSample;
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
  private
    Device    : TDevice;
    Channel   : array [0..63] of TChannel;
    ChCount   : LongInt;
    procedure Init;
    procedure Free;
    procedure Render(Data: PBufferArray);
    procedure FreeChannel(Index: LongInt);
    function AddChannel(const Ch: TChannel): Boolean;
  public
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
    GL_FRONT = $0404, GL_BACK, GL_FRONT_AND_BACK = $0408,
  // Tests
    GL_DEPTH_TEST = $0B71, GL_STENCIL_TEST = $0B90, GL_ALPHA_TEST = $0BC0, GL_SCISSOR_TEST = $0C11,
  // GetTarget
    GL_CULL_FACE = $0B44, GL_BLEND = $0BE2,
  // Data Types
    GL_BYTE = $1400, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT, GL_INT, GL_UNSIGNED_INT, GL_FLOAT,
  // Matrix Mode
    GL_MODELVIEW = $1700, GL_PROJECTION, GL_TEXTURE,
  // Pixel Format
    GL_RGB = $1907, GL_RGBA, GL_RGB8 = $8051, GL_RGBA8 = $8058, GL_BGR = $80E0, GL_BGRA, GL_DEPTH_COMPONENT = $1902,
  // PolygonMode
    GL_POINT = $1B00, GL_LINE, GL_FILL,
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
    GL_TEXTURE_WRAP_S = $2802, GL_TEXTURE_WRAP_T, GL_REPEAT = $2901, GL_CLAMP_TO_EDGE = $812F, GL_TEXTURE_BASE_LEVEL = $813C, GL_TEXTURE_MAX_LEVEL,
  // Textures
    GL_TEXTURE_2D = $0DE1, GL_TEXTURE0 = $84C0, GL_TEXTURE_MAX_ANISOTROPY = $84FE, GL_MAX_TEXTURE_MAX_ANISOTROPY, GL_GENERATE_MIPMAP = $8191,
  // Compressed Textures
    GL_COMPRESSED_RGB_S3TC_DXT1 = $83F0, GL_COMPRESSED_RGBA_S3TC_DXT1, GL_COMPRESSED_RGBA_S3TC_DXT3, GL_COMPRESSED_RGBA_S3TC_DXT5,
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
    TexImage2D     : procedure (target: TGLConst; level: LongInt; internalformat: TGLConst; width, height, border: LongInt; format, _type: TGLConst; data: Pointer); stdcall;
    TexSubImage2D  : procedure (target: TGLConst; level, x, y, width, height: LongInt; format, _type: TGLConst; data: Pointer); stdcall;
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
    AlphaFunc      : procedure (func: TGLConst; factor: Single); stdcall;
    BlendFunc      : procedure (sfactor, dfactor: TGLConst); stdcall;
    StencilFunc    : procedure (func: TGLConst; ref: LongInt; mask: LongWord); stdcall;
    DepthFunc      : procedure (func: TGLConst); stdcall;
    StencilOp      : procedure (fail, zfail, zpass: TGLConst); stdcall;
    Lightfv        : procedure (light, pname: TGLConst; params: Pointer); stdcall;
    Viewport       : procedure (x, y, width, height: LongInt); stdcall;
    Beginp         : procedure (mode: TGLConst); stdcall;
    Endp           : procedure;
    LineWidth      : procedure (width: Single); stdcall;
    Color4ub       : procedure (r, g, b, a: Byte); stdcall;
    Vertex2f       : procedure (x, y: Single); stdcall;
    Vertex2fv      : procedure (xy: Pointer); stdcall;
    Vertex3f       : procedure (x, y, z: Single); stdcall;
    Vertex3fv      : procedure (xyz: Pointer); stdcall;
    TexCoord2f     : procedure (s, t: Single); stdcall;
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
  end;
{$ENDREGION}

// Render ----------------------------------------------------------------------
{$REGION 'Render'}
  TBlendType = (btNone, btNormal, btAdd, btMult);

  TRenderSupport = (rsMT, rsVBO, rsFBO, rsGLSL, rsOQ);

  TRender = object
  private
    FVendor   : string;
    FRenderer : string;
    FVersion  : string;
    FCPUCount  : LongInt;
    FDeltaTime : Single;
    OldTime    : LongInt;
    FFPS       : LongInt;
    SBuffer    : array [TRenderSupport] of Boolean;
    procedure Init;
    procedure Free;
    function GetTime: LongInt;
    procedure SetBlend(Value: TBlendType);
    procedure SetDepthTest(Value: Boolean);
    procedure SetDepthWrite(Value: Boolean);
    procedure SetCullFace(Value: Boolean);
  public
    function Support(RenderSupport: TRenderSupport): Boolean;
    procedure Update;
    procedure Clear(ClearColor, ClearDepth: Boolean);
    procedure Color(R, G, B, A: Byte);
    procedure Set2D(Width, Height: LongInt);
    procedure Set3D(FOV, Aspect: Single; zNear: Single = 0.1; zFar: Single = 1000);
    procedure Quad(x, y, w, h, s, t, sw, th: Single);
    property Vendor: string read FVendor;
    property Renderer: string read FRenderer;
    property Version: string read FVersion;
    property CPUCount: LongInt read FCPUCount;
    property FPS: LongInt read FFPS;
    property Time: LongInt read GetTime;
    property DeltaTime: Single read FDeltaTime;
    property Blend: TBlendType write SetBlend;
    property DepthTest: Boolean write SetDepthTest;
    property DepthWrite: Boolean write SetDepthWrite;
    property CullFace: Boolean write SetCullFace;
  end;
{$ENDREGION}

// Physic ----------------------------------------------------------------------
{$REGION 'Physic'}

{$ENDREGION}

// Texture ---------------------------------------------------------------------
{$REGION 'Texture'}
  TTexture = object
  private
    ResIdx  : LongInt;
    FWidth  : LongInt;
    FHeight : LongInt;
  public
    procedure Init(DWidth, DHeight: LongInt; Data: Pointer; DType: TGLConst = GL_RGBA);
    procedure Load(const FileName: string);
    procedure Free;
    procedure SetData(X, Y, DWidth, DHeight: LongInt; Data: Pointer; DType: TGLConst = GL_RGBA);
    procedure Enable(Channel: LongInt = 0);
    property Width: LongInt read FWidth;
    property Height: LongInt read FHeight;
  end;
{$ENDREGION}

// Font ------------------------------------------------------------------------
{$REGION 'Font'}

{$ENDREGION}

// GUI -------------------------------------------------------------------------
{$REGION 'GUI'}

{$ENDREGION}

// Shader ----------------------------------------------------------------------
{$REGION 'Shader'}
  TShaderUniformType = (utInt, utFloat, utVec2, utVec3, utVec4, utMat3, utMat4);
  TShaderAttribType  = (atFloat, atVec2, atVec3, atVec4);

  TShaderUniform = object
  private
    FType : TShaderUniformType;
    FID   : LongInt;
    FName : string;
    procedure Init(ShaderID: LongWord; UniformType: TShaderUniformType; const UName: string);
  public
    procedure Value(const Data; Count: LongInt = 1);
    property Name: string read FName;
  end;

  TShaderAttrib = object
  private
    FType : TShaderAttribType;
    FID   : LongInt;
    FName : string;
    procedure Init(ShaderID: LongWord; AttribType: TShaderAttribType; const AName: string);
  public
    procedure Value(Stride: LongInt; const Data);
    property Name: string read FName;
  end;

  TShader = object
    procedure Init(const FileName: string; const Defines: string = '');
    procedure Free;
  private
    ResIdx : LongInt;
    FID    : LongWord;
    FUniform : array of TShaderUniform;
    FAttrib  : array of TShaderAttrib;
  public
    function Uniform(UniformType: TShaderUniformType; const UName: string): TShaderUniform;
    function Attrib(AttribType: TShaderAttribType; const AName: string): TShaderAttrib;
    procedure Enable;
    procedure Disable;
  end;
{$ENDREGION}

// Material --------------------------------------------------------------------
{$REGION 'Material'}

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
    procedure Grid(GCols, GRows: LongInt);
    procedure Free;
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
{$ENDREGION}

// Mesh ------------------------------------------------------------------------
{$REGION 'Mesh'}
  TDataType = (dtIndex, dtVertex);

  TMeshBuffer = object
  private
    ResIdx : LongInt;
    RType  : LongInt;
    DType  : TGLConst;
    ID     : LongWord;
    FData  : Pointer;
  public
    procedure Init(DataType: TDataType; Size: LongInt; Data: Pointer);
    procedure Free;
    procedure SetData(Offset, Size: LongInt; Data: Pointer);
    procedure Enable;
    procedure Disable;
    property DataPtr: Pointer read FData;
  end;

  TMesh = object
    Buffer : array [TDataType] of TMeshBuffer;
    procedure Draw;
  end;
{$ENDREGION}

// Model -----------------------------------------------------------------------
{$REGION 'Model'}

{$ENDREGION}

// Terrain ---------------------------------------------------------------------
{$REGION 'Terrain'}

{$ENDREGION}

// Scene -----------------------------------------------------------------------
{$REGION 'Scene'}

{$ENDREGION}

type
  TCoreProc = procedure;

var
  FileSys : TFileSys;
  gl      : TGL;
  Screen  : TScreen;
  Input   : TInput;
  Sound   : TSound;
  Render  : TRender;

  procedure Init;
  procedure Free;
  procedure Start(PInit, PFree, PRender: TCoreProc);
  procedure Quit;
  procedure Assert(const Error: string; Flag: Boolean = True);

implementation

// System API ==================================================================
{$REGION 'Windows System'}
{$IFDEF WINDOWS}
// Windows API -----------------------------------------------------------------
type
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

const
  kernel32            = 'kernel32.dll';
  user32              = 'user32.dll';
  gdi32               = 'gdi32.dll';
  opengl32            = 'opengl32.dll';
  winmm               = 'winmm.dll';
  WS_VISIBLE          = $10000000;
  WM_DESTROY          = $0002;
  WM_ACTIVATEAPP      = $001C;
  WM_SETICON          = $0080;
  WM_KEYDOWN          = $0100;
  WM_CHAR             = $0102;
  WM_SYSKEYDOWN       = $0104;
  WM_LBUTTONDOWN      = $0201;
  WM_RBUTTONDOWN      = $0204;
  WM_MBUTTONDOWN      = $0207;
  WM_MOUSEWHEEL       = $020A;
  SW_SHOW             = 5;
  SW_MINIMIZE         = 6;
  GWL_WNDPROC         = -4;
  GWL_STYLE           = -16;
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
  procedure InitializeCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure EnterCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure LeaveCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  procedure DeleteCriticalSection(var CS: TRTLCriticalSection); stdcall; external kernel32;
  function CreateThread(lpThreadAttributes: Pointer; dwStackSize: LongWord; lpStartAddress: TThreadProc; lpParameter: Pointer; dwCreationFlags: LongWord; lpThreadId: Pointer): LongWord; stdcall; external kernel32;
  function TerminateThread(hThread: LongWord; dwExitCode: LongWord): Boolean; stdcall; external kernel32;
  function SuspendThread(hThread: LongWord): LongWord; stdcall; external kernel32;
  function ResumeThread(hThread: LongWord): LongWord; stdcall; external kernel32;
  procedure Sleep(dwMilliseconds: LongWord); stdcall; external kernel32;
  function SetThreadAffinityMask(hThread: LongWord; dwThreadAffinityMask: LongWord): LongWord; stdcall; external kernel32;
  function GetProcessAffinityMask(hProcess: LongWord; out lpProcessAffinityMask, lpSystemAffinityMask: LongWord): Boolean; stdcall; external kernel32;
  function GetCurrentProcess: LongWord; stdcall; external kernel32;
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

  KeyCodes : array [KK_PLUS..KK_DEL] of Word =
     ($BB, $BD, $C0,
      $30, $31, $32, $33, $34, $35, $36, $37, $38, $39,
      $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A,
      $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B,
      $1B, $03, $08, $09, $10, $11, $12, $20, $21, $22, $23, $24, $25, $26, $27, $28, $2D, $2E);

  SND_FREQ     = 44100;
  SND_BPP      = 16;
  SND_BUF_SIZE = 40 * SND_FREQ * (SND_BPP div 8) * 2 div 1000; // 40 ms latency

var
  DC, RC   : LongWord;
  TimeFreq : Int64;
  JoyCaps  : TJoyCaps;
  JoyInfo  : TJoyInfo;
  SoundDF  : TWaveFormatEx;
  SoundDB  : array [0..1] of TWaveHdr;
  SoundCS  : TRTLCriticalSection;
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
    $000005, {1,} // GLX_DOUBLEBUFFER
    $000004,  1, // GLX_RGBA
    $000002, 32, // GLX_BUFFER_SIZE
    $00000C, 24, // GLX_DEPTH_SIZE
    $00000D,  8, // GLX_STENCIL_SIZE
    0);

  KeyCodes : array [KK_PLUS..KK_DEL] of Word =
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

  WM_PROTOCOLS : LongWord;
  WM_DESTROY   : LongWord;
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
  Result := Self - (n * (2 * Dot(n)));
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
begin
  Result := (v - Self).Length;
end;

function TVec2f.Lerp(const v: TVec2f; t: Single): TVec2f;
begin
  Result := Self + (v - Self) * t;
end;

function TVec2f.Clamp(const Min, Max: TVec2f): TVec2f;
begin
  Result := Vec2f(CoreX.Clamp(x, Min.x, Max.x), CoreX.Clamp(y, Min.y, Max.y));
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
  Result := ArcCos(Dot(v) / sqrt(LengthQ * v.LengthQ))
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
  Result := Self - (n * (2 * Dot(n)));
end;

function TVec3f.Refract(const n: TVec3f; Factor: Single): TVec3f;
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
begin
  Result := (v - Self).Length;
end;

function TVec3f.Lerp(const v: TVec3f; t: Single): TVec3f;
begin
  Result := Self + (v - Self) * t;
end;

function TVec3f.Clamp(const Min, Max: TVec3f): TVec3f;
begin
  Result := Vec3f(CoreX.Clamp(x, Min.x, Max.x), CoreX.Clamp(y, Min.y, Max.y), CoreX.Clamp(z, Min.z, Max.z));
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
{$ENDREGION}

{$REGION 'TMat4f'}
{ TMat4f }
function TMat4f.GetPos: TVec3f;
begin
  Result := Vec3f(e03, e13, e23);
end;

procedure TMat4f.SetPos(const v: TVec3f);
begin
  e03 := v.x;
  e13 := v.y;
  e23 := v.z;
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

function TMat4f.FromAxisAngle(Angle: Single; const Axis: TVec3f): TMat4f;
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
  m := m.FromAxisAngle(Angle, Axis);
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
  Self := m * Self;
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
  FOV := Clamp(FOV, EPS, 180 - EPS);
  y := ZNear * Tan(FOV * deg2rad * 0.5);
  x := y * Aspect;
  Frustum(-x, x, -y, y, ZNear, ZFar);
end;
{$ENDREGION}

{$REGION 'Math'}
function Vec2f(x, y: Single): TVec2f;
begin
  Result.x := x;
  Result.y := y;
end;

function Vec3f(x, y, z: Single): TVec3f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function Vec4f(x, y, z, w: Single): TVec4f;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;
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

function Ceil(const x: Extended): LongInt;
begin
  Result := LongInt(Trunc(x));
  if Frac(x) > 0 then
    Inc(Result);
end;

function Floor(const x: Extended): LongInt;
begin
  Result := LongInt(Trunc(x));
  if Frac(x) < 0 then
    Dec(Result);
end;

function Tan(x: Single): Single;
asm
  fld x
  fptan
  fstp st(0)
  fwait
end;

procedure SinCos(Theta: Single; out Sin, Cos: Single);
asm
  fld Theta
  fsincos
  fstp [edx]
  fstp [eax]
  fwait
end;

function ArcTan2(y, x: Single): Single;
asm
  fld y
  fld x
  fpatan
  fwait
end;

function ArcCos(x: Single): Single;
asm
  fld x
  fmul st, st
  fsubr ONE
  fsqrt
  fld x
  fpatan
end;

function ArcSin(x: Single): Single;
asm
  fld x
  fld st
  fmul st, st
  fsubr ONE
  fsqrt
  fpatan
end;

function Pow(x, y: Single): Single;
begin
  Result := exp(ln(x) * y);
end;
{$ENDREGION}

// Utils =======================================================================
{$REGION 'TResManager'}
type
  TResType = (rtTexture, rtShader, rtSound);
  TResActive = (raTexture, raShader = 16, raVbuffer, raIBuffer);

  TResData = record
    Ref  : LongInt;
    Name : string;
    case TResType of
      rtTexture, rtShader : (
        ID     : LongWord;
        Width  : LongInt;
        Height : LongInt;
      );
      rtSound : (
        Length : LongInt;
        Data   : PDataArray;
      );
  end;

  TResManager = object
    Items : array of TResData;
    Count : LongInt;
    Active : array [TResActive] of LongInt;
    procedure Init;
    function Add(const Name: string; out Idx: LongInt): Boolean;
    function Delete(Idx: LongInt): Boolean;
  end;

var
  ResManager : TResManager;

procedure TResManager.Init;
var
  i : TResActive;
begin
  Items := nil;
  Count := 0;
  for i := Low(i) to High(i) do
    Active[i] := -1;
end;

function TResManager.Add(const Name: string; out Idx: LongInt): Boolean;
var
  i : LongInt;
begin
  Idx := -1;
  Result := False;
// Resource in array?
  if Name <> '' then
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
var
 i : TResActive;
begin
  Dec(Items[Idx].Ref);
  Result := Items[Idx].Ref <= 0;
  if Result then
  begin
    Items[Idx].Name := '';
    for i := Low(i) to High(i) do
      if Active[i] = Idx then
        Active[i] := -1;
  end;
end;
{$ENDREGION}

{$REGION 'TStream'}
procedure TStream.Init(Memory: Pointer; MemSize: LongInt);
begin
  SType := stMemory;
  Mem   := Memory;
  FSize := MemSize;
  FPos  := 0;
  FBPos := 0;
end;

procedure TStream.Init(const FileName: string; RW: Boolean);
begin
  SType := stFile;
  FBPos := 0;
  Self  := FileSys.Open(FileName, RW);
end;

procedure TStream.Free;
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

procedure TStream.SetBlock(BPos, BSize: LongInt);
begin
  FSize := BSize;
  FBPos := BPos;
  Pos := 0;
end;

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
  Stream.Init(FileName);
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
  Stream.Init(FileName, True);
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
constructor TXML.Create(const FileName: string);
const
  UTF16_HEADER : Word = $FEFF;
var
  Stream   : TStream;
  AnsiText : AnsiString;
  WideText : WideString;
  Text     : string;
  Code     : Word;
  Size     : LongInt;
begin
  Stream.Init(FileName);
  Size := Stream.Size;
  Stream.Read(Code, SizeOf(Code));
  if Code = UTF16_HEADER then
  begin
    SetLength(WideText, Size div 2);
    Stream.Read(WideText[1], Size);
    Text := string(WideText);
  end else
  begin
    Stream.Pos := 0;
    SetLength(AnsiText, Size);
    Stream.Read(AnsiText[1], Size);
    Text := string(AnsiText);
  end;
  Create(Text, 1);
  Stream.Free;
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
  FHandle := CreateThread(nil, 0, Proc, Param, Flag, nil);
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

{$REGION 'Utils'}
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
    while AnsiChar(Str[i]) in Chars do
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
{$ENDREGION}

// FileSys =====================================================================
{$REGION 'TFilePack'}
procedure TFilePack.Init(const PackName: string);
var
  Stream   : TStream;
  AName    : AnsiString;
  Len      : Byte;
  i, Count : LongInt;
begin
  FName := PackName;
  Stream := FileSys.Open(PackName);
  Stream.Read(Count, SizeOf(Count));
  SetLength(FTable, Count);
  for i := 0 to Length(FTable) - 1 do
    with FTable[i] do
    begin
      Stream.Read(Pos, SizeOf(Pos));
      Stream.Read(Size, SizeOf(Size));
      Stream.Read(Len, SizeOf(Len));
      SetLength(AName, Len);
      Stream.Read(AName[1], Len);
      FileName := string(AName);
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
      Stream := FileSys.Open(FName);
      Stream.SetBlock(FTable[i].Pos, FTable[i].Size);
      Result := True;
      Exit;
    end;
  Result := False;
end;
{$ENDREGION}

{$REGION 'TFileSys'}
procedure TFileSys.Init;
begin
  chdir(ExtractFileDir(ParamStr(0)));
end;

procedure TFileSys.Clear;
begin
  FPack := nil;
end;

procedure TFileSys.Add(const PackName: string);
begin
  SetLength(FPack, Length(FPack) + 1);
  FPack[Length(FPack) - 1].Init(PackName);
end;

procedure TFileSys.Del(const PackName: string);
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

function TFileSys.Open(const FileName: string; RW: Boolean): TStream;
var
  i : LongInt;
begin
  if not RW then
    for i := 0 to Length(FPack) - 1 do
      if FPack[i].Open(FileName, Result) then
        Exit;

  FileMode := 2;
  AssignFile(Result.F, FileName);
{$I-}
  if RW then
  begin
    FileMode := 1;
    Rewrite(Result.F, 1)
  end else
  begin
    FileMode := 0;
    Reset(Result.F, 1);
  end;
{$I+}
  if IOResult = 0 then
  begin
    Result.FSize  := FileSize(Result.F);
    Result.FPos   := 0;
  end else
    Assert('Can''t open "' + FileName + '"');
end;
{$ENDREGION}

// Screen ======================================================================
{$REGION 'TScreen'}
{$IFDEF WINDOWS}
function WndProc(Hwnd, Msg: LongWord; WParam, LParam: LongInt): LongInt; stdcall;
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
        FActive := Word(wParam) = 1;
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
  // Keyboard
    WM_KEYDOWN, WM_KEYDOWN + 1, WM_SYSKEYDOWN, WM_SYSKEYDOWN + 1 :
      begin
        Input.SetState(Input.Convert(WParam), (Msg = WM_KEYDOWN) or (Msg = WM_SYSKEYDOWN));
        if (Msg = WM_SYSKEYDOWN) and (WParam = 13) then // Alt + Enter
          Screen.FullScreen := not Screen.FullScreen;
      end;
    WM_CHAR :
      if (WParam > 31) then
        Input.FText := Input.FText + Char(WParam);
  // Mouse
    WM_LBUTTONDOWN, WM_LBUTTONDOWN + 1 : Input.SetState(KM_L, Msg = WM_LBUTTONDOWN);
    WM_RBUTTONDOWN, WM_RBUTTONDOWN + 1 : Input.SetState(KM_R, Msg = WM_RBUTTONDOWN);
    WM_MBUTTONDOWN, WM_MBUTTONDOWN + 1 : Input.SetState(KM_M, Msg = WM_MBUTTONDOWN);
    WM_MOUSEWHEEL :
      begin
        Inc(Input.Mouse.Delta.Wheel, SmallInt(wParam  shr 16) div 120);
        Input.SetState(KM_WHUP, SmallInt(wParam shr 16) > 0);
        Input.SetState(KM_WHDN, SmallInt(wParam shr 16) < 0);
      end;
    else
      Result := DefWindowProcA(Hwnd, Msg, WParam, LParam);
  end;
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
          1 : Key := KM_L;
          2 : Key := KM_R;
          3 : Key := KM_M;
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
    Handle := CreateWindowExA(0, 'EDIT', nil, 0, 0, 0, 0, 0, 0, 0, 0, nil);
    DC := GetDC(Handle);
    SetPixelFormat(DC, ChoosePixelFormat(DC, @PFD), @PFD);
    RC := wglCreateContext(DC);
    wglMakeCurrent(DC, RC);
    ChoisePF := TwglChoosePixelFormatARB(wglGetProcAddress('wglChoosePixelFormatARB'));
    if @ChoisePF <> nil then
      ChoisePF(DC, @PFDAttrib, @AttribF, 1, @PFIdx, @PFCount);
    wglMakeCurrent(0, 0);
    wglDeleteContext(RC);
    ReleaseDC(Handle, DC);
    DestroyWindow(Handle);
  end;
  FCustom := Handle <> 0;
// Window
  if not FCustom then
  begin
    Handle := CreateWindowExA(0, 'STATIC', PAnsiChar(AnsiString(FCaption)), 0,
                              0, 0, 0, 0, 0, 0, HInstance, nil);
    SendMessageA(Handle, WM_SETICON, 1, LoadIconA(HInstance, 'MAINICON'));
    SetWindowLongA(Handle, GWL_WNDPROC, LongInt(@WndProc));
  end;

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

procedure TScreen.Free;
{$IFDEF WINDOWS}
begin
  Render.Free;
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  ReleaseDC(Handle, DC);
  if not FCustom then
    DestroyWindow(Handle);
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

procedure TScreen.Update;
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

procedure TScreen.Restore;
{$IFDEF WINDOWS}
var
  Style : LongWord;
  Rect  : TRect;
begin
  if FCustom then
    Exit;
// Change main window style
  if FFullScreen then
    Style := 0
  else
    Style := $CA0000; // WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX
  SetWindowLongA(Handle, GWL_STYLE, Style or WS_VISIBLE);

  Rect.Left   := 0;
  Rect.Top    := 0;
  Rect.Right  := Width;
  Rect.Bottom := Height;
  AdjustWindowRect(Rect, Style, False);
  with Rect do
    SetWindowPos(Handle, LongWord(-2 + Ord(FFullScreen)), 0, 0, Right - Left, Bottom - Top, $222);
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
  gl.Viewport(0, 0, Width, Height);
  VSync := FVSync;
  Swap;
  Swap;
end;
{$ENDIF}

procedure TScreen.SetFullScreen(Value: Boolean);
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

procedure TScreen.SetVSync(Value: Boolean);
begin
  FVSync := Value;
  if @gl.SwapInterval <> nil then
    gl.SwapInterval(Ord(FVSync));
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
  Inc(FFPSIdx);
  if Render.Time - FFPSTime >= 1000 then
  begin
    Render.FFPS := FFPSIdx;
    FFPSIdx  := 0;
    FFPSTime := Render.Time;
    Caption := 'CoreX [FPS: ' + Conv(Render.FPS) + ']';
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
  Result := KK_NONE;
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
  if (not Value) and (InputKey <> KK_NONE) then
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
    if Max - Min <> 0 then
      Result := Round((Value + Min) / (Max - Min) * 200 - 100)
    else
      Result := 0;
  end;
{$ENDIF}
{$IFDEF LINUX}
  WRoot, WChild, Mask : LongWord;
  X, Y, rX, rY        : longInt;
{$ENDIF}
begin
  FillChar(FHit, SizeOf(FHit), False);
  FText    := '';
  FLastKey := KK_NONE;
  Mouse.Delta.Wheel := 0;
  SetState(KM_WHUP, False);
  SetState(KM_WHDN, False);
{$IFDEF WINDOWS}
// Mouse
  GetWindowRect(Screen.Handle, Rect);
  GetCursorPos(Pos);
  if not FCapture then
  begin
  // Calc mouse cursor pos (Client Space)
    ScreenToClient(Screen.Handle, Pos);
    Mouse.Delta.X := Pos.X - Mouse.Pos.X;
    Mouse.Delta.Y := Pos.Y - Mouse.Pos.Y;
    Mouse.Pos.X := Pos.X;
    Mouse.Pos.Y := Pos.Y;
  end else
    if Screen.Active then // Main window active?
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
          JKey  := TInputKey(Ord(KJ_1) + i);
          JDown := Input.Down[JKey];
          if (wButtons and (1 shl i) <> 0) xor JDown then
            Input.SetState(JKey, not JDown);
        end;
      end;
  end;
{$ENDIF}
{$IFDEF LINUX}
  with Screen do
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
{$ENDREGION}

// Sound =======================================================================
{$REGION 'TSample'}
{ TSample }
procedure TSample.Load(const FileName: string);
var
  Stream : TStream;
  Header : record
    Some1 : array [0..4] of LongWord;
    Fmt   : TWaveFormatEx;
    Some2 : Word;
    DLen  : LongWord;
  end;
begin
  if ResManager.Add(FileName, ResIdx) then
  begin
    Stream.Init(FileName);
    Stream.Read(Header, SizeOf(Header));
    with Header, Fmt do
      if (wBitsPerSample = 16) and (nChannels = 1) and (nSamplesPerSec = 44100) then
        with ResManager.Items[ResIdx] do
        begin
          Length := Header.DLen div nBlockAlign;
          Data   := GetMemory(DLen);
          Stream.Read(Data^, DLen);
        end;
    Stream.Free;
  end;
  Frequency := 44100;
  Volume    := 100;
end;

procedure TSample.Free;
var
  i : LongInt;
begin
  if ResIdx > -1 then
    if ResManager.Delete(ResIdx) then
    begin
      i := 0;
      while i < Sound.ChCount do
        if Sound.Channel[i].Sample^.ResIdx = ResIdx then
          Sound.FreeChannel(i)
        else
          Inc(i);
      FreeMemory(ResManager.Items[ResIdx].Data);
      ResIdx := -1;
    end;
end;

procedure TSample.Play(Loop: Boolean);
var
  Channel : TChannel;
begin
  if ResIdx > -1 then
  begin
    Channel.Sample  := @Self;
    Channel.Offset  := 0;
    Channel.Loop    := Loop;
    Channel.Playing := True;
    Sound.AddChannel(Channel);
  end;
end;

procedure TSample.SetVolume(Value: LongInt);
begin
  FVolume := Min(100, Max(0, Value));
end;
{$ENDREGION}

{$REGION 'TDevice'}
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
{$ENDREGION}

{$REGION 'TSound'}
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
      with Channel[j], ResManager.Items[Sample^.ResIdx] do
      begin
        for i := 0 to SAMPLE_COUNT - 1 do
        begin
          sidx := Offset + Trunc(i * Sample^.Frequency / 44100);
          if sidx >= Length then
            if Loop then
            begin
              Offset := Offset - sidx;
              sidx := 0;
            end else
            begin
              Playing := False;
              break;
            end;
          Amp := Sample^.Volume * Data^[sidx] div 100;
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


{$ENDREGION}

// Render ======================================================================
{$REGION 'TRender'}
procedure TRender.Init;
var
  pm, sm : LongWord;
begin
  gl.Init;
{$IFDEF WINDOWS}
  QueryPerformanceFrequency(TimeFreq);
{$ENDIF}
  Screen.Restore;
  Blend := btNormal;

  gl.Enable(GL_TEXTURE_2D);
  gl.Enable(GL_ALPHA_TEST);
  gl.AlphaFunc(GL_GREATER, 0.0);
  gl.Disable(GL_DEPTH_TEST);
  gl.ColorMask(True, True, True, False);
  FVendor   := string(gl.GetString(GL_VENDOR));
  FRenderer := string(gl.GetString(GL_RENDERER));
  FVersion  := string(gl.GetString(GL_VERSION));

  Assert('Update your video card driver!', FRenderer = 'GDI Generic');


  SBuffer[rsMT]   := @gl.ActiveTexture <> nil;
  SBuffer[rsVBO]  := @gl.BindBuffer <> nil;
//  SBuffer[rsFrameTex]  := @gl. <> nil;
  SBuffer[rsGLSL] := @gl.CreateProgram <> nil;

// Get number of processors
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

function TRender.GetTime: LongInt;
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
  Result := tv.tv_sec * 1000 + tv.tv_usec div 1000;
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

procedure TRender.SetCullFace(Value: Boolean);
begin
  if Value then
    gl.Enable(GL_CULL_FACE)
  else
    gl.Disable(GL_CULL_FACE);
end;

function TRender.Support(RenderSupport: TRenderSupport): Boolean;
begin
  Result := SBuffer[RenderSupport];
end;

procedure TRender.Update;
begin
  FDeltaTime := (Time - OldTime) / 1000;
  OldTime := Time;
end;

procedure TRender.Clear(ClearColor, ClearDepth: Boolean);
var
  Mask : LongWord;
begin
  Mask := 0;
  if ClearColor then Mask := Mask or Ord(GL_COLOR_BUFFER_BIT);
  if ClearDepth then Mask := Mask or Ord(GL_DEPTH_BUFFER_BIT);
  gl.Clear(TGLConst(Mask));
end;

procedure TRender.Color(R: Byte; G: Byte; B: Byte; A: Byte);
begin
  gl.Color4ub(R, G, B, A);
end;

procedure TRender.Set2D(Width, Height: LongInt);
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadIdentity;
  gl.Ortho(-Width/2, Width/2, -Height/2, Height/2, -1, 1);
//  gl.Ortho(0, Width, Height, 0, -1, 1);
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
  v[0] := Vec4f(x, y, s, t + th);
  v[1] := Vec4f(x + w, y, s + sw, t + th);
  v[2] := Vec4f(x + w, y + h, s + sw, t);
  v[3] := Vec4f(x, y + h, s, t);

  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.TexCoord2fv(@v[0].z);
    gl.Vertex2fv(@v[0].x);
    gl.TexCoord2fv(@v[1].z);
    gl.Vertex2fv(@v[1].x);
    gl.TexCoord2fv(@v[3].z);
    gl.Vertex2fv(@v[3].x);
    gl.TexCoord2fv(@v[2].z);
    gl.Vertex2fv(@v[2].x);
  gl.Endp;
end;
{$ENDREGION}

// Texture =====================================================================
{$REGION 'TTexture'}
procedure TTexture.Init(DWidth, DHeight: LongInt; Data: Pointer; DType: TGLConst);
begin
  if ResManager.Add('', ResIdx) then
  begin
    with ResManager.Items[ResIdx] do
    begin
      Width   := DWidth;
      Height  := DHeight;
      FWidth  := DWidth;
      FHeight := DHeight;
      gl.GenTextures(1, @ID);
      gl.BindTexture(GL_TEXTURE_2D, ID);
    end;
    gl.TexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, DType, GL_UNSIGNED_BYTE, Data);
    gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  end;
end;

procedure TTexture.Load(const FileName: string);
const
  DDPF_ALPHAPIXELS = $01;
  DDPF_FOURCC      = $04;
var
  Stream  : TStream;
  i, w, h : LongInt;
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
  if ResManager.Add(FileName, ResIdx) then
  begin
    Stream.Init(FileName);

    Stream.Read(DDS, SizeOf(DDS));
    Data := GetMemory(DDS.POLSize);
    with ResManager.Items[ResIdx] do
    begin
      Width  := DDS.Width;
      Height := DDS.Height;
      gl.GenTextures(1, @ID);
      gl.BindTexture(GL_TEXTURE_2D, ID);
    end;
  // Select OpenGL texture format
    f := GL_RGB8;
    c := GL_BGR;
    with DDS do
    begin
      if pfFlags and DDPF_FOURCC = DDPF_FOURCC then
        case pfFourCC[3] of
          '1' : f := GL_COMPRESSED_RGBA_S3TC_DXT1;
          '3' : f := GL_COMPRESSED_RGBA_S3TC_DXT3;
          '5' : f := GL_COMPRESSED_RGBA_S3TC_DXT5;
        end
      else
        if pfFlags and DDPF_ALPHAPIXELS = DDPF_ALPHAPIXELS then
        begin
          f := GL_RGBA8;
          c := GL_BGRA;
        end;

      if MipMapCount = 0 then
        MipMapCount := 1
      else
        for i := 0 to MipMapCount - 1 do
          if (Width shr i < 4) or (Height shr i < 4) then
          begin
            MipMapCount := i;
            break;
          end;

      case f of
        GL_RGB8  : pfRGBbpp := 24;
        GL_RGBA8 : pfRGBbpp := 32;
        GL_COMPRESSED_RGBA_S3TC_DXT1 : pfRGBbpp := 4;
        GL_COMPRESSED_RGBA_S3TC_DXT3,
        GL_COMPRESSED_RGBA_S3TC_DXT5 : pfRGBbpp := 8;
      end;

      for i := 0 to MipMapCount - 1 do
      begin
        w := Width shr i;
        h := Height shr i;
        Size := (w * h * pfRGBbpp) div 8;
        Stream.Read(Data^, Size);
        if pfFlags and DDPF_FOURCC = DDPF_FOURCC then
          gl.CompressedTexImage2D(GL_TEXTURE_2D, i, f, w, h, 0, Size, Data)
        else
          gl.TexImage2D(GL_TEXTURE_2D, i, f, w, h, 0, c, GL_UNSIGNED_BYTE, Data);
      end;
      FreeMemory(Data);
    // Filter
      gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      if MipMapCount > 1 then
      begin
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, TGLConst(MipMapCount - 1));
      end else
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    end;
  end;
  Stream.Free;

  with ResManager.Items[ResIdx] do
  begin
    Self.FWidth  := Width;
    Self.FHeight := Height;
  end;
end;

procedure TTexture.Free;
begin
  if ResManager.Delete(ResIdx) then
    gl.DeleteTextures(1, @ResManager.Items[ResIdx].ID);
end;

procedure TTexture.SetData(X, Y, DWidth, DHeight: LongInt; Data: Pointer; DType: TGLConst);
begin
  Enable;
  gl.TexSubImage2D(GL_TEXTURE_2D, 0, X, Y, DWidth, DHeight, DType, GL_UNSIGNED_BYTE, Data);
end;

procedure TTexture.Enable(Channel: LongInt);
begin
  if not (Channel in [0..15]) then
    Assert('Incorrect texture channel number (' + Conv(Channel) + ') ' + ResManager.Items[ResIdx].Name);
  if ResManager.Active[TResActive(Channel)] <> ResIdx then
  begin
    if Render.Support(rsMT) then
      gl.ActiveTexture(TGLConst(Ord(GL_TEXTURE0) + Channel));
    gl.BindTexture(GL_TEXTURE_2D, ResManager.Items[ResIdx].ID);
    ResManager.Active[TResActive(Channel)] := ResIdx;
  end;
end;
{$ENDREGION}

// Shader ======================================================================
{$REGION 'TShaderUniform'}
procedure TShaderUniform.Init(ShaderID: LongWord; UniformType: TShaderUniformType; const UName: string);
begin
  FID   := gl.GetUniformLocation(ShaderID, PAnsiChar(AnsiString(UName)));
  FName := UName;
  FType := UniformType;
end;

procedure TShaderUniform.Value(const Data; Count: LongInt);
begin
  case FType of
    utInt   : gl.Uniform1iv(FID, Count, @Data);
    utFloat : gl.Uniform1fv(FID, Count, @Data);
    utVec2  : gl.Uniform2fv(FID, Count, @Data);
    utVec3  : gl.Uniform3fv(FID, Count, @Data);
    utVec4  : gl.Uniform4fv(FID, Count, @Data);
    utMat3  : gl.UniformMatrix3fv(FID, Count, False, @Data);
    utMat4  : gl.UniformMatrix4fv(FID, Count, False, @Data);
  end;
end;
{$ENDREGION}

{$REGION 'TShaderAttrib'}
procedure TShaderAttrib.Init(ShaderID: LongWord; AttribType: TShaderAttribType; const AName: string);
begin
  FID   := gl.GetAttribLocation(ShaderID, PAnsiChar(AnsiString(AName)));
  FName := AName;
  FType := AttribType;
end;

procedure TShaderAttrib.Value(Stride: LongInt; const Data);
begin
  gl.VertexAttribPointer(FID, Byte(FType), GL_FLOAT, False, Stride, @Data);
end;
{$ENDREGION}

{$REGION 'TShader'}
procedure TShader.Init(const FileName, Defines: string);

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

var
  Status : LongInt;
  Stream : TStream;
  Source  : AnsiString;
  CSource : AnsiString;
begin
  if not Render.Support(rsGLSL) then
    Assert('GLSL shaders are not supported');

  if ResManager.Add(FileName + '*' + Defines, ResIdx) then
  begin
    FID := gl.CreateProgram();
  // Reading
    Stream.Init(FileName);
    SetLength(Source, Stream.Size);
    Stream.Read(Source[1], Stream.Size);
    Stream.Free;
  // Compiling
    CSource := AnsiString(Defines + CRLF + '#define VERTEX' + CRLF + string(Source));
    Attach(GL_VERTEX_SHADER, CSource);
    CSource := AnsiString(Defines + CRLF + '#define FRAGMENT' + CRLF + string(Source));
    Attach(GL_FRAGMENT_SHADER, CSource);
  // Linking
    gl.LinkProgram(FID);
    gl.GetProgramiv(FID, GL_LINK_STATUS, @Status);
    if Status <> 1 then
      InfoLog(FID, True);
    ResManager.Items[ResIdx].ID := FID;
  end else // already loaded
    FID := ResManager.Items[ResIdx].ID;
end;

procedure TShader.Free;
begin
  gl.DeleteProgram(FID);
end;

function TShader.Uniform(UniformType: TShaderUniformType; const UName: string): TShaderUniform;
var
  i : LongInt;
begin
  for i := 0 to Length(FUniform) - 1 do
    if FUniform[i].Name = UName then
    begin
      Result := FUniform[i];
      Exit;
    end;
  Result.Init(FID, UniformType, UName);
  SetLength(FUniform, Length(FUniform) + 1);
  FUniform[Length(FUniform) - 1] := Result;
end;

function TShader.Attrib(AttribType: TShaderAttribType; const AName: string): TShaderAttrib;
var
  i : LongInt;
begin
  for i := 0 to Length(FAttrib) - 1 do
    if FAttrib[i].Name = AName then
    begin
      Result := FAttrib[i];
      Exit;
    end;
  Result.Init(FID, AttribType, AName);
  SetLength(FAttrib, Length(FAttrib) + 1);
  FAttrib[Length(FAttrib) - 1] := Result;
end;

procedure TShader.Enable;
begin
  gl.UseProgram(FID);
end;

procedure TShader.Disable;
begin
  gl.UseProgram(0);
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
  Texture.Load(Cfg.Read('sprite', 'Texture', ''));
  Blend := btNormal;
  Cat := Cfg.Read('sprite', 'Blend', 'normal');
  for b := Low(b) to High(b) do
    if BlendStr[b] = Cat then
    begin
      Blend := b;
      break;
    end;
  Play(Cfg.Read('sprite', 'Anim', 'default'), True);
  Grid(2, 2);
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

procedure TSprite.Free;
begin
  Texture.Free;
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
  Texture.Enable;
  with Anim.Items[CurIndex] do
  begin
    if Playing then
      CurFrame := (Render.Time - StartTime) div (1000 div FPS) mod Frames
    else
      CurFrame := 0;
    Render.Blend := Blend;

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
        gl.TexCoord2fv(@t[x, y]);         gl.Vertex2fv(@v[x, y]);
        gl.TexCoord2fv(@t[x + 1, y]);     gl.Vertex2fv(@v[x + 1, y]);
        gl.TexCoord2fv(@t[x + 1, y + 1]); gl.Vertex2fv(@v[x + 1, y + 1]);
        gl.TexCoord2fv(@t[x, y + 1]);     gl.Vertex2fv(@v[x, y + 1]);
      end;
  gl.Endp;

  gl.PopMatrix;
end;
{$ENDREGION}

// Mesh ========================================================================
{$REGION 'TMeshBuffer'}
procedure TMeshBuffer.Init(DataType: TDataType; Size: LongInt; Data: Pointer);
begin
  if DataType = dtIndex then
  begin
    DType := GL_ELEMENT_ARRAY_BUFFER;
    RType := Ord(raIBuffer);
  end else
  begin
    DType := GL_ARRAY_BUFFER;
    RType := Ord(raVBuffer);
  end;

  if Render.Support(rsVBO) then
  begin
    gl.GenBuffers(1, @ID);
    Enable;
    gl.BufferData(DType, Size, Data, GL_STATIC_DRAW);
    Disable;
    FData := nil;
  end else
  begin
    FData := GetMemory(Size);
    if Data <> nil then
      Move(Data^, FData^, Size);
  end;
  ResManager.Add(Conv(LongWord(Pointer(@Self))), ResIdx);
end;

procedure TMeshBuffer.Free;
begin
  if FData = nil then
    FreeMemory(FData)
  else
    gl.DeleteBuffers(1, @ID);
end;

procedure TMeshBuffer.SetData(Offset, Size: LongInt; Data: Pointer);
var
  p : PByteArray;
begin
  if FData = nil then
  begin
    Enable;
    P := gl.MapBuffer(DType, GL_WRITE_ONLY);
  end else
    P := FData;
  Move(Data^, P[Offset], Size);
  if FData = nil then
  begin
    gl.UnmapBuffer(DType);
    Disable;
  end;
end;

procedure TMeshBuffer.Enable;
begin
  if ResManager.Active[TResActive(RType)] <> ResIdx then
  begin
    if FData = nil then
      gl.BindBuffer(DType, ID);
    ResManager.Active[TResActive(RType)] := ResIdx;
  end;
end;

procedure TMeshBuffer.Disable;
begin
  if ResManager.Active[TResActive(RType)] <> -1 then
  begin
    if FData = nil then
      gl.BindBuffer(DType, 0);
    ResManager.Active[TResActive(RType)] := -1;
  end;
end;
{$ENDREGION}

{$REGION 'TMesh'}
procedure TMesh.Draw;
begin
  Buffer[dtIndex].Enable;
  Buffer[dtVertex].Disable;

//  gl.VertexPointer(3, GL_FLOAT, SizeOf(TVec3f), @Map[0, 0]);
//  gl.DrawElements(GL_TRIANGLES, sqr(LOD_SIZE - 1) * 2 * 3, GL_UNSIGNED_INT, @Face[0]);

  Buffer[dtVertex].Disable;
  Buffer[dtIndex].Disable;
end;
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
    'glTexSubImage2D',
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
    'glAlphaFunc',
    'glBlendFunc',
    'glStencilFunc',
    'glDepthFunc',
    'glStencilOp',
    'glLightfv',
    'glViewport',
    'glBegin',
    'glEnd',
    'glLineWidth',
    'glColor4ub',
    'glVertex2f',
    'glVertex2fv',
    'glVertex3f',
    'glVertex3fv',
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
    'glVertexAttribPointer'
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
    end;
  end;
{$IFDEF WINDOWS}
  Set8087CW($133F);
{$ELSE}
  {$IF DEFINED(cpui386) or DEFINED(cpux86_64)}
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
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
  FileSys.Init;
  ResManager.Init;
  Screen.Init;
  Input.Init;
  Sound.Init;
end;

procedure Free;
begin
  Sound.Free;
  Input.Free;
  Screen.Free;
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

procedure Assert(const Error: string; Flag: Boolean);
begin
  if Flag then
  begin
    {$IFDEF WINDOWS}
      MessageBoxA(Screen.Handle, PAnsiChar(AnsiString(Error)), 'Fatal Error', 16);
    {$ENDIF}
    Halt;
  end;
end;
{$ENDREGION}

end.
