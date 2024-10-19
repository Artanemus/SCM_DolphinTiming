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
  FireDAC.Phys.SQLiteVDataSet;

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
    memtblLink: TFDMemTable;
    memtblLinkID: TFDAutoIncField;
    memtblLinkEventType: TBooleanField;
    memtblLinkHeatID: TIntegerField;
    memtblLinkEntrantID: TIntegerField;
    memtblLinkTeamID: TIntegerField;
    memtblLinkLane: TIntegerField;
    memtblLinkEventID: TIntegerField;
    memtblLinkDTFileName: TStringField;
    qryDistance: TFDQuery;
    qryStroke: TFDQuery;
    vimglistDTGrid: TVirtualImageList;
    memtblDT: TFDMemTable;
    memtblDTID: TFDAutoIncField;
    memtblDTfSessionNum: TIntegerField;
    memtblDTfEventNum: TIntegerField;
    memtblDTfHeatNum: TIntegerField;
    memtblDTfGender: TStringField;
    memtblDTfRaceID: TStringField;
    memtblDTfCreationDT: TDateTimeField;
    memtblDTfFileType: TIntegerField;
    memtblDTSession: TIntegerField;
    memtblDTEvent: TIntegerField;
    memtblDTHeat: TIntegerField;
    memtblDTGender: TStringField;
    memtblDTLaneNum: TIntegerField;
    memtblDTTime1: TTimeField;
    memtblDTTime2: TTimeField;
    memtblDTTime3: TTimeField;
    memtblDTSplit1: TTimeField;
    memtblDTSplit2: TTimeField;
    memtblDTSplit4: TTimeField;
    memtblDTSplit5: TTimeField;
    memtblDTSplit6: TTimeField;
    memtblDTCheckSum: TStringField;
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

    property IsActive: Boolean read fDTDataIsActive write fDTDataIsActive;
    property SessionID: integer read fSessionID write fSessionID;
    property Connection: TFDConnection read FConnection write FConnection;

  end;

var
  DTData: TDTData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDTData.DataModuleDestroy(Sender: TObject);
begin
  // clean-up.
end;

procedure TDTData.ActivateData;
begin
  fDTDataIsActive := false;
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
