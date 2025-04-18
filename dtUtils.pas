unit dtUtils;

interface

uses dmDTData, vcl.ComCtrls, Math, System.Types, System.IOUtils,
  SysUtils, Windows, StrUtils, System.Classes, SCMDefines;

function StripAlphaChars(const InputStr: string): string;

type
  TdtUtils = record
  private
    type
      PTime = ^TTime;
    var
      fSplits: array[0..9] of double;
      fTimeKeepers: array[0..2] of double;
      fPrecedence: dtPrecedence;
      fSList: TStringList; // Header, Body(multi-line ... lanes) and Footer.
      fFileType: dtFileType; // dtUnknow,dtDO3, dtDO4
      fFileName: string; // Filename + EXTENSION. NO PATH.
      fCreatedDT: TDateTime;
      fAcceptedDeviation: double;
      fCalcMode: integer; // 0 = DT Method. (Default) 1 = SCM Method.

    // --------------------------------------------
    { Routine to :
      - Extract Filename+Ext to dtUtils.fFileName. (EXCLUDES PATH)
      - load dtUtils.fStrList with TFilename.
      - store dtUtils.fFileType with dtFileType.
     }
    function PrepareExtraction(const AFileName: TFileName): boolean;
    // After prepare the following routines can be called.
    // --------------------------------------------
    { TStringList - HEADER}
    function sListHeaderSessionNum(): integer;
    function sListHeaderEventNum(): integer;
    function sListHeaderHeatNum(): integer;
    function sListHeaderGenderChar(): char;
    { TStringList - BODY - ref: fSListIndex }
    function sListBodyLane(LineIndex: integer): integer;
    function sListBodyTimeKeepers(LineIndex: integer; var ATimeKeepers: array of double): boolean;
    function sListBodySplits(LineIndex: integer; var ASplits: array of double): boolean;
    { TStringList - FOOTER }
    function sListFooterHashStr(): string;
    { FILENAME EXTRACTION ROUTINES...}
    function fn_SessionNum(): integer;
    function fn_EventNum(): integer;
    function fn_HeatNum(): integer;
    function fn_RoundChar(): char;
    function fn_HashStr(): string;
    function fn_RaceID(): integer;

    // --------------------------------------------
    // Main Process entry points
    procedure ProcessDirectory(const ADirectory: string;
      pBar: TProgressBar);
    procedure ProcessEvent(SessionID: integer);
    procedure ProcessHeat(EventID: integer);
    procedure ProcessEntrant(HeatID: integer);

//    function TryParseCustomTime(const s: string; out ATimeValue: TDateTime): boolean;
    function ConvertSecondsStrToTime(ASecondsStr: string): TTime;

  public
    // Sub-routines for Process
    procedure ProcessFile(const AFileName: string; pBar: TProgressBar);
    procedure ProcessSession(AFileName: TFileName);
    procedure PrepareDTData();
    procedure PopulateDTData(const ADirectory: string; pBar: TProgressBar);
    procedure AppendDTData(const AFileName: string);
    // procedure CalculateDeviation(EntrantID: integer; AEventType: scmEventType);

    function DirectoryHasDTFiles(const ADirectory: string): boolean;
    function GetDTFileTypeOfFile(const AFileName: string): dtFileType;

    class operator Initialize(out Dest: TdtUtils);
    class operator Finalize(var Dest: TdtUtils);

    property AcceptedDeviation: double read FAcceptedDeviation write FAcceptedDeviation;

  end;


// ---------------------------------------------------

{
This is a CSV file and can be hand typed or generated by meet management software.
Each line of this file should be formatted as follows:
Event Number,EventName,Number of Heats,Number of Splits,Round.
Example:
  1A,Boys 50 M Free,4,1,P
  1B,Girls 50 M Free,5,1,P
  2A,Boys 100 M Breaststroke,2,2,P
  2B,Girls 100 M Breaststroke,2,2,P
...
}

implementation

uses System.Character, DateUtils, Data.DB;

function StripAlphaChars(const InputStr: string): string;
var
  Achar: Char;
begin
  Result := '';
  for Achar in InputStr do
    if Achar.IsDigit then
      Result := Result + Achar;
end;

function TdtUtils.ConvertSecondsStrToTime(ASecondsStr: string): TTime;
var
  TotalSeconds: Double;
  Hours, Minutes, Seconds, Milliseconds: Word;
begin
  Result := 0; // Initialize the result to zero

  // Check if the input string is empty
  if Trim(ASecondsStr) = '' then
    Exit;

  // Attempt to convert the string to a floating point value
  try
    TotalSeconds := StrToFloat(ASecondsStr);
  except
    // If an error occurs, return zero
    Exit;
  end;

  // Calculate the hours, minutes, seconds, and milliseconds components
  Hours := Trunc(TotalSeconds) div 3600;
  TotalSeconds := TotalSeconds - (Hours * 3600);
  Minutes := Trunc(TotalSeconds) div 60;
  TotalSeconds := TotalSeconds - (Minutes * 60);
  Seconds := Trunc(TotalSeconds);
  Milliseconds := Round(Frac(TotalSeconds) * 1000);

  // Encode the components back into a TTime value
  Result := EncodeTime(Hours, Minutes, Seconds, Milliseconds);
