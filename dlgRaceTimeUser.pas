unit dlgRaceTimeUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TRaceTimeUser = class(TForm)
    pnlFooter: TPanel;
    pnlBody: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    edtRaceTimeUser: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fRaceTime: TTime;
    fRaceTimeUser: TTime;
  public
    { Public declarations }
    property RaceTime: TTime read FRaceTime write FRaceTime;
    property RaceTimeUser: TTime read fRaceTimeUser write fRaceTimeUser;
  end;

var
  RaceTimeUser: TRaceTimeUser;

implementation

{$R *.dfm}

uses System.DateUtils;

procedure TRaceTimeUser.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRaceTimeUser.btnOkClick(Sender: TObject);
var
dt: TDateTime;
fs: TFormatSettings;
begin
  fs := TFormatSettings.Create;
  if TryStrToTime(edtRaceTimeUser.Text, dt, fs) then
    fRaceTimeUser := TimeOf(dt);

  ModalResult := mrOk;
end;

procedure TRaceTimeUser.FormCreate(Sender: TObject);
begin
  fRaceTime := 0;
  fRaceTimeUser := 0;
end;

procedure TRaceTimeUser.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin
    ModalResult := mrCancel;
  end;
end;

procedure TRaceTimeUser.FormShow(Sender: TObject);
begin
  if (fRaceTimeUser <> 0) then
    edtRaceTimeUser.Text := TimeToStr(fRaceTimeUser)
  else
    edtRaceTimeUser.Text := TimeToStr(fRaceTime);
end;

end.
