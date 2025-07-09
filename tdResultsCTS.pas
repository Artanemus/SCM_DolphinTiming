unit tdResultsCTS;

interface

uses XSuperJSON, XSuperObject, dmTDS, System.Types, System.StrUtils,
	uAppUtils, SCMDefines, System.Classes, tdResultsCTSFile, System.UITypes;

type

	TResultsCTS = class(TObject)
	private
		fSList: TStringList; // Header, Body(multi-line ... lanes) and Footer.

		procedure ProcFile(AFileName: string); // prepares record ... CTSFile
		procedure ProcSess(var CTSFile: TCTSFile);
		procedure ProcEvent(ASessionID: integer;  var CTSFile: TCTSFile);
		procedure ProcHeat(AEventID: integer; var CTSFile: TCTSFile);
		procedure ProcLane(AHeatID: integer; var CTSFile: TCTSFile);

	public
		procedure ProcessFile(const AFileName: string);

    constructor Create();
    destructor Destroy; override;
	end;

	// Main Process entry points


implementation

uses
	SysUtils, System.JSON, System.IOUtils, Windows,
	Vcl.Dialogs, DateUtils, uWatchTime;


constructor TResultsCTS.Create;
begin
	fSList := TStringList.Create;
end;

destructor TResultsCTS.Destroy;
begin
	FreeAndNil(fSList);
	inherited;
end;

procedure TResultsCTS.ProcessFile(const AFileName: string);
begin
	if FileExists(AFileName) then
	begin
		// =====================================================
		// De-attach from Master-Detail. Create flat files.
		// Necessary to calculate table Primary keys.
		TDS.DisableAllTDControls;
		TDS.DisableTDMasterDetail;
		// =====================================================
		try
			ProcFile(AFileName);
		finally
			// =====================================================
			// Re-attach Master-Detail.
			TDS.EnableTDMasterDetail;
			TDS.EnableAllTDControls;
			// =====================================================
		end;
	end;
end;

{$HINTS OFF}  // remove Assignment of PK not used.
procedure TResultsCTS.ProcEvent(ASessionID: integer; var CTSFile: TCTSFile);
var
	PK: integer;
	str: string;
	found: boolean;
begin
	PK := 0;
	// TDS.tblmEvent.ApplyMaster; // Redundant?
	found := TDS.LocateTEventNum(ASessionID, CTSFile.EventNum);
	if Found then
		PK := TDS.tblmEvent.FieldByName('EventID').AsInteger
	else
	begin
		try
			begin
				PK := TDS.MaxID_Event + 1; // Calc a primary key.
				TDS.tblmEvent.Insert; // create new event
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
	if (PK <>  0) then ProcHeat(PK, CTSFile);
end;
{$HINTS ON}

procedure TResultsCTS.ProcHeat(AEventID: integer; var CTSFile: TCTSFile);
var
PK: integer;
found: boolean;
wt: TWatchTime;
begin
	PK := 0;
	//	TDS.tblmHeat.ApplyMaster; // Redundant?
	found := TDS.LocateTHeatNum(AEventID, CTSFile.HeatNum);
	if found then
		PK := TDS.tblmHeat.FieldByName('HeatID').AsInteger
	else
	begin // Create a new heat in TDS.tblmHeat.
		try
			begin
				PK := TDS.MaxID_Heat() + 1;
				TDS.tblmHeat.Insert;
				TDS.tblmHeat.FieldByName('HeatNum').AsInteger := CTSFile.HeatNum;
				// calculate the IDENTIFIER.
				// ID isn't AutoInc - calc manually.
				TDS.tblmHeat.fieldbyName('HeatID').AsInteger := PK;
				// master - detail.
				TDS.tblmHeat.fieldbyName('EventID').AsInteger := AEventID;
				// Timing system created results file on DateTime...
				TDS.tblmHeat.fieldbyName('startTime').AsDateTime := CTSFile.FileCreatedOn;
				// User UI - readable
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
	begin
		ProcLane(PK, CTSFile);
		// calculate race-time data for each lane in tblmLane.
		wt := TWatchTime.Create();
		wt.ProcessHeat(PK);
		wt.Free;
	end;