end;

class operator TdtUtils.Finalize(var Dest: TdtUtils);
begin
  FreeAndNil(Dest.fSList);
  Dest.fFileType := dtUnknown;
end;

class operator TdtUtils.Initialize(out Dest: TdtUtils);
begin
  Dest.fSList := TStringList.Create;
  Dest.fFileType := dtUnknown;
  Dest.fFileName := '';
  Dest.fCalcMode := 0;
end;

function TdtUtils.DirectoryHasDTFiles(const ADirectory: string): boolean;
var
  LList: TStringDynArray;
  LSearchOption: TSearchOption;
  fileMask: string;
begin
  fileMask := '*.DO?';
  result := false;
  // do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;
  try
    { For files use GetFiles method }
    LList := TDirectory.GetFiles(ADirectory, fileMask, LSearchOption);
    // TEST for Dolphin Timing files.
    if (Length(LList) > 0) then
    begin
      result := true;
      exit;
    end;
  except
    { Catch the possible exceptions }
    MessageBox(0, PChar('Incorrect path or search mask'),
      PChar('Get file type of directory...'), MB_ICONERROR or MB_OK);
    exit;
  end;
end;

function TdtUtils.GetDTFileTypeOfFile(const AFileName: string): dtFileType;
begin
  result := dtUnknown;
  if AfileName.Contains('.DO3') then
    result := dtDO3
  else if AfileName.Contains('.DO4') then
    result := dtDO4;
end;

function TdtUtils.fn_SessionNum: integer;
var
  Fields: TArray<string>;
begin
  result := 0;
  if fFileName.IsEmpty() then exit;
  // Split string by the '-' character
  Fields := SplitString(fFileName, '-');
  if Length(Fields) > 0 then
    // Extract the first field - SessionID
    result := StrToIntDef(Fields[0], 0);
end;

function TdtUtils.fn_EventNum(): integer;
var
  Fields: TArray<string>;
begin
  result := 0;
  if fFileName.IsEmpty then exit;
  // Split string by the '-' character
  // example of fFileName
  // - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
  Fields := SplitString(fFileName, '-');
  if Length(Fields) > 1 then
    // Extract the first field - SessionID
    result := StrToIntDef(Fields[1], 0);
end;

function TdtUtils.fn_HeatNum(): integer;
var
  Fields: TArray<string>;
  HeatNumStr: string;
begin
  result := 0;
  if fFileName.IsEmpty then exit;
  // only Dolphin Timing v4 Files have 'Heat Number' information in FileName.
  if (fFileType <> dtDO4) then exit;
  // example of fFileName
  // - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
  // Split string by the '-' character
  Fields := SplitString(fFileName, '-');
  if Length(Fields) > 2 then
  begin
    // remove the 'Round' character ['A', 'P', 'F'].
    HeatNumStr := StripAlphaChars(Fields[2]);
    // Extract the first field - SessionID
    result := StrToIntDef(HeatNumStr, 0);
  end;
end;

function TdtUtils.fn_HashStr(): string;
var
  HashStr: string;
  Fields: TArray<string>;
begin
  result := '';
  HashStr := '';
  if fFileName.IsEmpty then exit;
  // Split string by the '-' character
  // example of fFileName
  // - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
  Fields := SplitString(fFileName, '-');
  case fFileType of
    dtUnknown: ;
    dtDO4:
      begin
        if Length(Fields) > 3 then
        begin
          // The fourthfield has a '.' delimiter for the string and the '.do4' part
          HashStr := Copy(Fields[3], 1, Pos('.', Fields[3]) - 1);
        end;
      end;
    dtDO3:
      begin
        if Length(Fields) > 2 then
        begin
          // The third field has a '.' delimiter for the string and the '.do3' part
          HashStr := Copy(Fields[2], 1, Pos('.', Fields[2]) - 1);
        end;
      end;
    dtALL: ;
  end;
  if Length(HashStr) > 0 then
    // only 8 character permitted.
    result := Copy(HashStr, 1, 8);
end;

function TdtUtils.fn_RaceID(): integer;
var
  RaceStr: string;
  Fields: TArray<string>;
begin
  result := 0;
  RaceStr := '';
  if fFileName.IsEmpty then exit;
  if (fFileType <> dtDO4) then exit;
  // Split string by the '-' character
  // example of fFileName
  // - 088-001-001A-0001.do4
  Fields := SplitString(fFileName, '-');
  if Length(Fields) > 3 then
  begin
    // The fourthfield has a '.' delimiter for the string and the '.do4' part
    RaceStr := Copy(Fields[3], 1, Pos('.', Fields[3]) - 1);
    if Length(RaceStr) > 0 then
      // only 8 character permitted.
      result := StrToIntDef(RaceStr, 0);
  end;
