unit dmDTData;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client;

type
  TDTData = class(TDataModule)
    scmConnection: TFDConnection;
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
  if Assigned(fConnection) and fConnection.Connected then
  begin
    scmConnection := FConnection;
    // setup DB params and master - detail
    if (fSessionID <> 0) then
    begin
      // qrySession

      // open all tables.
      fDTDataIsActive := true;
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
