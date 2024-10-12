unit dmDTData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, dmSCM,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

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
    vimglistDT: TVirtualImageList;
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
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
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

end.