end;

function TdtUtils.fn_RoundChar(): char;
var
  RoundChar: char;
  Fields: TArray<string>;
begin
  result := 'A'; // Safe to assign: DEFAULT.
  if fFileName.IsEmpty then exit;
  // only Dolphin Timing v4 Files have 'Heat Number' information in FileName.
  if (fFileType <> dtDO4) then exit;
  // Split string by the '-' character
  // example of fFileName - 088-001-001A-0001.do4
  // The letter A in the above example, indicates the 'Round Type'
  // Round � �A� for all, �P� for prelim or �F� for final.
  Fields := SplitString(fFileName, '-');
  if Length(Fields) > 2 then // Correct condition
  begin
    RoundChar := Fields[2][Length(Fields[2])]; // Get the last character of Fields[2]
    // Convert to uppercase before checking
    RoundChar := UpCase(RoundChar);
    // Round � �A� for all, �P� for prelim or �F� for final.
    if CharInSet(RoundChar, ['A', 'P', 'F']) then
      result := RoundChar;
  end;
end;

procedure TdtUtils.AppendDTData(const AFileName:string);
Begin
  ProcessSession(AFileName);
End;

function TdtUtils.PrepareExtraction(const AFileName: TFileName): boolean;
begin
  { Called by ProcessSession for each TFileName. Initialises private fields.
    These paramas are then used later by fn_ and sList functions. }
  result := false;
  if not Assigned(fSList) then exit;
  fSList.Clear;
  if FileExists(AFileName) then
  begin
    fFileName := ExtractFileName(AFileName);
      // Time stamp of file. Created On DateTime.
    fCreatedDT :=TFile.GetCreationTime(AFileName);
    fSList.LoadFromFile(AFilename);
    fFileType := GetDTFileTypeOfFile(fFileName);;
    result := true;
  end
  else
  begin
    fFileName := '';
    fSList.Clear;
    fFileType := dtUnKNown;
  end;
end;

procedure TdtUtils.PrepareDTData();
begin
  fPrecedence := dtPrecHeader; // (sListHeaderSessionNum)

  // clear all data records ....
  DTData.tblDTSession.EmptyDataSet;
  DTData.tblDTEvent.EmptyDataSet;
  DTData.tblDTHeat.EmptyDataSet;
  DTData.tblDTEntrant.EmptyDataSet;
  DTData.tblDTNoodle.EmptyDataSet;

  // re-establish Master Detail ...
  DTData.tblDTEvent.MasterSource := DTData.dsDTSession;
  DTData.tblDTEvent.MasterFields := 'SessionID';
  DTData.tblDTEvent.DetailFields := 'SessionID';
  DTData.tblDTEvent.IndexFieldNames := 'SessionID';

  DTData.tblDTHeat.MasterSource := DTData.dsDTEvent;
  DTData.tblDTHeat.MasterFields := 'EventID';
  DTData.tblDTHeat.DetailFields := 'EventID';
  DTData.tblDTHeat.IndexFieldNames := 'EventID';

  DTData.tblDTEntrant.MasterSource := DTData.dsHeat;
  DTData.tblDTEntrant.MasterFields := 'HeatID';
  DTData.tblDTEntrant.DetailFields := 'HeatID';
  DTData.tblDTEntrant.IndexFieldNames := 'HeatID';

  DTData.tblDTNoodle.MasterSource := DTData.dsDTHeat;
  DTData.tblDTNoodle.MasterFields := 'HeatID';
  DTData.tblDTNoodle.DetailFields := 'HeatID';
  DTData.tblDTNoodle.IndexFieldNames := 'HeatID';

end;

Procedure TdtUtils.PopulateDTData(const ADirectory: string; pBar: TProgressBar);
begin
  DTData.tblDTSession.DisableControls;
  DTData.tblDTEvent.DisableControls;
  DTData.tblDTHeat.DisableControls;
  DTData.tblDTEntrant.DisableControls;
  DTData.tblDTNoodle.DisableControls;

  if Assigned(pBar) then pBar.Position := 0;

  // NOTE: ProcessDirectory will disabled/enabled Master-Detail.
  // Necessary to calculate table Primary keys, etc.
  ProcessDirectory(ADirectory, pBar);

  DTData.tblDTSession.First;
  dtData.tblDTEvent.ApplyMaster;
  dtData.tblDTEvent.First;
  dtData.tblDTHeat.ApplyMaster;
  dtData.tblDTHeat.First;

  DTData.tblDTSession.EnableControls;
  DTData.tblDTEvent.EnableControls;
  DTData.tblDTHeat.EnableControls;
  DTData.tblDTEntrant.EnableControls;
  DTData.tblDTNoodle.EnableControls;

  end;

