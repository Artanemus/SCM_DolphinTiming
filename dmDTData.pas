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
  dtFileType = (dtUnknown, dtDO4, dtDO3, dtALL);
  // 5 x modes m-enabled, m-disabled, a-enabled, a-disabled, unknown (err or nil).
  dtTimeMode = (tmUnknow, tmManualDisabled, tmMaualenabled, tmAutoDisabled,
    tmAutoEnabled);
  dtTimeModeErr = (tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty);
  dtPrecedence = (dtPrecHeader, dtPrecFileName);

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
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fDTDataIsActive: Boolean;
    msgHandle: HWND;  // TForm.dtfrmExec ...
    function GetActiveSessionID: integer;

  public
    { Public declarations }
    procedure ActivateData();
    procedure ActivateDataDT();
    procedure BuildDTData;
    procedure BuildCSVEventData(AFileName: string);

    procedure WriteToBinary(AFilePath:string);
    procedure ReadFromBinary(AFilePath:string);

    procedure EnableDTMasterDetail();
    procedure DisableDTMasterDetail();

    // Look for Dolphin Timing session number given :
    // - in the filename  fn_FileName()
    // - or in the file's text : line one (Header) sListHeaderSessionNum()
    function LocateDT_SessionNum(ASessionNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDT_EventNum(SessionID, AEventNum: integer; Aprecedence: dtPrecedence):
        boolean;
    function LocateDT_HeatNum(EventID, AHeatNum: integer; Aprecedence: dtPrecedence):
        boolean;

    function LocateSession(ASessionID: integer): boolean;
    function LocateEvent(AEventID: integer): boolean;
    function LocateHeat(AHeatID: integer): boolean;
    function LocateDTSession(ASessionID: integer): boolean;
    function LocateDTEvent(AEventID: integer): boolean;
    function LocateDTHeat(AHeatID: integer): boolean;
    function LocateNearestSession(aDate: TDateTime): integer;
    function dtLocateEventNum(AEventNum: integer): boolean;
    function dtLocateSessionNum(ASessionNum: integer): boolean;

    function GetNumberOfHeats(AEventID: integer): integer;
    function GetRoundABBREV(AEventID: integer): string;
    property IsActive: Boolean read fDTDataIsActive write fDTDataIsActive;
    property ActiveSessionID: integer read GetActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
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
  tblDTSession.Active := true;
  tblDTEvent.Active := true;
  tblDTHeat.Active := true;
  tblDTEntrant.Active := true;
  tblDTNoodle.Active := true;

  EnableDTMasterDetail;

end;

procedure TDTData.EnableDTMasterDetail();
begin
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
end;

procedure TDTData.DisableDTMasterDetail();
begin
  // ASSERT Master - Detail
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
  tblDTEvent.First;
  tblDTHeat.First;
  tblDTEntrant.First;
  tblDTNoodle.First;
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
2B,Girls 100 M Breaststroke,2,2,P 

The first line will be event index 1, the second line will be event index 2 and so on. Events
will always come up in event index order although this can be overridden and events and
heats may be run in any order.

}
  sl := TStringlist.Create;
  qryEvent.First();
  while not qryEvent.Eof do
  begin
    s := '';
    // Event Number  Up to 5 alpha-numeric characters. Example: 12B ...
    i := qryEvent.FieldByName('EventNum').AsInteger;
    s := s + IntToStr(i) + ',';
    // Event Name  Up to 25 alpha-numeric characters. Example: Mens 50 Meter Freestyle
    s2 := qryDistance.FieldByName('Caption').AsString + ' ' +
    qryStroke.FieldByName('Caption').AsString;
    s3 := qryEvent.FieldByName('Caption').AsString;
    if Length(s3) > 0 then
      s2 := s2 + ' ' + s3;
    s := s + s2 + ',';
    // Get Number of Heats
    // Number of Heats  (0-99) Number of expected heats for the given event
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
    // Round  A for all, P for prelim or F for final
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

