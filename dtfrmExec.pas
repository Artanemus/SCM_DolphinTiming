﻿unit dtfrmExec;

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
  Vcl.PlatformVclStylesActnCtrls, Vcl.WinXPanels, Vcl.WinXCtrls,
  System.Types, System.IOUtils, dtUtils, Math, DirectoryWatcher;

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
    FileSaveDlgCSV: TFileSaveDialog;
    lblEventDetails: TLabel;
    lblHeatNum: TLabel;
    lblMeters: TLabel;
    PickDTFolderDlg: TFileOpenDialog;
    sbtnSyncDTtoSCM: TSpeedButton;
    scmGrid: TDBAdvGrid;
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
    actnImportAppendDO: TAction;
    actnClearReScanMeets: TAction;
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
    actnSyncDT: TAction;
    actnConnect: TAction;
    actnPost: TAction;
    lblMetersRelay: TLabel;
    lblSessionStart: TLabel;
    btnPickSCMTreeView: TButton;
    btnPickDTTreeView: TButton;
    actnSelectSwimClub: TAction;
    btnDataDebug: TButton;
    lblDTDetails: TLabel;
    actnRefresh: TAction;
    DTAppendFile: TFileOpenDialog;
    actnReportSCMSession: TAction;
    actnReportDT: TAction;
    actnReportSCMEvent: TAction;
    sbtnAutoPatch: TSpeedButton;
    sbtnSyncSCMtoDT: TSpeedButton;
    sbtnRefreshSCM: TSpeedButton;
    ShapeSpaceerSCM: TShape;
    actnSyncSCM: TAction;
    StatBar: TStatusBar;
    Timer1: TTimer;
    procedure actnExportDTCSVExecute(Sender: TObject);
    procedure actnExportDTCSVUpdate(Sender: TObject);
    procedure actnClearReScanMeetsExecute(Sender: TObject);
    procedure actnImportAppendDOExecute(Sender: TObject);
    procedure actnPostExecute(Sender: TObject);
    procedure actnPostUpdate(Sender: TObject);
    procedure actnPreferencesExecute(Sender: TObject);
    procedure actnReConstructDO3Execute(Sender: TObject);
    procedure actnReConstructDO3Update(Sender: TObject);
    procedure actnReConstructDO4Execute(Sender: TObject);
    procedure actnReConstructDO4Update(Sender: TObject);
    procedure actnRefreshExecute(Sender: TObject);
    procedure actnSelectSessionExecute(Sender: TObject);
    procedure actnSetDTMeetsFolderExecute(Sender: TObject);
    procedure actnSyncDTExecute(Sender: TObject);
    procedure actnSyncSCMExecute(Sender: TObject);
    procedure btnDataDebugClick(Sender: TObject);
    procedure btnNextDTFileClick(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPickDTTreeViewClick(Sender: TObject);
    procedure btnPickSCMTreeViewClick(Sender: TObject);
    procedure btnPrevDTFileClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure dtGridClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var Value:
        string);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
    FConnection: TFDConnection;
    fDolphinMeetsFolder: string;
    // dtPrecedence = (dtPrecHeader, dtPrecFileName);
    fPrecedence: dtPrecedence;
    fDirectoryWatcher: TDirectoryWatcher;
    { On FormShow - prompt user to select session.
      Default value : FALSE     }
    fFlagSelectSession: boolean;

    procedure OnFileChanged(Sender: TObject; const FileName: string);

    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure SaveToSettings; // JSON Program Settings
    procedure UpdateCaption();
    procedure UpdateSessionStartLabel();
    procedure UpdateEventDetailsLabel();
    procedure UpdateDTDetailsLabel();
    procedure DeleteFilesWithWildcard(const APath, APattern: string);
    procedure ReconstructAndExportFiles(fileExtension: string; messageText: string);
    procedure UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
        dtActiveRT);

  const
    AcceptedTimeKeeperDeviation = 0.3;
    SCM_SELECTSESSION = WM_USER + 999;

  protected
    procedure MSG_UpdateUI(var Msg: TMessage); message SCM_UPDATEUI;
    procedure MSG_UpdateUI2(var Msg: TMessage); message SCM_UPDATEUI2;
    procedure MSG_UpdateUI3(var Msg: TMessage); message SCM_UPDATEUI3;
    procedure MSG_SelectSession(var Msg: TMessage); message SCM_SELECTSESSION;

  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection);
    property DolphinFolder: string read fDolphinMeetsFolder write fDolphinMeetsFolder;
    property FlagSelectSession: boolean read fFlagSelectSession write fFlagSelectSession;
  end;

var
  dtExec: TdtExec;
  dtUtils: TdtUtils;

implementation

{$R *.dfm}

