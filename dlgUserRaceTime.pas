unit dlgUserRaceTime;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TUserRaceTime = class(TForm)
    pnlFooter: TPanel;
    pnlBody: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    edtUserRaceTime: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fManualRaceTime: TTime;
    fUserRaceTime: TTime;
  public
    { Public declarations }
    property ManualRaceTime: TTime read FManualRaceTime write FManualRaceTime;
    property UserRaceTime: TTime read fUserRaceTime write fUserRaceTime;
  end;

var
  UserRaceTime: TUserRaceTime;

implementation

{$R *.dfm}

uses System.DateUtils;

procedure TUserRaceTime.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TUserRaceTime.btnOkClick(Sender: TObject);
var
dt: TDateTime;
fs: TFormatSettings;
begin
  fs := TFormatSettings.Create;
  if TryStrToTime(edtUserRaceTime.Text, dt, fs) then
    fUserRaceTime := TimeOf(dt);

  ModalResult := mrOk;
end;

procedure TUserRaceTime.FormCreate(Sender: TObject);
begin
  fManualRaceTime := 0;
  fUserRaceTime := 0;
end;

procedure TUserRaceTime.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin
    ModalResult := mrCancel;
  end;
end;

procedure TUserRaceTime.FormShow(Sender: TObject);
begin
  if (fUserRaceTime <> 0) then
    edtUserRaceTime.Text := TimeToStr(fUserRaceTime)
  else
    edtUserRaceTime.Text := TimeToStr(fmanualRaceTime);
end;

end.
