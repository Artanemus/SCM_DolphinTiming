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
  FireDAC.Stan.StorageBin, FireDAC.Stan.Storage;

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
    tblDT: TFDMemTable;
    tblDTHeat: TFDMemTable;
    dsDT: TDataSource;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    tblDTLane: TFDMemTable;
    dsDTHeat: TDataSource;
    dsDTLane: TDataSource;
    qrySwimClub: TFDQuery;
    dsSwimClub: TDataSource;
    qrySessionList: TFDQuery;
    dsSessionList: TDataSource;
    tblDTDTID: TIntegerField;
    tblDTCreatedDT: TDateTimeField;
    tblDTFileName: TStringField;
    tblDTfSession: TIntegerField;
    tblDTfEvent: TIntegerField;
    tblDTfHeat: TIntegerField;
    tblDTfGender: TStringField;
    tblDTfGUID: TStringField;
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
    tblDTLaneDTLaneID: TIntegerField;
    tblDTLaneDTHeatID: TIntegerField;
    tblDTLaneLane: TIntegerField;
    tblDTLaneAutoTime: TBooleanField;
    tblDTLaneUseTime1: TBooleanField;
    tblDTLaneUseTime2: TBooleanField;
    tblDTLaneUseTime3: TBooleanField;
    tblDTLaneCalcTime: TTimeField;
    tblDTLaneimgPatch: TIntegerField;
    tblDTLaneTime1: TTimeField;
    tblDTLaneTime2: TTimeField;
    tblDTLaneTime3: TTimeField;
    tblDTLaneSplit1: TTimeField;
    tblDTLaneSplit2: TTimeField;
    tblDTLaneSplit3: TTimeField;
    tblDTLaneSplit4: TTimeField;
    tblDTLaneSplit5: TTimeField;
    tblDTLaneSplit6: TTimeField;
    tblDTLaneSplit7: TTimeField;
    tblDTLaneSplit8: TTimeField;
    tblDTLaneSplit9: TTimeField;
    tblDTLaneSplit10: TTimeField;
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
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure qryEventAfterScroll(DataSet: TDataSet);
    procedure qryHeatAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fDTDataIsActive: Boolean;
    procedure BuildDTData;
    function GetActiveSessionID: integer;

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
    property ActiveSessionID: integer read GetActiveSessionID;
    property Connection: TFDConnection read FConnection write FConnection;

  end;

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
begin

  BuildDTData;

  // ASSERT Master - Detail
  tblDTHeat.MasterSource := dsDT;
  tblDTHeat.MasterFields := 'DTID';
  tblDTHeat.DetailFields := 'DTID';
  tblDTHeat.IndexFieldNames := 'DTID';

  tblDTLane.MasterSource := dsDTHeat;
  tblDTLane.MasterFields := 'DTHeatID';
  tblDTLane.DetailFields := 'DTHeatID';
  tblDTLane.IndexFieldNames := 'DTHeatID';

  tblDTNoodle.MasterSource := dsDTLane;
  tblDTNoodle.MasterFields := 'DTLaneID';
  tblDTNoodle.DetailFields := 'DTLaneID';
  tblDTNoodle.IndexFieldNames := 'DTLaneID';

  tblDT.Active := true;
  tblDTHeat.Active := true;
  tblDTLane.Active := true;
  tblDTNoodle.Active := true;

  if Assigned(fConnection) and fConnection.Connected then
  begin
    // GRAND MASTER.
    qrySwimClub.Connection := fConnection;
    qrySwimClub.Active;

    qrySessionList.Connection := fConnection;
    qrySessionList.Active;

    if qrySessionList.Active and not qrySessionList.IsEmpty then
      qrySessionList.First;

    // setup DB params and master - detail
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
  tblDT.Active := false;
  tblDTHeat.Active := false;
  tblDTLane.Active := false;
  tblDTNoodle.Active := false;

  tblDT.FieldDefs.Clear;
  // Create the CORE MEM TABLE schema... tblDT.
  // ---------------------------------------------
  tblDT.FieldDefs.Add('DTID', ftInteger);
  tblDT.FieldDefs.Add('CreatedDT', ftDateTime);
  tblDT.FieldDefs.Add('FileName', ftString, 512);
  tblDT.FieldDefs.Add('fSession', ftInteger);
  tblDT.FieldDefs.Add('fEvent', ftInteger);
  tblDT.FieldDefs.Add('fHeat', ftInteger); // DO4.
  tblDT.FieldDefs.Add('fGender', ftString, 1); // DO4 A=boys, B=girls, X=any.
  tblDT.FieldDefs.Add('fGUID', ftString, 8); // DO4 can be converted to int.
  tblDT.CreateDataSet;

  // save schema ...
  tblDT.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTData.xml', sfAuto);

  tblDTHeat.FieldDefs.Clear;
  // Create the HEAT MEM TABLE schema... tblDTHeat.
  // ---------------------------------------------
  tblDTHeat.FieldDefs.Add('DTHeatID', ftInteger);
  tblDTHeat.FieldDefs.Add('DTID', ftInteger); // Master- Detail
  // Dolphin Timing file header - line one.
  tblDTHeat.FieldDefs.Add('Session', ftInteger); // header param 1.
  tblDTHeat.FieldDefs.Add('Event', ftInteger); // header param 2.
  tblDTHeat.FieldDefs.Add('Heat', ftInteger); // header param 3.
  tblDTHeat.FieldDefs.Add('Gender', ftString, 1); // header param 4. A=boys, B=girls, X=any.
  // Date to assist in auto - syncing
  tblDTHeat.FieldDefs.Add('totTime1', ftTime); // sum of racetimes lanes 1-10.
  tblDTHeat.FieldDefs.Add('totTime2', ftTime); // sum of racetimes lanes 1-10.
  tblDTHeat.FieldDefs.Add('totTime3', ftTime); // sum of racetimes lanes 1-10.
  tblDTHeat.FieldDefs.Add('Deviation1', ftTime);
  tblDTHeat.FieldDefs.Add('Deviation2', ftTime);
  tblDTHeat.FieldDefs.Add('Deviation3', ftTime);
  tblDTHeat.FieldDefs.Add('CheckSum', ftString, 16); // footer.
  tblDTHeat.CreateDataSet;

  // save schema ...
  tblDTHeat.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataHeat.xml');

  tblDTLane.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTLane.
  // ---------------------------------------------
  tblDTLane.FieldDefs.Add('DTLaneID', ftInteger);
  tblDTLane.FieldDefs.Add('DTHeatID', ftInteger); // Master- Detail
  tblDTLane.FieldDefs.Add('Lane', ftInteger); // Lane Number.
  tblDTLane.FieldDefs.Add('AutoTime', ftBoolean); // Auto-Calc best racetime.
  tblDTLane.FieldDefs.Add('UseTime1', ftBoolean); // Manual select time.
  tblDTLane.FieldDefs.Add('UseTime2', ftBoolean); // Manual select time.
  tblDTLane.FieldDefs.Add('UseTime3', ftBoolean); // Manual select time.
  tblDTLane.FieldDefs.Add('CalcTime', ftTime); // Swimmers calculated racetime.
  tblDTLane.FieldDefs.Add('imgPatch', ftInteger); // index in DTData.vimglistDTGrid.
  tblDTLane.FieldDefs.Add('Time1', ftTime); // timekeeper 1.
  tblDTLane.FieldDefs.Add('Time2', ftTime); // timekeeper 2.
  tblDTLane.FieldDefs.Add('Time3', ftTime);  // timekeeper 3.
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

  // save schema ...
  tblDTLane.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataLane.xml');


  tblDTNoodle.FieldDefs.Clear;
  // Create the NOODLE MEM TABLE schema... tblDTNoodle.
  // ---------------------------------------------
  tblDTNoodle.FieldDefs.Add('DTNoodleID', ftInteger);
  tblDTNoodle.FieldDefs.Add('DTLaneID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('EventID', ftInteger); // dbo.SwimClubMeet.Event.EventID.
  tblDTNoodle.FieldDefs.Add('EventType', ftInteger); // 1=INDV | 2=TEAM.
  tblDTNoodle.FieldDefs.Add('HeatID', ftInteger); // dbo.SwimClubMeet.Heat.HeatID.
  tblDTNoodle.FieldDefs.Add('EntrantID', ftInteger); // dbo.SwimClubMeet.Entrant.EntrantID.
  tblDTNoodle.FieldDefs.Add('TeamID', ftInteger); // dbo.SwimClubMeet.Team.TeamID.
  tblDTNoodle.FieldDefs.Add('LaneNumber', ftInteger); // dbo.SwimClubMeet. table - either INDV or TEAM.
  tblDTNoodle.CreateDataSet;

  // save schema ...
  tblDTNoodle.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataNoodle.xml');

  // Master - Detail
  tblDTHeat.MasterSource := dsDT;
  tblDTHeat.MasterFields := 'DTID';
  tblDTHeat.DetailFields := 'DTID';
  tblDTHeat.IndexFieldNames := 'DTID';

  tblDTLane.MasterSource := dsDTHeat;
  tblDTLane.MasterFields := 'DTHeatID';
  tblDTLane.DetailFields := 'DTHeatID';
  tblDTLane.IndexFieldNames := 'DTHeatID';

  tblDTNoodle.MasterSource := dsDTLane;
  tblDTNoodle.MasterFields := 'DTLaneID';
  tblDTNoodle.DetailFields := 'DTLaneID';
  tblDTNoodle.IndexFieldNames := 'DTLaneID';

end;

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  fDTDataIsActive := false;
  FConnection := nil;
end;

procedure TDTData.qryEventAfterScroll(DataSet: TDataSet);
begin
  // send message to update dtfrmExec lblHeatNum
  if Owner is TForm then
    PostMessage(TForm(Owner).Handle,SCM_EVENTSCROLL, 0, 0);
end;

procedure TDTData.qryHeatAfterScroll(DataSet: TDataSet);
begin
  // send message to update dtfrmExec lblHeatNum
  if Owner is TForm then
    PostMessage(TForm(Owner).Handle,SCM_HEATSCROLL, 0, 0);
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
  tblDT.SaveToFile(s + 'DTMaster.fsBinary', sfXML);
  tblDTHeat.SaveToFile(s + 'DTHeat.fsBinary', sfXML);
  tblDTLane.SaveToFile(s + 'DTLane.fsBinary', sfXML);
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
  tblDT.LoadFromFile(s + 'DTMaster.fsBinary');
  tblDTHeat.LoadFromFile(s + 'DTHeat.fsBinary');
  tblDTLane.LoadFromFile(s + 'DTLane.fsBinary');
end;


end.
