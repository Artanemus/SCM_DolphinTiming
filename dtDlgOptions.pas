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
    btnedtReConstructDO4: TButtonedEdit;
    chkbxEnableManualMeanTime: TCheckBox;
    chkbxRenameSession: TCheckBox;
    lblAppCaption1: TLabel;
    lbledtDeviation: TLabeledEdit;
    lblAppData: TLabel;
    lblHeaderTitle: TLabel;
    lblMeetFolder: TLabel;
    lblEventCSV: TLabel;
    lblReConstructDO4: TLabel;
    pgcntrl: TPageControl;
    PickCSVFolder: TFileOpenDialog;
    pnlBody: TPanel;
    pnlFooter: TPanel;
    pnlHeader: TPanel;
    rgrpMeanTimeMethod: TRadioGroup;
    tabSettings: TTabSheet;
    tabsheetPaths: TTabSheet;
    vimgDT: TVirtualImage;
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
  btnedtReConstructDO4.Text := Settings.DolphinReConstructDO4;
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
  Settings.DolphinReConstructDO4 := btnedtReConstructDO4.Text;

  Settings.SaveToFile();
end;

end.
