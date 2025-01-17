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
  dtTimeKeeperMode = (dtAutomatic, dtManual);

type
  TDTData = class(TDataModule)
    qrySession: TFDQuery;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    qryINDV: TFDQuery;
    qryTEAM: TFDQuery;
    qryTEAMEntrant: TFDQuery;
    dsSession: TDataSource;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    dsINDV: TDataSource;
    dsTEAM: TDataSource;
    dsTEAMEntrant: TDataSource;
    imgcolDT: TImageCollection;
    vimglistDTEvent: TVirtualImageList;
    qryNearestSessionID: TFDQuery;
    tblDTNoodle: TFDMemTable;
    qryDistance: TFDQuery;
    qryStroke: TFDQuery;
    vimglistDTGrid: TVirtualImageList;
    tblDTSession: TFDMemTable;
    tblDTHeat: TFDMemTable;
    dsDTSession: TDataSource;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    tblDTEntrant: TFDMemTable;
    dsDTHeat: TDataSource;
    dsDTEntrant: TDataSource;
    qrySwimClub: TFDQuery;
    dsSwimClub: TDataSource;
    qrySessionList: TFDQuery;
    dsSessionList: TDataSource;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    vimglistMenu: TVirtualImageList;
    qrySessionListSessionID: TFDAutoIncField;
    qrySessionListCaption: TWideStringField;
    qrySessionListSessionStart: TSQLTimeStampField;
    qrySessionListClosedDT: TSQLTimeStampField;
    qrySessionListSwimClubID: TIntegerField;
    qrySessionListSessionStatusID: TIntegerField;
    vimglistTreeView: TVirtualImageList;
    vimglistStateImages: TVirtualImageList;
    tblDTEvent: TFDMemTable;
    dsDTEvent: TDataSource;
    SVGIconImageCollection1: TSVGIconImageCollection;
    vimglistDTCell: TVirtualImageList;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure tblDTHeatAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fSCMDataIsActive: Boolean;
    fDTDataIsActive: Boolean;
    fDTMasterDetailActive: Boolean;
    msgHandle: HWND;  // TForm.dtfrmExec ...
    function GetSCMActiveSessionID: integer;
  public
    { Public declarations }
    procedure ActivateDataSCM();
    procedure ActivateDataDT();
    procedure BuildDTData;
    procedure BuildCSVEventData(AFileName: string);
    procedure ReadFromBinary(AFilePath:string);
    procedure WriteToBinary(AFilePath:string);
    procedure EnableDTMasterDetail();
    procedure DisableDTMasterDetail();
    // L O C A T E S   F O R   D T   D A T A.
    // .......................................................
    function LocateDTSessionID(ASessionID: integer): boolean;
    // WARNING : Master-Detail enabled... DT EventID may not be visible.
    function LocateDTEventID(AEventID: integer): boolean;
    // WARNING : Master-Detail enabled... DT HeatID may not be visible.
    function LocateDTHeatID(AHeatID: integer): boolean;
    // WARNING : Master-Detail enabled...
    // Use DisableDTMasterDetail() before calling here?
    // USED BY TdtUtils.ProcessSession.
    function LocateDTSessionNum(ASessionNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDTEventNum(SessionID, AEventNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDTHeatNum(EventID, AHeatNum: integer; Aprecedence: dtPrecedence):
        boolean;
    // .......................................................
    // FIND MAXIMUM IDENTIFIER VALUE IN DOLPHIN TIMING TABLES.
    // These routines are needed as there is no AutoInc on Primary Key.
    // .......................................................
    // WARNING : DisableDTMasterDetail() before calling MaxID routines.
    function MaxID_Session():integer;
    function MaxID_Event(): integer;
    function MaxID_Heat(): integer;
    function MaxID_Entrant: integer;
    // .......................................................

    // L O C A T E S   F O R   S W I M C L U B M E E T   D A T A.
    // .......................................................
    // WARNING : Master-Detail enabled...
    // Dependant on selected SwimClub if SCM SessionID is visible.
    function LocateSCMSessionID(ASessionID: integer): boolean;
    // WARNING : Master-Detail enabled...
    // Dependant on selected session if SCM EventID is visible.
    function LocateSCMEventID(AEventID: integer): boolean;
    // WARNING : Master-Detail enabled...
    // Dependant on selected event if SCM HeatID is visible.
    function LocateSCMHeatID(AHeatID: integer): boolean;
    // Uses SessionStart TDateTime...
    function LocateSCMNearestSessionID(aDate: TDateTime): integer;
    // MISC SCM ROUTINES/FUNCTIONS
    function GetSCMNumberOfHeats(AEventID: integer): integer;
    function GetSCMRoundABBREV(AEventID: integer): string;

    procedure ToggleTimeKeeperMode(ADataSet: TDataSet);
    // Available only when in TimeKeeperMode - dtManual.
    // returns true - Enabled ... false - Disabled.
    function ToggleEnableTimeKeeper(ADataSet: TDataSet; idx: integer): Boolean;
    procedure SetTimeKeeperMode(ADataSet: TDataSet; ATimeKeeperMode:
        dtTimeKeeperMode);

    // Routines ONLY for TimeKeeperMode = dtManual
    // For dtAutomatic Racetime, Deviation and validation are perform on
    // loading of the DO file.
    // --------------------------------------------
    procedure CalcRaceTime(ADataSet: TDataSet);
    function ValidateTimeKeeper(ADataSet: TDataSet; TimeKeeperIndx: integer):
        boolean;
    // --------------------------------------------
    // Routines ONLY for TimeKeeperMode = dtAutomatic
    procedure CalcRaceTimeA(ADataSet: TDataSet; AcceptedDeviation: double);

    property SCMDataIsActive: Boolean read fSCMDataIsActive;
    property DTDataIsActive: Boolean read fDTDataIsActive;
    property DTMasterDetailActive: Boolean read fDTMasterDetailActive;
    property ActiveSessionID: integer read GetSCMActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
    property MSG_Handle: HWND read msgHandle write msgHandle;
  end;

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils;

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  // Init params.
  fDTDataIsActive := false;
  fDTMasterDetailActive := false;
  FConnection := nil;
  fSCMDataIsActive := false; // activated later once FConnection is assigned.
  // Assign all the params to create the Master-Detail relationships
  // between Dolphin Timing memory tables.
  EnableDTMasterDetail();
  // Makes 'Active' the Dolphin Timing tables.
  ActivateDataDT;
  msgHandle := 0;
end;

procedure TDTData.DataModuleDestroy(Sender: TObject);
begin
  // clean-up.
end;

procedure TDTData.ActivateDataDT;
begin
  fSCMDataIsActive := false;
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
          tblDTEntrant.Open;
          tblDTNoodle.Open;
          if tblDTEntrant.Active and tblDTNoodle.Active then
            fSCMDataIsActive := true;
        end;
      end;
    end;
  except on E: Exception do
    // failed to open memory table.
  end;
end;

procedure TDTData.ActivateDataSCM;
begin
  if Assigned(fConnection) and fConnection.Connected then
  begin
    // GRAND MASTER.
    qrySwimClub.Connection := fConnection;
    qrySwimClub.Active;
    qrySwimClub.First;
    // Query used by pick session dialogue.
    qrySessionList.Connection := fConnection;
    qrySessionList.Close;
    qrySessionList.ParamByName('SWIMCLUBID').AsInteger :=
      qrySwimClub.FieldByName('SwimClubID').AsInteger;
    qrySessionList.Prepare;
    qrySessionList.Open;
    // Sessions listed are 'OPEN' and reference SwimClubID.
    if qrySessionList.Active and not qrySessionList.IsEmpty then
    begin
      qrySessionList.First;
    end;

    // setup connection for master - detail
    qrySession.Connection := fConnection;
    qryEvent.Connection := fConnection;
    qryDistance.Connection := fConnection;
    qryStroke.Connection := fConnection;
    qryHeat.Connection := fConnection;
    qryINDV.Connection := fConnection;
    qryTEAM.Connection := fConnection;
    qryTEAMEntrant.Connection := fConnection;

    qrySession.Open;

    if qrySwimClub.Active and qrySession.Active then
    begin
      qrySession.Open;
      qrySession.First;
      qryEvent.Open;
      qryDistance.Open;
      qryStroke.Open;
      qryHeat.Open;
      qryINDV.Open;
      qryTEAM.Open;
      qryTEAMEntrant.Open;
      fSCMDataIsActive := true;
    end;

  end;
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
  tblDTEntrant.MasterSource := dsDTHeat;
  tblDTEntrant.MasterFields := 'HeatID';
  tblDTEntrant.DetailFields := 'HeatID';
  tblDTEntrant.IndexFieldNames := 'HeatID';
  tblDTNoodle.MasterSource := dsDTHeat;
  tblDTNoodle.MasterFields := 'HeatID';
  tblDTNoodle.DetailFields := 'HeatID';
  tblDTNoodle.IndexFieldNames := 'HeatID';
  tblDTSession.First;
  fDTMasterDetailActive := true;
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
  tblDTEntrant.MasterSource := nil;
  tblDTEntrant.MasterFields := '';
  tblDTEntrant.DetailFields := '';
  tblDTEntrant.IndexFieldNames := 'EntrantID';
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
  tblDTEvent.ApplyMaster;
  tblDTEvent.First;
  tblDTHeat.ApplyMaster;
  tblDTHeat.First;
  tblDTEntrant.ApplyMaster;
  tblDTEntrant.First;
  tblDTNoodle.ApplyMaster;
  tblDTNoodle.First;

  fDTMasterDetailActive := false;
end;

procedure TDTData.BuildCSVEventData(AFileName: string);
var
  sl: TStringList;
  s, s2, s3: string;
  i, id: integer;
begin
{
The Load button lets the user load all event data from an event file.
This is a CSV file and can be hand typed or generated by meet
management software. Each line of this file should be formatted as follows:
Event Number,EventName,Number of Heats,Number of Splits,Round ...

Example:
1A,Boys 50 M Free,4,1,P
1B,Girls 50 M Free,5,1,P
2A,Boys 100 M Breaststroke,2,2,P
2B,Girls 100 M Breaststroke,2,2,P …

The first line will be event index 1, the second line will be event index 2 and so on. Events
will always come up in event index order although this can be overridden and events and
heats may be run in any order.

}
  sl := TStringlist.Create;
  qryEvent.First();
  while not qryEvent.Eof do
  begin
    s := '';
    // Event Number – Up to 5 alpha-numeric characters. Example: 12B ...
    i := qryEvent.FieldByName('EventNum').AsInteger;
    s := s + IntToStr(i) + ',';
    // Event Name – Up to 25 alpha-numeric characters. Example: Men’s 50 Meter Freestyle
    s2 := qryDistance.FieldByName('Caption').AsString + ' ' +
    qryStroke.FieldByName('Caption').AsString;
    s3 := qryEvent.FieldByName('Caption').AsString;
    if Length(s3) > 0 then
      s2 := s2 + ' ' + s3;
    s := s + s2 + ',';
    // Get Number of Heats
    // Number of Heats – (0-99) Number of expected heats for the given event
    id := qryEvent.FieldByName('EventID').AsInteger;
    i := GetSCMNumberOfHeats(id);
    s := s + IntToStr(i) + ',';
    { TODO -oBSA : Implement Splits for Dolphin Timing }
    // Number of Splits - NOT AVAILABLE IN THIS VERSION.
    s := s + '0,';
    { Round .... requires db v1.1.5.4.
    * A: ALL  (CTS DOLPHIN - ref F912 ).
    * P: Preliminary (DEFAULT)
    * Q: Quarterfinals
    * S: Semifinals
    * F: Finals
    }
    // Round – “A” for all, “P” for prelim or “F” for final
    s := s + 'P';
    sl.Add(s);
    qryEvent.Next;
  end;
  qryEvent.First();
  if not sl.IsEmpty then
    sl.SaveToFile(AFileName);
  sl.free;
end;

procedure TDTData.BuildDTData;
begin
  fSCMDataIsActive := false;
  tblDTSession.Active := false;
  tblDTEvent.Active := false;
  tblDTHeat.Active := false;
  tblDTEntrant.Active := false;
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
  // Round – “A” for all, “P” for prelim or “F” for final.
  tblDTEvent.FieldDefs.Add('fnRoundStr', ftString, 1);
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

  tblDTEntrant.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTEntrant.
  // ---------------------------------------------
  tblDTEntrant.FieldDefs.Add('EntrantID', ftInteger); // PK.
  tblDTEntrant.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
  tblDTEntrant.FieldDefs.Add('Lane', ftInteger); // Lane Number.
  // Dolphin Timing Specific
  tblDTEntrant.FieldDefs.Add('Caption', ftString, 64); // Summary of status/mode
  { TimeKeeper's MODE of operation - FLAG ...
      TRUE : using Auto enabled/disable flags. (DEFAUT)
      FALSE : using Manual enable/disable flags.
  }
  tblDTEntrant.FieldDefs.Add('TimeKeeperMode', ftInteger); // default true.
  // Swimmers calculated racetime - value that is posted after patching.
  // May display dtManual (calc on demand). OR RaceTimeA (calc on load).
  tblDTEntrant.FieldDefs.Add('RaceTime', ftTime);
  // dtAutomatic - calc on load and switched 'in and out' on toggle Auto/Manual.
  tblDTEntrant.FieldDefs.Add('RaceTimeA', ftTime);
  // NOODLE or PATCH cable .
  tblDTEntrant.FieldDefs.Add('imgPatch', ftInteger); // index in DTData.vimglistDTGrid.
  // User manually selecting TimeKeeper's race-times to use - OR - Auto
  tblDTEntrant.FieldDefs.Add('imgAuto', ftInteger); // index in DTData.vimglistDTGrid.
  // TimeKeeper's RACE_TIMES - 1,2, 3  (DT allows for 3 TimeKeepers.)
  tblDTEntrant.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTEntrant.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTEntrant.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.
  // Manual mode - flag TimeKeeper's race-time ENABLED.DISABLED?
  tblDTEntrant.FieldDefs.Add('Time1EnabledM', ftBoolean);
  tblDTEntrant.FieldDefs.Add('Time2EnabledM', ftBoolean);
  tblDTEntrant.FieldDefs.Add('Time3EnabledM', ftBoolean);
  // Auto mode - flag TimeKeeper's race-time ENABLED.DISABLED?
  // DEFAULT true: Time1 is enabled and will be used 'CalcTime'.
  tblDTEntrant.FieldDefs.Add('Time1EnabledA', ftBoolean);
  tblDTEntrant.FieldDefs.Add('Time2EnabledA', ftBoolean);
  tblDTEntrant.FieldDefs.Add('Time3EnabledA', ftBoolean);

  tblDTEntrant.FieldDefs.Add('UseFinalSplitAsRaceTime', ftBoolean); // DO4.
  // Dolphin timing (dtfiletype dtDO4) stores MAX 10 splits.
  tblDTEntrant.FieldDefs.Add('Split1', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split2', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split3', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split4', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split5', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split6', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split7', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split8', ftTime); // DO4.
  tblDTEntrant.FieldDefs.Add('Split9', ftTime); // DO4.
  // Last split can also represent TimeKeeper 4.
  tblDTEntrant.FieldDefs.Add('Split10', ftTime); // DO4.
  tblDTEntrant.CreateDataSet;
{$IFDEF DEBUG}
  // save schema ...
  tblDTEntrant.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEntrant.xml');
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

procedure TDTData.CalcRaceTimeA(ADataSet: TDataSet; AcceptedDeviation: double);
var
  t, tot, avg, AcceptedDeviationAsTime: TTime;
  isValidTime: Array[1..3] of boolean;
  count, I, J: integer;
  s: string;
  CalcRaceTime: TTime;

  indx1, indx2: Integer;
  t1, t2: TTime;
  dev: TTime;
  validIndices: array[0..1] of Integer;
  validTimes: array[0..1] of TTime;
  found: Integer;


begin
  count := 0;
  CalcRaceTime := 0;

  // clear arrays
  for I := 1 to 3 do
  begin
    isValidTime[i] := true;
  end;

  { A TDateTime value is essentially a double, where the integer part is the
      number of days and fraction is the time.
    In a day there are 24*60*60 = 86400 seconds (SecsPerDay constant
      declared in SysUtils) so to get AcceptedDeviation (given in seconds)
      as TDateTime do:
  }
  AcceptedDeviationAsTime := AcceptedDeviation/(SecsPerDay);

  // Validate watch time. Count the number of valid watch times.
  for I := 1 to 3 do
  begin
    s := 'Time' + IntToStr(I);
    if ADataSet.FieldByName(s).IsNull then
    begin
      isValidTime[I] := false
    end
    else
    begin
      t := TimeOF(ADataSet.FieldByName(s).AsDateTime);
      if (t = 0) then
        isValidTime[I] := false;
    end;
    if isValidTime[I] then Inc(count);
  end;

  {

- A. If there is one watch per lane, that time will also be placed in
  'racetime'.

- B. If there are two watches for a given lane, the average will be
  computed and placed in 'racetime'.

- C. If there are 3 watch times for a given lane, the middle time will be
  placed in 'racetime'.


  CASE B. NOTE:
  If there is more than the 'Accepted Deviation' difference between the
  two watch times, the average result time will NOT be computed and
  warning icons will show for both watch times in this lane.
  The 'RaceTime' will be empty.
  Switch to manaul mode and select which time to use.
  You are permitted to select both - in which case a average of the
  two watch times is used in 'racetime' .
  }

 {
  - one watch per lane: deviation is 0.
  - two watches per lane: deviation is the difference between the two.
  - three watch per lane: deviation is the difference between the average of
    the three watch times.
  }

  if (count = 1) then
  begin
    // Cue-to-time
    for I := 1 to 3 do
    begin
      if isValidTime[I] then
      begin
        s := 'Time' + IntToStr(I);
        CalcRaceTime := TimeOF(ADataSet.FieldByName(s).AsDateTime);
        break;
      end;
    end;
  end;

if (count = 2) then
begin
  found := 0;
  indx1 := 0;
  t1 := 0;

  // Loop through the times to find the valid ones and assign values immediately
  for I := 1 to 3 do
  begin
    if isValidTime[I] then
    begin
      s := 'Time' + IntToStr(I);
      if found = 0 then
      begin
        t1 := TimeOF(ADataSet.FieldByName(s).AsDateTime);
        indx1 := I;
      end
      else if found = 1 then
      begin
        t2 := TimeOF(ADataSet.FieldByName(s).AsDateTime);
        indx2 := I;

        // Calculate deviation and update isValidTime and CalcRaceTime
        dev := Abs(t1 - t2);

        if dev >= AcceptedDeviationAsTime then
        begin
          isValidTime[indx1] := false;
          isValidTime[indx2] := false;
          CalcRaceTime := 0;
        end
        else
        begin
          CalcRaceTime := (t1 + t2) / 2;
        end;

        Break; // Exit loop after processing two valid times
      end;
      Inc(found);
    end;
  end;

  if found < 2 then
  begin
    // Handle the case where there are not exactly two valid times
    // Add your error handling logic here
  end;
end;

  if (count = 3) then
  begin
    tot := 0;
    var times: array[1..3] of TTime;
    var UseSCMTimeMode: boolean;

    UseSCMTimeMode := false;

    // Add up all racetimes
    for I := 1 to 3 do
    begin
      if isValidTime[I] then
      begin
        s := 'Time' + IntToStr(I);
        t := TimeOF(ADataSet.FieldByName(s).AsDateTime);
        times[i] := t;
        tot := tot + t;
      end;
    end;

    if UseSCMTimeMode then
    begin
      // Calculate the average stopwatch time.
      CalcRaceTime := (tot / count);
    end
    else
    begin
      // Sort the times array
      var temp: TTime;
      for I := 1 to 2 do
        for J := I + 1 to 3 do
          if times[I] > times[J] then
          begin
            temp := times[I];
            times[I] := times[J];
            times[J] := temp;
          end;

      // The middle time is the second element in the sorted array
      CalcRaceTime := times[2];
    end;

  end;

  // Write out database values (tblDTEntrant)
  // calculated deviation and if TimeKeeper's stopwatch time is to be enabled.
  ADataSet.Edit;
  try
    // Convert msec to TTime.
    for I := 1 to 3 do
    begin
      s := 'Time' + IntToStr(I) + 'EnabledA';
      ADataSet.FieldByName(s).AsBoolean := (isValidTime[I]);
    end;
    if (CalcRaceTime<>0) then
      ADataSet.FieldByName('RaceTimeA').AsDateTime := CalcRaceTime
    else
      ADataSet.FieldByName('RaceTimeA').Clear;
    ADataSet.Post;
  except
    ADataSet.Cancel;
    raise;
  end;

end;

procedure TDTData.CalcRaceTime(ADataSet: TDataSet);
var
  I: Integer;
  s: string;
  count: integer;
  b: boolean;
  t: TTime;
begin
  t := 0;
  count:= 0;
  for I := 1 to 3 do
  begin
    b := ValidateTimeKeeper(ADataSet, I);
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


function TDTData.GetSCMRoundABBREV(AEventID: integer): string;
var
SQL: string;
v: variant;
ARoundID: integer;
begin
  {
  SwimClubMeet.dbo.Round database version 1.1.5.4
  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID'
  * P: Preliminary (DEFAULT)
  * Q: Quarterfinals
  * S: Semifinals
  * F: Finals
  }
  result := 'P';
  SQL := 'SELECT [RoundID] FROM dbo.Event WHERE EventID = :ID;';
  v := DTData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  ARoundID := v;

  SQL := 'SELECT [ABREV] FROM dbo.Round WHERE RoundID = :ID;';
  v := DTData.Connection.ExecSQLScalar(SQL, [ARoundID]);
  if VarIsNull(v) or VarIsEmpty(v) then exit;
  result := v;

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

function TDTData.LocateSCMEventID(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (aEventID = 0) then exit;
  SearchOptions := [];
  if dsEvent.DataSet.Active then
      result := dsEvent.DataSet.Locate('EventID', aEventID, SearchOptions);
end;

function TDTData.LocateSCMHeatID(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  if dsHeat.DataSet.Active then
      result := dsHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
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

function TDTData.LocateSCMNearestSessionID(aDate: TDateTime): integer;
begin
  result := 0;
  // find the session with 'aDate' or bestfit.
  qryNearestSessionID.Connection := fConnection;
  qryNearestSessionID.ParamByName('ADATE').AsDateTime := DateOf(aDate);
  qryNearestSessionID.Prepare;
  qryNearestSessionID.Open;
  if not qryNearestSessionID.IsEmpty then
   result := qryNearestSessionID.FieldByName('SessionID').AsInteger;
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


function TDTData.LocateSCMSessionID(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fSCMDataIsActive then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  if dsSession.DataSet.Active then
      result := dsSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
end;

function TDTData.MaxID_Entrant: integer;
var
max, id: integer;
begin
  // To function correctly disableDTMasterDetail.
  max := 0;
  tblDTEntrant.First;
  while not tblDTEntrant.eof do
  begin
    id := tblDTEntrant.FieldByName('EntrantID').AsInteger;
    if (id > max) then
      max := id;
    tblDTEntrant.Next;
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

function TDTData.GetSCMActiveSessionID: integer;
begin
  result := 0;
  if not fSCMDataIsActive then exit;
  if qrySession.Active and not qrySession.IsEmpty then
    result := qrySession.FieldByName('SessionID').AsInteger;
end;

function TDTData.GetSCMNumberOfHeats(AEventID: integer): integer;
var
SQL: string;
v: variant;
begin
  result := 0;
  SQL := 'SELECT COUNT(HeatID) FROM dbo.HeatIndividual WHERE EventID = :ID;';
  v := DTData.Connection.ExecSQLScalar(SQL, [AEventID]);
  if VarIsNull(v) or VarIsEmpty(v) or (v=0)  then exit;
  result := v;
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
  tblDTEntrant.SaveToFile(s + 'DTLane.fsBinary', sfXML);
  tblDTNoodle.SaveToFile(s + 'DTNoodle.fsBinary', sfXML);
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
  tblDTEntrant.LoadFromFile(s + 'DTLane.fsBinary');
  tblDTNoodle.LoadFromFile(s + 'DTNoodle.fsBinary');
end;

procedure TDTData.SetTimeKeeperMode(ADataSet: TDataSet; ATimeKeeperMode:
    dtTimeKeeperMode);
begin
  // Test: Field already set to this mode.
  if (ADataSet.FieldByName('TimeKeeperMode').AsInteger = ORD(ATimeKeeperMode)) then exit;
  // Assign data fields to reflect new timemode.
  try
    ADataSet.edit;
    ADataSet.FieldByName('TimeKeeperMode').AsInteger := ORD(ATimeKeeperMode);
    case ATimeKeeperMode of
      dtAutomatic:
          ADataSet.fieldbyName('imgAuto').AsInteger := 1;
      dtManual:
          ADataSet.fieldbyName('imgAuto').AsInteger := 2;
    end;
    ADataSet.post;
  except on E: Exception do
      // handle arror.
  end;
end;

procedure TDTData.tblDTHeatAfterScroll(DataSet: TDataSet);
begin
  if (msgHandle <> 0) then
    PostMessage(msgHandle, SCM_UPDATEUI3, 0,0);
end;

function TDTData.ToggleEnableTimeKeeper(ADataSet: TDataSet; idx: integer):
    Boolean;
var
s: string;
b: boolean;
begin
  // Available only when in TimeKeeperMode - dtManual.
  // returns true - Enabled ... false - Disabled.
  // RANGE : idx in [1..3].
  result := false;
  // Assert state ...
  if not ADataSet.Active then exit;
  if (ADataSet.Name <> 'tblDTEntrant') then exit;
  if ADataSet.FieldByName('TimeKeeperMode').AsInteger <> ORD(dtManual) then
    exit;
  if not idx in [1,2,3] then exit;
  // params ...
  s := 'Time' + IntToStr(idx) + 'EnabledM';
  b := ADataSet.FieldByName(s).AsBoolean;
  b := not b; // Perform toggle;
  try
    ADataSet.edit;
    ADataSet.FieldByName(s).AsBoolean := b;
    ADataSet.Post;
  finally
    // hack : no error checking done here.
    result := b; // Assign an optimistic result.
  end;

end;

procedure TDTData.ToggleTimeKeeperMode(ADataSet: TDataSet);
var
  ATimeKeeperMode: dtTimeKeeperMode;
  t1, t2, t3: TTime;
begin
  if ADataSet.Active and (ADataSet.Name = 'tblDTEntrant') then
  begin
    // if there is no time-keeper data then it's pointless
    // changing TimeMode. Also the icon will be removed.
    t1 := TimeOF(ADataSet.FieldByName('Time1').AsDateTime);
    t2 := TimeOF(ADataSet.FieldByName('Time2').AsDateTime);
    t3 := TimeOF(ADataSet.FieldByName('Time3').AsDateTime);
    if (t1 = 0) and (t2 = 0) and (t3 = 0) then
    begin
      if ADataSet.fieldbyName('imgAuto').AsInteger <> -1 then
      begin
        try
          ADataSet.edit;
          ADataSet.fieldbyName('imgAuto').AsInteger := -1;
          ADataSet.post;
        except on E: Exception do
          // handle eception
        end;
      end;
      exit;
    end;
    // toogle state.
    if (ADataSet.FieldByName('TimeKeeperMode').AsInteger = ORD(dtAutomatic)) then
      ATimeKeeperMode := dtManual
    else
      ATimeKeeperMode := dtAutomatic;
    SetTimeKeeperMode(ADataSet, ATimeKeeperMode);
    if (ATimeKeeperMode = dtManual) then CalcRaceTime(ADataSet);
  end;
end;

function TDTData.ValidateTimeKeeper(ADataSet: TDataSet; TimeKeeperIndx:
  integer): boolean;
var
  ATimeKeeperMode: dtTimeKeeperMode;
begin
  result := false;
  // only TimeKeeperMode .. dtManual is accepted here.
  ATimeKeeperMode := dtTimeKeeperMode(ADataSet.FieldByName('TimeKeeperMode').AsInteger);
  if ATimeKeeperMode <> dtManual then exit;

  case TimeKeeperIndx of
    1:
      begin
        if (TimeOF(ADataSet.FieldByName('Time1').AsDateTime) = 0) then
          exit;
        if (ADataSet.FieldByName('Time1EnabledM').AsBoolean = false) then
          exit;
      end;
    2:
      begin
        if (TimeOF(ADataSet.FieldByName('Time2').AsDateTime) = 0) then
          exit;
        if (ADataSet.FieldByName('Time2EnabledM').AsBoolean = false) then
          exit;
      end;
    3:
      begin
        if (TimeOF(ADataSet.FieldByName('Time3').AsDateTime) = 0) then
          exit;
        if (ADataSet.FieldByName('Time3EnabledM').AsBoolean = false) then
          exit;
      end;
  end;
  result := true;
end;


end.