uses UITypes, DateUtils ,dlgSessionPicker, dtDlgOptions, dtTreeViewSCM,
  dlgDataDebug, dtTreeViewDT, dlgRaceTimeUser, dtPostData;

const
  MSG_CONFIRM_RECONSTRUCT =
    'This uses the data in the current session to build Dolphin Timing %s files.' +
    sLineBreak +
    'Files are saved to the reconstruct folder specified in preferences.' +
    sLineBreak +
    'Do you want to perform the reconstruct?';
  MSG_RECONSTRUCT_COMPLETE = 'Re-construct and export of %s files is complete.';
  CAPTION_RECONSTRUCT = '%s files ...';
  DO4_FILE_EXTENSION = 'DO4';
  DO3_FILE_EXTENSION = 'DO3';


procedure TdtExec.actnExportDTCSVExecute(Sender: TObject);
var
  fn: TFileName;
  i: integer;
  dt: TDatetime;
  s: string;
  fs: TFormatSettings;
begin
  FileSaveDlgCSV.DefaultFolder := Settings.DolphinEventFolder;
  i := DTData.qrySession.FieldByName('SessionID').AsInteger;
try
  dt := DTData.qrySession.FieldByName('SessionStart').AsDateTime;
  fs := TFormatSettings.Create;
  fs.DateSeparator := '_';
  s := '-' + DatetoStr(dt, fs);
except
  on E: Exception do
    s := '';
end;
  fn := 'SCM_DT_event_session_' + IntToStr(i) + s + '.csv';
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

procedure TdtExec.actnClearReScanMeetsExecute(Sender: TObject);
var
  s: string;
  mr: TModalResult;
begin
  s := '''
    This will clear all patches. The dolphin meets folder will be re-scanned and the DT data tables will be rebuilt.
    Any posted racetimes, made to SwimClubMeet, will remain intact. There is no undo.
    (HINT: use ''Save SCM-DT Session'' to store all work prior to calling here.)
    Do you really want to rescan?
  ''';
  mr := MessageBox(0, PChar(s), PChar('Clear and Rescan Meets Folder. '),
    MB_ICONEXCLAMATION or MB_YESNO or MB_DEFBUTTON2);
  if IsPositiveResult(mr) then
  begin
    // Test DT directory exists...
    if DirectoryExists(Settings.DolphinMeetsFolder) then
    begin
        if dtUtils.DirectoryHasDTFiles(Settings.DolphinMeetsFolder) then
        begin
          dtUtils.PrepareDTData;
          dtUtils.PopulateDTData(Settings.DolphinMeetsFolder, pBar);
          // Update lblDTDetails.
          PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
          // Paint cell icons.
          PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
        end;
    end;
  end;

end;

procedure TdtExec.actnImportAppendDOExecute(Sender: TObject);
var
  AFile: string;
begin
  if DTAppendFile.Execute() then
  begin
    // =====================================================
    // De-attach from Master-Detail. Create flat files.
    // Necessary to calculate table Primary keys.
    DTData.DisableDTMasterDetail;
    // =====================================================
    try
      for AFile in DTAppendFile.Files do
      begin
        { Calls - PrepareExtraction, ProcessEvent, ProcessHeat, ProcessEntrant }
        dtUtils.ProcessSession(AFile);
      end;
    finally
      // =====================================================
      // Re-attach Master-Detail.
      DTData.EnableDTMasterDetail;
      // =====================================================
    end;
  end;
end;

procedure TdtExec.actnPostExecute(Sender: TObject);
var
  dlg: TPostData;
  mr: TModalResult;
  I, idx: integer;
  ALaneNum: integer;
  s: string;
begin
  // Establish if SCM AND DT are syncronized.
  if not DTData.SyncCheck(fPrecedence) then
  begin
    s := '''
      SCM and DT are not synronized. (Based on Session ID, event and heat number.)
      However you are permitted to perform the post.
      Do you want to CONTINUE?
      ''';
    mr := MessageBox(0, PChar(s), PChar('POST ''RACE-TIMES'' WARNING'), MB_ICONEXCLAMATION or MB_YESNO or MB_DEFBUTTON2);
    if not IsPositiveResult(mr) then
    begin
      StatBar.SimpleText := 'No POST was made.';
      Timer1.Enabled := true;
      exit;
    end;
  end;

  // dialogue to pick 'selected' or 'all'.
  dlg := TPostData.Create(Self);
  mr := dlg.ShowModal;
  idx := dlg.rgrpSelection.ItemIndex;
  // release the dlg in case of 'POST' exceptions.
  dlg.free;

  if IsPositiveResult(mr) then
  begin
    // Post all race-times to SCM ...
    if idx = 0 then
    begin
      DTGrid.BeginUpdate;
      DTData.POST_All;
      DTGrid.ClearRowSelect;  // UI clean-up .
      DTGrid.EndUpdate;
    end
    // Post only racetimes from selected lanes to SCM ...
    else if idx = 1 then
    begin
      DTGrid.BeginUpdate;
      for i := 0 to DTGrid.SelectedRowCount - 1 do
      begin
        idx := DTGrid.SelectedRow[i];
        ALaneNum := StrToIntDef(DTGrid.Cells[2, idx], 0);
        DTData.POST_Lane(ALaneNum);
      end;
      DTGrid.ClearRowSelect; // UI clean-up .
      DTGrid.EndUpdate;
    end;
    StatBar.SimpleText := 'The POST race-times to SCM completed.';
    Timer1.Enabled := true;
  end
  else
  begin
    StatBar.SimpleText := 'The POST was aborted.';
    Timer1.Enabled := true;
  end;
