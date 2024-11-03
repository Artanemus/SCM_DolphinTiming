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
  Vcl.ExtDlgs, FireDAC.Stan.Param, Vcl.ComCtrls, Vcl.DBCtrls;

type
  TdtExec = class(TForm)
    actnCreateDTCSV: TAction;
    actnManager: TActionManager;
    actnMenuBar: TActionMainMenuBar;
    actnPickSession: TAction;
    actnSetDTFolder: TAction;
    dtGrid: TDBAdvGrid;
    btnNextDTFile: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnPrevEvent: TButton;
    btnRefresh: TButton;
    Button1: TButton;
    FileSaveDlgCSV: TFileSaveDialog;
    lblDTFileName: TLabel;
    lblEventDetails: TLabel;
    lblHeatNum: TLabel;
    lblMeters: TLabel;
    PickDTFolderDlg: TFileOpenDialog;
    sbtnLoadDO3: TSpeedButton;
    sbtnSync: TSpeedButton;
    scmGrid: TDBAdvGrid;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    vimgHeatNum: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    vimgStrokeBug: TVirtualImage;
    pBar: TProgressBar;
    dbtxtDTFileName: TDBText;
    dbgrid1: TDBGrid;
    dbgrid2: TDBGrid;
    dbgrid3: TDBGrid;
    procedure actnCreateDTCSVExecute(Sender: TObject);
    procedure actnCreateDTCSVUpdate(Sender: TObject);
    procedure actnPickSessionExecute(Sender: TObject);
    procedure actnSetDTFolderExecute(Sender: TObject);
    procedure btnNextDTFileClick(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPrevDTFileClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnLoadDO3Click(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fDolphinFolder: string;
    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure SaveToSettings; // JSON Program Settings
    procedure SetSession(ASessionID: integer);
    procedure UpdateCaption();
    procedure UpdateEventDetailsLabel();
  protected
    procedure MSG_AfterEventScroll(var Msg: TMessage); message SCM_EVENTSCROLL;
    procedure MSG_AfterHeatScroll(var Msg: TMessage); message SCM_HEATSCROLL;
  public
  const
  AcceptedTimeKeeperDeviation = 0.3;
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection; aSessionID: Integer = 0);
    property DolphinFolder: string read FDolphinFolder write FDolphinFolder;
  end;

var
  dtExec: TdtExec;

implementation

{$R *.dfm}

uses dtUtils, UITypes, DateUtils ,dlgSessionPicker;

procedure TdtExec.actnCreateDTCSVExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if FileSaveDlgCSV.Execute then
    fn := FileSaveDlgCSV.FileName
  else
    Exit; // User cancelled.

  // Build CSV Event Data and save to file.
  DTData.BuildCSVEventData(fn);
end;

procedure TdtExec.actnCreateDTCSVUpdate(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TdtExec.actnPickSessionExecute(Sender: TObject);
var
  dlg: TSessionPicker;
  mr: TModalResult;
begin
  dlg := TSessionPicker.Create(Self);
  // the picker will locate to the given session id.
  dlg.SessionID := DTData.qrySession.FieldByName('SessionID').AsInteger;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) and (dlg.SessionID > 0) then
    SetSession(dlg.SessionID);
  dlg.Free;
  UpdateCaption;
end;

procedure TdtExec.actnSetDTFolderExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if PickDTFolderDlg.Execute then
    fn := PickDTFolderDlg.FileName
  else
    Exit; // User cancelled.
  // Make the path persistent in JSON.
  fDolphinFolder := fn;
  // SavePreferencesToJSON.
end;

procedure TdtExec.btnNextDTFileClick(Sender: TObject);
begin
    if not DTData.dsDT.DataSet.EOF then
    begin
      DTData.dsDT.DataSet.next;
      lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
    end;
end;

procedure TdtExec.btnNextEventClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
  end
  else
  begin
    if DTData.dsHeat.DataSet.EOF then
    begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
    end
    else
      DTData.dsHeat.DataSet.next;
  end;
end;

procedure TdtExec.btnPrevDTFileClick(Sender: TObject);
begin
  if not DTData.dsdt.DataSet.BOF then
  begin
      DTData.dsdt.DataSet.prior;
      lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
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
  if DTData.dsHeat.DataSet.BOF then
  begin
      DTData.dsEvent.DataSet.prior;
      DTData.dsHeat.DataSet.Last;
    end
    else
      DTData.dsHeat.DataSet.prior;
  end;
end;

procedure TdtExec.FormCreate(Sender: TObject);
begin
  { test for and connect to DTData}
  // C R E A T E   T H E   D A T A M O D U L E .
  if NOT Assigned(DTData) then
    DTData := TDTData.Create(Self);

  // A Class that uses JSON to read and write application configuration .
  // Created on bootup by dtfrmBoot.
  {if Settings = nil then
    Settings := TPrgSetting.Create; }
  LoadSettings;
end;

procedure TdtExec.FormDestroy(Sender: TObject);
begin
  SaveToSettings;
  // destroyed by dtfrmBoot.
  {FreeAndNil(Settings);}
end;

procedure TdtExec.LoadFromSettings;
begin
  fDolphinFolder := Settings.DolphinFolder;
end;

procedure TdtExec.LoadSettings;
begin
  // created by dtfrmBoot.
  {if Settings = nil then
    Settings := TPrgSetting.Create; }

  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TdtExec.MSG_AfterEventScroll(var Msg: TMessage);
var
  i: Integer;
begin
  // update EVENT UI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    UpdateEventDetailsLabel;
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
        vimgRelayBug.ImageName := 'RELAY_DOT'; // RELAY.
    else
      vimgRelayBug.ImageIndex := -1; // INDV or Swim-O-Thon.
    end;
    lblMeters.Caption := UpperCase(DTData.qryDistance.FieldByName('Caption').AsString);
  end;
end;

procedure TdtExec.MSG_AfterHeatScroll(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    UpdateEventDetailsLabel; // append heat number to label
    i := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    if i = 0 then
      lblHeatNum.Caption := ''
    else
      lblHeatNum.Caption := IntToStr(i);
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

procedure TdtExec.Prepare(AConnection: TFDConnection; aSessionID: Integer);
begin
  FConnection := AConnection;
  if Assigned(DTData) then
  begin
    DTData.Connection := FConnection;
    DTData.SessionID := aSessionID;
    DTData.ActivateData;
  end;
  UpdateCaption;
end;

procedure TdtExec.SaveToSettings;
begin
  Settings.DolphinFolder := fDolphinFolder;
  Settings.SaveToFile();
end;

procedure TdtExec.sbtnLoadDO3Click(Sender: TObject);
var
s: string;
begin
  if DirectoryExists(fDolphinFolder) then
  begin
    pBar.Visible := true;
    ProcessDTFiles(fDolphinFolder, pBar);
    pBar.Visible := false;
    DTData.dsDT.DataSet.First;
    lblDTFileName.Caption := DTData.dsDT.DataSet.FieldByName('FileName').AsString;
  end
  else
  begin
    s := '''
      The Dolphin Timing folder couldn''t be found.
      Use the File menu to setup the folder''s location.
    ''';
    MessageBox(0, PChar(s), PChar('Missing DT Folder '), MB_ICONERROR or MB_OK);
  end;
end;

procedure TdtExec.SetSession(ASessionID: integer);
begin
    DTData.qrySession.DisableControls;
    DTData.qrySession.Close;
    DTData.qrysession.ParamByName('SESSIONID').AsInteger := ASessionID;
    DTData.qrysession.Prepare;
    DTData.qrysession.Open;
    DTData.qrySession.EnableControls;
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
          lblEventDetails.Caption := s;
      end;
end;

end.
