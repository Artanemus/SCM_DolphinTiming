unit dmDTData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, dmSCM,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, SCMDefines, Windows, Winapi.Messages, vcl.Forms,
  FireDAC.Phys.SQLiteVDataSet, Datasnap.DBClient, FireDAC.Stan.StorageXML,
  FireDAC.Stan.StorageBin, FireDAC.Stan.Storage, Datasnap.Provider,
  SVGIconImageCollection;

type
  dtFileType = (dtUnknown, dtDO4, dtDO3, dtALL);
  // 5 x modes m-enabled, m-disabled, a-enabled, a-disabled, unknown (err or nil).
  //  dtTimeModeErr = (tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty);
  dtPrecedence = (dtPrecHeader, dtPrecFileName);
  dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);

type

  TDTData = class(TDataModule)
		dsDTLane: TDataSource;
		dsDTEvent: TDataSource;
		dsDTHeat: TDataSource;
		dsDTSession: TDataSource;
    tblDTLane: TFDMemTable;
		tblDTEvent: TFDMemTable;
		tblDTHeat: TFDMemTable;
		tblDTNoodle: TFDMemTable;
		tblDTSession: TFDMemTable;
    dsDTNoodle: TDataSource;
		procedure DataModuleCreate(Sender: TObject);
		procedure DataModuleDestroy(Sender: TObject);
		procedure tblDTHeatAfterScroll(DataSet: TDataSet);
	private
		FConnection: TFDConnection;
		fDTDataIsActive: Boolean;
		fDTMasterDetailActive: Boolean;
		FPatchesEnabled: Boolean;  // TODO: check it's in use.
		msgHandle: HWND;  // TForm.dtfrmExec ...
	public
		procedure ActivateDataDT();
		procedure BuildDTData;
		procedure CalcRaceTimeM(ADataSet: TDataSet);
		procedure DisableDTMasterDetail();
		procedure EnableDTMasterDetail();
		function LocateDTEventID(AEventID: integer): boolean;
		function LocateDTEventNum(SessionID, AEventNum: integer; Aprecedence: dtPrecedence):
				boolean;
		function LocateDTHeatID(AHeatID: integer): boolean;
		function LocateDTHeatNum(EventID, AHeatNum: integer; Aprecedence: dtPrecedence):
				boolean;
		function LocateDTLane(ALane: integer): boolean;
		function LocateDTSessionID(ASessionID: integer): boolean;
		function LocateDTSessionNum(ASessionNum: integer; Aprecedence: dtPrecedence):
				boolean;
		function MaxID_Lane: integer;
		function MaxID_Event(): integer;
		function MaxID_Heat(): integer;
		function MaxID_Session():integer;
		procedure POST_All;
		procedure POST_Lane(ALane: Integer);
		procedure ReadFromBinary(AFilePath:string);
		procedure SetActiveRT(ADataSet: TDataSet; aActiveRT: dtActiveRT);
		function SyncCheck(APrecedence: dtPrecedence): boolean;
		function SyncDTtoSCM(APrecedence: dtPrecedence): boolean;
		function ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0): dtActiveRT;
		function ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: dtActiveRT): Boolean;
		function ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer; art:
				dtActiveRT): boolean;
		procedure WriteToBinary(AFilePath:string);
		property Connection: TFDConnection read FConnection write FConnection;
		property DTDataIsActive: Boolean read fDTDataIsActive;
		property DTMasterDetailActive: Boolean read fDTMasterDetailActive;
		property MSG_Handle: HWND read msgHandle write msgHandle;
end;

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils;


procedure TDTData.ActivateDataDT;
begin
	// MAKE LIVE THE DOLPHIN TIMING TABLES
	try
		tblDTSession.Open;
		if tblDTSession.Active then
		begin
			tblDTEvent.Open;
			if tblDTEvent.Active then
			begin
				tblDTHeat.Open;
				if tblDTHeat.Active then
				begin
					tblDTLane.Open;
					tblDTNoodle.Open;
				end;
			end;
		end;
	except on E: Exception do
		// failed to open memory table.
	end;