end;

procedure TdtExec.actnPostUpdate(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
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

procedure TdtExec.actnRefreshExecute(Sender: TObject);
begin
  SCMGrid.BeginUpdate;
  DTData.RefreshSCM;
  SCMGrid.EndUpdate;
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
    DTData.LocateSCMSessionID(dlg.rtnSessionID);
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

procedure TdtExec.actnSyncDTExecute(Sender: TObject);
var
found: boolean;
begin
  DTGrid.BeginUpdate;
  found := DTData.SyncDTtoSCM(fPrecedence); // data event - scroll.
  DTGrid.EndUpdate;
  UpdateDTDetailsLabel;
  if not found then
  begin
    StatBar.SimpleText := 'Syncronization of Dolphin Timing to SwimClubMeet failed. '
    + 'Your Dolphin Meets folder may not contain the session files required to sync.';
    timer1.enabled := true;
  end;
end;

procedure TdtExec.actnSyncSCMExecute(Sender: TObject);
begin
  if not DTData.SyncCheckSession(fPrecedence) then
  begin
    StatBar.SimpleText := 'The SwimClubMeet session cannot be synced to the DT data. '
    +   'Load the correct session and try again.';
    timer1.enabled := true;
    exit;
  end;

  SCMGrid.BeginUpdate;
  DTData.SyncSCMtoDT(fPrecedence);
  SCMGrid.EndUpdate;
  UpdateEventDetailsLabel;
end;

procedure TdtExec.btnDataDebugClick(Sender: TObject);
var
dlg: TDataDebug;
begin
  dlg := TDataDebug.Create(self);
  dlg.ShowModal;
  dlg.Free;
end;

procedure TdtExec.btnNextDTFileClick(Sender: TObject);
var
  lastHtID, lastEvID, IDht, IDev: integer;
  found: boolean;
begin
  DTGrid.BeginUpdate;
  // this hack find the last event ID and last heat ID in the current
  // Master-Detail linked Dolphin Timing data tables.
  IDHt := DTData.tbldtHeat.fieldbyName('HeatID').AsInteger;
  DTData.tbldtHeat.Last;
  lastHtID := DTData.tbldtHeat.fieldbyName('HeatID').AsInteger;
  IDEv := DTData.tbldtEvent.fieldbyName('EventID').AsInteger;
  DTData.tbldtEvent.Last;
  lastEvID := DTData.tbldtHeat.fieldbyName('EventID').AsInteger;
  found := DTData.tbldtEvent.Locate('EventID', IDEv);
  if found then
    DTData.tbldtHeat.Locate('HeatID', IDHt);
  DTGrid.EndUpdate;

  // CNTRL+SHIFT - quick key to move to NEXT S E S S I O N .
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    DTData.dsDTSession.DataSet.next;
    DTData.dsDTEvent.DataSet.first;
    DTData.dsDTHeat.DataSet.first;
  end
    // CNTRL- quick key to move to NEXT E V E N T .
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    { After reaching the last event for the current session ...
      a second click of btnNextDTFileClick is needed to recieve a Eof.
      Checking for max eventID removes this UI nonscence.}
    if ((DTData.dsdtEvent.DataSet.Eof) or
      (DTData.tbldtEvent.fieldbyName('EventID').AsInteger = lastEvID)) then
    begin
      DTData.dsdtSession.DataSet.next;
      DTData.dsdtHeat.DataSet.First;
      DTData.dsDTHeat.DataSet.first;
    end
    else
    begin
      DTData.dsdtEvent.DataSet.next;
      DTData.dsdtHeat.DataSet.First;
    end;
  end
    // move to N E X T   H E A T .
  else
  begin
    { After reaching the last record a second click of btnNextDTFileClick is needed to
      recieve a Eof. Checking for max heatID removes this UI nonscence.}
    if DTData.dsdtHeat.DataSet.Eof or
      (DTData.tbldtHeat.fieldbyName('HeatID').AsInteger = lastHtID) then
    begin
      DTData.dsdtEvent.DataSet.next;
      DTData.dsdtHeat.DataSet.First;
    end
    else
    begin
      DTData.dsdtHeat.DataSet.next;
    end;
  end;
  // Update lblDTDetails.
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
  // paint cell icons into grid
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
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

procedure TdtExec.btnPickDTTreeViewClick(Sender: TObject);
var
dlg: TTreeViewDT;
sessID, evID, htID: integer;
mr: TModalResult;
found: boolean;
SearchOptions: TLocateOptions;
begin
  {
  MANATORY HERE - ELSE IT DOESN'T WORK!
  Use the ApplyMaster method to synchronize this detail dataset with the
  current master record.  This method is useful, when DisableControls was
  called for the master dataset or when scrolling is disabled by
  MasterLink.DisableScroll.
  }
  dtGrid.BeginUpdate;

  // Open the SCM TreeView.
  dlg := TTreeViewDT.Create(Self);
  SearchOptions := [];
  // Params to cue-to-record in DT TreeView.
    sessID := DTData.dsdtSession.DataSet.FieldByName('SessionID').AsInteger;
    evID := DTData.dsdtEvent.DataSet.FieldByName('EventID').AsInteger;
    htID := DTData.dsdtHeat.DataSet.FieldByName('HeatID').AsInteger;

  // DT TreeView will attemp to cue-to-node based on params.

  dlg.Prepare(sessID, evID, htID);
  mr := dlg.ShowModal;
  // A TreeView node was selected.
  if IsPositiveResult(mr) then
  begin
    { NOTE: DT session pick by the user may differ from the current
      SCM session being operated on. }

    DTData.dsdtEntrant.DataSet.DisableControls;
    DTData.dsdtHeat.DataSet.DisableControls;
    DTData.dsdtEvent.DataSet.DisableControls;
    DTData.dsdtSession.DataSet.DisableControls;
    // Attempt to cue-to-data in Dolphin Timing tables.
    if (dlg.SelectedSessionID > 0) then
    begin
      found := DTData.LocateDTSessionID(dlg.SelectedSessionID);
      if not found then
        DTData.tblDTSession.First;
      DTData.tblDTEvent.ApplyMaster;
      DTData.tblDTEvent.First;
      DTData.tblDTHeat.ApplyMaster;
      DTData.tblDTHeat.First;
    end;
    if (dlg.SelectedEventID > 0) then
    begin
      found := DTData.LocateDTEventID(dlg.SelectedEventID);
      if not found then
        DTData.tblDTEvent.First;
      DTData.tblDTHeat.ApplyMaster;
      DTData.tblDTHeat.First;
      DTData.tblDTEntrant.ApplyMaster;
      DTData.tblDTEntrant.First;

    end;
    if (dlg.SelectedHeatID > 0) then
    begin
      found := DTData.LocateDTHeatID(dlg.SelectedHeatID);
      if not found then
        DTData.tblDTHeat.First;
    end;

    // Update the Dolphin Timing TDBAdvGrid.
    DTData.dsdtSession.DataSet.EnableControls;
    DTData.dsdtEvent.DataSet.EnableControls;
    DTData.dsdtHeat.DataSet.EnableControls;
    DTData.dsdtEntrant.DataSet.EnableControls;

//    dtGrid.update

    // Update UI controls ...
    PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
    // paint cell icons
    PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);

    end;
  dlg.Free;
  dtGrid.EndUpdate;

