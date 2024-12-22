unit dtfrmExec;

{
(Typical Meet Manager)  ... will read the data into the proper lanes.
- If there is one watch per lane, that time will also be placed in the result
column.
- If there are 3 watch times for a given lane, the middle time will be placed in
  the result column.
- If there are two watches for a given lane, the average will be computed and
  placed in the result column. Please note that if there is .3 or more seconds
  difference between the two watch times, the average result time will NOT be
  computed and a yellow line will show for this lane. Decide whether to throw out one
  of the watch times if you determine one of them is way off. If you are OK with the
  two times, then click Ctrl-K to display the watch averaging menu and it will compute
  the average for you and place it in the result column. If one of the times is no good,
  delete it and use Ctrl-K, or simply type in the time of the one good watch.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus, dmSCM, dmDTData, dtuSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids, SCMDefines, System.StrUtils, AdvUtil, AdvObj,
  BaseGrid, AdvGrid, DBAdvGrid, System.Actions, Vcl.ActnList, Vcl.ToolWin,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ExtDlgs, FireDAC.Stan.Param, Vcl.ComCtrls, Vcl.DBCtrls, dtReConstruct,
  Vcl.PlatformVclStylesActnCtrls, Vcl.WinXPanels, Vcl.WinXCtrls;

type
  TdtExec = class(TForm)
    actnManager: TActionManager;
    actnMenuBar: TActionMainMenuBar;
    actnSelectSession: TAction;
    dtGrid: TDBAdvGrid;
    btnNextDTFile: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnPrevEvent: TButton;
    btnRefresh: TButton;
    btnClose: TButton;
    FileSaveDlgCSV: TFileSaveDialog;
    lblEventDetails: TLabel;
    lblHeatNum: TLabel;
    lblMeters: TLabel;
    PickDTFolderDlg: TFileOpenDialog;
    sbtnSync: TSpeedButton;
    scmGrid: TDBAdvGrid;
    spbtnAutoConnect: TSpeedButton;
    spbtnPost: TSpeedButton;
    vimgHeatNum: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    vimgStrokeBug: TVirtualImage;
    pBar: TProgressBar;
    dbtxtDTFileName: TDBText;
    actnExportDTCSV: TAction;
    actnReConstructDO4: TAction;
    actnReConstructDO3: TAction;
    actnPreferences: TAction;
    actnImportDO4: TAction;
    actnImportDO3: TAction;
    pnlSCM: TPanel;
    pnlDT: TPanel;
    actnSaveSession: TAction;
    actnLoadSession: TAction;
    rpnlBody: TRelativePanel;
    pnlTool1: TPanel;
    pnlTool2: TPanel;
    stackpnlTool2: TStackPanel;
    ShapeSpacer: TShape;
    actnAbout: TAction;
    actnSync: TAction;
    actnConnect: TAction;
    actnPost: TAction;
    lblMetersRelay: TLabel;
    lblSessionStart: TLabel;
    btnPickEvent: TButton;
    btnPickDTFile: TButton;
    actnSelectSwimClub: TAction;
    procedure actnExportDTCSVExecute(Sender: TObject);
    procedure actnExportDTCSVUpdate(Sender: TObject);
    procedure actnImportDO4Execute(Sender: TObject);
    procedure actnPreferencesExecute(Sender: TObject);
    procedure actnReConstructDO3Execute(Sender: TObject);
    procedure actnReConstructDO3Update(Sender: TObject);
    procedure actnReConstructDO4Execute(Sender: TObject);
    procedure actnReConstructDO4Update(Sender: TObject);
    procedure actnSelectSessionExecute(Sender: TObject);
    procedure actnSetDTMeetsFolderExecute(Sender: TObject);
    procedure actnSyncExecute(Sender: TObject);
    procedure btnNextDTFileClick(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPickEventClick(Sender: TObject);
    procedure btnPrevDTFileClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbtnSyncClick(Sender: TObject);

  private
    { Private declarations }
    FConnection: TFDConnection;
    fDolphinMeetsFolder: string;
    { When flag is set...
        Non-Aware UI controls are re-calculated and re-painted.
        Non-Data-Aware labels are re-assigned and re-displayed.
      A switch to disable UI updates when doing complex table changes.
      Default value : FALSE
    }
    fFlagUIUpdate: boolean;
    { On FormShow - prompt user to select session.
      Default value : FALSE
    }
    fFlagSelectSession: boolean;
    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure SaveToSettings; // JSON Program Settings
    procedure UpdateCaption();
    procedure UpdateSessionStartLabel();
    procedure UpdateEventDetailsLabel();
    procedure DeleteFilesWithWildcard(const APath, APattern: string);
    procedure ReconstructAndExportFiles(fileExtension: string; messageText: string);

  const
    AcceptedTimeKeeperDeviation = 0.3;
    SCM_SELECTSESSION = WM_USER + 999;

  protected
    procedure MSG_AfterEventScroll(var Msg: TMessage); message SCM_EVENTSCROLL;
    procedure MSG_AfterHeatScroll(var Msg: TMessage); message SCM_HEATSCROLL;
    procedure MSG_UpdateUI(var Msg: TMessage); message SCM_UPDATEUI;
    procedure MSG_SelectSession(var Msg: TMessage); message SCM_SELECTSESSION;

  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection);
    property DolphinFolder: string read fDolphinMeetsFolder write fDolphinMeetsFolder;
    property FlagSelectSession: boolean read fFlagSelectSession write fFlagSelectSession;
  end;

var
  dtExec: TdtExec;

implementation

{$R *.dfm}

uses dtUtils, UITypes, DateUtils ,dlgSessionPicker, dtDlgOptions, dtTreeViewSCM;

const
  MSG_CONFIRM_RECONSTRUCT =
    'This uses the data in the current session to build Dolphin Timing %s files.%sFiles are saved to the EventCSV folder specified in preferences.%sDo you want to perform the reconstruct?';
  MSG_RECONSTRUCT_COMPLETE = 'Re-construct and export of %s files is complete.';
  CAPTION_RECONSTRUCT = '%s files ...';
  DO4_FILE_EXTENSION = 'DO4';
  DO3_FILE_EXTENSION = 'DO3';


procedure TdtExec.actnExportDTCSVExecute(Sender: TObject);
var
  fn: TFileName;
  i: integer;
begin
  FileSaveDlgCSV.DefaultFolder := Settings.DolphinEventFolder;
  i := DTData.qrySession.FieldByName('SessionID').AsInteger;
  fn := 'SCM_DTEvent_session' + IntToStr(i) + '.csv';
  FileSaveDlgCSV.FileName := fn;
  if FileSaveDlgCSV.Execute then
  begin
    fn := FileSaveDlgCSV.FileName;
    DTData.BuildCSVEventData(fn); // Build CSV Event Data and save to file.
    MessageBox(0,
      PChar('Export of the Dolphin Timing event csv has been completed.'),
      PChar('Export Event CSV'), MB_ICONINFORMATION or MB_OK);
  end;
end;

procedure TdtExec.actnExportDTCSVUpdate(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TdtExec.actnImportDO4Execute(Sender: TObject);
var
s: string;
begin
  if DirectoryExists(fDolphinMeetsFolder) then
  begin
    pBar.Visible := true;
    ProcessDTFiles(fDolphinMeetsFolder, pBar);
    pBar.Visible := false;
    DTData.dsDT.DataSet.First;
    // lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
  end
  else
  begin
    s := '''
      The Dolphin Timing meets folder couldn''t be found.
      Use the Edit|Preference menu to setup the folder''s location.
    ''';
    MessageBox(0, PChar(s), PChar('Missing meets folder.'), MB_ICONERROR or MB_OK);
  end;
end;

procedure TdtExec.actnPreferencesExecute(Sender: TObject);
var
  dlg: TDlgOptions;
  mr: TModalResult;
begin
  // open options menu
  dlg := TDlgOptions.Create(Self);
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) then
    // Update any preference changes
    LoadSettings;
  dlg.Free;
  UpdateCaption;
end;


procedure TdtExec.DeleteFilesWithWildcard(const APath, APattern: string);
var
  SR: TSearchRec;
  FullPath: string;
begin
  FullPath := IncludeTrailingPathDelimiter(APath) + APattern;
  if FindFirst(FullPath, faAnyFile, SR) = 0 then
  try
    repeat
      // Build the full filename
      if (SR.Attr and faDirectory) = 0 then
        DeleteFile(IncludeTrailingPathDelimiter(APath) + SR.Name);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

{
procedure TdtExec.actnReConstructDO4Execute(Sender: TObject);
var
  SessionID, currEv, currHt: integer;
  sess: string;
  mr: TModalResult;
begin
  if DTData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar('''
      This uses the data in the current session to build Dolphin Timing DO4 files.
      Files are saved to the EventCSV folder specified in preferences.
      Do you want to perform the reconstruct?
      '''),
      PChar('Re-construct and export DO4 files...'), MB_ICONQUESTION or
        MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := DTData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := DTData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := DTData.qrysession.FieldByName('SessionID').AsInteger;
      // remove the current session DO4 files.
      sess := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.DolphinReConstructDO4, sess + '-*.DO4');
      // re-contruct the Dolphin Timing DO4 files for this session.
      ReConstructDO4(SessionID);
      DTData.LocateEvent(currEv);
      DTData.LocateHeat(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar('Re-construct and export of DO4 files is complete.'),
        PChar('DO4 files ...'), MB_ICONINFORMATION or MB_OK);
    end;
  end;
end;

procedure TdtExec.actnReConstructDO3Execute(Sender: TObject);
var
  SessionID, currEv, currHt: integer;
  sess: string;
  mr: TModalResult;
begin
  if DTData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar('''
      This uses the data in the current session to build Dolphin Timing DO3 files.
      Files are saved to the EventCSV folder specified in preferences.
      Do you want to perform the reconstruct?
      '''),
      PChar('Re-construct and export DO3 files...'), MB_ICONQUESTION or
        MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := DTData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := DTData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := DTData.qrysession.FieldByName('SessionID').AsInteger;
      // remove the current session DO3 files.
      sess := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.DolphinReConstructDO3, sess + '-*.DO3');
      // re-contruct the Dolphin Timing DO3 files for this session.
      ReConstructDO4(SessionID);
      DTData.LocateEvent(currEv);
      DTData.LocateHeat(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar('Re-construct and export of DO3 files is complete.'),
        PChar('DO3 files ...'), MB_ICONINFORMATION or MB_OK);
    end;
  end;