function TDTData.dtLocateEventNum(AEventNum: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fDTDataIsActive then exit;
  if (AEventNum = 0) then exit;
  SearchOptions := [];
  if tbldtEvent.Active then
  begin
    tbldtEvent.DisableControls;
    result := tbldtEvent.Locate('EventNum', AEventNum, SearchOptions);
    tbldtEvent.EnableControls;
  end;
end;

function TDTData.dtLocateSessionNum(ASessionNum: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not fDTDataIsActive then exit;
  if (ASessionNum = 0) then exit;
  SearchOptions := [];
  if tbldtSession.Active then
  begin
    tbldtSession.DisableControls;
    result := tbldtSession.Locate('SessionNum', ASessionNum, SearchOptions);
    tbldtSession.EnableControls;
  end;
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

function TDTData.LocateDTEvent(AEventID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTEvent.Active then exit;
  if (AEventID = 0) then exit;
  SearchOptions := [];
  result := dsdtEvent.DataSet.Locate('EventID', AEventID, SearchOptions);
end;

function TDTData.LocateDTHeat(AHeatID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTHeat.Active then exit;
  if (AHeatID = 0) then exit;
  SearchOptions := [];
  result := dsdtHeat.DataSet.Locate('HeatID', AHeatID, SearchOptions);
end;

function TDTData.LocateDTSession(ASessionID: integer): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tblDTSession.Active then exit;
  if (ASessionID = 0) then exit;
  SearchOptions := [];
  result := dsdtSession.DataSet.Locate('SessionID', ASessionID, SearchOptions);
end;

function TDTData.LocateDT_EventNum(SessionID, AEventNum: integer; Aprecedence:
    dtPrecedence): boolean;
var
  SearchOptions: TLocateOptions;
  indexStr: string;
begin
  result := false;
  if not tbldtEvent.Active then exit;
  if (AEventNum = 0) then exit;
//  SearchOptions := [];
  indexStr := tbldtEvent.IndexFieldNames;
  if (Aprecedence = dtPrecFileName) then
  begin
    tbldtEvent.IndexFieldNames := 'SessionID;fnEventNum';
    result := tbldtEvent.Locate('fnEventNum', AEventNum, SearchOptions);
  end
  else if (Aprecedence = dtPrecHeader) then
  begin
    tbldtEvent.IndexFieldNames := 'SessionID;EventNum';
    result := tbldtEvent.Locate('EventNum', AEventNum, SearchOptions);
  end;
  // restore original index;
  tbldtEvent.IndexFieldNames := indexStr;
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

function TDTData.LocateDT_HeatNum(EventID, AHeatNum: integer; Aprecedence:
    dtPrecedence): boolean;
var
  SearchOptions: TLocateOptions;
  indexStr: string;
begin
  result := false;
  if not tbldtHeat.Active then exit;
  if (AHeatNum = 0) then exit;
  SearchOptions := [];
  indexStr := tbldtHeat.IndexFieldNames;
  if (Aprecedence = dtPrecFileName) then
  begin
    tbldtHeat.IndexFieldNames := 'EventID;fnHeatNum';
    result := tbldtHeat.Locate('fnHeatNum', AHeatNum, SearchOptions)
  end
  else if (Aprecedence = dtPrecHeader) then
  begin
    tbldtHeat.IndexFieldNames := 'EventID;HeatNum';
    result := tbldtHeat.Locate('HeatNum', AHeatNum, SearchOptions);
  end;
  // restore original index;
  tbldtHeat.IndexFieldNames := indexStr;
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

function TDTData.LocateDT_SessionNum(ASessionNum: integer; Aprecedence:
    dtPrecedence): boolean;
var
  SearchOptions: TLocateOptions;
begin
  result := false;
  if not tbldtSession.Active then exit;
  if (ASessionNum = 0) then exit;
  SearchOptions := [];
  if (Aprecedence = dtPrecFileName) then
    result := tbldtSession.Locate('fnSessionNum', ASessionNum, SearchOptions)
  else if (Aprecedence = dtPrecHeader) then
    result := tbldtSession.Locate('SessionNum', ASessionNum, SearchOptions)
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
      fDTDataIsActive := true;
    end;

  end;
end;

procedure TDTData.BuildDTData;
begin
  fDTDataIsActive := false;
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
  // Derived from filename : matches SCM qryEvent.EventNum.
  tblDTSession.FieldDefs.Add('fnEventNum', ftInteger);
  // Derived from filename : matches SCM qryHeat.HeatNum.
  tblDTSession.FieldDefs.Add('fnHeatNum', ftInteger);
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
  // Round  A for all, P for prelim or F for final.
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
  tblDTEntrant.FieldDefs.Add('AutoTime', ftBoolean); // Auto-Calc best racetime.
  tblDTEntrant.FieldDefs.Add('CalcTime', ftTime); // Swimmers calculated racetime.
  tblDTEntrant.FieldDefs.Add('imgPatch', ftInteger); // index in DTData.vimglistDTGrid.
  tblDTEntrant.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTEntrant.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTEntrant.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.
  // tmtimeMode = tmManualDisabled, tmMaualenabled, tmAutoDisabled, tmAutoEnabled.
  tblDTEntrant.FieldDefs.Add('Time1Mode', ftInteger);
  tblDTEntrant.FieldDefs.Add('Time2Mode', ftInteger);
  tblDTEntrant.FieldDefs.Add('Time3Mode', ftInteger);
  // tmtimeModeerr = tmeUnknow, tmeBadTime, tmeExceedsDeviation, tmeEmpty.
  tblDTEntrant.FieldDefs.Add('Time1Err', ftInteger);
  tblDTEntrant.FieldDefs.Add('Time2Err', ftInteger);
  tblDTEntrant.FieldDefs.Add('Time3Err', ftInteger);
  // calculated deviation for each timekeeper based on average
  tblDTEntrant.FieldDefs.Add('Deviation1', ftTime); // deviation from average time1
  tblDTEntrant.FieldDefs.Add('Deviation2', ftTime); // deviation from average time2
  tblDTEntrant.FieldDefs.Add('Deviation3', ftTime); // deviation from average time3
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

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  // MAKE LIVE THE DOLPHIN TIMING TABLES
  tblDTSession.Active := true;

  // Master - Detail
  tblDTEvent.Active := true;

  if not Assigned(tblDTEvent.MasterSource) then
  begin
    tblDTEvent.MasterSource := dsDTSession;
    tblDTEvent.MasterFields := 'SessionID';
    tblDTEvent.DetailFields := 'SessionID';
    tblDTEvent.IndexFieldNames := 'SessionID';
  end;

  // Master - Detail
  tblDTHeat.Active := true;

  if not Assigned(tblDTHeat.MasterSource) then
  begin
    tblDTHeat.Active := true;
    tblDTHeat.MasterSource := dsDTEvent;
    tblDTHeat.MasterFields := 'EventID';
    tblDTHeat.DetailFields := 'EventID';
    tblDTHeat.IndexFieldNames := 'EventID';
  end;

  // Master - Detail
  tblDTEntrant.Active := true;

  if not Assigned(tblDTEntrant.MasterSource) then
  begin
    tblDTEntrant.Active := true;
    tblDTEntrant.MasterSource := dsDTHeat;
    tblDTEntrant.MasterFields := 'HeatID';
    tblDTEntrant.DetailFields := 'HeatID';
    tblDTEntrant.IndexFieldNames := 'HeatID';
  end;

  // Master - Detail
  tblDTNoodle.Active := true;

  if not Assigned(tblDTNoodle.MasterSource) then
  begin
    tblDTNoodle.Active := true;
    tblDTNoodle.MasterSource := dsDTHeat;
    tblDTNoodle.MasterFields := 'HeatID';
    tblDTNoodle.DetailFields := 'HeatID';
    tblDTNoodle.IndexFieldNames := 'HeatID';
  end;

  fDTDataIsActive := true;

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




end.