end;

procedure TdtExec.btnPickSCMTreeViewClick(Sender: TObject);
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
      found := DTData.LocateSCMEventID(dlg.SelectedEventID);
      if found then
      begin
        DTData.dsHeat.DataSet.Close;
        DTData.dsHeat.DataSet.Open;
        if (dlg.SelectedHeatID <> 0) then
          DTData.LocateSCMHeatID(dlg.SelectedHeatID);
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
var
  evNum, htNum: integer;
begin

  if fPrecedence = dtPrecFileName then
  begin
    evNum := DTData.dsDTEvent.DataSet.FieldByName('fnEventNum').AsInteger;
    htNum := DTData.dsDTHeat.DataSet.FieldByName('fnHeatNum').AsInteger;
  end
  else
  begin
    evNum := DTData.dsDTEvent.DataSet.FieldByName('EventNum').AsInteger;
    htNum := DTData.dsDTHeat.DataSet.FieldByName('HeatNum').AsInteger;
  end;

  // CNTRL+SHIFT - quick key to move to previous session.
  if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_SHIFT) < 0) then
  begin
    // reached bottom of table ...
    if DTData.dsDTSession.DataSet.BOF then exit;
    DTData.dsDTSession.DataSet.prior;
    DTData.dsDTEvent.DataSet.first;
    DTData.dsDTHeat.DataSet.first;
  end
  // CNTRL move to previous event ...
  else if (GetKeyState(VK_CONTROL) < 0) then
  begin
    if DTData.dsDTEvent.DataSet.BOF or (evNum = 1) then
    begin
      DTData.dsDTSession.DataSet.prior;
      DTData.dsDTEvent.DataSet.first;
    end
    else
      DTData.dsDTEvent.DataSet.prior;
  end
  else
  begin
    { After reaching the first record a second click of btnPrevDTFileClick is needed to
      recieve a Bof. Checking for heatnum = 1 removes this UI nonsence.}
    if DTData.dsDTHeat.DataSet.BOF or (htNum = 1) then
    begin
      DTData.dsDTEvent.DataSet.prior;
      DTData.dsDTHeat.DataSet.Last;
    end
    else
      DTData.dsDTHeat.DataSet.prior;
  end;
  // Update UI controls ...
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
  // paint cell icons into grid.
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
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
    if (DTData.dsEvent.DataSet.FieldByName('EventNum').AsInteger = 1) and
      (DTData.dsHeat.DataSet.FieldByName('HeatNum').AsInteger = 1) then
    exit;

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

