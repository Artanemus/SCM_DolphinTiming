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
  FireDAC.Stan.StorageBin;

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
    qryGetCurrentSessionID: TFDQuery;
    tblDTNoodle: TFDMemTable;
    qryDistance: TFDQuery;
    qryStroke: TFDQuery;
    vimglistDTGrid: TVirtualImageList;
    tblDT: TFDMemTable;
    ClientDataSet1: TClientDataSet;
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
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure qryEventAfterScroll(DataSet: TDataSet);
    procedure qryHeatAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fSessionID: integer;
    fDTDataIsActive: Boolean;


  public
    { Public declarations }
    procedure ActivateData();
    function GetNumberOfHeats(AEventID: integer): integer;
    function GetRoundABBREV(AEventID: integer): string;
    property IsActive: Boolean read fDTDataIsActive write fDTDataIsActive;
    property SessionID: integer read fSessionID write fSessionID;
    property Connection: TFDConnection read FConnection write FConnection;

  end;

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses System.Variants;

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
  fDTDataIsActive := false;
  tblDT.Active := false;
  tblDTHeat.Active := false;
  tblDTLane.Active := false;
  tblDTNoodle.Active := false;

  tblDT.FieldDefs.Clear;
  // Create the CORE MEM TABLE schema... tblDT.
  // ---------------------------------------------
  tblDT.FieldDefs.Add('DTID', ftAutoInc);
  tblDT.FieldDefs.Add('CreatedDT', ftDateTime);
  tblDT.FieldDefs.Add('FileName', ftString);
  tblDT.FieldDefs.Add('fSession', ftInteger);
  tblDT.FieldDefs.Add('fEvent', ftInteger);
  tblDT.FieldDefs.Add('fHeat', ftInteger); // DO4.
  tblDT.FieldDefs.Add('fGender', ftString, 1); // DO4 A=boys, B=girls, X=any.
  tblDT.FieldDefs.Add('fGUID', ftString, 8); // DO4 can be converted to int.
  tblDT.CreateDataSet;
  tblDT.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTData.xml', sfAuto);

  tblDTHeat.FieldDefs.Clear;
  // Create the HEAT MEM TABLE schema... tblDTHeat.
  // ---------------------------------------------
  tblDTHeat.FieldDefs.Add('DTHeatID', ftAutoInc);
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

  tblDTHeat.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataHeat.xml');

  tblDTLane.FieldDefs.Clear;
  // Create the LANE MEM TABLE schema... tblDTLane.
  // ---------------------------------------------
  tblDTLane.FieldDefs.Add('DTLaneID', ftAutoInc);
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

  tblDTLane.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataLane.xml');


  tblDTNoodle.FieldDefs.Clear;
  // Create the NOODLE MEM TABLE schema... tblDTNoodle.
  // ---------------------------------------------
  tblDTNoodle.FieldDefs.Add('DTNoodleID', ftAutoInc);
  tblDTNoodle.FieldDefs.Add('DTLaneID', ftInteger); // Master-Detail
  tblDTNoodle.FieldDefs.Add('EventID', ftInteger); // dbo.SwimClubMeet.Event.EventID.
  tblDTNoodle.FieldDefs.Add('EventType', ftInteger); // 1=INDV | 2=TEAM.
  tblDTNoodle.FieldDefs.Add('HeatID', ftInteger); // dbo.SwimClubMeet.Heat.HeatID.
  tblDTNoodle.FieldDefs.Add('EntrantID', ftInteger); // dbo.SwimClubMeet.Entrant.EntrantID.
  tblDTNoodle.FieldDefs.Add('TeamID', ftInteger); // dbo.SwimClubMeet.Team.TeamID.
  tblDTNoodle.FieldDefs.Add('LaneNumber', ftInteger); // dbo.SwimClubMeet. table - either INDV or TEAM.
  tblDTNoodle.CreateDataSet;

  tblDTNoodle.SaveToFile('C:\Users\Ben\Documents\GitHub\SCM_DolphinTiming\DTDataNoodle.xml');

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



  if Assigned(fConnection) and fConnection.Connected then
  begin
    if fSessionID = 0 then
    begin
      // find the current session (today's date) or bestfit.
      qryGetCurrentSessionID.Connection := fConnection;
      qryGetCurrentSessionID.Open;
      if not qryGetCurrentSessionID.IsEmpty then
        fSessionID := qryGetCurrentSessionID.FieldByName('SessionID').AsInteger;
    end;
    // setup DB params and master - detail
    if (fSessionID <> 0) then
    begin
      qrySession.Connection := fConnection;
      qryEvent.Connection := fConnection;
      qryDistance.Connection := fConnection;
      qryStroke.Connection := fConnection;
      qryHeat.Connection := fConnection;
      qryINDV.Connection := fConnection;
      qryTEAM.Connection := fConnection;
      qryTEAMEntrant.Connection := fConnection;
      qrySession.ParamByName('SESSIONID').AsInteger := fSessionID;
      qrySession.Prepare;
      qrySession.Open;
      if qrySession.Active then
      begin
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
end;

procedure TDTData.DataModuleCreate(Sender: TObject);
begin
  fDTDataIsActive := false;
  fSessionID := 0;
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

end.