end;


procedure TDTData.BuildDTData;
begin
	tblDTSession.Active := false;
	tblDTEvent.Active := false;
	tblDTHeat.Active := false;
	tblDTLane.Active := false;
	tblDTNoodle.Active := false;

	// Create Dolphin Timing DATA TABLES SCHEMA.
	// ---------------------------------------------
	tblDTSession.FieldDefs.Clear;
	// Primary Key
	tblDTSession.FieldDefs.Add('SessionID', ftInteger);
	// Derived from line one 'Header' within file.
	tblDTSession.FieldDefs.Add('SessionNum', ftInteger);
	// Derived from filename : Last three digits of SCM qrySession.SessionID.
	tblDTSession.FieldDefs.Add('fnSessionNum', ftInteger);
	// file creation date  - produced by Dolphin timing when file was saved.
	tblDTSession.FieldDefs.Add('SessionStart', ftDateTime);
	// TimeStamp - Now.
	tblDTSession.FieldDefs.Add('CreatedOn', ftDateTime);
	tblDTSession.FieldDefs.Add('Caption', ftString, 64);
	tblDTSession.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	tblDTSession.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataSession.xml', sfAuto);
{$ENDIF}

	tblDTEvent.FieldDefs.Clear;
	// Primary Key.
	tblDTEvent.FieldDefs.Add('EventID', ftInteger);
	// FK. Master-detail  (tblDTSession)
	tblDTEvent.FieldDefs.Add('SessionID', ftInteger);
	// Derived from SplitString Field[1]
	// SYNC with SCM EventNum.
	tblDTEvent.FieldDefs.Add('EventNum', ftInteger);
	// Derived from filename : matches SCM qryEvent.EventNum.
	tblDTEvent.FieldDefs.Add('fnEventNum', ftInteger);
	tblDTEvent.FieldDefs.Add('Caption', ftString, 64);
	tblDTEvent.FieldDefs.Add('GenderStr', ftString, 1); // DO4 A=boys, B=girls, X=any.
	// Derived from filename
	tblDTEvent.FieldDefs.Add('fnRoundStr', ftString, 1); // Round A for all, P for prelim or F for final.
	tblDTEvent.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	tblDTEvent.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEvent.xml', sfAuto);
{$ENDIF}

	tblDTHeat.FieldDefs.Clear;
	// Create the HEAT MEM TABLE schema... tblDTHeat.
	// ---------------------------------------------
	tblDTHeat.FieldDefs.Add('HeatID', ftInteger); // PK.
	tblDTHeat.FieldDefs.Add('EventID', ftInteger); // Master- Detail
	// This timestamp is the moment when the event is brought into the
	// swimclubmeet dolphin timing application.
	// It's used to assist in 'pooling time' of the DT Meet Bin
	tblDTHeat.FieldDefs.Add('TimeStampDT', ftDateTime);
	// heat number should match
	// - SCM.dsHeat.Dataset.FieldByName('HeatNum)
	// - DT Filename - SplitString Field[2] - only available in D04
	// - Line one of FileName. Referenced as 'Header' - SplitString Field[2]
	tblDTHeat.FieldDefs.Add('HeatNum', ftInteger);
	// the heat number as shown in the DT filename.
	tblDTHeat.FieldDefs.Add('fnHeatNum', ftInteger);
	// Auto-created eg. 'Event 1 : #FILENAME#'
	tblDTHeat.FieldDefs.Add('Caption', ftString, 64);
	// Time stamp of file - created by Dolphin Timing system on write of file.
	tblDTHeat.FieldDefs.Add('CreatedDT', ftDateTime);
	// Path isn't stotred
	// FileName includes file extension.    (.DO3, .DO4)
	// determines dtFileType dtDO3, dtDO4.
	tblDTHeat.FieldDefs.Add('FileName', ftString, 128);
	// Last line of file - Referenced as 'Footer'
	tblDTHeat.FieldDefs.Add('CheckSum', ftString, 16); // footer.
	// Filename params sess, ev, ht don't match SCM session, event, heat
	// Used to prompt user to rename DT FileName.
	tblDTHeat.FieldDefs.Add('fnBadFN', ftBoolean);
	// Derived from FileName.
	// DO3 - SplitString Field[2] hash number (alpha-numerical).
	// DO4 - SplitString Field[3] hash number (numerical - sequence).
	tblDTHeat.FieldDefs.Add('fnHashStr', ftString, 8);
	// Derived from FileName.
	// DO4 Hashstr can be converted to RaceID.
	tblDTHeat.FieldDefs.Add('fnRaceID', ftInteger);
	tblDTHeat.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	tblDTHeat.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataHeat.xml');
{$ENDIF}

	{ NOTE :
		Dolphin Timing doesn't destinct INDV and TEAM.
		tblEntrant holds both INDV and TEAM data.
	}

	tblDTLane.FieldDefs.Clear;
	// Create the LANE MEM TABLE schema... tblDTLane.
	// ---------------------------------------------
	tblDTLane.FieldDefs.Add('EntrantID', ftInteger); // PK.
	tblDTLane.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
	tblDTLane.FieldDefs.Add('Lane', ftInteger); // Lane Number.
	// Dolphin Timing Specific
	tblDTLane.FieldDefs.Add('Caption', ftString, 64); // Summary of status/mode

	// If all timekeeper watch times are empty - then true;
	// calculated during load of DT file. Read Only.
	tblDTLane.FieldDefs.Add('LaneIsEmpty', ftBoolean);  //

	// Race-Time that will be posted to SCM.
	// Value shown here is dependant on ActiveRT.
	tblDTLane.FieldDefs.Add('RaceTime', ftTime);

	// A race-time entered manually by the user.
	tblDTLane.FieldDefs.Add('RaceTimeUser', ftTime);

	// dtAutomatic - calc on load. Read-Only.
	tblDTLane.FieldDefs.Add('RaceTimeA', ftTime);

	// dtActiveRT = (artAutomatic, artManual, artUser, artSplit, artNone);
	// ----------------------------------------------------------------
	// artAutomatic ...
	//  A race-time calculated when loading the DT file - read only.
	// artManual ...
	//  A race-time calculated on demand.
	// artUser ...
	//  The user must switch to manual mode and then CNTRL-LMB the race-time cell.
	//  AND then will be prompted to enter a user race-time. An icon will
	//  be displayed in the race-time cell. CNTRL-LMB to exit this mode.
	// artSplit ...
	// dtfiletype dtDO4 ONLY. Use the final split-time as race-time.
	// artNone ...
	// The lane is empty or data error.
	tblDTLane.FieldDefs.Add('ActiveRT', ftInteger);

	// CELL ICON - PATCH cable . index given in DTData.vimglistDTGrid.
	tblDTLane.FieldDefs.Add('imgPatch', ftInteger);

	// CELL ICON - ActiveRT.  index given in DTData.vimglistDTGrid.
	tblDTLane.FieldDefs.Add('imgActiveRT', ftInteger);

	// TimeKeeper's RACE_TIMES - 1,2, 3  (DT allows for 3 TimeKeepers.)
	tblDTLane.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
	tblDTLane.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
	tblDTLane.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.

	// dtManual - store flip/flop.
	// The watch time is enabled (true) - is disabled (false).
	tblDTLane.FieldDefs.Add('T1M', ftBoolean);
	tblDTLane.FieldDefs.Add('T2M', ftBoolean);
	tblDTLane.FieldDefs.Add('T3M', ftBoolean);

	// dtAutomatic - store flip/flop.
	// The watch time is valid  (true).
	// SET on load of DT file (DO3 .. DO4). Read only.
	tblDTLane.FieldDefs.Add('T1A', ftBoolean);
	tblDTLane.FieldDefs.Add('T2A', ftBoolean);
	tblDTLane.FieldDefs.Add('T3A', ftBoolean);

	// Deviation - store flip/flop.
	// The watch time is within accepted deviation (true).
	// Only 2xfields Min-Mid, Mid-Max
	// SET on load of DT file (DO3 .. DO4). Read only.
	tblDTLane.FieldDefs.Add('TDev1', ftBoolean);
	tblDTLane.FieldDefs.Add('TDev2', ftBoolean);

	// Dolphin timing (dtfiletype dtDO4) stores MAX 10 splits.
	tblDTLane.FieldDefs.Add('Split1', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split2', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split3', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split4', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split5', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split6', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split7', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split8', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split9', ftTime); // DO4.
	tblDTLane.FieldDefs.Add('Split10', ftTime); // DO4.

	tblDTLane.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	tblDTLane.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEntrant.xml');
{$ENDIF}

	tblDTNoodle.FieldDefs.Clear;
	// Create the NOODLE MEM TABLE schema... tblDTNoodle.
	// ---------------------------------------------
	// Primary Key
	tblDTNoodle.FieldDefs.Add('NoodleID', ftInteger);
	// dtHeat Master-Detail.
	tblDTNoodle.FieldDefs.Add('HeatID', ftInteger);
	// dtEntrant - Route to lane/timekeepers/splits details
	tblDTNoodle.FieldDefs.Add('EntrantID', ftInteger);
	// dtEntrant.Lane - Quick lookup. Improve search times?
	tblDTNoodle.FieldDefs.Add('Lane', ftInteger);
	// LINK TO SwimClubMeet DATA
	// An entrant may be INDV or TEAM event.
	tblDTNoodle.FieldDefs.Add('SCM_EventTypeID', ftInteger);
	// Route to individual entrant.
	tblDTNoodle.FieldDefs.Add('SCM_INDVID', ftInteger);
	// Route to team (relay-team) entrant.
	tblDTNoodle.FieldDefs.Add('SCM_TEAMID', ftInteger);
	// Quick lookup?
	tblDTNoodle.FieldDefs.Add('SCM_Lane', ftInteger);
	tblDTNoodle.CreateDataSet;
{$IFDEF DEBUG}
	// save schema ...
	tblDTNoodle.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataNoodle.xml');
{$ENDIF}

