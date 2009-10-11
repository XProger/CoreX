program xpk;

{$APPTYPE CONSOLE}

uses
  Windows;

type
  TPackFile = record
    Name : AnsiString;
    Pos  : LongInt;
    Size : LongInt;
  end;

var
  PackFile : array of TPackFile;

procedure Dir(const Path: string);
var
  fd : TWin32FindData;
  h  : THandle;
begin
  h := FindFirstFile(PChar(Path + '*.*'), fd);
  if h <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if fd.cFileName[0] <> '.' then
        if fd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
        begin
          SetLength(PackFile, Length(PackFile) + 1);
          with PackFile[Length(PackFile) - 1] do
          begin
            Name := AnsiString(Path + fd.cFileName);
            Size := fd.nFileSizeLow;
            if Length(PackFile) > 1 then
              Pos := PackFile[Length(PackFile) - 2].Pos + PackFile[Length(PackFile) - 2].Size
            else
              Pos := 0;
          end;
        end else
          Dir(Path + fd.cFileName + '/')
    until not FindNextFile(h, fd);
    FindClose(h);
  end;
end;

procedure Save(const Path, PackName: string);
var
  F, Fp : File;
  i    : LongInt;
  Len  : Byte;
  Data : Pointer;
begin
  AssignFile(F, PackName);
  Rewrite(F, 1);
// Write header
  i := Length(PackFile);
  BlockWrite(F, i, SizeOf(i)); // FileCount
  for i := 0 to Length(PackFile) - 1 do
    with PackFile[i] do
    begin
      Len := Length(Name);
      BlockWrite(F, Len, SizeOf(Len));
      BlockWrite(F, Name[1], Length(Name));
      BlockWrite(F, Pos, SizeOf(Pos));
      BlockWrite(F, Size, SizeOf(Size));
    end;
// Write Files
  for i := 0 to Length(PackFile) - 1 do
    with PackFile[i] do
    begin
      Writeln('Packing "', string(PackFile[i].Name), '"');
      AssignFile(Fp, Path + string(PackFile[i].Name));
      Reset(Fp, 1);
      Data := GetMemory(Size);
      BlockRead(Fp, Data^, Size);
      BlockWrite(F, Data^, Size);
      FreeMemory(Data);
      CloseFile(Fp);
    end;
  CloseFile(F);
  Writeln('done!');
end;

var
  i, HSize : LongInt;

  Path, PackName : string;
begin
  Path := ParamStr(1);
  PackName := ParamStr(2);
  if (Path = '') or (PackName = '') then
  begin
    Writeln('xpk Path PackName');
    Writeln('Example: xpk ../media/ media.xpk');
    Exit;
  end;

  Writeln('Packing directory "', Path, '" into pack file "', PackName, '"');

// Get FileNames
  Dir(Path);
  if Length(PackFile) = 0 then
  begin
    Writeln('No files found');
    Exit;
  end;

// Calc header size
  HSize := 4; // FileCount
  for i := 0 to Length(PackFile) - 1 do
    with PackFile[i] do
    begin
      Delete(Name, 1, Length(Path));
      Inc(HSize, 1 + Length(Name) + 4 + 4); // Len, Name, Pos, Size
    end;
  Writeln('Header Size : ', HSize);
  Writeln('Files Count : ', Length(PackFile));
  with PackFile[Length(PackFile) - 1] do
    Writeln('Pack Size   : ', (Pos + Size)/1024/1024:0:2, ' mb');

// Recalc PackFile positions
  for i := 0 to Length(PackFile) - 1 do
    with PackFile[i] do
      Inc(Pos, HSize);

// Save
  Save(Path, PackName);
end.
