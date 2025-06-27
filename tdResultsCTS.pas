unit tdResultsCTS;

interface

uses XSuperJSON, XSuperObject, dmTDS, System.Types, System.StrUtils,
	uAppUtils, SCMDefines, frmMain, System.Classes;

type

  TMainHelper = class helper for TMain
	private
		procedure ProcessSession(AList: TStringDynArray; ASessionID: integer);
		procedure ProcSession(AFileName: string; AFileType: scmDTFileType);
		procedure ProcEvent(AList: TStringDynArray; ASessionID: integer);
		procedure ProcHeat(AList: TStringDynArray; AEventID: integer);
		procedure ProcLane(AList: TStringDynArray; AHeatID: integer);
		procedure ProcINDV(AList: TStringDynArray; AHeatID: integer);
		procedure ProcTEAM(AList: TStringDynArray; AHeatID: integer);

	public
		procedure ProcessDirectory(const ADirectory: string);
		procedure ProcessFile(const AFileName: string);
	end;


	// Main Process entry points


implementation

uses
	SysUtils, System.JSON, System.IOUtils, Windows,
	Vcl.Dialogs, DateUtils, uWatchTime;


function GetFileTypeCTS(const AFileName: string): scmDTFileType;
begin
  result := scmDTFileType.ftUnknown;
	if AfileName.Contains('.DO3') then
		result := ftDO3
	else if AfileName.Contains('.DO4') then
		result := ftDO4;
end;



procedure TMainHelper.ProcessDirectory(const ADirectory: string);
begin
	// do something;
end;


procedure TMainHelper.ProcessFile(const AFileName: string);
var
	SessionID, RaceNum: integer;
	//, EventNum, HeatNum: integer;
	Fields: TArray<string>;
	fn: string;
	ft: scmDTFileType;
begin
	RaceNum := 0;
	if FileExists(AFileName) then
	begin
		TDS.DisableAllTDControls;
		// =====================================================
		// De-attach from Master-Detail. Create flat files.
		// Necessary to calculate table Primary keys.
		TDS.DisableTDMasterDetail;
		// =====================================================
		try
			begin
				// remove path from filename
				fn := ExtractFileName(AFileName);
				ft := GetFileTypeCTS(fn);
				ProcSession(AFileName, ft);

			end;
		finally
			// =====================================================
				 // Re-attach Master-Detail.
			TDS.EnableTDMasterDetail;
			TDS.EnableAllTDControls;
			// =====================================================

		end;
	end;
end;

procedure TMainHelper.ProcessSession(AList: TStringDynArray; ASessionID: integer);
var
	I: integer;
	Fields: TArray<string>;
begin
	// iterate over the filenames.
	for I := 0 to Length(AList) - 1 do
	begin
		// test filename matches sessionID
		Fields := SplitString(AList[I], '_');
		if Length(Fields) > 1 then
		begin
			if Fields[0].Contains(IntToStr(ASessionID)) then
			begin
				ProcessFile(AList[I]);
			end;
		end;
	end;
end;


procedure TMainHelper.ProcEvent(AList: TStringDynArray; ASessionID: integer);
begin

end;

procedure TMainHelper.ProcHeat(AList: TStringDynArray; AEventID: integer);
begin

end;

procedure TMainHelper.ProcINDV(AList: TStringDynArray; AHeatID: integer);
begin

end;

procedure TMainHelper.ProcLane(AList: TStringDynArray; AHeatID: integer);
begin

end;

procedure TMainHelper.ProcSession(AFileName: string; AFileType: scmDTFileType);
var
	Fields: TArray<string>;
begin
	case AFileType of
		ftUnknown:
			exit;
		ftDO3: // use the file header for heat data eg. 088-000-00F0147.do3
			begin
				Fields := SplitString(AFileName, '-');
				if Length(Fields) > 1 then
				begin
					// Strip non-numeric characters from Fields[1]
					Fields[0] := StripNonNumeric(Fields[0]);
					SessionID := StrToIntDef(Fields[0], 0);
					if (SessionID <> 0) then
					begin
						RaceNum := -1;

						// GO read file data...

					end;
				end;
			end;
		ftDO4: // all fields found in filename. eg. 113-001-001A-0001.DO4
			begin
				Fields := SplitString(AFileName, '-');
				if Length(Fields) > 1 then
				begin
					// Strip non-numeric characters from Fields[1]
					Fields[0] := StripNonNumeric(Fields[0]);
					SessionID := StrToIntDef(Fields[0], 0);
					if (SessionID <> 0) then
					begin
//									if Length(Fields) > 2 then
//										EventNum := StrToIntDef(StripNonNumeric(Fields[1]), 0);
//									if Length(Fields) > 3 then
//										HeatNum := StrToIntDef(StripNonNumeric(Fields[2]), 0);
						if Length(Fields) > 4 then
							RaceNum := StrToIntDef(StripNonNumeric(Fields[3]), 0);

						// GO read file data...

					end;
				end;
			end;
	end;

end;

procedure TMainHelper.ProcTEAM(AList: TStringDynArray; AHeatID: integer);
begin

end;

end.
