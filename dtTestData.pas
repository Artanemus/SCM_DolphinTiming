unit dtTestData;

interface

uses dmSCM, dmDTData, System.SysUtils, System.Classes, system.Hash,
DateUtils, variants, SCMDefines, Data.DB;

procedure BuildTestDataDO3();
procedure TestDataSess(SessionID: integer);
procedure TestDataEv(sess: string; sl: TStringList);
procedure TestDataHt(sess, ev: string; aEventType: scmEventType; var ht: string; sl: TStringList);
procedure TestDataINDV(sl: TStringList);
procedure TestDataTEAM(sl: TStringList);

const
MYPATH = 'C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\TESTDATA\';


implementation


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
  Result := IntToHex(combinedValue, 7);
end;

procedure BuildTestDataDO3();
var
sess, ev, ht, fn, hash: string;
i, j, k: integer;
begin
  DTData.qrySession.first;
  while not DTData.qrySession.eof do
  begin
    i := DTData.qrySession.FieldByName('SessionId').AsInteger;
    sess := Get3Digits(i);
    j := DTData.qryEvent.FieldByName('EventNum').AsInteger;
    ev := Get3Digits(j);
    k := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    ht := Get3Digits(k);
    hash := CreateHash(i, j, k);
    fn := sess + '-' + ev + '-' + hash + '.DO3';
    fn := MYPATH + fn;
    DTData.qrySession.next;
  end;
end;

procedure BuildTestDataDO4();
var
sess, ev, ht, fn, id, s, lane: string;
i, j, k, seed: integer;
sl: TStringList;
rt: TTime;
msec: double;
lanevalue: variant;
begin
  seed := 1;
  sl := TStringList.Create;
  DTData.qrySession.first;
  while not DTData.qrySession.eof do
  begin
    i := DTData.qrySession.FieldByName('SessionId').AsInteger;
    sess := Get3Digits(i);
    DTData.qryEvent.first;
    while not DTData.qryEvent.eof do
    begin
      j := DTData.qryEvent.FieldByName('EventNum').AsInteger;
      ev := Get3Digits(j);
      DTData.qryHeat.first;
      while not DTData.qryHeat.eof do
      begin
        sl.Clear;
        k := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
        ht := Get3Digits(k);
        id := Get4Digits(seed);
        // A=boys, B=girls, X=mixed.
        fn := sess + '-' + ev + '-' + ht + 'X-' + id + '.DO4';
        inc(seed);
        // populate sl with lane details....
        // header
        s := sess + ';' + ev + ';' + ht + ';X';
        sl.Add(s);
        // lanes
        DTData.qryINDV.first;
        while not DTData.qryINDV.eof do
        begin
          // lane data
          laneValue := DTData.qryINDV.FieldByName('LaneNum').Value;
          if not VarIsNull(laneValue) then
            lane := IntToStr(laneValue)
          else
            lane := '0'; // or some default value

          rt := TimeOf(DTData.qryINDV.FieldByName('RaceTime').AsDateTime);
          msec := TimeToMilliseconds(rt) / 1000.00;

          if msec <> 0.0 then
            s := 'Lane' + lane + ';' + Format('%8.3f', [msec]) + ';;'
          else
            s := 'Lane' + lane + ';0.000;;'; // or some default value

          sl.Add(s);
          DTData.qryINDV.next;
        end;
        // checksum
        s := THashSHA2.GetHashString(sl.Text, SHA256);
        sl.Add(s);
        sl.SaveToFile(fn);
        DTData.qryHeat.next;
      end;
      DTData.qryEvent.next;
    end;
    DTData.qrySession.next;
  end;
  sl.Free;
end;

procedure TestDataSess(SessionID: integer);
var
sess: string;
sl: TStringList;
begin
  DTData.qrySession.Filter := 'SessionID = ' + inttostr(SessionID);
  if not DTData.qrySession.Filtered then
    DTData.qrySession.Filtered := true;
  sl := TStringList.Create;
  if DTData.qrySession.RecordCount = 1 then
  begin
    sess := Get3Digits(SessionID);
    TestDataEv(sess, sl);
  end;
  sl.Free;
  DTData.qrySession.Filtered := false;
  DTData.qrySession.first;