end;

procedure TDTData.CalcRaceTimeM(ADataSet: TDataSet);
var
	I: Integer;
	s: string;
	count: integer;
	b: boolean;
	t: TTime;
begin
	t := 0;
	count:= 0;
	// check isnull, zero and T?M
	for I := 1 to 3 do
	begin
		b := ValidateWatchTime(ADataSet, I, artManual);
		if b then
		begin
			s := 'Time' + IntToStr(I);
			t := t + TimeOF(ADataSet.FieldByName(s).AsDateTime);
			INC(count);
		end;
	end;

	ADataSet.Edit;
	if count = 0 then
	begin
		// If no valid times, clear the RaceTime field
		ADataSet.FieldByName('RaceTime').Clear;
	end
	else
	begin
		// Calculate average time
		t := t / count;
		ADataSet.FieldByName('RaceTime').AsDateTime := t;
	end;
	ADataSet.Post;
end;

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
	// Init params.
	fDTDataIsActive := false;
	fDTMasterDetailActive := false;
	FConnection := nil;
	// Assign all the params to create the Master-Detail relationships
	// between Dolphin Timing memory tables.
	EnableDTMasterDetail();
	// Makes 'Active' the Dolphin Timing tables.
	ActivateDataDT;
	msgHandle := 0;
end;

