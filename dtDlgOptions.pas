unit dtDlgOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dmDTData, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.VirtualImage, Vcl.Mask, dtuSetting;

type
  TdlgOptions = class(TForm)
    btnClose: TButton;
    btnedtAppData: TButtonedEdit;
    btnedtEventCSV: TButtonedEdit;
    btnedtMeetFolder: TButtonedEdit;
    btnedtReConstruct: TButtonedEdit;
    chkbxRenameSession: TCheckBox;
    lblAppCaption1: TLabel;
    lbledtDeviation: TLabeledEdit;
    lblAppData: TLabel;
    lblHeaderTitle: TLabel;
    lblMeetFolder: TLabel;
    lblEventCSV: TLabel;
    lblReConstructDO4: TLabel;
    pgcntrl: TPageControl;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    pnlHeader: TPanel;
    rgrpMeanTimeMethod: TRadioGroup;
    tabSettings: TTabSheet;
    tabsheetPaths: TTabSheet;
    vimgDT: TVirtualImage;
    BrowseFolderDlg: TFileOpenDialog;
    rgrpPrecedence: TRadioGroup;
    procedure btnCloseClick(Sender: TObject);
    procedure btnedtAppDataRightButtonClick(Sender: TObject);
    procedure btnedtEventCSVRightButtonClick(Sender: TObject);
    procedure btnedtMeetFolderRightButtonClick(Sender: TObject);
    procedure btnedtReConstructRightButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure LoadFromSettings;
    procedure LoadSettings;
    procedure SaveToSettings;
  end;

var
  dlgOptions: TdlgOptions;

implementation

{$R *.dfm}


procedure TdlgOptions.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgOptions.btnedtAppDataRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for application data folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtAppData.Text) ;
  BrowseFolderDlg.DefaultExtension := '.CSV';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select SCM_DolphinTiming data folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtAppData.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TdlgOptions.btnedtEventCSVRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for DT events CSV export folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtEventCSV.Text) ;
  BrowseFolderDlg.DefaultExtension := '.CSV';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select Dolphin Timing event CSV folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtEventCSV.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TdlgOptions.btnedtMeetFolderRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for meets folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtMeetFolder.Text) ;
  BrowseFolderDlg.DefaultExtension := '.DO4';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'Dolphin Timing meets DO4';
  ft.FileMask :=   '*.DO4';
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'Dolphin Timing meets DO3';
  ft.FileMask :=   '*.DO3';
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select Dolphin Timing meets folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtMeetFolder.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TdlgOptions.btnedtReConstructRightButtonClick(Sender: TObject);
var
ft: TFileTypeItem;
begin
  // browse for export of SCM to Dolphin Timing DO4 folder.
  BrowseFolderDlg.DefaultFolder :=
    IncludeTrailingPathDelimiter(btnedtReConstruct.Text) ;
  BrowseFolderDlg.DefaultExtension := '.CSV';
  BrowseFolderDlg.OkButtonLabel := 'Select Folder';
  BrowseFolderDlg.FileTypes.Clear;
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'Dolphin Timing meets file.';
  ft.FileMask :=   '*.DO4;*.DO3';
  ft := BrowseFolderDlg.FileTypes.Add;
  ft.DisplayName :=  'All Files';
  ft.FileMask :=   '*.*';
  BrowseFolderDlg.Title := 'Select re-construct folder.';
  if BrowseFolderDlg.Execute then
  begin
    btnedtReConstruct.Text := BrowseFolderDlg.FileName;
  end;
end;

procedure TdlgOptions.FormDestroy(Sender: TObject);
begin
  SaveToSettings;
end;

procedure TdlgOptions.FormCreate(Sender: TObject);
begin
  // INIT ...
  pgcntrl.TabIndex := 0;
end;

procedure TdlgOptions.FormShow(Sender: TObject);
begin
  LoadSettings;
end;

procedure TdlgOptions.LoadFromSettings;
begin
  btnedtMeetFolder.Text := Settings.DolphinMeetsFolder;
  btnedtEventCSV.Text := Settings.DolphinEventFolder;
  btnedtAppData.Text := Settings.DolphinAppData;
  btnedtReConstruct.Text := Settings.DolphinReConstruct;
  case Settings.DolphinPrecedence of
  dtPrecHeader:
    rgrpPrecedence.ItemIndex := 0;
  dtPrecFileName:
    rgrpPrecedence.ItemIndex := 1;
  end;
  case Settings.DolphinCalcRTMethod of
  1:
    // extended SCM method.
    rgrpMeanTimeMethod.ItemIndex := 1;
  else
    // default DT method (default).
    rgrpMeanTimeMethod.ItemIndex := 0;
  end;
end;

procedure TdlgOptions.LoadSettings;
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

procedure TdlgOptions.SaveToSettings;
begin
  Settings.DolphinMeetsFolder := btnedtMeetFolder.Text;
  Settings.DolphinEventFolder := btnedtEventCSV.Text;
  Settings.DolphinAppData := btnedtAppData.Text;
  Settings.DolphinReConstruct := btnedtReConstruct.Text;
  case rgrpPrecedence.ItemIndex of
    1:
    Settings.DolphinPrecedence := dtPrecFileName;
    else
    Settings.DolphinPrecedence := dtPrecHeader;
  end;

  Settings.SaveToFile();
end;

end.