procedure TdtUtils.ProcessFile(const AFileName: string; pBar: TProgressBar);
begin
  if Assigned(pBar) then pBar.Position := 0;
  if FileExists(AFileName) then
  begin
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    DTData.DisableDTMasterDetail;
    // =====================================================
    ProcessSession(AFileName);
    // =====================================================
    // Re-attach Master-Detail.
    DTData.EnableDTMasterDetail;
    // =====================================================
  end;
end;



procedure TdtUtils.ProcessDirectory(const ADirectory: string; pBar: TProgressBar);
var
  LList, LListDO3, LListDO4: TStringDynArray;
  LSearchOption: TSearchOption;
  I: integer;
begin
{
NOTE: The pattern '*.DO?' will match any file with a .DO extension followed
by any single character. This means it will match *.DO3, *.DO4, *.DO5, etc.
.. but to future proof the following method was chosen.
}
  if Assigned(pBar) then pBar.Position := 0;
  { Select the search option }
  // do not do recursive extract into subfolders
  LSearchOption := TSearchOption.soTopDirectoryOnly;

  // clear all datasets of records.
  DTData.tblDTSession.EmptyDataSet;
  DTData.tblDTEvent.EmptyDataSet;
  DTData.tblDTHeat.EmptyDataSet;
  DTData.tblDTEntrant.EmptyDataSet;
  DTData.tblDTNoodle.EmptyDataSet;

  // =====================================================
  // De-attach from Master-Detail. Create flat files.
  // Necessary to calculate table Primary keys.
  DTData.DisableDTMasterDetail;
  // =====================================================

  try
    { For files use GetFiles method }
    LListDO3 := TDirectory.GetFiles(ADirectory, '*.DO3', LSearchOption);
    LListDO4 := TDirectory.GetFiles(ADirectory, '*.DO4', LSearchOption);

    { Combine the lists }
    SetLength(LList, Length(LListDO3) + Length(LListDO4));
    if Length(LListDO3) > 0 then
      Move(LListDO3[0], LList[0], Length(LListDO3) * SizeOf(string));
    if Length(LListDO4) > 0 then
      Move(LListDO4[0], LList[Length(LListDO3)], Length(LListDO4) * SizeOf(string));

    { Extract DATA and Populate the memory table. }
    for I := 0 to Length(LList) - 1 do
    begin
      { Calls - PrepareExtraction, ProcessEvent, ProcessHeat, ProcessEntrant }
      ProcessSession(LList[I]);
      // update progress bar.
      if Assigned(pBar) then
      begin
        pBar.Position := Trunc(Ceil((I + 1) / Length(LList) * 100));
        pBar.RePaint;
      end;
    end;
  except
    { Catch the possible exceptions }
    MessageBox(0, PChar('Incorrect path or search mask'),
      PChar('Extract Dolphin .DO3 and .DO4 Files'), MB_ICONERROR or MB_OK);
  end;

  // =====================================================
  // Re-attach Master-Detail.
  DTData.EnableDTMasterDetail;
  // =====================================================

end;

procedure TdtUtils.ProcessSession(AFileName: TFileName);
var
  i, id: integer;
  s: string;
  fCreationDT: TDateTime;
  fs: TFormatSettings;
  Found: boolean;
begin
  // NOTE: Assumption - FileExists!
  { Preparation of filename extraction must succeed.
    On ERR - skip file - silent.}
  if not (PrepareExtraction(AFileName)) then exit;
  // DEFAULT Precedence dtPrecHeader - use the SessionNum given in the
  // 'Header' (TStringList sList : line one : SplitString - field[0])
  if (FPrecedence = dtPrecFileName) then
    i := fn_SessionNum()
  else
    i := sListHeaderSessionNum();
  // DOES THIS SESSION PK AREADY EXSIST?
  Found := DTData.LocateDTSessionNum(i, FPrecedence);
  if Found then
  begin
    // assign this id to ProcessEvent.
    id := DTData.tblDTSession.FieldByName('SessionID').AsInteger;
  end
  else
  begin
    // ID isn't AutoInc - calc manually.
    id := DTData.MaxID_Session + 1;
    // Get the creation time of the specified file
    fCreationDT := TFile.GetCreationTime(AFileName);
    DTData.tblDTSession.Append;
    // Primary Key
    DTData.tblDTSession.FieldByName('SessionID').AsInteger := id;
    // Derived from line one ('Header') within the DT file.
    DTData.tblDTSession.fieldbyName('SessionNum').AsInteger := sListHeaderSessionNum();
    // Derived from filename : Last three digits of SCM qrySession.SessionID.
    DTData.tblDTSession.fieldbyName('fnSessionNum').AsInteger := fn_SessionNum();
    // Creation date of file - by Dolphin Timing system.
    DTData.tblDTSession.fieldbyName('SessionStart').AsDateTime := fCreationDT;
    // TimeStamp
    DTData.tblDTSession.fieldbyName('CreatedOn').AsDateTime := Now;
    // Create a session caption.
    fs := TFormatSettings.Create;
    fs.DateSeparator := '_';
    s := 'Session: ' + IntToStr(fn_SessionNum()) + ' Date: ' + DatetoStr(fCreationDT, fs);
    DTData.tblDTSession.fieldbyName('Caption').AsString := s;
    // FINALIZE - POST NEW RECORD.
    DTData.tblDTSession.Post;
  end;
  // process event >> heat >> entrant.
  ProcessEvent(id);