procedure TDTData.DataModuleDestroy(Sender: TObject);
begin
//	DeActivateDataTDS;
end;


procedure TDTData.DisableDTMasterDetail();
begin
	// ASSERT Master - Detail
	tblDTSession.IndexFieldNames := 'SessionID';
	tblDTEvent.MasterSource := nil;
	tblDTEvent.MasterFields := '';
	tblDTEvent.DetailFields := '';
	tblDTEvent.IndexFieldNames := 'EventID';
	tblDTHeat.MasterSource := nil;
	tblDTHeat.MasterFields := '';
	tblDTHeat.DetailFields := '';
	tblDTHeat.IndexFieldNames := 'HeatID';
	tblDTLane.MasterSource := nil;
	tblDTLane.MasterFields := '';
	tblDTLane.DetailFields := '';
	tblDTLane.IndexFieldNames := 'LaneID';
	tblDTNoodle.MasterSource := nil;
	tblDTNoodle.MasterFields := '';
	tblDTNoodle.DetailFields := '';
	tblDTNoodle.IndexFieldNames := 'NoodleID';
	tblDTSession.First;
	{
	Use the ApplyMaster method to synchronize this detail dataset with the
	current master record.  This method is useful, when DisableControls was
	called for the master dataset or when scrolling is disabled by
	MasterLink.DisableScroll.
	}
	tblDTEvent.First;
	tblDTHeat.First;
	tblDTLane.First;
	tblDTNoodle.First;

	fDTMasterDetailActive := false;
