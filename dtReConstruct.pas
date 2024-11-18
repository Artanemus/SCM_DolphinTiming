unit dtReConstruct;

interface

uses dmSCM, dmDTData, System.SysUtils, System.Classes, system.Hash,
DateUtils, variants, SCMDefines, Data.DB, dtuSetting;

procedure ReConstructDO3(SessionID: integer);
procedure ReConstructDO4(SessionID: integer);
function Get3Digits(i: integer): string;
function Get4Digits(i: integer): string;

implementation

var
seed: integer = 1;

type
dtFileType = (dtUnknown, dtDO3, dtDO4);


function GetStringListChecksum(sl: TStringList; hashLength: Integer = 8): string;
var
  fullHash: string;
begin
  // Generate the full SHA256 hash of the concatenated TStringList text
  fullHash := THashSHA2.GetHashString(sl.Text);

  // Truncate to the desired length if needed (e.g., first 8 characters for a short checksum)
  Result := Copy(fullHash, 1, hashLength);
end;

function GetEventType(aEventID: integer): scmEventType;
var
  v: variant;
  SQL: string;
begin
  result := etUnknown;
    if not DTData.qryEvent.IsEmpty then
    begin
      SQL := 'SELECT [EventTypeID] FROM [SwimClubMeet].[dbo].[Event] ' +
        'INNER JOIN Distance ON [Event].DistanceID = Distance.DistanceID ' +
        'WHERE EventID = :ID';
      v := SCM.scmConnection.ExecSQLScalar(SQL, [aEventID]);
      if VarIsNull(v) or VarIsEmpty(v) or (v = 0) then exit;
    end;
    case v of
      1: result := etINDV;
      2: result := etTEAM;
    end;
end;

function Get4Digits(i: integer): string;
var
  s: string;
begin
  // Step 2: Convert i to a string
  s := IntToStr(i);
  // Step 3: Pad with leading zeros if less than four characters
  while Length(s) < 4 do
    s := '0' + s;
  // Step 4: Trim to four characters if longer than four
  if Length(s) > 4 then
    s := Copy(s, Length(s) - 3, 4);
  // Return the result
  Result := s;
end;

function Get3Digits(i: integer): string;
var
s: string;
begin
    // Step 2: Convert i to a string
    s := IntToStr(i);
    // Step 3: Pad with leading zeros if less than three characters
    while Length(s) < 3 do
      s := '0' + s;
    // Step 4: Trim to three characters if longer than three
    if Length(s) > 3 then
      s := Copy(s, Length(s) - 2, 3);
  // Return the result
  Result := s;
end;

function CreateHash(sess, ev, ht: integer): string;
var
  combinedValue: Integer;
begin
  // Step 1: Combine sess, ev, and ht as integers
  combinedValue := sess * 1000000 + ev * 1000 + ht;
  // Step 2: Generate a seven-digit hex hash (mod a large prime to constrain size)
  combinedValue := combinedValue mod 9999999;
  // Step 3: Convert to a hexadecimal string, padded to ensure seven digits
  Result := UpperCase(IntToHex(combinedValue, 7));
end;

function GetGenderTypeStr(AEventID: integer): string;
var
  boysCount, girlsCount: Integer;
  SQL: string;
begin
  // Default result is 'X' (mixed genders)
  Result := 'X';

  // Ensure the query isn't empty
  if not DTData.qryEvent.IsEmpty then
  begin
    // Query to get boys count
    SQL := 'SELECT COUNT(*) FROM [SwimClubMeet].[dbo].[Event] ' +
           'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
           'INNER JOIN Entrant ON [HeatIndividual].HeatID = Entrant.HeatID ' +
           'INNER JOIN Member ON [Entrant].MemberID = Member.MemberID ' +
           'WHERE [Event].EventID = :ID AND GenderID = 1';
    boysCount := SCM.scmConnection.ExecSQLScalar(SQL, [AEventID]);

    // Query to get girls count
    SQL := 'SELECT COUNT(*) FROM [SwimClubMeet].[dbo].[Event] ' +
           'INNER JOIN HeatIndividual ON [Event].EventID = HeatIndividual.EventID ' +
           'INNER JOIN Entrant ON [HeatIndividual].HeatID = Entrant.HeatID ' +
           'INNER JOIN Member ON [Entrant].MemberID = Member.MemberID ' +
           'WHERE [Event].EventID = :ID AND GenderID = 2';
    girlsCount := SCM.scmConnection.ExecSQLScalar(SQL, [AEventID]);

    // Determine the result based on counts
    if (boysCount > 0) and (girlsCount > 0) then
      Result := 'X'
    else if boysCount > 0 then
      Result := 'A'
    else if girlsCount > 0 then
      Result := 'B';
  end;
end;

procedure TestDataINDV(sl: TStringList; adtFileType: dtFileType);
var
  lanevalue: variant;
  s, lane: string;
  rt: TTime;
  msec: double;
begin
  if DTData.qryINDV.IsEmpty then exit;

  DTData.qryINDV.first;
  while not DTData.qryINDV.eof do
  begin
    // lane data
    laneValue := DTData.qryINDV.FieldByName('Lane').AsVariant;
    if not VarIsNull(laneValue) then
      lane := IntToStr(laneValue)
    else
      lane := '0'; // or some default value

    rt := TimeOf(DTData.qryINDV.FieldByName('RaceTime').AsDateTime);
    msec := TimeToMilliseconds(rt) / 1000.00;
    case adtFileType of
      dtUnknown: ;
      dtDO3: ;
      dtDO4: lane := 'Lane' + lane;
    end;

    if msec <> 0.0 then
      s := lane + ';' + Format('%0.3f', [msec]) + ';;'
    else
      s := lane + ';;;'; // or some default value

    sl.Add(s);
    DTData.qryINDV.next;
  end;