end;

procedure TdtUtils.ProcessEvent(SessionID: integer);
var
  i,j, id: integer;
  Found: boolean;
begin
  id := 0;
  // NOTE: Assumption - FileExists!
  // DEFAULT Precedence dtPrecHeader
  if (FPrecedence = dtPrecFileName) then
    i := fn_EventNum()
  else
    i := sListHeaderEventNum();

  // DOES THIS EVENT PK AREADY EXSIST?
  Found := DTData.LocateDTEventNum(SessionID, i, FPrecedence);


  if Found then
    // assign this id to ProcessHeat.
    id := DTData.tblDTEvent.FieldByName('EventID').AsInteger
  else
  begin
    if not fSList.IsEmpty then
    begin
      // calculate the Primary Key : IDENTIFIER.
      // ID isn't AutoInc - calc manually.
      id := DTData.MaxID_Event + 1;
      // NEW RECORD.
      DTData.tblDTEvent.Append;
      // Primary Key.
      DTData.tblDTEvent.fieldbyName('EventID').AsInteger := id;
      // master - detail. Also Index Field.
      DTData.tblDTEvent.fieldbyName('SessionID').AsInteger := SessionID;
      // Derived from DT filename.
      DTData.tblDTEvent.fieldbyName('fnEventNum').AsInteger := fn_EventNum();
      // Derived from TStringList - 'HEADER' - SplitString Field[1]
      j := sListHeaderEventNum();
      DTData.tblDTEvent.fieldbyName('EventNum').AsInteger := j;
      // CAPTION for Event :
      DTData.tblDTEvent.fieldbyName('Caption').AsString :=
        'Event: ' +  IntToStr(j);
      // DO4 A=boys, B=girls, X=any.
      DTData.tblDTEvent.fieldbyName('GenderStr').AsString := sListHeaderGenderChar;
      // Derived from FileName
      // Round � �A� for all, �P� for prelim or �F� for final
      DTData.tblDTEvent.fieldbyName('fnRoundStr').AsString := fn_RoundChar();
      // POST
      DTData.tblDTEvent.Post;
//      DTData.tblDTEvent.ApplyUpdates();
    end;
  end;
  // CORE DATA - TimeStamp, Record Creation Date, Heat Number, etc.
  ProcessHeat(id);
end;

procedure TdtUtils.ProcessHeat(EventID: integer);
var
  i, id: integer;
  Found: boolean;
begin
  id := 0;

  if (FPrecedence = dtPrecFileName) then
    i := fn_HeatNum()
  else
    i := sListHeaderHeatNum();

  // HAS THIS HEAT AREADY been processed?
  Found := DTData.LocateDTHeatNum(EventID, i, FPrecedence);
  if Found then
    // use this id to call process entrant.
    id := DTData.tblDTHeat.FieldByName('HeatID').AsInteger
  else
  begin
    // read header and lane information (Racetimes x3).
    if not fSList.IsEmpty then
    begin
      // calculate the IDENTIFIER.
      // ID isn't AutoInc - calc manually.
      id := DTData.MaxID_Heat() + 1;
      // NEW RECORD.
      DTData.tblDTHeat.Append;
      // PK
      DTData.tblDTHeat.fieldbyName('HeatID').AsInteger := id;
      // master - detail.
      DTData.tblDTHeat.fieldbyName('EventID').AsInteger := EventID;
      // TIME STAMP
      DTData.tblDTHeat.fieldbyName('TimeStampDT').AsDateTime := Now;
      // Derived from Dolphin filename.
      DTData.tblDTHeat.fieldbyName('fnHeatNum').AsInteger := fn_HeatNum;
      // Derived from TStringList HEADER - first line of text - common
      i := sListHeaderHeatNum();
      DTData.tblDTHeat.fieldbyName('HeatNum').AsInteger := i;
      DTData.tblDTHeat.fieldbyName('Caption').AsString := 'Heat: ' + IntToStr(i);
      // Time stamp of file - created by Dolphin Timing system on write of file.
      DTData.tblDTHeat.fieldbyName('CreatedDT').AsDateTime := fCreatedDT;
      // FileName includes file extension.    (.DO3, .DO4)
      // determines dtFileType dtDO3, dtDO4.
      DTData.tblDTHeat.fieldbyName('FileName').AsString := fFileName;
      // CHECKSUM - last line of text - common
      // Max of 16 characters
      DTData.tblDTHeat.fieldbyName('CheckSum').AsString := sListFooterHashStr();
      // Filename doesn't match header info ...
      DTData.tblDTHeat.fieldbyName('fnBadFN').AsBoolean := false;
      // DO3 - SplitString Field[2] hash number (alpha-numerical).
      // DO4 - SplitString Field[3] hash number (numerical - sequence).
      // NOTE: MAX of 8 characters.
      DTData.tblDTHeat.fieldbyName('fnHashStr').AsString := fn_HashStr;
      // CONVERT DO4 - SplitString Field[3]
      // A sequential number for each file (within the DT Session?)
      if fFileType = dtDO4 then
        DTData.tblDTHeat.fieldbyName('fnRaceID').AsInteger:= fn_RaceID;
      DTData.tblDTHeat.Post;
    end;
  end;
  // DON'T process heats we have already done...
  if not Found then
    ProcessEntrant(id);