procedure TdtExec.dtGridClickCell(Sender: TObject; ARow, ACol: Integer);
var
  Grid: TDBAdvGrid;
  ADataSet: TDataSet;
  s: string;
  ActiveRT: dtActiveRT;
  t: TTime;
  dlg: TRaceTimeUser;
  mr: TModalResult;
begin
  Grid := Sender as TDBAdvGrid;
  ADataSet := Grid.DataSource.DataSet;


  if (ARow >= DTgrid.FixedRows) then
  begin
    case ACol of
      7: // C O L U M N   E N T E R   U S E R   R A C E T I M E  .
        begin
          if (GetKeyState(VK_MENU) < 0) then
          begin
            ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
            if (ActiveRT = artUser) then // Enter a user race-time.
            begin
              grid.BeginUpdate;
              // create the 'Enter Race-Time' dialogue.
              dlg := TRaceTimeUser.Create(Self);
              // Assign : Current displayed racetime.
              dlg.RaceTime := ADataSet.FieldByName('RaceTime').AsDateTime;
              // Assign : Store user racetime.
              dlg.RaceTimeUser := ADataSet.FieldByName('RaceTimeUser').AsDateTime;
              mr := dlg.ShowModal;
              if IsPositiveResult(mr) then
              begin
                t := dlg.RaceTimeUser;
                ADataSet.Edit;
                if (t = 0) then
                  ADataSet.FieldByName('RaceTime').Clear
                else
                  ADataSet.FieldByName('RaceTime').AsDateTime := t;
                ADataSet.FieldByName('RaceTimeUser').AsDateTime := t;
                ADataSet.Post;
              end;
              dlg.Free;
              grid.EndUpdate;
            end;
          end;
        end;
      6: // C O L U M N   T O G G L E   A C T I V E - R T .
        begin
          grid.BeginUpdate;
          { Toggle tblEntrant.ActiveRT}
          if (GetKeyState(VK_MENU) < 0) then
            // toggle backwards
            ActiveRT := DTData.ToggleActiveRT(ADataSet, 1)
          else
            // toggle forward (default)
            ActiveRT := DTData.ToggleActiveRT(ADataSet);
          { Modifies tblEntrant: ActiveRT, RaceTime, imgActiveRT }
          DTData.SetActiveRT(ADataSet, ActiveRT);
          case ActiveRT of
            artAutomatic:
            begin
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artManual:
            begin
              // The RaceTime needs to be recalculated...
              DTData.CalcRaceTimeM(ADataSet);
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artUser:
            begin
              UpdateCellIcons(ADataSet, ARow, ActiveRT);
            end;
            artSplit:
               UpdateCellIcons(ADataSet, ARow, ActiveRT);
            artNone:
               UpdateCellIcons(ADataSet, ARow, ActiveRT);
          end;
          grid.EndUpdate;
        end;
      3, 4, 5:
        begin

          if ADataSet.FieldByName('LaneIsEmpty').AsBoolean then exit;

          ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
          // Must be artmanual for the user to toggle watch-time state.
          if ActiveRT <> artManual then exit;

          // the ALT key is required to perform toggle.
          if (GetKeyState(VK_MENU) < 0) then
          begin
            s := 'Time' + IntToStr(ACol - 2);
            // Can toggle an empty TimeKeeper's stopwatch time...
            if (ADataSet.FieldByName(s).IsNull) then exit;
            grid.BeginUpdate;
            // modify TimeKeeper's stopwatch state.
            // idx in [1..3]. Asserts : dtTimeKeeperMode = dtManual.
            DTData.ToggleWatchTime(ADataSet, (Acol - 2), ActiveRT);
            UpdateCellIcons(ADataSet, ARow, ActiveRT);
            // The RaceTime needs to be recalculated...
            DTData.CalcRaceTimeM(ADataset);
            grid.EndUpdate;
          end;
        end;
    end;
  end;
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
  // local fields init.
  fFlagSelectSession := false;
  // UI initialization.
  lblSessionStart.Caption := '';
  lblEventDetails.Caption := '';
  lblMetersRelay.Caption := '';
  lblHeatNum.Caption := '';
  lblMeters.Caption := '';
  vimgHeatNum.ImageIndex := -1;
  vimgHeatStatus.ImageIndex := -1;
  vimgRelayBug.ImageIndex := -1;
  vimgStrokeBug.ImageIndex := -1;

  dtUtils.AcceptedDeviation := Settings.DolphinAcceptedDeviation;

  FDirectoryWatcher := nil;
  // Test DT directory exists...
  if DirectoryExists(Settings.DolphinMeetsFolder) then
  begin
      if dtUtils.DirectoryHasDTFiles(Settings.DolphinMeetsFolder) then
      begin
        dtUtils.PrepareDTData;
        dtUtils.PopulateDTData(Settings.DolphinMeetsFolder, pBar);
        // Update UI controls ...
        PostMessage(Self.Handle, SCM_UPDATEUI2, 0, 0);
        // Paint cell icons.
        PostMessage(Self.Handle, SCM_UPDATEUI3, 0, 0);
      end;
    // Set up the file system watcher
    FDirectoryWatcher := TDirectoryWatcher.Create(Settings.DolphinMeetsFolder);
    FDirectoryWatcher.OnFileChanged := OnFileChanged;
    FDirectoryWatcher.Start;
  end;