end;

procedure TDTData.EnableDTMasterDetail();
begin
	// Master - index field.
	tblDTSession.IndexFieldNames := 'SessionID';
	// ASSERT Master - Detail
	tblDTEvent.MasterSource := dsDTSession;
	tblDTEvent.MasterFields := 'SessionID';
	tblDTEvent.DetailFields := 'SessionID';
	tblDTEvent.IndexFieldNames := 'SessionID';
	tblDTHeat.MasterSource := dsDTEvent;
	tblDTHeat.MasterFields := 'EventID';
	tblDTHeat.DetailFields := 'EventID';
	tblDTHeat.IndexFieldNames := 'EventID';
	tblDTLane.MasterSource := dsDTHeat;
	tblDTLane.MasterFields := 'HeatID';
	tblDTLane.DetailFields := 'HeatID';
	tblDTLane.IndexFieldNames := 'HeatID';
	tblDTNoodle.MasterSource := dsDTHeat;
	tblDTNoodle.MasterFields := 'HeatID';
	tblDTNoodle.DetailFields := 'HeatID';
	tblDTNoodle.IndexFieldNames := 'HeatID';
	tblDTSession.First;
	fDTMasterDetailActive := true;
end;

function TDTData.LocateDTEventID(AEventID: integer): boolean;
var
	SearchOptions: TLocateOptions;
begin
	result := false;
	if not tblDTHeat.Active then exit;
	if (AEventID = 0) then exit;
	SearchOptions := [];
	result := dsdtEvent.DataSet.Locate('EventID', AEventID, SearchOptions);
	if result then
		dsdtHeat.DataSet.Refresh;
end;

function TDTData.LocateDTEventNum(SessionID, AEventNum: integer; APrecedence:
	dtPrecedence): boolean;
var
	indexStr: string;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessEvent.
	result := false;
	// Exit if the table is not active or if AEventNum is 0
	if not tbldtEvent.Active then exit;
	if AEventNum = 0 then exit;
	// Store the original index field names
	indexStr := tbldtEvent.IndexFieldNames;
	tbldtEvent.IndexFieldNames := 'EventID';
	// Set the index based on the precedence
	if APrecedence = dtPrecFileName then
		result := tbldtEvent.Locate('SessionID;fnEventNum', VarArrayOf([SessionID,
			AEventNum]), [])
	else if APrecedence = dtPrecHeader then
		result := tbldtEvent.Locate('SessionID;EventNum', VarArrayOf([SessionID,
			AEventNum]), []);
	// Restore the original index field names
	tbldtEvent.IndexFieldNames := indexStr;
end;

function TDTData.LocateDTHeatID(AHeatID: integer): boolean;
var
	SearchOptions: TLocateOptions;
begin
	result := false;
	if not tblDTHeat.Active then exit;
	if (AHeatID = 0) then exit;
	SearchOptions := [];
	result := dsdtHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TDTData.LocateDTHeatNum(EventID, AHeatNum: integer; Aprecedence:
		dtPrecedence): boolean;