end;

procedure TdtUtils.ProcessEntrant(HeatID: integer);
var
  id, I, j, k, lane: integer;
  s: string;
  Found: boolean;
begin
  if HeatID = 0 then exit;

  Found := DTData.tblDTEntrant.Locate('HeatID', HeatID, []);
  if Found then
    // This heat has been process of all it's lane data ...
    exit;

  // dtfrmExec has a grid linked to this datasource.
  DTData.tblDTEntrant.DisableControls;
  // ID isn't AutoInc - calc manually.
  // NOTE: Master-Detail relationships have been disabled at this point.
  id := DTData.MaxID_Entrant + 1;
  { TStringList FIRST LINE = HEADER INFO.
   TStringList FIRST LINE + 1 to LAST LINE - 1 = LANES INFORMATION.
   TStringList LAST LINE  = FOOTER - CHECKSUM.
  }
  // Process lanes...
  for I := 1 to (fSList.Count - 2) do
  begin
    lane := sListBodyLane(I);
    id := id + 1;

    DTData.tblDTEntrant.Append;
    // primary key
    DTData.tblDTEntrant.fieldbyName('EntrantID').AsInteger := id;
    // master.detail.
    DTData.tblDTEntrant.fieldbyName('HeatID').AsInteger := HeatID;
    // SYNC with SwimClubMeet - INDV or TEAM lane
    DTData.tblDTEntrant.fieldbyName('Lane').AsInteger := lane;
    // Should read 'Lane: #Lane#'
    s := 'Lane: ' + IntToStr(lane);
    DTData.tblDTEntrant.fieldbyName('Caption').AsString := s;

    DTData.tblDTEntrant.fieldbyName('LaneIsEmpty').AsBoolean := false;

    // Swimmers calculated racetime for post.
    DTData.tblDTEntrant.fieldbyName('RaceTime').Clear;
    // A user entered race-time.
    DTData.tblDTEntrant.fieldbyName('RaceTimeUser').Clear;
    // The Automatic race-time. Calculated on load of DT file.
    DTData.tblDTEntrant.fieldbyName('RaceTimeA').Clear;
    // dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
    DTData.tblDTEntrant.fieldbyName('ActiveRT').AsInteger := ORD(artAutoMatic);

    // graphic used in column[6] - GRID IMAGES DTData.vimglistDTCell .
    // image index 1 indicts - dtTimeKeeperMode = dtAutomatic.
    DTData.tblDTEntrant.fieldbyName('imgActiveRT').AsInteger := -1;

    // graphic used in column[1] - for noodle drawing...
    DTData.tblDTEntrant.fieldbyName('imgPatch').AsInteger := 0;

    // gather up the timekeepers 1-3 recorded race times for this lane.
    sListBodyTimeKeepers(I, fTimeKeepers);

    for k := 0 to 2 do
    begin
      if (fTimeKeepers[k] = 0) then
      begin
        // The user's manual watch-time is disabled.
        s := Format('T%dM', [k + 1]);
        DTData.tblDTEntrant.fieldbyName(s).AsBoolean := false;
        // Initialize - The Automatic watch-time is invalid.
        s := Format('T%dA', [k + 1]);
        DTData.tblDTEntrant.fieldbyName(s).AsBoolean := false;
        DTData.tblDTEntrant.fieldbyName(s).Clear;
      end
      else
      begin
        // The user's manual watch-time is enabled.
        s := Format('T%dM', [k + 1]);
        DTData.tblDTEntrant.fieldbyName(s).AsBoolean := true;
        // Initialize - The Automatic watch-time is valid.
        // (vertified later in procedure)
        s := Format('T%dA', [k + 1]);
        DTData.tblDTEntrant.fieldbyName(s).AsBoolean := true;
        // Place watch-time in manual time field.
        s := Format('Time%d', [k + 1]);
        DTData.tblDTEntrant.fieldbyName(s).AsDateTime := TimeOf(fTimeKeepers[k]);
      end;
    end;

    // D e v i a t i o n  --- initialization
    // The watch-times, min-mid and mid-max, are within accepted deviation.
    // (verified later in procedure)
    DTData.tblDTEntrant.fieldbyName('TDev1').AsBoolean := true;
    DTData.tblDTEntrant.fieldbyName('TDev2').AsBoolean := true;

    // gather up the timekeepers 1-3 recorded race times for this lane.
    sListBodySplits(I, fSplits);
    for j := low(fSplits)  to High(fSplits) do
    begin
      if (fSplits[j] > 0) then
      begin
        s := 'Split' + IntTostr((j+1));
        DTData.tblDTEntrant.FieldByName(s).AsDateTime := TDateTime(fSplits[j]);
      end;
    end;
    DTData.tblDTEntrant.Post;

    // Main form assigns value. ASSERT - avoid division by zero.
    if fAcceptedDeviation = 0 then
      fAcceptedDeviation := 0.3; // Dolphin Timing's default.

    // Cacluate RaceTimeA for the ActiveRT. (artAutomatic)
    // AND verify deviaiton AND assert fields [T1A, T2A, T3A]
    DTData.CalcRaceTimeA(DTData.tblDTEntrant, fAcceptedDeviation, fCalcMode);

    // FINALLY place values into manual and automatic watch time fields.
    DTData.tblDTEntrant.Edit;
    DTData.tblDTEntrant.fieldbyName('RaceTime').AsVariant :=
      DTData.tblDTEntrant.fieldbyName('RaceTimeA').AsVariant;
    DTData.tblDTEntrant.post;

  end;
  DTData.tblDTEntrant.EnableControls;
