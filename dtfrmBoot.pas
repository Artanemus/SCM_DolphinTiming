unit dtfrmBoot;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.Imaging.pngimage, Vcl.WinXCtrls, Vcl.StdCtrls, dmSCM,
  dtuSetting, SCMDefines, SCMSimpleConnect;

type
  TdtBoot = class(TForm)
    lblServer: TLabel;
    lblUserName: TLabel;
    lblPassword: TLabel;
    lblAniIndicatorStatus: TLabel;
    StatusMsg: TLabel;
    chkbUseOsAuthentication: TCheckBox;
    edtPassword: TEdit;
    edtServerName: TEdit;
    edtUser: TEdit;
    btnConnect: TButton;
    btnDisconnect: TButton;
    ActivityIndicator1: TActivityIndicator;
    Panel1: TPanel;
    imgDTBanner: TImage;
    btnDolphinTiming: TButton;
    ActionList1: TActionList;
    actnConnect: TAction;
    actnDisconnect: TAction;
    actnDolphinTiming: TAction;
    Timer1: TTimer;
    procedure actnConnectExecute(Sender: TObject);
    procedure actnConnectUpdate(Sender: TObject);
    procedure actnDisconnectExecute(Sender: TObject);
    procedure actnDisconnectUpdate(Sender: TObject);
    procedure btnDolphinTimingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fLoginTimeOut: integer;
    fConnectionCountdown: integer;
    fSessionID: integer;
    procedure ConnectOnTerminate(Sender: TObject); // THREAD.
    procedure Status_ConnectionDescription;
    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure SaveToSettings; // JSON Program Settings
    function GetSCMVerInfo(): string;

  public
    { Public declarations }
  end;

var
  dtBoot: TdtBoot;

implementation

{$R *.dfm}

uses exeinfo, dtfrmExec;

procedure TdtBoot.actnConnectExecute(Sender: TObject);
var
  sc: TSimpleConnect;
  myThread: TThread;
begin
  if (Assigned(SCM) and (SCM.scmConnection.Connected = false)) then
  begin
    lblAniIndicatorStatus.Caption := 'Connecting ' +
      IntToStr(CONNECTIONTIMEOUT);
    StatusMsg.Caption := '';
    ActivityIndicator1.Animate := true; // start spinning
    lblAniIndicatorStatus.Visible := true; // a label 'Connecting'
    fConnectionCountdown := CONNECTIONTIMEOUT - 1;
    Timer1.Enabled := true; // start the countdown

    myThread := TThread.CreateAnonymousThread(
      procedure
      begin
        // can only be assigned if not connected
        SCM.scmConnection.Params.Values['LoginTimeOut'] :=
          IntToStr(fLoginTimeOut);
        sc := TSimpleConnect.CreateWithConnection(Self, SCM.scmConnection);
        sc.DBName := 'SwimClubMeet'; // DEFAULT
        sc.SaveConfigAfterConnection := false; // using JSON not System.IniFiles
        sc.SimpleMakeTemporyConnection(edtServerName.Text, edtUser.Text,
          edtPassword.Text, chkbUseOsAuthentication.Checked);
        sc.Free
      end);

    myThread.OnTerminate := ConnectOnTerminate;
    myThread.Start;
  end;
end;

procedure TdtBoot.actnConnectUpdate(Sender: TObject);
begin
  // verbose code - stop unecessary repaints ...
  if Assigned(SCM) then
  begin
    if SCM.scmConnection.Connected and actnConnect.Enabled then
      actnConnect.Enabled := false;
    if not SCM.scmConnection.Connected and not actnConnect.Enabled then
      actnConnect.Enabled := true;
  end
  else // D E F A U L T  I N I T  . Data module not created.
  begin
    if not actnConnect.Enabled then
      actnConnect.Enabled := true;
  end;
  // btnConnect.Enabled := actnConnect.Enabled;
end;

procedure TdtBoot.actnDisconnectExecute(Sender: TObject);
begin
  if Assigned(SCM) then
  begin
    SCM.DeActivateTable;
    SCM.scmConnection.Connected := false;
  end;
  ActivityIndicator1.Animate := false;
  lblAniIndicatorStatus.Visible := false;
  SaveToSettings; // As this was a OK connection - store parameters.
  Status_ConnectionDescription;

  // CALL IT DIRECTLY - ELSE IT WILL NOT WORK
  actnDisconnectUpdate(Self);
  actnConnectUpdate(Self);
end;

procedure TdtBoot.actnDisconnectUpdate(Sender: TObject);
begin
  // verbose code - stop unecessary repaints ...
  if Assigned(SCM) then
  begin
    if SCM.scmConnection.Connected and not actnDisconnect.Enabled then
      actnDisconnect.Enabled := true;
    if not SCM.scmConnection.Connected and actnDisconnect.Enabled then
      actnDisconnect.Enabled := false;
  end
  else // D E F A U L T  I N I T  . Data module not created.
  begin
    if actnDisconnect.Enabled then
      actnDisconnect.Enabled := false;
  end;
end;