end;
}

procedure TdtExec.actnReConstructDO4Execute(Sender: TObject);
begin
  ReconstructAndExportFiles(DO4_FILE_EXTENSION, 'DO4');
end;

procedure TdtExec.actnReConstructDO3Execute(Sender: TObject);
begin
  ReconstructAndExportFiles(DO3_FILE_EXTENSION, 'DO3');
end;


procedure TdtExec.actnReConstructDO3Update(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TdtExec.actnReConstructDO4Update(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TdtExec.actnSelectSessionExecute(Sender: TObject);
var
  dlg: TSessionPicker;
  mr: TModalResult;
begin
  dlg := TSessionPicker.Create(Self);
  // the picker will locate to the given session id.
  dlg.rtnSessionID := DTData.qrySession.FieldByName('SessionID').AsInteger;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) and (dlg.rtnSessionID > 0) then
  begin
    DTData.MSG_Handle := 0;
    DTData.ActiveSessionID := dlg.rtnSessionID;
    DTData.MSG_Handle := Self.Handle;
  end;
  dlg.Free;
  UpdateCaption;
  PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TdtExec.actnSetDTMeetsFolderExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if PickDTFolderDlg.Execute then
    fn := PickDTFolderDlg.FileName
  else
    Exit; // User cancelled.
  // Make the path persistent in JSON.
  fDolphinMeetsFolder := fn;
  // SavePreferencesToJSON.
end;

procedure TdtExec.actnSyncExecute(Sender: TObject);
begin
  LoadSession(DTData.ActiveSessionID, Settings.DolphinMeetsFolder, pBar);
  DTData.LocateEvent(0);
  DTData.LocateHeat(0);
end;

procedure TdtExec.btnNextDTFileClick(Sender: TObject);
begin
    if not DTData.dsDT.DataSet.EOF then
    begin
      DTData.dsDT.DataSet.next;
      // lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
    end;
end;

procedure TdtExec.btnNextEventClick(Sender: TObject);
var
  v: variant;
  sql: string;
  id: integer;
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
  end
  else
  begin
    // Get the MAX HeatNum...
    sql := 'SELECT MAX(HeatNum) FROM [SwimClubMeet].[dbo].[HeatIndividual] WHERE [EventID] = :ID';
    id := DTData.dsEvent.DataSet.FieldByName('EventID').AsInteger;
    v := SCM.scmConnection.ExecSQLScalar(sql,[id]);
    if VarIsNull(v) then v := 0;
    { After reaching the last record a second click of btnNextEvent is needed to
      recieve a Eof. Checking for max heatnum removes this UI nonsence.}
    if DTData.dsHeat.DataSet.Eof or (DTData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = v)  then
    begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
    end
    else
    begin
      DTData.dsHeat.DataSet.next;
    end;
  end;
  PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TdtExec.btnPickEventClick(Sender: TObject);
var
dlg: TTreeViewSCM;
sess, ev, ht: integer;
mr: TModalResult;
found: boolean;
begin
  // Open the SCM TreeView.
  dlg := TTreeViewSCM.Create(Self);

  sess := DTData.dsSession.DataSet.FieldByName('SessionID').AsInteger;
  ev := DTData.dsEvent.DataSet.FieldByName('EventID').AsInteger;
  ht := DTData.dsHeat.DataSet.FieldByName('HeatID').AsInteger;
  dlg.Prepare(SCM.scmConnection, sess, ev, ht);
  mr := dlg.ShowModal;

    // CUE-TO selected TreeView item ...
  if IsPositiveResult(mr) then
  begin
    DTData.dsEvent.DataSet.DisableControls;
    DTData.dsHeat.DataSet.DisableControls;
    if (dlg.SelectedEventID <> 0) then
    begin
      found := DTData.LocateEvent(dlg.SelectedEventID);
      if found and (dlg.SelectedHeatID <> 0) then
      begin
        DTData.LocateHeat(dlg.SelectedHeatID);
      end;
    end;
    DTData.dsEvent.DataSet.EnableControls;
    DTData.dsHeat.DataSet.EnableControls;
    // Update UI controls ...
    PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
  end;
  dlg.Free;

end;

procedure TdtExec.btnPrevDTFileClick(Sender: TObject);
begin
  if not DTData.dsdt.DataSet.Bof then
  begin
      DTData.dsdt.DataSet.prior;
//      lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
  end;
end;

procedure TdtExec.btnPrevEventClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      DTData.dsEvent.DataSet.prior;
      DTData.dsHeat.DataSet.first;
  end
  else
  begin
    { After reaching the first record a second click of btnPrevEvent is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence.}
  if DTData.dsHeat.DataSet.BOF or
    (DTData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
  begin
      DTData.dsEvent.DataSet.prior;
      DTData.dsHeat.DataSet.Last;
    end
    else
    begin
      DTData.dsHeat.DataSet.prior;
    end;
  end;
  PostMessage(Self.Handle, SCM_UPDATEUI, 0, 0);
end;

procedure TdtExec.FormCreate(Sender: TObject);
begin
  // A Class that uses JSON to read and write application configuration .
  // Created on bootup by dtfrmBoot.
  LoadSettings;
  {
    Sort out the menubar font height - so tiny!

    The font of the MenuItemTextNormal element (or any other) in the style
    designer has no effect, this is because the Vcl Style Engine simply
    ignores the font-size and font-name, and just uses the font color defined in
    the vcl style file.

    S O L U T I O N :

    Define and register a new TActionBarStyleEx descendent and override
    the DrawText methods of the TCustomMenuItem and TCustomMenuButton
    classes, using the values of the Screen.MenuFont to draw the menu
  }
  Screen.MenuFont.Name := 'Segoe UI Semibold';
  Screen.MenuFont.Size := 12;
  actnManager.Style := PlatformVclStylesStyle;

  fFlagUIUpdate := false;
  fFlagSelectSession := false;
  // UI initialization
  lblSessionStart.Caption := '';
  lblEventDetails.Caption := '';
  lblMetersRelay.Caption := '';
  lblHeatNum.Caption := '';
  lblMeters.Caption := '';
  vimgHeatNum.ImageIndex := -1;
  vimgHeatStatus.ImageIndex := -1;
  vimgRelayBug.ImageIndex := -1;
  vimgStrokeBug.ImageIndex := -1;
end;

procedure TdtExec.FormDestroy(Sender: TObject);
begin
  SaveToSettings;
  if Assigned(DTData) then DTData.MSG_Handle := 0;
end;

procedure TdtExec.FormHide(Sender: TObject);
begin
  if Assigned(DTData) then DTData.MSG_Handle := 0;
end;

procedure TdtExec.FormShow(Sender: TObject);
begin
  if DTData.qrySession.IsEmpty then
  begin
    pnlSCM.Visible := false;
    pnlDT.Visible := false;
    actnSelectSession.Execute;
  end
  else
  begin
    pnlSCM.Visible := true;
    pnlDT.Visible := true;
  end;
  // Windows handle to message after after data scroll...
  if Assigned(DTData) then DTData.MSG_Handle := Self.Handle;
  if fFlagSelectSession then
    // Prompt user to select session. (... and update UI.)
    PostMessage(Self.Handle, SCM_SELECTSESSION, 0 , 0 )
  else
    // Assert UI display is up-to-date.
    PostMessage(Self.Handle, SCM_UPDATEUI, 0 , 0 );

end;

procedure TdtExec.LoadFromSettings;
begin
  fDolphinMeetsFolder := Settings.DolphinMeetsFolder;
end;

procedure TdtExec.LoadSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TdtExec.MSG_AfterEventScroll(var Msg: TMessage);
begin
  fFlagUIUpdate := false;
end;

procedure TdtExec.MSG_AfterHeatScroll(var Msg: TMessage);
begin
  fFlagUIUpdate := false;
end;

procedure TdtExec.MSG_SelectSession(var Msg: TMessage);
begin
  actnSelectSessionExecute(Self);
end;

procedure TdtExec.MSG_UpdateUI(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    UpdateEventDetailsLabel; // append heat number to label
    UpdateSessionStartLabel; //

    i := DTData.qryEvent.FieldByName('StrokeID').AsInteger;
    case i of
      1:
        vimgStrokeBug.ImageName := 'StrokeFS';
      2:
        vimgStrokeBug.ImageName := 'StrokeBS';
      3:
        vimgStrokeBug.ImageName := 'StrokeBK';
      4:
        vimgStrokeBug.ImageName := 'StrokeBF';
      5:
        vimgStrokeBug.ImageName := 'StrokeIM';
    else
      vimgStrokeBug.ImageIndex := -1;
    end;

    i := DTData.qryDistance.FieldByName('EventTypeID').AsInteger;
    case i of
      2:
      begin
        vimgRelayBug.ImageName := 'RELAY_DOT'; // RELAY.
        lblMetersRelay.Caption := UpperCase(DTData.qryDistance.FieldByName('Caption').AsString);
        lblMetersRelay.Visible := true;
        lblMeters.Caption := '';
      end;
    else
      begin
        vimgRelayBug.ImageIndex := -1; // INDV or Swim-O-Thon.
        lblMeters.Caption := UpperCase(DTData.qryDistance.FieldByName('Caption').AsString);
        lblMetersRelay.Visible := false;
      end;
    end;

    i := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    if i = 0 then
    begin
      lblHeatNum.Caption := '';
      vimgHeatNum.ImageIndex := -1;
      vimgHeatStatus.ImageIndex := -1;
    end
    else
    begin
      lblHeatNum.Caption := IntToStr(i);
      vimgHeatNum.ImageIndex := 14;
      i := DTData.qryHeat.FieldByName('HeatStatusID').AsInteger;
      case i of
      1:
        vimgHeatStatus.ImageName := 'HeatOpen';
      2:
        vimgHeatStatus.ImageName := 'HeatRaced';
      3:
        vimgHeatStatus.ImageName := 'HeatClosed';
      else
        vimgHeatStatus.ImageIndex := -1;
      end;
    end;

  end;

end;

procedure TdtExec.Prepare(AConnection: TFDConnection);
begin
  FConnection := AConnection;
  Caption := 'SwimClubMeet - Dolphin Timing. ';
end;

procedure TdtExec.ReconstructAndExportFiles(fileExtension: string; messageText:
  string);
var
  SessionID, currEv, currHt: integer;
  sessionPrefix: string;
  mr: TModalResult;
begin
  if DTData.qrysession.Active then
  begin
    mr := MessageBox(0,
      PChar(Format(MSG_CONFIRM_RECONSTRUCT, [fileExtension, sLineBreak,
        sLineBreak])),
      PChar(Format(CAPTION_RECONSTRUCT, [fileExtension])), MB_ICONQUESTION or
      MB_YESNO);
    if isPositiveResult(mr) then
    begin
      scmGrid.BeginUpdate;
      scmGrid.DataSource.DataSet.DisableControls;
      currEv := DTData.qryEvent.FieldByName('EventID').AsInteger;
      currHt := DTData.qryHeat.FieldByName('HeatID').AsInteger;
      SessionID := DTData.qrysession.FieldByName('SessionID').AsInteger;
      sessionPrefix := Get3Digits(SessionID);
      DeleteFilesWithWildcard(Settings.DolphinReConstruct + fileExtension,
        sessionPrefix + '-*.%' + fileExtension);
      if messageText = 'DO3' then
        ReConstructDO3(SessionID)
      else
        ReConstructDO4(SessionID);
      DTData.LocateEvent(currEv);
      DTData.LocateHeat(currHt);
      scmGrid.DataSource.DataSet.EnableControls;
      scmGrid.EndUpdate;
      MessageBox(0,
        PChar(Format(MSG_RECONSTRUCT_COMPLETE, [fileExtension])),
        PChar(Format(CAPTION_RECONSTRUCT, [fileExtension])), MB_ICONINFORMATION
          or MB_OK);
    end;
  end;
end;


procedure TdtExec.SaveToSettings;
begin
  Settings.DolphinMeetsFolder := fDolphinMeetsFolder;
  Settings.SaveToFile();
end;

procedure TdtExec.sbtnSyncClick(Sender: TObject);
begin
  // sync DT DO data with the current session - event - heat
  {
    1. get sessionID
    2. check session current in memory db tables else load
    3. get event + Heat
    4. locate event ... locate heat ...  chech grid ui state
    5. draw doodles if needed.
  }
  // - fSessionID;
  LoadSession(DTData.ActiveSessionID, Settings.DolphinMeetsFolder, pBar);
  DTData.LocateEvent(0);
  DTData.LocateHeat(0);

end;


procedure TdtExec.UpdateCaption;
var
s, s2: string;
v: variant;
dt: TDateTime;
begin
  if not DTData.qrysession.Active then
    Caption := 'SwimClubMeet - Dolphin Timing. ' // error ...
  else
  begin
    s2 := 'SwimClubMeet';
    v := DTData.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s2 := s2 + ' - Session: ' + DateToStr(dt);
    end;
    s := DTData.qrysession.FieldByName('Caption').AsString;
    if Length(s) > 0 then s2 := s2 + ' ' + s;
    Caption := s2;
  end;
end;

procedure TdtExec.UpdateEventDetailsLabel;
var
i: integer;
s, s2: string;
begin
  i := DTData.qryEvent.FieldByName('EventNum').AsInteger;
  if i = 0 then
    lblEventDetails.Caption := ''
  else
    begin
      // build the event detail string...  Distance Stroke (OPT: Caption)
      s := DTData.qryDistance.FieldByName('Caption').AsString;
      s := s + ' ' + DTData.qryStroke.FieldByName('Caption').AsString;
      // event description - entered in core app's grid extension mode.
      s2 := DTData.qryEvent.FieldByName('Caption').AsString;
      if (length(s2) > 0) then
      begin
        if (length(s2) > 17) then
          s2 := s2.Substring(0, 14) + '...';
        s := s +  ' - ' +  s2;
      end;
      // heat number...
      i:=DTData.qryHeat.FieldByName('HeatNum').AsInteger;
      s := s + ' - Heat: ' + IntToStr(i);
      if Length(s) > 0 then
      begin
        lblEventDetails.Caption := s;
      end;
    end;
end;

procedure TdtExec.UpdateSessionStartLabel;
var
s: string;
v: variant;
dt: TDateTime;
begin
  if not DTData.qrysession.Active then
  begin
    lblSessionStart.Caption := ''; // error ...
    exit;
  end;
  if DTData.qrySession.IsEmpty or
    (DTData.qrySession.FieldByName('SessionID').AsInteger = 0) then
    lblSessionStart.Caption := ''
  else
  begin
    s := 'SESSION' + sLineBreak;
    v := DTData.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s := s + DateToStr(dt);
    end;
    lblSessionStart.Caption := s;
  end;
end;

end.