end;

function TdtUtils.sListHeaderEventNum: integer;
var
  Fields: TArray<string>;
begin
  {first line : SessionNum;EventNum;HeatNum;gender (A,B,X) }
  result := 0;
  if not fSList.IsEmpty then
  begin
    Fields := SplitString(fSList[0], ';');
    if Length(Fields) > 1 then
      result := StrToIntDef(Fields[1], 0);
  end;
end;

function TdtUtils.sListHeaderGenderChar(): char;
var
  Fields: TArray<string>;
  GenderChar: char;
begin
  {first line : SessionNum;EventNum;HeatNum;gender (A,B,X) }
  result := #0;
  if not fSList.IsEmpty then
  begin
    Fields := SplitString(fSList[0], ';');
    if Length(Fields) > 3 then
    begin
      GenderChar := Fields[3].Chars[0];
      if CharInSet(GenderChar, ['A', 'B', 'X']) then
      begin
        result := UpperCase(GenderChar)[1]; // Convert to upper case if necessary
      end;
    end;
  end;
end;

function TdtUtils.sListHeaderHeatNum(): integer;
var
  Fields: TArray<string>;
begin
  {first line : SessionNum;EventNum;HeatNum;gender (A,B,X) }
  result := 0;
  if not fSList.IsEmpty then
  begin
    Fields := SplitString(fSList[0], ';');
    if Length(Fields) > 2 then
      result := StrToIntDef(Fields[2], 0);
  end;
end;

function TdtUtils.sListFooterHashStr(): string;
var
  HashStr: string;
begin
  {last line of TStringList : 16 bit HASH number.}
  result := '';
  if fSList.IsEmpty then exit;
  // last line of StringList
  HashStr := fSList[fSList.Count - 1];
  // Quick hack to assert hash string.
  // All preceeding lines in StringList contain character(s) ';'.
  if not ContainsText(HashStr, ';') then
  begin
    HashStr := Copy(HashStr,1, 16); // max 16 chars
    result := HashStr;
  end;
end;

function TdtUtils.sListHeaderSessionNum(): integer;
var
  Fields: TArray<string>;
begin
  {first line : SessionNum;EventNum;HeatNum;gender (A,B,X) }
  result := 0;
  if not fSList.IsEmpty then
  begin
    Fields := SplitString(fSList[0], ';');
    if Length(Fields) > 0 then
      result := StrToIntDef(Fields[0], 0);
  end;
end;

{
function TdtUtils.TryParseCustomTime(const s: string; out ATimeValue: TDateTime): boolean;
var
  Minutes, Seconds, Milliseconds: word;
  TimeParts: TArray<string>;
begin
  Result := False;
  ATimeValue := 0;
  Minutes := 0;
  Seconds := 0;
  Milliseconds := 0;
  ATimeValue := 0;

  if length(s) = 0 then exit;

  // Check if the string contains ':'
  if Pos(':', s) > 0 then
  begin
    // Split the string by the ':'
    TimeParts := SplitString(s, ':');
    if Length(TimeParts) = 2 then
    begin
      // Convert the minute part
      Minutes := StrToIntDef(TimeParts[0], -1);
      // Further split the seconds and optional milliseconds part by the '.'
      TimeParts := SplitString(TimeParts[1], '.');
      if Length(TimeParts) = 2 then
      begin
        // Convert the parts to integer values using StrToIntDef
        Seconds := StrToIntDef(TimeParts[0], -1);
        Milliseconds := StrToIntDef(TimeParts[1], -1);
      end
      else
      begin
        // Only seconds part
        Seconds := StrToIntDef(TimeParts[0], -1);
      end;
    end;
  end
  else
  begin
    // Split the string by the '.'
    TimeParts := SplitString(s, '.');
    if Length(TimeParts) = 2 then
    begin
      // Convert the parts to integer values using StrToIntDef
      Seconds := StrToIntDef(TimeParts[0], -1);
      Milliseconds := StrToIntDef(TimeParts[1], -1);
    end
    else
    begin
      // Only seconds part
      Seconds := StrToIntDef(s, -1);
    end;
  end;

  // Validation not required.
  // Create the TDateTime value
  ATimeValue := EncodeTime(0, Minutes, Seconds, Milliseconds);
  Result := True;
end;
}