var
	indexStr: string;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessHeat.
	result := false;
	// Exit if the table is not active or if AHeatNum is 0
	if not tbldtHeat.Active then exit;
	if AHeatNum = 0 then exit;
	// Store the original index field names
	indexStr := tbldtHeat.IndexFieldNames;
	tbldtHeat.IndexFieldNames := 'HeatID';
	// Set the index based on the precedence
	if APrecedence = dtPrecFileName then
		result := tbldtHeat.Locate('EventID;fnHeatNum', VarArrayOf([EventID,
			AHeatNum]), [])
	else if APrecedence = dtPrecHeader then
		result := tbldtHeat.Locate('EventID;HeatNum', VarArrayOf([EventID,
			AHeatNum]), []);
	// Restore the original index field names
	tbldtHeat.IndexFieldNames := indexStr;
end;

function TDTData.LocateDTLane(ALane: integer): boolean;
begin
	// IGNORES SYNC STATE...
	result := tblDTLane.Locate('Lane', ALane, []);
end;

function TDTData.LocateDTSessionID(ASessionID: integer): boolean;
var
	SearchOptions: TLocateOptions;
begin
	result := false;
	if not tblDTSession.Active then exit;
	if (ASessionID = 0) then exit;
	SearchOptions := [];
	result := dsdtSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
	if result then
	begin
		dsdtEvent.DataSet.Refresh;
		dsdtHeat.DataSet.Refresh;
	end;
end;

function TDTData.LocateDTSessionNum(ASessionNum: integer; Aprecedence:
		dtPrecedence): boolean;
var
	indexStr: string;
begin
	// WARNING : DisableDTMasterDetail() before calling here.
	// USED ONLY BY TdtUtils.ProcessSession
	result := false;
	if not tbldtSession.Active then exit;
	if ASessionNum = 0 then exit;
	// Store the original index field names
	indexStr := tbldtSession.IndexFieldNames;
	if (ASessionNum = 0) then exit;
	tbldtSession.IndexFieldNames := 'SessionID';
	if (Aprecedence = dtPrecFileName) then
		result := tbldtSession.Locate('fnSessionNum', ASessionNum, [])
	else if (Aprecedence = dtPrecHeader) then
		result := tbldtSession.Locate('SessionNum', ASessionNum, []);
	// Restore the original index field names
	tbldtSession.IndexFieldNames := indexStr;
end;



function TDTData.MaxID_Lane: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblDTLane.First;
	while not tblDTLane.eof do
	begin
		id := tblDTLane.FieldByName('LaneID').AsInteger;
		if (id > max) then
			max := id;
		tblDTLane.Next;
	end;
	result := max;
end;

function TDTData.MaxID_Event: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblDTEvent.First;
	while not tblDTEvent.eof do
	begin
		id := tblDTEvent.FieldByName('EventID').AsInteger;
		if (id > max) then
			max := id;
		tblDTEvent.Next;
	end;
	result := max;
end;

function TDTData.MaxID_Heat: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblDTHeat.First;
	while not tblDTHeat.eof do
	begin
		id := tblDTHeat.FieldByName('HeatID').AsInteger;
		if (id > max) then
			max := id;
		tblDTHeat.Next;
	end;
	result := max;
end;

function TDTData.MaxID_Session: integer;
var
max, id: integer;
begin
	// To function correctly disableDTMasterDetail.
	max := 0;
	tblDTSession.First;
	while not tblDTSession.eof do
	begin
		id := tblDTSession.FieldByName('SessionID').AsInteger;
		if (id > max) then
			max := id;
		tblDTSession.Next;
	end;
	result := max;
end;

procedure TDTData.POST_All;
begin
	tblDTLane.DisableControls;
	tblDTLane.First;
	while not (tblDTLane.eof) do
	begin
//		POST_Lane();
		tblDTLane.Next;
	end;
	tblDTLane.EnableControls;
end;

procedure TDTData.POST_Lane(ALane: Integer);
var
	AEventType: scmEventType;
	b1, b2: boolean;
begin
	tblDTLane.DisableControls;
	// SYNC to ROW ...
	b1 := LocateDTLane(ALane);
	b2 := LocateSCMLane(ALane, AEventType);
	if (b1 and b2) then
	begin

	end;
	tblDTLane.EnableControls;
end;

