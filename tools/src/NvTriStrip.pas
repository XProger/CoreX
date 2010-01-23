unit NVTriStrip;

(*** NVTriStrip DLL
 *
 * Written by Tom Nuydens (tom@delphi3d.net -- http://www.delphi3d.net), based
 * on the original NVTriStrip library by NVIDIA.
 *
 *)

// Modified by XProger
// http://xproger.mirgames.ru :D

interface

const
  NVTRISTRIP_DLL = 'nvtristrip.dll';

// Valid cache sizes:
const
  NVTS_CACHE_SIZE_GEFORCE1_2  = 16;
  NVTS_CACHE_SIZE_GEFORCE3    = 24;

// Primitive types:
const
  NVTS_TRIANGLE_LIST   = 0;
  NVTS_TRIANGLE_STRIP  = 1;
  NVTS_TRIANGLE_FAN    = 2;

// A primitive group:
type
  PWordArray = ^TWordArray;
  TWordArray = array [0..1] of Word;

  PNVTSPrimitiveGroup = ^NVTSPrimitiveGroup;
  NVTSPrimitiveGroup = record
    pgtype     : Cardinal;
    numIndices : Cardinal;
    indices    : PWordArray;
  end;

// Exported functions:
procedure nvtsSetCacheSize(s: Cardinal);
  stdcall; external NVTRISTRIP_DLL name '_nvtsSetCacheSize@4';
procedure nvtsSetStitchStrips(s: Boolean);
  stdcall; external NVTRISTRIP_DLL name '_nvtsSetStitchStrips@4';
procedure nvtsSetMinStripLength(l: Cardinal);
  stdcall; external NVTRISTRIP_DLL name '_nvtsSetMinStripLength@4';
procedure nvtsSetListOnly(l: Boolean);
  stdcall; external NVTRISTRIP_DLL name '_nvtsSetListOnly@4';
procedure nvtsGenerateStrips(in_indices: PWordArray; in_numIndices: Cardinal;
                             var primGroups: PNVTSPrimitiveGroup;
                             var numGroups: Word);
  stdcall; external NVTRISTRIP_DLL name '_nvtsGenerateStrips@16';
procedure nvtsRemapIndices(in_primGroups: PNVTSPrimitiveGroup; numGroups: Word;
                           numVerts: Word;
                           var remappedGroups: PNVTSPrimitiveGroup);
  stdcall; external NVTRISTRIP_DLL name '_nvtsRemapIndices@16';
procedure nvtsDeletePrimitiveGroups(primGroups: PNVTSPrimitiveGroup;
                                    numGroups: Word);
  stdcall; external NVTRISTRIP_DLL name '_nvtsDeletePrimitiveGroups@8';

implementation

end.
