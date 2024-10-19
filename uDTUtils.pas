unit uDTUtils;

interface

uses dmDTData;

function GetFileCreationTime(const FileName: string): TDateTime;
procedure ExtractDataDO3Files(const ADirectory: string);
procedure ExtractDataDO4Files(const ADirectory: string);
procedure ExtractHeaderFields(const InputStr: string; var Session: integer;
  var Event: integer; var Heat: integer; var Gender: string);
procedure ExtractTextFieldsDO3(const InputStr: string; var lane: integer;  var Time1: TTime;
   var Time2: TTime; var Time3: TTime);

implementation

uses
  SysUtils, Windows, System.IOUtils, System.Types,
  StrUtils, System.Classes;

function GetFileCreationTime(const FileName: string): TDateTime;
var
  Handle: THandle;
  FindData: TWin32FindData;
  SystemTime: TSystemTime;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    // Convert file time to local file time
    if FileTimeToLocalFileTime(FindData.ftCreationTime, LocalFileTime) then
    begin
      // Convert file time to system time
      if FileTimeToSystemTime(LocalFileTime, SystemTime) then
      begin
        // Convert system time to TDateTime
        Result := SystemTimeToDateTime(SystemTime);
        Exit;
      end;
    end;
  end;
  // Return 0 if there is an error
  Result := 0;
end;

procedure ExtractHeaderFields(const InputStr: string; var Session: integer;
  var Event: integer; var Heat: integer; var Gender: string);
var
  Fields: TArray<string>;
begin
  // Split string by the '-' character
  Fields := SplitString(InputStr, '-');
  if Length(Fields) <> 4 then
    raise Exception.Create('Invalid format');
  Session := StrToInt(Fields[0]);
  Event := StrToInt(Fields[1]);
  Heat := StrToInt(Fields[2]);
  Gender := Fields[3];
end;

function StrToCustomTime(const TimeStr: string): TTime;
var
  Seconds, Hundredths: Integer;
  DotPos: Integer;
  TimeValue: Double;
begin
  // Handle empty string (no time provided)
  if TimeStr = '' then
    Exit(0);

  // Find the position of the dot
  DotPos := Pos('.', TimeStr);

  if DotPos > 0 then
  begin
    // Convert the part before the dot (seconds)
    Seconds := StrToInt(Copy(TimeStr, 1, DotPos - 1));

    // Convert the part after the dot (hundredths)
    Hundredths := StrToInt(Copy(TimeStr, DotPos + 1, Length(TimeStr) - DotPos));

    // Calculate the time as a fraction of a day (TTime uses days)
    TimeValue := (Seconds + (Hundredths / 100)) / SecsPerDay; // SecsPerDay is 86400 (seconds in a day)
  end
  else
  begin
    // If there's no dot, treat the string as whole seconds
    Seconds := StrToInt(TimeStr);
    TimeValue := Seconds / SecsPerDay;
  end;

  Result := TimeValue;
end;

procedure ExtractTextFieldsDO3(const InputStr: string; var Lane: Integer; var Time1, Time2, Time3: TTime);
var
  Fields: TArray<string>;
begin
  // Split string by the ';' character
  Fields := SplitString(InputStr, ';');
  if Length(Fields) < 2 then
    raise Exception.Create('Invalid format');

  // Extract the lane as an integer
  Lane := StrToInt(Fields[0]);

  // Convert time fields using the custom function
  Time1 := StrToCustomTime(Fields[1]);

  // Handle optional time fields (Time2 and Time3)
  if Length(Fields) > 2 then
    Time2 := StrToCustomTime(Fields[2])
  else
    Time2 := 0; // No Time2 provided

  if Length(Fields) > 3 then
    Time3 := StrToCustomTime(Fields[3])
  else
    Time3 := 0; // No Time3 provided
end;

procedure ExtractFileNameFieldsDO3(const InputStr: string; var Session: integer; var Event:integer; var RaceID: string);
var
  Fields: TArray<string>;
