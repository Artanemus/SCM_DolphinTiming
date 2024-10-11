unit dtfrmExec;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus, dmSCM, dmDTData, dtuSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TdtExec = class(TForm)
    btnPrevEvent: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnNextDTFile: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    File2: TMenuItem;
    ImageCollection1: TImageCollection;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Setup1: TMenuItem;
    Button1: TButton;
    btnRefresh: TButton;
    dbgridSCM: TDBGrid;
    dbgridDT: TDBGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection; aSessionID: Integer = 0);

  end;

var
  dtExec: TdtExec;

implementation

{$R *.dfm}

procedure TdtExec.FormCreate(Sender: TObject);
begin
  { test for and connect to DTData}
  // C R E A T E   T H E   D A T A M O D U L E .
  if NOT Assigned(DTData) then
    DTData := TDTData.Create(Self);
  if DTData.scmConnection.Connected then
    DTData.scmConnection.Connected := false;
end;

procedure TdtExec.Prepare(AConnection: TFDConnection; aSessionID: Integer);
begin
  FConnection := AConnection;
  if Assigned(DTData) then
  begin
    DTData.Connection := FConnection;
    DTData.SessionID := aSessionID;
    DTData.ActivateData;
  end;
end;

end.