end;

procedure TResultsCTS.ProcLane(AHeatID: integer; var CTSFile: TCTSFile);
var
I, PK: integer;
lane: TCTSLane;
found: boolean;
begin

	for I := 1 to CTSFile.NumOflanes do
	begin
		// Routine handles zero based lane numbering - converts to base one.
		lane := CTSFile.Lane[I];
		if lane.LaneNum <> 0 then
		begin
			// TDS.tblmLane.ApplyMaster; // Redundant?
			// Find lane number within heat.
			found := TDS.LocateTLaneNum(AHeatID, lane.LaneNum);
			try
				begin
					if found then
						TDS.tblmLane.Edit
					else
					begin
						// Calculate a new unique primary key.
						PK := TDS.MaxID_Lane + 1;
						TDS.tblmLane.Insert;
						TDS.tblmLane.fieldbyName('LaneID').AsInteger := PK;
						TDS.tblmLane.FieldByName('HeatID').AsInteger := AHeatID; // master.detail.
						TDS.tblmLane.FieldByName('LaneNum').AsInteger := lane.LaneNum;
					end;

					TDS.tblmLane.fieldbyName('Caption').AsString := 'Lane: ' + IntToStr(lane.LaneNum);
					TDS.tblmLane.FieldByName('finalTime').Clear; // not used in CTS Dolphin
					TDS.tblmLane.FieldByName('padTime').Clear; // not used in CTS Dolphin

					if lane.TimeKeeper1 = 0 then
						TDS.tblmLane.FieldByName('time1').Clear
					else
						TDS.tblmLane.FieldByName('time1').AsDateTime := lane.TimeKeeper1;
					if lane.TimeKeeper2 = 0 then
						TDS.tblmLane.FieldByName('time2').Clear
					else
						TDS.tblmLane.FieldByName('time2').AsDateTime := lane.TimeKeeper2;
					if lane.TimeKeeper3 = 0 then
						TDS.tblmLane.FieldByName('time3').Clear
					else
						TDS.tblmLane.FieldByName('time3').AsDateTime := lane.TimeKeeper3;

					TDS.tblmLane.fieldbyName('LaneIsEmpty').AsBoolean := lane.IsEmpty;
					TDS.tblmLane.fieldbyName('isDq').AsBoolean := lane.IsDq;

					// Swimmers calculated racetime for post.
					TDS.tblmLane.fieldbyName('RaceTime').Clear;
					// A user entered race-time.
					TDS.tblmLane.fieldbyName('RaceTimeUser').Clear;
					// The Automatic race-time. Calculated on load of DT file.
					TDS.tblmLane.fieldbyName('RaceTimeA').Clear;
					// dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
					TDS.tblmLane.fieldbyName('ActiveRT').AsInteger := ORD(artAutoMatic);
					// graphic used in column[6] - GRID IMAGES TDS.vimglistDTCell .
					// image index 1 indicts - dtTimeKeeperMode = dtAutomatic.
					TDS.tblmLane.fieldbyName('imgActiveRT').AsInteger := -1;
					// graphic used in column[1] - for noodle drawing...
					TDS.tblmLane.fieldbyName('imgPatch').AsInteger := 0;

					// Init misc fields
					TDS.tblmLane.fieldbyName('TDev1').AsBoolean := true;
					TDS.tblmLane.fieldbyName('TDev2').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T1M').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T2M').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T3M').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T1A').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T2A').AsBoolean := true;
					TDS.tblmLane.fieldbyName('T3A').AsBoolean := true;

					// SPLITs 1 .. 10
					if Lane.Split1 = 0 then
						TDS.tblmLane.FieldByName('Split1').Clear
					else
						TDS.tblmLane.FieldByName('Split1').AsDateTime := Lane.Split1;
					TDS.tblmLane.FieldByName('SplitDist1').AsFloat := 0;

					if Lane.Split2 = 0 then
						TDS.tblmLane.FieldByName('Split2').Clear
					else
						TDS.tblmLane.FieldByName('Split2').AsDateTime := Lane.Split2;
					TDS.tblmLane.FieldByName('SplitDist2').AsFloat := 0;

					if Lane.Split3 = 0 then
						TDS.tblmLane.FieldByName('Split3').Clear
					else
						TDS.tblmLane.FieldByName('Split3').AsDateTime := Lane.Split3;
					TDS.tblmLane.FieldByName('SplitDist3').AsFloat := 0;

					if Lane.Split4 = 0 then
						TDS.tblmLane.FieldByName('Split4').Clear
					else
						TDS.tblmLane.FieldByName('Split4').AsDateTime := Lane.Split4;
					TDS.tblmLane.FieldByName('SplitDist4').AsFloat := 0;

					if Lane.Split5 = 0 then
						TDS.tblmLane.FieldByName('Split5').Clear
					else
						TDS.tblmLane.FieldByName('Split5').AsDateTime := Lane.Split5;
					TDS.tblmLane.FieldByName('SplitDist5').AsFloat := 0;

					if Lane.Split6 = 0 then
						TDS.tblmLane.FieldByName('Split6').Clear
					else
						TDS.tblmLane.FieldByName('Split6').AsDateTime := Lane.Split6;
					TDS.tblmLane.FieldByName('SplitDist6').AsFloat := 0;

					if Lane.Split7 = 0 then
						TDS.tblmLane.FieldByName('Split7').Clear
					else
						TDS.tblmLane.FieldByName('Split7').AsDateTime := Lane.Split7;
					TDS.tblmLane.FieldByName('SplitDist7').AsFloat := 0;

					if Lane.Split8 = 0 then
						TDS.tblmLane.FieldByName('Split8').Clear
					else
						TDS.tblmLane.FieldByName('Split8').AsDateTime := Lane.Split8;
					TDS.tblmLane.FieldByName('SplitDist8').AsFloat := 0;

					if Lane.Split9 = 0 then
						TDS.tblmLane.FieldByName('Split9').Clear
					else
						TDS.tblmLane.FieldByName('Split9').AsDateTime := Lane.Split9;
					TDS.tblmLane.FieldByName('SplitDist9').AsFloat := 0;

					if Lane.Split10 = 0 then
						TDS.tblmLane.FieldByName('Split10').Clear
					else
						TDS.tblmLane.FieldByName('Split10').AsDateTime := Lane.Split10;
					TDS.tblmLane.FieldByName('SplitDist10').AsFloat := 0;

					TDS.tblmLane.Post; // Post the inserted or edited record.
				end;

			except on E: Exception do
				begin
					TDS.tblmLane.Cancel;
				end;
			end;
		end;
	end;