procedure TDTData.ReadFromBinary(AFilePath:string);
var
s: string;
begin
	if Length(AFilePath) > 0 then
		// Assert that the end delimiter is attached
		s := IncludeTrailingPathDelimiter(AFilePath)
	else
		s := ''; // or handle this case if the path is mandatory
	tblDTSession.LoadFromFile(s + 'DTMaster.fsBinary');
	tblDTEvent.LoadFromFile(s + 'DTEvent.fsBinary');
	tblDTHeat.LoadFromFile(s + 'DTHeat.fsBinary');
	tblDTLane.LoadFromFile(s + 'DTLane.fsBinary');
	tblDTNoodle.LoadFromFile(s + 'DTNoodle.fsBinary');
end;



procedure TDTData.SetActiveRT(ADataSet: TDataSet; aActiveRT: dtActiveRT);
var
	RaceTimeField: TField;
	RaceTimeUField: TField;
	RaceTimeAField: TField;
begin

	if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then
	begin
		ADataSet.edit;
		ADataSet.fieldbyName('imgActiveRT').AsInteger := -1;
		ADataSet.FieldByName('RaceTime').Clear;
		ADataSet.post;
		exit;
	end;

	try
		case aActiveRT of
			artAutomatic:
				begin
					ADataSet.edit;
					try
						ADataSet.FieldByName('ActiveRT').AsInteger := Ord(artAutomatic);
						ADataSet.fieldbyName('imgActiveRT').AsInteger := 2;
						if ADataSet.FieldByName('RaceTimeA').IsNull then
							ADataSet.FieldByName('RaceTime').Clear
						else
							ADataSet.FieldByName('RaceTime').AsVariant :=
							ADataSet.FieldByName('RaceTimeA').AsVariant;
						ADataSet.post;
					except on E: Exception do
						begin
							ADataSet.Cancel; // Cancel the changes if an exception occurs
							raise; // Re-raise the exception to propagate it further
						end;
					end;
				end;

			artManual:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artManual);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 3;
					ADataSet.post;
				end;

			artUser:
				begin
					ADataSet.edit;

					RaceTimeField := ADataSet.FieldByName('RaceTime');
					RaceTimeUField := ADataSet.FieldByName('RaceTimeUser');
					RaceTimeAField := ADataSet.FieldByName('RaceTimeA');

					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artUser);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 4;

					if RaceTimeUField.IsNull then
						RaceTimeUField.AsVariant := RaceTimeAField.AsVariant;

					RaceTimeField.AsVariant := RaceTimeUField.AsVariant;

					ADataSet.post;
				end;

			artSplit:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artSplit);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 5;
					ADataSet.FieldByName('RaceTime').Clear;
					ADataSet.post;
				end;

			artNone:
				begin
					ADataSet.edit;
					ADataSet.FieldByName('ActiveRT').AsInteger := ORD(artNone);
					ADataSet.fieldbyName('imgActiveRT').AsInteger := 6;
					ADataSet.FieldByName('RaceTime').Clear;
					ADataSet.post;
				end;
		end;

	except on E: Exception do
			// handle arror.
	end;
end;

function TDTData.SyncCheck(APrecedence: dtPrecedence): boolean;
var
	IsSynced: boolean;
begin
	IsSynced := false;
	case APrecedence of
		dtPrecHeader:
			begin

							IsSynced := true;
			end;
		dtPrecFileName:
			begin

							IsSynced := true;
			end;
	end;
	result := IsSynced;

end;


function TDTData.SyncDTtoSCM(APrecedence: dtPrecedence): boolean;
var
	found: boolean;
begin
	result := false;
	tblDTEvent.DisableControls;
	tblDTHeat.DisableControls;
	tblDTLane.DisableControls;
	tblDTSession.DisableControls;
	// NOTE : SCM Sesssion ID = DT SessionNum.

	tblDTSession.EnableControls;
	tblDTEvent.EnableControls;
	tblDTHeat.EnableControls;
	tblDTLane.EnableControls;
end;