end;

procedure TestDataEv(sess: string; sl: TStringList);
var
i, seed: integer;
ev, ht, id, fn: string;
aEventType: scmEventType;
success: boolean;
begin
  seed := 1;

  if DTData.qryEvent.IsEmpty then exit;

  DTData.qryEvent.first;
  while not DTData.qryEvent.eof do
  begin
    i := DTData.qryEvent.FieldByName('EventNum').AsInteger;
    ev := Get3Digits(i);
    i := DTData.qryEvent.FieldByName('EventID').AsInteger;
    aEventType := GetEventType(i);
    sl.Clear;
    id := Get4Digits(seed);
    // populate the stringlist with text lines (data).
    TestDataHt(sess, ev, aEventType, ht, sl);
    // A=boys, B=girls, X=mixed.
    fn := sess + '-' + ev + '-' + ht + 'X-' + id + '.DO4';
    fn := MYPATH + fn;
    if not sl.IsEmpty then
    begin
      success := true;
      if fileExists(fn) then
        success := DeleteFile(fn);
      if success then
        sl.SaveToFile(fn);
    end;
    inc(seed);
    DTData.qryEvent.next;
  end;
end;

procedure TestDataHt(sess, ev: string; aEventType: scmEventType; var ht: string; sl: TStringList);
var
  i: integer;
  s: string;
begin

  if DTData.qryHeat.IsEmpty then exit;

  DTData.qryHeat.first;
  while not DTData.qryHeat.eof do
  begin
    i := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    ht := Get3Digits(i);
    // first line - header.
    s := sess + ';' + ev + ';' + ht + ';X';
    sl.Add(s);
    // body - lanes and timekeepers times.
    if aEventType = etINDV then
      TestDataINDV(sl)
    else if aEventType = etTEAM then
      TestDataTEAM(sl);
    // last line - footer. - checksum
    s := GetStringListChecksum(sl, 8);
//    s := THashSHA2.GetHashString(sl.Text, SHA256);
    sl.Add(s);
    DTData.qryHeat.Next
  end;
end;


procedure TestDataINDV(sl: TStringList);
var
lanevalue: integer;
s, lane: string;
rt: TTime;
msec: double;
begin
  if DTData.qryINDV.IsEmpty then exit;

  DTData.qryINDV.first;
  while not DTData.qryINDV.eof do
  begin
    // lane data
    laneValue := DTData.qryINDV.FieldByName('Lane').Value;
    if not VarIsNull(laneValue) then
      lane := IntToStr(laneValue)
    else
      lane := '0'; // or some default value

    rt := TimeOf(DTData.qryINDV.FieldByName('RaceTime').AsDateTime);
    msec := TimeToMilliseconds(rt) / 1000.00;

    if msec <> 0.0 then
      s := 'Lane' + lane + ';' + Format('%8.3f', [msec]) + ';;'
    else
      s := 'Lane' + lane + ';;;'; // or some default value

    sl.Add(s);
    DTData.qryINDV.next;
  end;
end;

procedure TestDataTEAM(sl: TStringList);
var
lanevalue: integer;
s, lane: string;
rt: TTime;
msec: double;
begin
  if DTData.qryTEAM.IsEmpty then exit;

  DTData.qryTEAM.first;
  while not DTData.qryTEAM.eof do
  begin
    // lane data
    laneValue := DTData.qryTEAM.FieldByName('Lane').Value;
    if not VarIsNull(laneValue) then
      lane := IntToStr(laneValue)
    else
      lane := '0'; // or some default value

    rt := TimeOf(DTData.qryTEAM.FieldByName('RaceTime').AsDateTime);
    msec := TimeToMilliseconds(rt) / 1000.00;

    if msec <> 0.0 then
      s := 'Lane' + lane + ';' + Format('%8.3f', [msec]) + ';;'
    else
      s := 'Lane' + lane + ';0.000;;'; // or some default value

    sl.Add(s);
    DTData.qryTEAM.next;
  end;
end;

end.
