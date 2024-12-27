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
  FireDAC.Stan.StorageBin, FireDAC.Stan.Storage, Datasnap.Provider;

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
    tblDTINDV: TFDMemTable;
    dsDTHeat: TDataSource;
    dsDTINDV: TDataSource;
    qrySwimClub: TFDQuery;
    dsSwimClub: TDataSource;
    qrySessionList: TFDQuery;
    dsSessionList: TDataSource;
    tblDTSessionDTID: TIntegerField;
    tblDTSessionCreatedDT: TDateTimeField;
    tblDTSessionFileName: TStringField;
    tblDTSessionfSession: TIntegerField;
    tblDTSessionfEvent: TIntegerField;
    tblDTSessionfHeat: TIntegerField;
    tblDTSessionfGender: TStringField;
    tblDTSessionfGUID: TStringField;
    tblDTHeatDTHeatID: TIntegerField;
    tblDTHeatDTID: TIntegerField;
    tblDTHeatSession: TIntegerField;
    tblDTHeatEvent: TIntegerField;
    tblDTHeatHeat: TIntegerField;
    tblDTHeatGender: TStringField;
    tblDTHeattotTime1: TTimeField;
    tblDTHeattotTime2: TTimeField;
    tblDTHeattotTime3: TTimeField;
    tblDTHeatDeviation1: TTimeField;
    tblDTHeatDeviation2: TTimeField;
    tblDTHeatDeviation3: TTimeField;
    tblDTHeatCheckSum: TStringField;
    tblDTINDVIDTLaneID: TIntegerField;
    tblDTINDVIDTHeatID: TIntegerField;
    tblDTINDVLane: TIntegerField;
    tblDTINDVAutoTime: TBooleanField;
    tblDTINDVUseTime1: TBooleanField;
    tblDTINDVUseTime2: TBooleanField;
    tblDTINDVUseTime3: TBooleanField;
    tblDTINDVCalcTime: TTimeField;
    tblDTINDVimgPatch: TIntegerField;
    tblDTINDVTime1: TTimeField;
    tblDTINDVTime2: TTimeField;
    tblDTINDVTime3: TTimeField;
    tblDTINDVSplit1: TTimeField;
    tblDTINDVSplit2: TTimeField;
    tblDTINDVSplit3: TTimeField;
    tblDTINDVSplit4: TTimeField;
    tblDTINDVSplit5: TTimeField;
    tblDTINDVSplit6: TTimeField;
    tblDTINDVSplit7: TTimeField;
    tblDTINDVSplit8: TTimeField;
    tblDTINDVSplit9: TTimeField;
    tblDTINDVSplit10: TTimeField;
    tblDTNoodleDTNoodleID: TIntegerField;
    tblDTNoodleDTLaneID: TIntegerField;
    tblDTNoodleEventID: TIntegerField;
    tblDTNoodleEventType: TIntegerField;
    tblDTNoodleHeatID: TIntegerField;
    tblDTNoodleEntrantID: TIntegerField;
    tblDTNoodleTeamID: TIntegerField;
    tblDTNoodleLaneNumber: TIntegerField;
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
    tblDTTEAM: TFDMemTable;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    IntegerField3: TIntegerField;
    BooleanField1: TBooleanField;
    BooleanField2: TBooleanField;
    BooleanField3: TBooleanField;
    BooleanField4: TBooleanField;
    TimeField1: TTimeField;
    IntegerField4: TIntegerField;
    TimeField2: TTimeField;
    TimeField3: TTimeField;
    TimeField4: TTimeField;
    TimeField5: TTimeField;
    TimeField6: TTimeField;
    TimeField7: TTimeField;
    TimeField8: TTimeField;
    TimeField9: TTimeField;
    TimeField10: TTimeField;
    TimeField11: TTimeField;
    TimeField12: TTimeField;
    TimeField13: TTimeField;
    TimeField14: TTimeField;
    dsDTTEAM: TDataSource;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fDTDataIsActive: Boolean;
    msgHandle: HWND;  // TForm.dtfrmExec ...
    procedure BuildDTData;
    function GetActiveSessionID: integer;
    procedure SetActiveSessionID(const Value: integer);

  public
    { Public declarations }
    procedure ActivateData();
    procedure BuildCSVEventData(AFileName: string);

    procedure WriteToBinary(AFilePath:string);
    procedure ReadFromBinary(AFilePath:string);

    function LocateSession(ASessionID: integer): boolean;
    function LocateEvent(AEventID: integer): boolean;
    function LocateHeat(AHeatID: integer): boolean;
    function LocateNearestSession(aDate: TDateTime): integer;

    function GetNumberOfHeats(AEventID: integer): integer;
    function GetRoundABBREV(AEventID: integer): string;
    property IsActive: Boolean read fDTDataIsActive write fDTDataIsActive;
    property ActiveSessionID: integer read GetActiveSessionID write SetActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
    property MSG_Handle: HWND read msgHandle write msgHandle;


  end;

