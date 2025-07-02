unit dlgScanOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, tdSetting,
  uAppUtils;

type
	TScanOptions = class(TForm)
    pnlHeader: TPanel;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    lblHeader: TLabel;
    rgrpScanOptions: TRadioGroup;
    edtSessionID: TEdit;
    lblSessionID: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    rgrpFileType: TRadioGroup;
    procedure FormDestroy(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
		fSessionID: Integer;
		FWildCard: string;
		procedure SetSessionID(const Value: Integer);
    { Private declarations }
	public
		property SessionID: Integer read fSessionID write SetSessionID;
		property WildCard: string read FWildCard;

		{ Public declarations }
  end;

var
  ScanOptions: TScanOptions;

implementation

{$R *.dfm}

procedure TScanOptions.FormDestroy(Sender: TObject);
begin
  if Assigned(Settings) then
  begin
    Settings.ScanOption := rgrpScanOptions.ItemIndex;
    Settings.ScanOptionSessionID := SessionID;
  end;
end;

procedure TScanOptions.FormCreate(Sender: TObject);
begin
	edtSessionID.Text := '';
	fSessionID := 0;
	FWildCard := '';
	if Assigned(Settings) then
	begin
		if Settings.ScanOption in [0,1] then
			rgrpScanOptions.ItemIndex := Settings.ScanOption
		else
			rgrpScanOptions.ItemIndex := -1;
		edtSessionID.Text := IntToStr(Settings.ScanOptionSessionID);

		case Settings.DTUseFileType of
			0:
				rgrpFileType.ItemIndex := 0; //BOTH (default)
			1:
				rgrpFileType.ItemIndex := 1; // *.DO3
			2:
				rgrpFileType.ItemIndex := 2; // *.DO4
		else
			rgrpFileType.ItemIndex := 0;
		end;
	end;
end;

procedure TScanOptions.btnCancelClick(Sender: TObject);
begin
	fSessionID := 0;
	fWildCard := '';
	ModalResult := mrCancel;
end;

procedure TScanOptions.btnOkClick(Sender: TObject);
var
  i: integer;
begin
  if length(edtSessionID.Text) > 0 then
  begin
    // TEdit.NumbersOnly = true;
    // Note, however, that a user can paste non-numeric characters in the
    // textfield even when this property is set
		i := StrToIntDef(uAppUtils.StripNonNumeric(edtSessionID.Text), 0);
		fSessionID := i;
  end
  else
		fSessionID := 0;

  if Assigned(Settings) then
  begin
    if rgrpFileType.ItemIndex in [0..2] then
			Settings.DTUseFileType := rgrpFileType.ItemIndex
		else 	Settings.DTUseFileType := 0;
	end;

	case rgrpFileType.ItemIndex of
		0: fWildCard := '*.DO?';
		1: fWildCard := '*.DO3';
		2: fWildCard := '*.DO4';
		else fWildCard := '';
	end;

	if (rgrpScanOptions.ItemIndex = 1) and (fSessionID <> 0)
		and (not fWildCard.IsEmpty()) then
		// scan for secific session...
		fWildCard := IntToStr(fSessionID) + '-' + fWildCard;

	ModalResult := mrOk;
end;

procedure TScanOptions.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_Escape then
  begin
		fSessionID := 0;
		fWildCard := '';
		Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TScanOptions.SetSessionID(const Value: Integer);
begin
	fSessionID := Value;
	if (fSessionID <= 0) then
			edtSessionID.Text := ''
	else
		edtSessionID.Text := IntToStr(fSessionID);
end;


end.