procedure TdtBoot.btnDolphinTimingClick(Sender: TObject);
var
dlg: TdtExec;
begin
  if Assigned(SCM) and SCM.IsActive and SCM.scmConnection.Connected then
  begin
    dlg := TdtExec.Create(Self);
    // TFDConnection, SessionID.
    dlg.Prepare(SCM.scmConnection, fSessionID); // init Dolphin Timing.
    Visible := false; // hide boot form.
    dlg.ShowModal(); // Execute - Dolphin Timing
    dlg.Free;
    if Assigned(SCM) then  // handle data module.
      FreeAndNil(SCM);
    Visible := true; // redundant?
    ExecuteAction(actnDisconnect);
    Close();  // terminate application ....
  end;
end;

procedure TdtBoot.FormCreate(Sender: TObject);
begin
  // Initialization of params.
  application.ShowHint := true;
  ActivityIndicator1.Animate := false;
  fLoginTimeOut := CONNECTIONTIMEOUT; // DEFAULT 20 - defined in ProgramSetting
  fConnectionCountdown := CONNECTIONTIMEOUT - 1;
  fSessionID := 0;
  Timer1.Enabled := false;
  lblAniIndicatorStatus.Visible := false;
  StatusMsg.Caption := '';

  // A Class that uses JSON to read and write application configuration
  if Settings = nil then
    Settings := TPrgSetting.Create;

  // C R E A T E   T H E   D A T A M O D U L E .
  if NOT Assigned(SCM) then
    SCM := TSCM.Create(Self);
  if SCM.scmConnection.Connected then
    SCM.scmConnection.Connected := false;

  // READ APPLICATION   C O N F I G U R A T I O N   PARAMS.
  // JSON connection settings. Windows location :
  // %SYSTEMDRIVE\%%USER%\%USERNAME%\AppData\Roaming\Artanemus\SwimClubMeet\Member
  LoadSettings;

  Status_ConnectionDescription;
end;

procedure TdtBoot.ConnectOnTerminate(Sender: TObject);
begin
  lblAniIndicatorStatus.Visible := false;
  ActivityIndicator1.Animate := false;
  Timer1.Enabled := false;
  fConnectionCountdown := CONNECTIONTIMEOUT - 1;

  if TThread(Sender).FatalException <> nil then
  begin
    raise Exception.Create('On termination: thread failed.');
  end;

  if not Assigned(SCM) then
    exit;
  // C O N N E C T E D  .
  if (SCM.scmConnection.Connected) then
  begin
    SCM.ActivateTable;
    if (SCM.IsActive = true) then
      PostMessage(Handle, SCM_INITIALISE, 0, 0);
  end;

  if not SCM.scmConnection.Connected then
  begin
    // Attempt to connect failed.
    StatusMsg.Caption :=
      'A connection couldn''t be made. (Check you input values.)';
  end
  else
  // Status : SwimClub name + APP and DB version.
  Status_ConnectionDescription;
  // CALL IT DIRECTLY ....
  actnDisconnectUpdate(Self);
  actnConnectUpdate(Self);
end;

function TdtBoot.GetSCMVerInfo: string;
var
  myExeInfo: TExeInfo;
begin
  result := '';
  // if connected - display the application version
  // and the SwimClubMeet database version.
  if Assigned(SCM) then
    if SCM.scmConnection.Connected then
      result := 'DB v' + SCM.GetDBVerInfo;
  // get the application version number
  myExeInfo := TExeInfo.Create(Self);
  result := 'App v' + myExeInfo.FileVersion + ' - ' + result;
  myExeInfo.Free;
end;

procedure TdtBoot.LoadFromSettings;
begin
  edtServerName.Text := Settings.Server;
  edtUser.Text := Settings.User;
  edtPassword.Text := Settings.Password;
  chkbUseOsAuthentication.Checked := Settings.OSAuthent;
  fLoginTimeOut := Settings.LoginTimeOut;
end;

procedure TdtBoot.LoadSettings;
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

procedure TdtBoot.SaveToSettings;
begin
  Settings.Server := edtServerName.Text;
  Settings.User := edtUser.Text;
  Settings.Password := edtPassword.Text;
  if chkbUseOsAuthentication.Checked then
    Settings.OSAuthent := true
  else
    Settings.OSAuthent := false;
  Settings.LoginTimeOut := fLoginTimeOut;
  Settings.SaveToFile();
end;

procedure TdtBoot.Status_ConnectionDescription;
begin
  var
    s: string;
  begin
    if Assigned(SCM) and SCM.IsActive then
    begin
      // STATUS BAR CAPTION.
      StatusMsg.Caption := 'Connected to SwimClubMeet database. ';
      StatusMsg.Caption := StatusMsg.Caption + GetSCMVerInfo;

      if Assigned(SCM.dsSwimClub.DataSet) then
        s := SCM.dsSwimClub.DataSet.FieldByName('Caption').AsString
      else
        s := '';
      StatusMsg.Caption := StatusMsg.Caption + sLineBreak + s;
    end
    else
      StatusMsg.Caption := '';
  end;
end;

end.