function TdtUtils.sListBodySplits(LineIndex: integer; var ASplits: array of double): boolean;
var
  Fields: TArray<string>;
  i, SplitIndex: Integer;
  s: string;
  Found: boolean;
  ATimeValue: TDateTime;
begin
  {
    Number of Splits � (1-10) Enter 1 to use the first time as the final time.
    A single length race would have only one split (i.e. the final time), and
    multi length races would have one split for every lap.

    Example 1: A 25 yard race in a 25 yard pool would have a split count of 1
    meaning only on one time is collected (i.e. the final time)

    Example 2: A 100 meter race in a 50 meter pool would also have a split count
    of 1 (i.e: the final time of the single lap.)

    Example 3: A 200 yard race in a 25 yard pool would have a split count of 4.
  }

  Result := False;
  Found := False;

  // Initialize splits - zero indicates no race time recorded.
  for i := Low(ASplits) to High(ASplits) do
    ASplits[i] := 0;

  // Only DO4 captures split data
  if fFileType <> dtDO4 then
    Exit;

  // Using LineIndex, get the TStringList[...] string and split it by the ';' character
  Fields := SplitString(fSList[LineIndex], ';');

  // Check if there are splits available (Fields[4] and beyond are split-times)
  if Length(Fields) <= 4 then
    Exit; // NO SPLITS..

  // Extract split data
  for i := 4 to Length(Fields) - 1 do
  begin
    s := Fields[i];
    if s <> '' then
    begin
      // Try to parse the time
      ATimeValue := ConvertSecondsStrToTime(s);
      if ATimeValue > 0 then
      begin
        // Calculate the ASplit index
        SplitIndex := i - 4;
        // Ensure index is within bounds
        if (SplitIndex >= Low(ASplits)) and (SplitIndex <= High(ASplits)) then
        begin
          ASplits[SplitIndex] := ATimeValue;
          Found := True;
        end;
      end;
    end;
  end;

  if Found then
    Result := True;
end;

function TdtUtils.sListBodyLane(LineIndex: integer): integer;
var
  Fields: TArray<string>;
  s: string;
begin
  result := 0;
  // Split string by the ';' character
  Fields := SplitString(fSList[LineIndex], ';');
  if Length(Fields) = 0 then exit;   // Input string is empty - err.
  // examples.
  // DO4 - 'Lane1;55.98;;'
  // DO3 - '1;95.25;;'
  s := StripAlphaChars(Fields[0]);
  if Length(s) > 0 then
    result := StrToIntDef(s, 0); // Extract the lane as an integer
end;

function TdtUtils.sListBodyTimeKeepers(LineIndex: integer; var ATimeKeepers:
  array of double): boolean;
var
  Fields: TArray<string>;
  i: integer;
  ATimeValue: TDateTime;
  s: string;
  Found: boolean;
  //  Hour, Min, Sec, MSec: word;
begin
  // Note: Dolphin Timing allows for three timekeepers.
  // Fields[0] = lane number.
  // Fields[1], Fields[2], Fields[3] - TimeKeepers data in DTTime format.
  // examples.  DO4 - 'Lane1;55.98;;' ...  DO3 - '1;95.25;;'
  result := false;
  Found := false;

  // Using LineIndex, get the TStringList[...] string.
  // Split string by the ';' character
  s := fSList[LineIndex];
  Fields := SplitString(fSList[LineIndex], ';');
  // Initialize timekeepers - zero indicates no race time recorded
  for I := Low(ATimeKeepers) to High(ATimeKeepers) do
    ATimeKeepers[I] := 0;
  // Extract timekeepers data.
  // Fields[4] and beyond are split-times.
  for I := 1 to 3 do
  begin
    if Length(Fields) > I then
    begin
      s := Fields[I];
      if s <> '' then
      begin
        // Try to parse the time
        ATimeValue := ConvertSecondsStrToTime(s);
        if ATimeValue > 0 then
        begin
          ATimeKeepers[I - 1] := ATimeValue;
          Found := true;
        end;
      end
    end;
  end;
  if Found then
    result := true;
end;



end.