{$IFNDEF DEBUG}
  btnDataDebug.Visible := false;
{$ENDIF}

  // Assert StatusBar params
  // Ensure that the StyleElements property does not include seFont
  //  StatBar.StyleElements := StatBar.StyleElements - [seFont];
  //  StatBar.ParentFont := False;
  StatBar.Font.Size := 12;
  StatBar.Font.Color := clWebAntiqueWhite;

  // Enable hint information
  Application.ShowHint := true;

end;

procedure TdtExec.FormDestroy(Sender: TObject);
begin
{
Summary:
SignalTerminate Method: This public method in TDirectoryWatcher signals the
termination event, allowing the Execute method to exit cleanly.

Calling SignalTerminate: In FormDestroy, SignalTerminate is called after
calling Terminate to ensure the thread exits properly.

This approach ensures that the TDirectoryWatcher thread can be terminated
gracefully without causing the application to hang.
}
  if Assigned(FDirectoryWatcher) then
  begin
    try
      FDirectoryWatcher.Terminate;
      {  Problems terminating ... }
      // Signal the termination event...
      FDirectoryWatcher.SignalTerminate;
      FDirectoryWatcher.WaitFor;
    finally
      FDirectoryWatcher.Free;
    end;
  end;

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
  if Assigned(DTData) then
  begin
    DTData.MSG_Handle := Self.Handle;
    // Assert Master - Detail ...
    DTData.ActivateDataDT;
  end;
  if fFlagSelectSession then
    // Prompt user to select session. (... and update UI.)
    PostMessage(Self.Handle, SCM_SELECTSESSION, 0 , 0 )
  else
    // Assert UI display is up-to-date.
    PostMessage(Self.Handle, SCM_UPDATEUI, 0 , 0 );

  // Update lblDTDetails.
  PostMessage(Self.Handle, SCM_UPDATEUI2, 0 , 0 );
  // paint cell icons into grid.
  PostMessage(Self.Handle, SCM_UPDATEUI3, 0 , 0 );
end;

procedure TdtExec.LoadFromSettings;
begin
  fDolphinMeetsFolder := Settings.DolphinMeetsFolder;
  fPrecedence := Settings.DolphinPrecedence;
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

procedure TdtExec.MSG_SelectSession(var Msg: TMessage);
begin
  actnSelectSessionExecute(Self);
end;