end;

procedure TestDataTEAM(sl: TStringList; adtFileType: dtFileType);
var
lanevalue: variant;
s, lane: string;
rt: TTime;
msec: double;
seed: integer;
begin
  if DTData.qryTEAM.IsEmpty then exit;
  seed := 1;
  DTData.qryTEAM.first;
  while not DTData.qryTEAM.eof do
  begin
    // lane data
    laneValue := DTData.qryTEAM.FieldByName('Lane').AsVariant;
    if not VarIsNull(laneValue) then
      lane := IntToStr(laneValue)
    else
      lane := IntToStr(seed);

    rt := TimeOf(DTData.qryTEAM.FieldByName('RaceTime').AsDateTime);
    msec := TimeToMilliseconds(rt) / 1000.00;
    case adtFileType of
      dtUnknown: ;
      dtDO3: ;
      dtDO4: lane := 'Lane' + lane;
    end;

    if msec <> 0.0 then
      s := lane + ';' + Format('%8.3f', [msec]) + ';;'
    else
      s := lane + ';0.000;;'; // or some default value

    sl.Add(s);
    inc(seed);
    DTData.qryTEAM.next;
  end;
end;

procedure ReConstructHeat(SessionID, eventNum: integer; gender: string;
   aEventType: scmEventType; sl: TStringList; adtFileType: dtFileType);
var
  HeatNum: integer;
  s, fn, id, sess, ev, ht: string;
  success: boolean;
begin
  if DTData.qryHeat.IsEmpty then exit;
  if adtFileType = dtUnknown then exit;

  // Assert the state of the local param 'seed' (int) ...
  if (seed > 999) or (seed = 0) then seed := 1;
  DTData.qryHeat.first;
  while not DTData.qryHeat.eof do
  begin
    sl.Clear; // ensures - only one heat per file.
    HeatNum := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    // first line - header.
    s := IntTostr(SessionID) + ';' + IntTostr(EventNum) + ';' + IntTostr(HeatNum) + ';' + gender;
    sl.Add(s);
    // body - lanes and timekeepers times.
    if aEventType = etINDV then
      TestDataINDV(sl, adtFileType)
    else if aEventType = etTEAM then
      TestDataTEAM(sl, adtFileType);
    // last line - footer. - checksum
    s := UpperCase(GetStringListChecksum(sl, 16));
    // ALT METHOD : THashSHA2.GetHashString(sl.Text, SHA256);
    sl.Add(s);
    if not sl.IsEmpty then
    begin
      success := true;
      // C o n s t r u c t   f i l e n a m e .
      // NOTE: GENDER >> A=boys, B=girls, X=mixed.
      // pad numbers with leading zeros.
      ht := Get3Digits(HeatNum);
      ev := Get3Digits(EventNum);
      sess := Get3Digits(SessionID);
      case adtFileType of
        dtUnknown:
          fn := '';
        dtDO3:
          begin
          id := CreateHash(SessionID, EventNum, HeatNum);
          fn := sess + '-' + ev + '-' + id + '.DO3';
          end;
        dtDO4:
        begin
          id := Get4Digits(seed);
          fn := sess + '-' + ev + '-' + ht + gender + '-' + id + '.DO4';
        end;
      end;
      fn := IncludeTrailingPathDelimiter(Settings.DolphinReConstruct) + fn;
      // trap for exception error.
      if fileExists(fn) then
        success := DeleteFile(fn);
      if success then
      begin
        sl.SaveToFile(fn);
        inc(seed); // calculate next seed number.
        if seed > 9999 then seed := 1; // check - out of bounds.
      end;
    end;
    DTData.qryHeat.Next
  end;
end;

procedure ReConstructEvent(SessionID: integer; sl: TStringList; adtFileType: dtFileType);
var
i, EventNum: integer;
gender: string;
aEventType: scmEventType;
begin
  if DTData.qryEvent.IsEmpty then exit;
  DTData.qryEvent.first;
  while not DTData.qryEvent.eof do
  begin
    EventNum := DTData.qryEvent.FieldByName('EventNum').AsInteger;
    i := DTData.qryEvent.FieldByName('EventID').AsInteger;
    // NOTE: scmEventType >> etUnknown, etINDV, etTEAM.
    aEventType := GetEventType(i);
    // NOTE: GENDER >> A=boys, B=girls, X=mixed.
    gender := GetGenderTypeStr(i);
    // R e - c o n s t r u c t   D O 4 .
    ReConstructHeat(SessionID, EventNum, gender, aEventType, sl, adtFileType);
    DTData.qryEvent.next;
  end;
end;

procedure ReConstructDO4(SessionID: integer);
var
sl: TStringList;
begin
  // Core DTData tables are Master-Detail schema.
  // qrySession is cued, ready to process.
  seed := 1;
  sl := TStringList.Create;
  ReConstructEvent(SessionID, sl, dtDO4);
  sl.Free;
end;

procedure ReConstructDO3(SessionID: integer);
var
sl: TStringList;
begin
  // Core DTData tables are Master-Detail schema.
  // qrySession is cued, ready to process.
  seed := 1;
  sl := TStringList.Create;
  ReConstructEvent(SessionID, sl, dtDO3);
  sl.Free;
end;



end.
