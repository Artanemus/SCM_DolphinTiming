unit tdResultsCTS;

interface

uses XSuperJSON, XSuperObject, dmTDS, System.Types, System.StrUtils,
	uAppUtils, SCMDefines, frmMain, System.Classes, tdResultsCTSFile;

type



	TResultsCTS = record
	private
		fSList: TStringList; // Header, Body(multi-line ... lanes) and Footer.
		fNameOfFile: string;

		procedure ProcFile(AFileName: string); // prepares record ... CTSFile
		procedure ProcSess(var CTSFile: TCTSFile);
		procedure ProcEvent(ASessionID: integer;  var CTSFile: TCTSFile);
		procedure ProcHeat(AEventID: integer; var CTSFile: TCTSFile);
		procedure ProcLane(AHeatID: integer; var CTSFile: TCTSFile);
		procedure ProcINDV(AHeatID: integer; var CTSFile: TCTSFile);
//		procedure ProcTEAM(AList: TStringDynArray; AHeatID: integer);

	public
		procedure ProcessFile(const AFileName: string);

		class operator Initialize(out Dest:	TResultsCTS);
		class operator Finalize(var Dest: TResultsCTS) ;

	end;


	// Main Process entry points


implementation

uses
	SysUtils, System.JSON, System.IOUtils, Windows,
	Vcl.Dialogs, DateUtils, uWatchTime;


class operator TResultsCTS.Finalize(var Dest: TResultsCTS);
begin
	FreeAndNil(Dest.fSList);
end;

class operator TResultsCTS.Initialize(out Dest: TResultsCTS);
begin
	Dest.fSList := TStringList.Create;
end;


procedure TResultsCTS.ProcessFile(const AFileName: string);
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
				ProcFile(AFileName);
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


procedure TResultsCTS.ProcEvent(ASessionID: integer; var CTSFile: TCTSFile);
var
  PK: integer;
  str: string;
begin
  TDS.tblmEvent.ApplyMaster; // Redundant?
  // Calc a primary key.
  PK := 0;
  // ignore if found...
  if not TDS.LocateTEventNum(ASessionID, CTSFile.EventNum) then
  begin
    try
      begin
        PK := TDS.MaxID_Event + 1;
        // create new event
        TDS.tblmEvent.Insert;
        TDS.tblmEvent.FieldByName('EventNum').AsInteger := CTSFile.EventNum;
        // Calculate the Primary Key : IDENTIFIER.
        // ID isn't AutoInc. the primary key is calculated manually.
        TDS.tblmEvent.fieldbyName('EventID').AsInteger := PK;
        // master - detail. Also Index Field.
        TDS.tblmEvent.fieldbyName('SessionID').AsInteger := ASessionID;
        // CAPTION for Event :
        str := 'Event: ' + IntToStr(CTSFile.EventNum);
        TDS.tblmEvent.fieldbyName('Caption').AsString := str;
        TDS.tblmEvent.Post;
      end;
    except on E: Exception do
      begin
        TDS.tblmSession.Cancel;
        PK := 0;
      end;
    end;
	end;

	if PK <>  0 then
		ProcHeat(PK, CTSFile);

end;

procedure TResultsCTS.ProcHeat(AEventID: integer; var CTSFile: TCTSFile);
var
PK: integer;
found: boolean;
begin
	PK := TDS.MaxID_Heat() + 1;
	TDS.tblmHeat.ApplyMaster; // Redundant?
	found := TDS.LocateTHeatNum(AEventID, CTSFile.HeatNum);
	// Create a new heat in TDS.tblmHeat.
	if not found then
	begin
		try
			begin
				TDS.tblmHeat.Insert;
				TDS.tblmHeat.FieldByName('HeatNum').AsInteger := CTSFile.HeatNum;
				// calculate the IDENTIFIER.
				// ID isn't AutoInc - calc manually.
				TDS.tblmHeat.fieldbyName('HeatID').AsInteger := PK;
				// master - detail.
				TDS.tblmHeat.fieldbyName('EventID').AsInteger := AEventID;
				TDS.tblmHeat.fieldbyName('Caption').AsString := 'Heat: ' + IntToStr(CTSFile.HeatNum);
				// A unique sequential number for each heat.
				TDS.tblmHeat.fieldbyName('RaceNum').AsInteger:= CTSFile.RaceNum;
				// TimeStamp of TimeDrops Results file. - code - could be better.
				TDS.tblmHeat.fieldbyName('CreatedOn').AsDateTime := Now;
				TDS.tblmHeat.Post;
				found := true;
			end;
		except on E: Exception do
			begin
				TDS.tblmHeat.Cancel;
				found := false;
			end;
		end;
	end;

	if found then
		ProcLane(PK, CTSFile);

end;

procedure TResultsCTS.ProcINDV(AHeatID: integer; var CTSFile: TCTSFile);
begin

end;

procedure TResultsCTS.ProcLane(AHeatID: integer; var CTSFile: TCTSFile);
begin

end;

procedure TResultsCTS.ProcSess(var CTSFile: TCTSFile);
var
	maxID, PK: integer;
	fs: TFormatSettings;
	str: string;
	fCreationDT: TDateTime;
begin
	maxID := TDS.MaxID_Session;
	fCreationDT := Now;
	PK := 0;
	TDS.tblmSession.ApplyMaster;
	// ignore if found...
	if not TDS.LocateTSessionNum(CTSFile.SessionNum) then
	begin
		try
			begin
				PK := maxID + 1;
				// add the newly discovered session
				TDS.tblmSession.Insert;
				// Currently not used. May help to track an approx session time.
				TDS.tblmSession.FieldByName('createdOn').AsDateTime := fCreationDT;
				// Primary Key.
				TDS.tblmSession.FieldByName('sessionId').AsInteger := PK;
				// Session Number.
				TDS.tblmSession.FieldByName('sessionNum').AsInteger := CTSFile.SessionNum;
				// Create a basic session caption.
				fs := TFormatSettings.Create;
				fs.DateSeparator := '_';
				fs.ShortDateFormat := 'yyyy-mm-dd';
				str := 'Session: ' + IntToStr(CTSFile.SessionNum) + ' Date: ' +
				DatetoStr(fCreationDT, fs);
				TDS.tblmSession.fieldbyName('Caption').AsString := str;
				TDS.tblmSession.Post;
			end;
		except on E: Exception do
			begin
				TDS.tblmSession.Cancel;
				PK := 0;
			end;
		end;
  end;

	if PK <>  0 then
		ProcEvent(PK, CTSFile);
end;

procedure TResultsCTS.ProcFile(AFileName: string);
var
		CTSFile: TCTSFile;
begin
	CTSFile.Prepare(AFileName);
	if CTSFile.Prepared then
	begin
		if CTSFile.SessionNum <> 0 then
				ProcSess(CTSFile);
	end;
end;




end.
