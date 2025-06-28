unit tdResultsCTSFile;

interface

uses System.Types, System.StrUtils,	uAppUtils, SCMDefines, System.Classes,
dmTDS;


type
  TCTSFile = record
  private
		fSessionNum, fEventNum, fHeatNum, fRaceNum: integer;
    fHash: string;
    fRound: char;
    fFileType: scmDTFileType;
    fFileName: string; // full path and NameOFIle:
    fNameOfFile: string; // name + file extension.
    fSList: TStringList;
		fPrepared: boolean;

		function ConvertSecondsStrToTime(ASecondsStr: string): TTime;

		function GetSessionNum(): integer;
    function GetEventNum(): integer;
    function GetHeatNum(): integer;
    function GetRaceNum(): integer;
    function GetHash(): string;
    function GetRound(): char;
		function GetFileType(): scmDTFileType;

		function sListHeaderEventNum: integer;
		function sListHeaderGenderChar(): char;
		function sListHeaderHeatNum(): integer;
		function sListFooterHashStr(): string;
		function sListHeaderSessionNum(): integer;
		function sListBodySplits(LineIndex: integer; var ASplits: array of double): boolean;
    function sListBodyLane(LineIndex: integer): integer;
    function sListBodyTimeKeepers(LineIndex: integer;
      var ATimeKeepers: array of double): boolean;

  public
		class operator Initialize(out Dest: TCTSFile);
		class operator Finalize(var Dest: TCTSFile);

		procedure Prepare(AFileName: string);

		property FileType: scmDTFileType read GetFileType;
		property SessionNum: integer read FSessionNum;
		property EventNum: integer read FEventNum;
		property HeatNum: integer read FHeatNum;
		property RaceNum: integer read fRaceNum;

		property Prepared: boolean read fPrepared;

	end;



implementation

uses
	SysUtils, System.JSON, System.IOUtils, Windows,
	Vcl.Dialogs, DateUtils, uWatchTime;


{ TCTSFile }

class operator TCTSFile.Initialize(out Dest: TCTSFile);
begin
	Dest.fSList := TStringList.Create(true); // owns objects.
	Dest.fPrepared := false;
	Dest.fFileName := '';
	Dest.fNameOfFile := '';
end;

function TCTSFile.ConvertSecondsStrToTime(ASecondsStr: string): TTime;
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

class operator TCTSFile.Finalize(var Dest: TCTSFile);
begin
	FreeAndNil(Dest.fSList);
end;

function TCTSFile.GetEventNum: integer;
var
  Fields: TArray<string>;
begin
  result := 0;
	if fNameOfFile.IsEmpty then exit;
  // Split string by the '-' character
  // example of fFileName
  // - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
	Fields := SplitString(fNameOfFile, '-');
	if Length(Fields) > 1 then
    // Extract the first field - SessionID
    result := StrToIntDef(Fields[1], 0);
end;

function TCTSFile.GetFileType(): scmDTFileType;
begin
	result := scmDTFileType.ftUnknown;
	if fFileName.IsEmpty then exit;
	if fFileName.Contains('.DO3') then
		result := ftDO3
	else if fFileName.Contains('.DO4') then
		result := ftDO4;
end;

function TCTSFile.GetHash: string;
var
  HashStr: string;
  Fields: TArray<string>;
begin
	result := '';
  HashStr := '';
	if fNameOfFile.IsEmpty then exit;
  // Split string by the '-' character
	// example of fNameOfFile
	// - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
	Fields := SplitString(fNameOfFile, '-');
  case fFileType of
    scmDTFileType.ftUnknown: ;
    ftDO4:
      begin
        if Length(Fields) > 3 then
        begin
					// The fourthfield has a '.' delimiter for the string and the '.do4' part
          HashStr := Copy(Fields[3], 1, Pos('.', Fields[3]) - 1);
        end;
      end;
    ftDO3:
      begin
        if Length(Fields) > 2 then
        begin
          // The third field has a '.' delimiter for the string and the '.do3' part
          HashStr := Copy(Fields[2], 1, Pos('.', Fields[2]) - 1);
        end;
			end;
	end;
  if Length(HashStr) > 0 then
    // only 8 character permitted.
    result := Copy(HashStr, 1, 8);
end;

function TCTSFile.GetHeatNum: integer;
var
	Fields: TArray<string>;
	HeatNumStr: string;
begin
  result := 0;
	if fNameOfFile.IsEmpty then exit;
  // only Dolphin Timing v4 Files have 'Heat Number' information in FileName.
  if (fFileType <> ftDO4) then exit;
  // example of fNameOfFile
  // - 088-001-001A-0001.do4
  // - 088-000-00F0147.do3
  // Split string by the '-' character
	Fields := SplitString(fNameOfFile, '-');
  if Length(Fields) > 2 then
  begin
    // remove the 'Round' character ['A', 'P', 'F'].
    HeatNumStr := StripAlphaChars(Fields[2]);
		// Extract the first field - SessionID
    result := StrToIntDef(HeatNumStr, 0);
	end;
end;

function TCTSFile.GetRaceNum: integer;
var
  RaceStr: string;
  Fields: TArray<string>;