begin
  // Split string by the '-' character
  Fields := SplitString(InputStr, '-');
  if Length(Fields) <> 3 then
    raise Exception.Create('Invalid format');
  // Extract the first and second fields as integers
  Session := StrToInt(Fields[0]);
  Event := StrToInt(Fields[1]);
  // The third field has a '.' delimiter for the string and the '.do3' part
  RaceID := Copy(Fields[2], 1, Pos('.', Fields[2]) - 1);
  // Check the '.do3' part
  {
  if Fields[2].Substring(Pos('.', Fields[2])) = '.do3' then
    FinalFieldInt := 1
  else
    raise Exception.Create('Invalid final part');
  }
end;


procedure ExtractDataDO4Files(const ADirectory: string);
begin

end;


procedure ExtractDataDO3Files(const ADirectory: string);
var
  LList: TStringDynArray;
  I, J: Integer;
  LSearchOption: TSearchOption;
  fileMask, fn: string;
  // filename params
  fCreationDT: TDateTime;
  fSessionNum, fEventNum: integer;
  fRaceID: string;
  // fileheader params
  session, Event, Heat: integer;
  gender: string;
  // filebody params
  lane: integer;
  time1, time2, time3: TTime;
  sl: TStringList;
  checksum: string;
begin
  fileMask := '*.DO3';
  { Select the search option }
  // do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;
  try
    { For files use GetFiles method }
    LList := TDirectory.GetFiles(ADirectory, fileMask, LSearchOption);
  except
    { Catch the possible exceptions }
    MessageBox(0, PChar('Incorrect path or search mask'), PChar('Extract Dolphin Files'), MB_ICONERROR or MB_OK);
    Exit;
  end;
  // clear all data records ....
  DTData.memtblDT.EmptyDataSet;
  { Extract DATA and Populate the memory table.  }
  for I := 0 to Length(LList) - 1 do
  begin
    fn := LList[I];
    // Get the creation time of the specified file
    fCreationDT := TFile.GetCreationTime(fn);
    // Filename used can show session, event. (After correct DT setup).
    // fRaceID is unique string(do3)/number(do4) given to each file by DT.
    ExtractFileNameFieldsDO3(fn, fSessionNum, fEventNum, fRaceID);
    // read header and lane information (Racetimes x3).
    sl := TStringList.Create();
    sl.LoadFromFile(fn);
    if not sl.IsEmpty then
    begin
      // first line represents session, event, heat, gender (A,B,X)
      // delimeter is ';'
      ExtractHeaderFields(sl[0], Session, Event, Heat, Gender);
      // checksum is the last line
      checksum := sl[sl.Count - 1];
      // A record for each lane. Ignore first (header) and last line (checkSum).
      for J := 1 to (sl.Count - 2) do
      begin
      // CREATE NEW RECORD - one for each lane.
      DTData.memtblDT.Insert;
      // FILENAME = INFORMATION (prefix f)  common
      DTData.memtblDT.fieldbyName('fSessionNum').AsInteger := fSessionNum;
      DTData.memtblDT.fieldbyName('fEventNum').AsInteger := fSessionNum;
      DTData.memtblDT.fieldbyName('fRaceID').AsString := fRaceID;
      // HEADER - first line of text - common
      DTData.memtblDT.fieldbyName('Session').AsInteger := Session;
      DTData.memtblDT.fieldbyName('Event').AsInteger := Event;
      DTData.memtblDT.fieldbyName('Heat').AsInteger := Heat;
      DTData.memtblDT.fieldbyName('Gender').AsString := Gender;
      // CHECKSUM - last line of text - common
      DTData.memtblDT.fieldbyName('CheckSum').AsString := checksum;
      // BODY -  (LANE and RACETIMES)
      // Lane data - up to 10 lanes ...
      ExtractTextFieldsDO3(sl[J], lane, time1, time2, time3);
      DTData.memtblDT.fieldbyName('Lane').AsInteger := lane;
      DTData.memtblDT.fieldbyName('Time1').AsDateTime := TDateTime(time1);
      DTData.memtblDT.fieldbyName('Time2').AsDateTime := TDateTime(time2);
      DTData.memtblDT.fieldbyName('Time3').AsDateTime := TDateTime(time3);
      // FINALIZE - POST NEW RECORD.
      DTData.memtblDT.Post;
      end;
    end;

    sl.Free;

  end;

end;







end.