procedure TDTData.tblDTHeatAfterScroll(DataSet: TDataSet);
begin
	if (msgHandle <> 0) then
	begin
		PostMessage(msgHandle, SCM_UPDATEUI_TDS, 0,0);
		PostMessage(msgHandle, SCM_UPDATE_NOODLES, 0,0);
	end;
end;

function TDTData.ToggleActiveRT(ADataSet: TDataSet; Direction: Integer = 0):
dtActiveRT;
var
	art: dtActiveRT;
begin
	result := artNone;
	if not ADataSet.Active then exit;
	if not (ADataSet.Name = 'tblDTLane') then exit;
	// Get the current ActiveRT value
	art := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
	if (Direction = 0) then
	begin
		// Toggle state using Succ and handling wrapping
		if art = High(dtActiveRT) then
			art := Low(dtActiveRT)
		else
			art := Succ(art);
	end
	else
	begin
		// Toggle state using Succ and handling wrapping
		if art = Low(dtActiveRT) then
			art := High(dtActiveRT)
		else
			art := Pred(art);
	end;

	try
		ADataSet.Edit;
		ADataSet.FieldByName('ActiveRT').AsInteger := ORD(art);
		ADataSet.Post;
		result := art;
	except on E: Exception do
		begin
			ADataSet.Cancel;
		end;
	end;
end;

function TDTData.ToggleWatchTime(ADataSet: TDataSet; idx: integer; art: dtActiveRT): Boolean;
var
s, s2: string;
b: boolean;
begin
	// RANGE : idx in [1..3].
	result := false;

	// Assert state ...
	if not ADataSet.Active then exit;
	if (ADataSet.Name <> 'tblDTLane') then exit;
	if not idx in [1..3] then exit;
	if art = artManual  then
		s2 := 'M'
	else if art = artAutomatic  then
		s2 := 'A';
	s := 'T' + IntToStr(idx) + s2;
	b := ADataSet.FieldByName(s).AsBoolean;
	b := not b; // Perform toggle;
	try
		ADataSet.edit;
		ADataSet.FieldByName(s).AsBoolean := b;
		ADataSet.Post;
	finally
		result := b;
	end;
end;

function TDTData.ValidateWatchTime(ADataSet: TDataSet; TimeKeeperIndx: integer;
		art: dtActiveRT): boolean;
var
	TimeField, EnabledField: TField;
begin
	result := false;
	EnabledField := nil;

	if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then exit;

	// Check if TimeKeeperIndx is within the valid range
	if (TimeKeeperIndx < 1) or (TimeKeeperIndx > 3) then
		exit;

	// Determine the field names based on the index
	TimeField := ADataSet.FindField(Format('Time%d', [TimeKeeperIndx]));
	if (art = artManual) then
		EnabledField := ADataSet.FindField(Format('T%dM', [TimeKeeperIndx]))
	else if (art = artAutomatic) then
		EnabledField := ADataSet.FindField(Format('T%dA', [TimeKeeperIndx]));

	// Check if fields are found
	if (TimeField = nil) or (EnabledField = nil) then
		exit;

	try
		// Validate - is the Time Active...
		if not EnabledField.AsBoolean then
			exit;
		// Validate the TTime field value.
		if TimeField.IsNull then
			exit;
		if TimeOf(TimeField.AsDateTime) = 0 then
			exit;

	except
		on E: Exception do
			exit; // Trap any unexpected errors
	end;

	result := true;
end;

procedure TDTData.WriteToBinary(AFilePath:string);
var
s: string;
begin
	if Length(AFilePath) > 0 then
		// Assert that the end delimiter is attached
		s := IncludeTrailingPathDelimiter(AFilePath)
	else
		s := ''; // or handle this case if the path is mandatory
	tblDTSession.SaveToFile(s + 'DTMaster.fsBinary', sfXML);
	tblDTEvent.SaveToFile(s + 'DTEvent.fsBinary', sfXML);
	tblDTHeat.SaveToFile(s + 'DTHeat.fsBinary', sfXML);
	tblDTLane.SaveToFile(s + 'DTLane.fsBinary', sfXML);
	tblDTNoodle.SaveToFile(s + 'DTNoodle.fsBinary', sfXML);
end;


end.
