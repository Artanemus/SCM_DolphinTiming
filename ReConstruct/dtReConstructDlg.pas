unit dtReConstructDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.VirtualImage, tdSetting;

type
  TReConstructDlg = class(TForm)
    pnlFooter: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlBody: TPanel;
    lblEventCSV: TLabel;
    vimgInfo1: TVirtualImage;
    btnedtExportFolder: TButtonedEdit;
    BrowseFolderDlg: TFileOpenDialog;
    BalloonHint1: TBalloonHint;
    lblInfo: TLabel;
    rgrpFileType: TRadioGroup;
    procedure btnCancelClick(Sender: TObject);
    procedure btnedtExportFolderClick(Sender: TObject);
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
  ReConstructDlg: TReConstructDlg;

implementation

{$R *.dfm}

procedure TReConstructDlg.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TReConstructDlg.btnedtExportFolderClick(Sender: TObject);
begin
  // Default folder to export result files.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(Settings.MeetsFolder) ;
  if BrowseFolderDlg.Execute then
  begin
    btnedtExportFolder.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TReConstructDlg.btnOkClick(Sender: TObject);
begin
  SaveToSettings;
  ModalResult := mrOk;
end;

procedure TReConstructDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TReConstructDlg.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TReConstructDlg.LoadFromSettings;
begin
  btnedtExportFolder.Text := Settings.ReConstructFolder;
end;

procedure TReConstructDlg.LoadSettings;
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

procedure TReConstructDlg.SaveToSettings;
begin
  Settings.ReConstructFolder := btnedtExportFolder.Text;
  Settings.SaveToFile();
end;

procedure TReConstructDlg.vimgInfo1MouseEnter(Sender: TObject);
begin
  BalloonHint1.Title := 'Export Folder ...';
  BalloonHint1.Description := '''
		The application writes re-engineered DO3 or DO4 files to the given folder.
		These files contains ASCII data identical to "results" files produced by
		CTS Dolphin Timing. They can be view in any simple text application.
		Select the variant you wish to create. Select the folder to write out the
		files and press "Re-Construct and Export Results".
		''';
  BalloonHint1.ShowHint(TControl(Sender));
end;

procedure TReConstructDlg.vimgInfo1MouseLeave(Sender: TObject);
begin
  BalloonHint1.HideHint;

end;

end.
