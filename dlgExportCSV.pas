unit dlgExportCSV;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, dmIMG,
  Vcl.VirtualImage, tdSetting;

type
  TExportCSV = class(TForm)
    lblEventCSV: TLabel;
    btnedtMeetProgram: TButtonedEdit;
    BrowseFolderDlg: TFileOpenDialog;
    pnlFooter: TPanel;
    pnlBody: TPanel;
    vimgInfo1: TVirtualImage;
    BalloonHint1: TBalloonHint;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnedtMeetProgramRightButtonClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure vimgInfo1MouseEnter(Sender: TObject);
    procedure vimgInfo1MouseLeave(Sender: TObject);
  private
    procedure LoadFromSettings;
    procedure LoadSettings;
    procedure SaveToSettings;
  public
    { Public declarations }
  end;

var
  ExportCSV: TExportCSV;

implementation

{$R *.dfm}

procedure TExportCSV.btnedtMeetProgramRightButtonClick(Sender: TObject);

begin
  // Default folder to browse for TD "meet program" files.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(Settings.MeetsFolder) ;
  if BrowseFolderDlg.Execute then
  begin
    btnedtMeetProgram.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TExportCSV.vimgInfo1MouseEnter(Sender: TObject);
begin
  BalloonHint1.Title := 'Export Folder ...';
	BalloonHint1.Description := '''
		To begin, the SwimClubMeet database must be connected.
		Using the current selected SCM session, the application writes a CSV file
		to the given folder.
		This file contains data which can be read by the Dolphin Timing system to
		initalize and/or update it's application state.
		''';
  BalloonHint1.ShowHint(vimgInfo1);
end;

procedure TExportCSV.vimgInfo1MouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;
end;

procedure TExportCSV.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TExportCSV.btnOkClick(Sender: TObject);
begin
  SaveToSettings;
  ModalResult := mrOk;
end;

procedure TExportCSV.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TExportCSV.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TExportCSV.LoadFromSettings;
begin
  btnedtMeetProgram.Text := Settings.ProgramFolder;
end;

procedure TExportCSV.LoadSettings;
begin
  if Settings = nil then
    Settings := TPrgSetting.Create;
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TExportCSV.SaveToSettings;
begin
  Settings.ProgramFolder := btnedtMeetProgram.Text;
	Settings.SaveToFile();
end;

end.