end;

{$HINTS OFF}
procedure TResultsCTS.ProcSess(var CTSFile: TCTSFile);
var
	PK: integer;
	fs: TFormatSettings;
	str: string;
	fCreationDT: TDateTime;
	found: boolean;
begin
	fCreationDT := Now;
	PK := 0;
	//	TDS.tblmSession.ApplyMaster;  // REDUNDANT?
	found := TDS.LocateTSessionNum(CTSFile.SessionNum);
	if found  then
		PK := TDS.tblmSession.FieldByName('SessionID').AsInteger
	else // go create the new session.
	begin
		try
			begin
				PK := TDS.MaxID_Session + 1;
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

	if (PK <> 0) then ProcEvent(PK, CTSFile);
end;
{$HINTS ON}

procedure TResultsCTS.ProcFile(AFileName: string);
var
	CTSFile: TCTSFile; // type record.
	s: string;
begin
	// Performs eccential tasks including, calculates the number of lanes.
	CTSFile.Prepare(AFileName);
	if CTSFile.Prepared then
	begin
		if CTSFile.SessionNum <> 0 then
			ProcSess(CTSFile)
		else
		begin
			s := '''
				%s cannot be processed as the given session number is zero.
				Events, heats or lames can be numbered zero, but not sessions.
				Rename your results file and try again.
				''';
			s := Format(s, [AFileName]);
			MessageDlg(s, mtError, [mbOK], 0);
		end;
	end;
end;




end.