procedure TdtExec.MSG_UpdateUI(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(DTData) AND DTData.SCMDataIsActive then
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

procedure TdtExec.MSG_UpdateUI2(var Msg: TMessage);
begin
    UpdateDTDetailsLabel;
end;

procedure TdtExec.MSG_UpdateUI3(var Msg: TMessage);
var
  J: integer;
  ActiveRT: dtActiveRT;
  ADataSet: TDataSet;
begin
  // DTData.tblDTHeat - AfterScroll event.
  // UI images in grid cells need to be re-assigned.
  DTGrid.BeginUpdate;
  // improve code readability ...
  ADataSet := DTGrid.DataSource.DataSet;

  { Typically this routine is call when
    a DTData.OnAfterScroll occurs..
    A DTGrid.Reload isn't required at this execution point. }

  // clear out all images in TimeKeepers columns [3..5]
  // --------------------------------------------------
  {
  for j := DTgrid.FixedRows to DTGrid.RowCount do
  begin
    for I := 3 to 5 do
    begin
      DTGrid.RemoveImageIdx(I, j); // Remove icon.
    end;
    // Remove UseUserRaceTime icon.
    DTGrid.RemoveImageIdx(7, j);
  end;
  }

  // iterate DTData and assign a cell images if needed.
  // --------------------------------------------------
  for j := DTgrid.FixedRows to (DTGrid.RowCount-DTgrid.FixedRows) do
  begin
    // SYNC DTData record to DTGrid row.
    ADataSet.RecNo := j;

    // A C T I V E R T .
    ActiveRT := dtActiveRT(ADataSet.FieldByName('ActiveRT').AsInteger);
    case ActiveRT of
      // A U T O M A T I C .
      artAutomatic:
      begin
        // Switch to the Auto-Calculated RaceTime.
        // RacetimeA was calculated when the DT file was first imported.
        DTData.SetActiveRT(ADataSet, artAutomatic);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      // M A N U A L .
      artManual:
      begin
        DTData.SetActiveRT(ADataSet, artManual);
        DTData.CalcRaceTimeM(ADataSet);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artUser:
      begin
        DTData.SetActiveRT(ADataSet, artUser);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artSplit:
      begin
        DTData.SetActiveRT(ADataSet, artSplit);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

      artNone:
      begin
        DTData.SetActiveRT(ADataSet, artNone);
        UpdateCellIcons(ADataSet, J, ActiveRT);
      end;

    end;

  end;
  ADataSet.First;
  DTGrid.EndUpdate;
  DTGrid.ClearRowSelect;

end;

procedure TdtExec.OnFileChanged(Sender: TObject; const FileName: string);
var
s: string;
begin
  // Handle the new file
  s := UpperCase(ExtractFileExt(FileName));

  if (s = '.DO4') OR (s = '.DO3') then
  begin
    ShowMessage('A new file was added to the directory: ' + FileName);
    dtUtils.ProcessFile(FileName, PBar);
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
      PChar(Format(MSG_CONFIRM_RECONSTRUCT, [fileExtension])),
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
      DTData.LocateSCMEventID(currEv);
      DTData.LocateSCMHeatID(currHt);
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

procedure TdtExec.scmGridGetDisplText(Sender: TObject; ACol, ARow: Integer; var
  Value: string);
begin
  { Quick 'hack' to clear the HTML text in the Entrant cells for lanes that
    don't have a swimmer assigned.}
  // Must be entrant column. Ignore header row.
  if (ACol = 4) and (ARow > 0) then
  begin
    { The hack works like this...
    A lane with no entrant will have a empty member's name surrounded by
    the HTML bold tag.
    NOTE: the 'empty' <#FName> results in a single space being
      inserted between the 'tag'
    }
    if Value.Contains('<B> </B>') then // The 'hack'.
      Value := ' ';
    { The event doesn't have any heats...
      ...but it will have a single empty row 1.
    }
    if scmGrid.DataSource.DataSet.IsEmpty then Value := ' ';
  end;
end;

procedure TdtExec.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False; // Stop the timer
  StatBar.SimpleText := ''; // Clear the message
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

procedure TdtExec.UpdateCellIcons(ADataset: TDataSet; ARow: Integer; AActiveRT:
    dtActiveRT);
var
I: integer;
s: string;
b, b2: boolean;
begin

  // SOURCE FOR GRID CELL IMAGES : DTData.vimglistDTCell.

  DTGrid.BeginUpdate;
  // Clear out - point to cell icon
  DTGrid.RemoveImageIdx(7, ARow);

  case AActiveRT of
    artAutomatic:
    begin
      // Update watch time : cell's icon.
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
        begin
          s := 'T' + IntToStr(I - 2) + 'A';
          b := ADataSet.FieldByName(s).AsBoolean;
          // Empty, zero or bad race-time - display CROSS in BOX.
          if (b = false) then
          begin
              DTGrid.AddImageIdx(I, ARow, 5, TCellHAlign.haFull,
                TCellVAlign.vaFull);
          end;
          { watch-time 1 :
              If the time is valid but the deviation between min and mid_
              is not acceptable then ...
          }
          if (I = 3)  then
          begin
            s := 'TDev1';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if b and b2 then
            begin
                DTGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
          { watch-time 3 :
              If the time is valid but the deviation between mid and max
              is not acceptable then ...
          }
          if (I = 5)  then
          begin
            s := 'TDev2';
            b2 := ADataSet.FieldByName(s).AsBoolean;
            // Unacceptable deviation - display DEV,CROSS in BOX.
            if b and b2 then
            begin
                DTGrid.AddImageIdx(I, ARow, 10, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
        end;
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'AUTO';
    end;
    artManual:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
          continue
        else
          begin
            s := 'T' + IntToStr(I - 2) + 'M';
            b := ADataSet.FieldByName(s).AsBoolean;
            // Empty, zero or illegal watch time - display CROSS in BOX.
            if (not b) then
            begin
                DTGrid.AddImageIdx(I, ARow, 6, TCellHAlign.haFull,
                  TCellVAlign.vaFull);
            end;
          end;
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'MANUAL';
    end;
    artUser:
    begin
      for I := 3 to 5 do
      begin
        dtGrid.RemoveImageIdx(i, ARow);
      { s := 'Time' + IntToStr(I - 2);
        if ADataSet.FieldByName(s).IsNull then
        continue;
        DTGrid.AddImageIdx(I, ARow, 7, TCellHAlign.haFull,
        TCellVAlign.vaFull); }
      end;
        // USER MODE : display - cell pointer
      DTGrid.AddImageIdx(7, ARow, 9, TCellHAlign.haAfterText, TCellVAlign.vaTop);
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'USER RT';
    end;
    artSplit:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        // display small blue bug.
        DTGrid.AddImageIdx(I, ARow, 11, TCellHAlign.haFull,
            TCellVAlign.vaFull);
      end;
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'SPLIT';
    end;
    artNone:
    begin
      for I := 3 to 5 do
      begin
        DTGrid.RemoveImageIdx(I, ARow);
        // display red cross.
        DTGrid.AddImageIdx(I, ARow, 8, TCellHAlign.haFull,
            TCellVAlign.vaFull);
      DTGrid.ColumnByFieldName['imgActiveRT'].Header := 'NONE';
      end;
    end;
  end;

  DTGrid.EndUpdate;

end;

procedure TdtExec.UpdateDTDetailsLabel;
var
i: integer;
s: string;
begin
  lblDTDetails.caption := '';

  if DTData.tblDTSession.IsEmpty then exit;
  s := 'Session : ';
  if fPrecedence = dtPrecFileName then
    i := DTData.tblDTSession.FieldByName('fnSessionNum').AsInteger
  else
    i := DTData.tblDTSession.FieldByName('SessionNum').AsInteger;
  s := s + IntToStr(i);

  if DTData.tblDTEvent.IsEmpty then
  begin
    lblDTDetails.caption := s;
    exit;
  end;
  s := s + '  Event : ';
  if fPrecedence = dtPrecFileName then
    i := DTData.tblDTEvent.FieldByName('fnEventNum').AsInteger
  else
    i := DTData.tblDTEvent.FieldByName('EventNum').AsInteger;
  s := s + IntToStr(i);

  if DTData.tblDTHeat.IsEmpty then
  begin
    lblDTDetails.caption := s;
    exit;
  end;
  s := s + ' - Heat : ';
  if fPrecedence = dtPrecFileName then
    i := DTData.tblDTHeat.FieldByName('fnHeatNum').AsInteger
  else
    i := DTData.tblDTHeat.FieldByName('HeatNum').AsInteger;
  s := s + IntToStr(i);
  lblDTDetails.caption := s;

end;

procedure TdtExec.UpdateEventDetailsLabel;
var
i, ASessionID: integer;
s, s2: string;
begin
  lblEventDetails.Caption := '';
  if DTData.qryEvent.IsEmpty then exit;

  i := DTData.qryEvent.FieldByName('EventNum').AsInteger;
  if (i = 0) then exit;

  ASessionID := DTData.qryEvent.FieldByName('SessionID').AsInteger;
  s := IntToStr(ASessionID);

  s := s + ' : Event ' + IntToStr(i) + ' : ';
  // build the event detail string...  Distance Stroke (OPT: Caption)
  s := s + DTData.qryDistance.FieldByName('Caption').AsString;
  s := s + ' ' + DTData.qryStroke.FieldByName('Caption').AsString;
  // heat number...
  i:=DTData.qryHeat.FieldByName('HeatNum').AsInteger;
  if (i > 0) then
    s := s + ' - Heat : ' + IntToStr(i);
  // event description - entered in core app's grid extension mode.
  s2 := DTData.qryEvent.FieldByName('Caption').AsString;
  if (length(s2) > 0) then
  begin
    if (length(s2) > 128) then
      s2 := s2.Substring(0, 124) + '...';
    s := s + sLineBreak +  s2;
  end;
  // assignment
  if Length(s) > 0 then
  begin
    lblEventDetails.Caption := s;
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
    s := 'Session: ' + IntToStr(DTData.qrysession.FieldByName('SessionID').AsInteger)
      + sLineBreak;
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