begin
	result := 0;
	RaceStr := '';
	if fNameOfFile.IsEmpty then exit;
  if (fFileType <> ftDO4) then exit;
  // Split string by the '-' character
  // example of fNameOfFile
	// - 088-001-001A-0001.do4
	Fields := SplitString(fNameOfFile, '-');
  if Length(Fields) > 3 then
  begin
    // The fourthfield has a '.' delimiter for the string and the '.do4' part
    RaceStr := Copy(Fields[3], 1, Pos('.', Fields[3]) - 1);
    if Length(RaceStr) > 0 then
			// only 8 character permitted.
      result := StrToIntDef(RaceStr, 0);
  end;
end;

function TCTSFile.GetRound: char;
var
  RoundChar: char;
  Fields: TArray<string>;
begin
	result := 'A'; // Safe to assign: DEFAULT.
	if fNameOfFile.IsEmpty then exit;
	// only Dolphin Timing v4 Files have 'Heat Number' information in FileName.
  if (fFileType <> ftDO4) then exit;
	// Split string by the '-' character
  // example of fNameOfFile - 088-001-001A-0001.do4
  // The letter A in the above example, indicates the 'Round Type'
  // Round – “A” for all, “P” for prelim or “F” for final.
	Fields := SplitString(fNameOfFile, '-');
  if Length(Fields) > 2 then // Correct condition
  begin
		RoundChar := Fields[2][Length(Fields[2])]; // Get the last character of Fields[2]
    // Convert to uppercase before checking
    RoundChar := UpCase(RoundChar);
    // Round – “A” for all, “P” for prelim or “F” for final.
    if CharInSet(RoundChar, ['A', 'P', 'F']) then
			result := RoundChar;
  end;
end;

function TCTSFile.GetSessionNum: integer;
var
  Fields: TArray<string>;
begin
  result := 0;
	if fNameOfFile.IsEmpty() then exit;
  // Split string by the '-' character
	Fields := SplitString(fNameOfFile, '-');
  if Length(Fields) > 0 then
    // Extract the first field - SessionID
    result := StrToIntDef(Fields[0], 0);
end;

procedure TCTSFile.Prepare(AFileName: string);
var
	Fields: TArray<string>;
begin
	// AFileName has path and name of file.
	fSessionNum := 0;
	fEventNum := 0;
	fHeatNum := 0;
	fRaceNum := 0;
	fPrepared := false;
	fNameOfFile := ExtractFileName(AFileName);
	fFileType := GetFileType();

	case fFileType of
		ftUnknown:
			exit;
		ftDO3: // use the file header for heat data eg. 088-000-00F0147.do3
			begin
				Fields := SplitString(AFileName, '-');
				if Length(Fields) > 1 then
				begin
					// Strip non-numeric characters from Fields[1]
					Fields[0] := StripNonNumeric(Fields[0]);
					fSessionNum := StrToIntDef(Fields[0], 0);
					if (fSessionNum <> 0) then
					begin
						if Length(Fields) > 2 then
							fEventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
					end;
					// DO3 type has no racenum.
					fRaceNum := -1;
				end;
			end;
		ftDO4: // all fields found in filename. eg. 113-001-001A-0001.DO4
			begin
				Fields := SplitString(AFileName, '-');
				if Length(Fields) > 1 then
				begin
					// Strip non-numeric characters from Fields[1]
					Fields[0] := StripNonNumeric(Fields[0]);
					fSessionNum := StrToIntDef(Fields[0], 0);
					if (fSessionNum <> 0) then
					begin
						if Length(Fields) > 2 then
							fEventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
						if Length(Fields) > 3 then
							fHeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
						if Length(Fields) > 4 then
							fRaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);
					end;
				end;
			end;
	end;

	if not Assigned(fSList) then
	begin
		// unexpected error throw exception
		{TODO -oBSA -cGeneral : Throw exception error}
		exit;
	end;

	fSList.Clear;
	if FileExists(AFileName) then
		fSList.LoadFromFile(AFilename); // open the file and extract a list of strings.

	// Use line1 data (Header info) to extract final fields.
	case fFileType of
		ftUnknown:
			exit;
		ftDO3:
		begin
			if fSessionNum = 0 then fSessionNum := sListHeaderSessionNum;
			if fEventNum = 0 then fEventNum := sListHeaderEventNum;
			fHeatNum := sListHeaderHeatNum;
		end;
		ftDO4:
		begin
			if fSessionNum = 0 then	fSessionNum := sListHeaderSessionNum;
			if fEventNum = 0 then fEventNum := sListHeaderEventNum;
			if fHeatNum = 0 then fHeatNum := sListHeaderHeatNum;
		end;
	end;

	fPrepared := true;
end;



function TCTSFile.sListHeaderEventNum: integer;
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

function TCTSFile.sListHeaderGenderChar(): char;
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

function TCTSFile.sListHeaderHeatNum(): integer;
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

function TCTSFile.sListFooterHashStr(): string;
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

function TCTSFile.sListHeaderSessionNum(): integer;
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

function TCTSFile.sListBodySplits(LineIndex: integer; var ASplits: array of double): boolean;
var
  Fields: TArray<string>;
  i, SplitIndex: Integer;
  s: string;
  Found: boolean;
  ATimeValue: TDateTime;
begin
  {
    Number of Splits – (1-10) Enter 1 to use the first time as the final time.
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
  if fFileType <> ftDO4 then
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

function TCTSFile.sListBodyLane(LineIndex: integer): integer;
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

function TCTSFile.sListBodyTimeKeepers(LineIndex: integer; var ATimeKeepers:
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