type
  dtFileType = (dtUnknown, dtDO4, dtDO3, dtALL);
  // 5 x modes m-enabled, m-disabled, a-enabled, a-disabled, unknown (err or nil).
  dtTimeMode = (tmUnknow, tmManualDisabled, tmMaualenabled, tmAutoDisabled,
    tmAutoEnabled);
  dtTimeModeErr = (tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty);

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants, System.DateUtils;

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
    i := GetNumberOfHeats(id);
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

procedure TDTData.DataModuleDestroy(Sender: TObject);
begin
  // clean-up.
end;

function TDTData.GetRoundABBREV(AEventID: integer): string;
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

function TDTData.LocateEvent(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fDTDataIsActive then exit;
  if (aEventID = 0) then exit;
  SearchOptions := [];
  if dsEvent.DataSet.Active then
      result := dsEvent.DataSet.Locate('EventID', aEventID, SearchOptions);
end;

function TDTData.LocateHeat(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fDTDataIsActive then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  if dsHeat.DataSet.Active then
      result := dsHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TDTData.LocateNearestSession(aDate: TDateTime): integer;
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

function TDTData.LocateSession(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fDTDataIsActive then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  if dsSession.DataSet.Active then
      result := dsSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
end;

function TDTData.GetActiveSessionID: integer;
begin
  result := 0;
  if not fDTDataIsActive then exit;
  if qrySession.Active and not qrySession.IsEmpty then
    result := qrySession.FieldByName('SessionID').AsInteger;
end;

function TDTData.GetNumberOfHeats(AEventID: integer): integer;
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

procedure TDTData.ActivateData;
var
  currentSessionID: integer;
begin

  currentSessionID := 0;
  BuildDTData;

  // ASSERT Master - Detail
  // Master - Detail
  tblDTEvent.MasterSource := dsDTSession;
  tblDTEvent.MasterFields := 'SessionID';
  tblDTEvent.DetailFields := 'SessionID';
  tblDTEvent.IndexFieldNames := 'SessionID';

  tblDTHeat.MasterSource := dsDTEvent;
  tblDTHeat.MasterFields := 'EventID';
  tblDTHeat.DetailFields := 'EventID';
  tblDTHeat.IndexFieldNames := 'EventID';

  tblDTINDV.MasterSource := dsDTHeat;
  tblDTINDV.MasterFields := 'HeatID';
  tblDTINDV.DetailFields := 'HeatID';
  tblDTINDV.IndexFieldNames := 'HeatID';

  tblDTTEAM.MasterSource := dsDTHeat;
  tblDTTEAM.MasterFields := 'HeatID';
  tblDTTEAM.DetailFields := 'HeatID';
  tblDTTEAM.IndexFieldNames := 'HeatID';

  tblDTNoodle.MasterSource := dsDTHeat;
  tblDTNoodle.MasterFields := 'DTHeatID';
  tblDTNoodle.DetailFields := 'DTHeatID';
  tblDTNoodle.IndexFieldNames := 'DTHeatID';

  tblDTSession.Active := true;
  tblDTHeat.Active := true;
  tblDTINDV.Active := true;
  tblDTTEAM.Active := true;
  tblDTNoodle.Active := true;

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
      currentSessionID := qrySessionList.FieldByName('SessionID').AsInteger;
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
      // NO PARAMS: instead a filter is used.
      // Zero ID is handled.
      SetActiveSessionID(currentSessionID);
      qryEvent.Open;
      qryDistance.Open;
      qryStroke.Open;
      qryHeat.Open;
      qryINDV.Open;
      qryTEAM.Open;
      qryTEAMEntrant.Open;
      fDTDataIsActive := true;
    end;

  end;
end;

procedure TDTData.BuildDTData;
begin
  fDTDataIsActive := false;
  tblDTSession.Active := false;
  tblDTHeat.Active := false;
  tblDTINDV.Active := false;
  tblDTTEAM.Active := false;
  tblDTNoodle.Active := false;

  // Create Dolphin Timing DATA TABLES SCHEMA.
  // ---------------------------------------------
  tblDTSession.FieldDefs.Clear;
  tblDTSession.FieldDefs.Add('SessionID', ftInteger);
  tblDTSession.FieldDefs.Add('CreatedDT', ftDateTime);
  tblDTSession.FieldDefs.Add('Path', ftString, 512);
  tblDTSession.FieldDefs.Add('FileName', ftString, 512);
  tblDTSession.FieldDefs.Add('SessionStart', ftDateTime); // file creation date
  tblDTSession.FieldDefs.Add('Caption', ftString, 64);
  tblDTSession.FieldDefs.Add('GUIDstr', ftString, 8);
  tblDTSession.FieldDefs.Add('GUID', ftInteger); // DO4 can be converted to int.
  tblDTSession.CreateDataSet;
  // save schema ...
  tblDTSession.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataSession.xml', sfAuto);

  tblDTEvent.FieldDefs.Clear;
  tblDTEvent.FieldDefs.Add('EventID', ftInteger);
  tblDTEvent.FieldDefs.Add('SessionID', ftInteger);
  tblDTEvent.FieldDefs.Add('CreatedDT', ftDateTime);
  tblDTEvent.FieldDefs.Add('EventNum', ftInteger);
  tblDTEvent.FieldDefs.Add('Caption', ftString, 64);
  tblDTEvent.FieldDefs.Add('GenderID', ftString, 1); // 1 MALE, 2 FEMALE or EMPTY
  tblDTEvent.FieldDefs.Add('GenderStr', ftString, 1); // DO4 A=boys, B=girls, X=any.
  tblDTEvent.CreateDataSet;
  // save schema ...
  tblDTEvent.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataEvent.xml', sfAuto);

  tblDTHeat.FieldDefs.Clear;
  // Create the HEAT MEM TABLE schema... tblDTHeat.
  // ---------------------------------------------
  tblDTHeat.FieldDefs.Add('HeatID', ftInteger);
  tblDTHeat.FieldDefs.Add('EventID', ftInteger); // Master- Detail
  tblDTHeat.FieldDefs.Add('HeatNum', ftInteger);
  tblDTHeat.FieldDefs.Add('Caption', ftString, 64);
  // Calculated Data to assist in auto - syncing.
  tblDTHeat.FieldDefs.Add('totTime1', ftTime); // sum of racetimes lanes 1-10.
  tblDTHeat.FieldDefs.Add('totTime2', ftTime); // sum of racetimes lanes 1-10.
  tblDTHeat.FieldDefs.Add('totTime3', ftTime); // sum of racetimes lanes 1-10.
  tblDTINDV.FieldDefs.Add('CheckSum', ftString, 16); // footer.

  tblDTHeat.CreateDataSet;
  // save schema ...
  tblDTHeat.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataHeat.xml');

  tblDTINDV.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTINDV.
  // ---------------------------------------------
  tblDTINDV.FieldDefs.Add('INDVID', ftInteger); // wit ... EntrantID.
  tblDTINDV.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
  tblDTINDV.FieldDefs.Add('Lane', ftInteger); // Lane Number.
  // Dolphin Timing Specific
  tblDTINDV.FieldDefs.Add('Caption', ftString, 64); // Summary of status/mode
  tblDTINDV.FieldDefs.Add('AutoTime', ftBoolean); // Auto-Calc best racetime.
  tblDTINDV.FieldDefs.Add('CalcTime', ftTime); // Swimmers calculated racetime.
  tblDTINDV.FieldDefs.Add('imgPatch', ftInteger); // index in DTData.vimglistDTGrid.
  tblDTINDV.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTINDV.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTINDV.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.
  // tmtimeMode = tmManualDisabled, tmMaualenabled, tmAutoDisabled, tmAutoEnabled.
  tblDTINDV.FieldDefs.Add('Time1Mode', ftInteger);
  tblDTINDV.FieldDefs.Add('Time2Mode', ftInteger);
  tblDTINDV.FieldDefs.Add('Time3Mode', ftInteger);
  // tmtimeModeerr = tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty.
  tblDTINDV.FieldDefs.Add('Time1Err', ftInteger);
  tblDTINDV.FieldDefs.Add('Time2Err', ftInteger);
  tblDTINDV.FieldDefs.Add('Time3Err', ftInteger);
  tblDTINDV.FieldDefs.Add('Deviation1', ftTime); // deviation from average time1
  tblDTINDV.FieldDefs.Add('Deviation2', ftTime); // deviation from average time2
  tblDTINDV.FieldDefs.Add('Deviation3', ftTime); // deviation from average time3
  tblDTINDV.FieldDefs.Add('Split1', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split2', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split3', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split4', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split5', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split6', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split7', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split8', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split9', ftTime); // DO4.
  tblDTINDV.FieldDefs.Add('Split10', ftTime); // DO4.
  tblDTINDV.CreateDataSet;
  // save schema ...
  tblDTINDV.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataINDV.xml');


  tblDTTEAM.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTLane.
  // ---------------------------------------------
  tblDTTEAM.FieldDefs.Add('TEAMID', ftInteger); // wit ... EntrantID.
  tblDTTEAM.FieldDefs.Add('HeatID', ftInteger); // Master- Detail
  tblDTTEAM.FieldDefs.Add('Lane', ftInteger); // Lane Number.
  // Dolphin Timing Specific
  tblDTTEAM.FieldDefs.Add('Caption', ftString, 64);  // Summary of status/mode
  tblDTTEAM.FieldDefs.Add('AutoTime', ftBoolean); // Auto-Calc best racetime.
  tblDTTEAM.FieldDefs.Add('CalcTime', ftTime); // Swimmers calculated racetime.
  tblDTTEAM.FieldDefs.Add('imgPatch', ftInteger); // index in DTData.vimglistDTGrid.
  tblDTTEAM.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTTEAM.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTTEAM.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.

  tblDTTEAM.FieldDefs.Add('Time1Mode', ftInteger);
  tblDTTEAM.FieldDefs.Add('Time2Mode', ftInteger);
  tblDTTEAM.FieldDefs.Add('Time3Mode', ftInteger);
  tblDTTEAM.FieldDefs.Add('Time1Err', ftInteger);
  tblDTTEAM.FieldDefs.Add('Time2Err', ftInteger);
  tblDTTEAM.FieldDefs.Add('Time3Err', ftInteger);
  tblDTTEAM.FieldDefs.Add('Deviation1', ftTime);
  tblDTTEAM.FieldDefs.Add('Deviation2', ftTime);
  tblDTTEAM.FieldDefs.Add('Deviation3', ftTime);
  tblDTTEAM.FieldDefs.Add('Split1', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split2', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split3', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split4', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split5', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split6', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split7', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split8', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split9', ftTime); // DO4.
  tblDTTEAM.FieldDefs.Add('Split10', ftTime); // DO4.
  tblDTTEAM.CreateDataSet;
  // save schema ...
  tblDTTEAM.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataTEAM.xml');

  tblDTNoodle.FieldDefs.Clear;
  // Create the NOODLE MEM TABLE schema... tblDTNoodle.
  // ---------------------------------------------
  tblDTNoodle.FieldDefs.Add('NoodleID', ftInteger);
  tblDTNoodle.FieldDefs.Add('HeatID', ftInteger); // dtHeat Master-Detail.
  tblDTNoodle.FieldDefs.Add('EventTypeID', ftInteger); // INDIV or TEAM
  tblDTNoodle.FieldDefs.Add('SCM_INDIVID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('SCM_TEAMID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('SCM_Lane', ftInteger); //
  tblDTNoodle.FieldDefs.Add('DT_INDIVID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('DT_TEAMID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('DT_Lane', ftInteger); //
  tblDTNoodle.CreateDataSet;
  // save schema ...
  tblDTNoodle.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataNoodle.xml');

  // Master - Detail
  tblDTEvent.MasterSource := dsDTSession;
  tblDTEvent.MasterFields := 'SessionID';
  tblDTEvent.DetailFields := 'SessionID';
  tblDTEvent.IndexFieldNames := 'SessionID';

  tblDTHeat.MasterSource := dsDTEvent;
  tblDTHeat.MasterFields := 'EventID';
  tblDTHeat.DetailFields := 'EventID';
  tblDTHeat.IndexFieldNames := 'EventID';

  tblDTINDV.MasterSource := dsDTHeat;
  tblDTINDV.MasterFields := 'HeatID';
  tblDTINDV.DetailFields := 'HeatID';
  tblDTINDV.IndexFieldNames := 'HeatID';

  tblDTTEAM.MasterSource := dsDTHeat;
  tblDTTEAM.MasterFields := 'HeatID';
  tblDTTEAM.DetailFields := 'HeatID';
  tblDTTEAM.IndexFieldNames := 'HeatID';

  tblDTNoodle.MasterSource := dsDTHeat;
  tblDTNoodle.MasterFields := 'DTHeatID';
  tblDTNoodle.DetailFields := 'DTHeatID';
  tblDTNoodle.IndexFieldNames := 'DTHeatID';

end;

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  fDTDataIsActive := false;
  FConnection := nil;
  msgHandle := 0;
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
  tblDTINDV.SaveToFile(s + 'DTLane.fsBinary', sfXML);
  tblDTTEAM.SaveToFile(s + 'DTLane.fsBinary', sfXML);
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
  tblDTINDV.LoadFromFile(s + 'DTLane.fsBinary');
  tblDTTEAM.LoadFromFile(s + 'DTLane.fsBinary');
  tblDTNoodle.LoadFromFile(s + 'DTNoodle.fsBinary');
end;

procedure TDTData.SetActiveSessionID(const Value: integer);
begin
  {  // NOT using PARAMETERS ... strict Master - Detail build...
      qrySession.DisableControls;
      qrySession.Close;
      qrysession.ParamByName('SESSIONID').AsInteger := ASessionID;
      qrysession.Prepare;
      qrysession.Open;
      qrySession.EnableControls;
  }
  if (Value = 0) then
  begin
    qrySession.Filtered := false;
    qrySession.First;
  end
  else
  begin
    qrySession.Filter := 'SessionID = ' + IntToStr(Value);
    if not qrySession.Filtered then
      qrySession.Filtered := true;
  end;

end;


end.
